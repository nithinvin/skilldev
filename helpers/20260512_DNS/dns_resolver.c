/*
 * dns_resolver.c — DNS resolution using POSIX getaddrinfo() and raw UDP sockets.
 *
 * Compile:
 *   gcc -Wall -o dns_resolver dns_resolver.c
 *
 * Usage:
 *   ./dns_resolver                        # runs all demos
 *   ./dns_resolver github.com             # lookup a specific domain
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>

/* ─────────────────────────────────────────────────────────
 * PART 1: getaddrinfo() — The modern, portable way
 * ───────────────────────────────────────────────────────── */

void demo_getaddrinfo(const char *hostname) {
    struct addrinfo hints, *res, *p;
    char ip_str[INET6_ADDRSTRLEN];

    printf("\n[getaddrinfo] Resolving: %s\n", hostname);
    printf("%-6s  %-40s  %s\n", "Family", "IP Address", "Socket Type");
    printf("%-6s  %-40s  %s\n", "------", "----------", "-----------");

    memset(&hints, 0, sizeof(hints));
    hints.ai_family   = AF_UNSPEC;   /* Accept IPv4 and IPv6 */
    hints.ai_socktype = SOCK_STREAM; /* TCP */

    int status = getaddrinfo(hostname, NULL, &hints, &res);
    if (status != 0) {
        fprintf(stderr, "  getaddrinfo error: %s\n", gai_strerror(status));
        return;
    }

    for (p = res; p != NULL; p = p->ai_next) {
        void *addr;
        const char *family;

        if (p->ai_family == AF_INET) {
            /* IPv4 */
            struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
            addr   = &(ipv4->sin_addr);
            family = "IPv4 ";
        } else {
            /* IPv6 */
            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
            addr   = &(ipv6->sin6_addr);
            family = "IPv6 ";
        }

        inet_ntop(p->ai_family, addr, ip_str, sizeof(ip_str));
        printf("%-6s  %-40s  %s\n",
               family, ip_str,
               (p->ai_socktype == SOCK_STREAM) ? "TCP" : "UDP");
    }

    freeaddrinfo(res);
}

/* ─────────────────────────────────────────────────────────
 * PART 2: getnameinfo() — Reverse DNS (IP → hostname)
 * ───────────────────────────────────────────────────────── */

void demo_reverse_dns(const char *ip_str) {
    struct sockaddr_in sa;
    char hostname[NI_MAXHOST];

    printf("\n[Reverse DNS] %s → ?\n", ip_str);

    memset(&sa, 0, sizeof(sa));
    sa.sin_family = AF_INET;

    if (inet_pton(AF_INET, ip_str, &sa.sin_addr) != 1) {
        fprintf(stderr, "  Invalid IP address: %s\n", ip_str);
        return;
    }

    int status = getnameinfo((struct sockaddr *)&sa, sizeof(sa),
                             hostname, sizeof(hostname),
                             NULL, 0,
                             NI_NAMEREQD);
    if (status == 0) {
        printf("  %s → %s\n", ip_str, hostname);
    } else {
        printf("  %s → (no PTR record: %s)\n", ip_str, gai_strerror(status));
    }
}

/* ─────────────────────────────────────────────────────────
 * PART 3: Measure DNS resolution latency
 * ───────────────────────────────────────────────────────── */

void measure_latency(const char *hostname) {
    struct addrinfo hints, *res;
    struct timespec t_start, t_end;
    char ip_str[INET6_ADDRSTRLEN];

    memset(&hints, 0, sizeof(hints));
    hints.ai_family   = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    clock_gettime(CLOCK_MONOTONIC, &t_start);
    int status = getaddrinfo(hostname, NULL, &hints, &res);
    clock_gettime(CLOCK_MONOTONIC, &t_end);

    double ms = (t_end.tv_sec  - t_start.tv_sec)  * 1000.0 +
                (t_end.tv_nsec - t_start.tv_nsec) / 1e6;

    if (status == 0) {
        struct sockaddr_in *ipv4 = (struct sockaddr_in *)res->ai_addr;
        inet_ntop(AF_INET, &ipv4->sin_addr, ip_str, sizeof(ip_str));
        printf("  %-30s → %-18s  %.2f ms\n", hostname, ip_str, ms);
        freeaddrinfo(res);
    } else {
        printf("  %-30s → %-18s  %.2f ms\n", hostname, "ERROR", ms);
    }
}

/* ─────────────────────────────────────────────────────────
 * PART 4: Raw DNS query over UDP (A record)
 *
 * We manually construct a DNS query packet and send it to
 * 8.8.8.8:53, then parse the response.
 * ───────────────────────────────────────────────────────── */

/* DNS header (12 bytes) */
typedef struct {
    uint16_t id;        /* Transaction ID */
    uint16_t flags;     /* Flags */
    uint16_t qdcount;   /* Question count */
    uint16_t ancount;   /* Answer count */
    uint16_t nscount;   /* Authority count */
    uint16_t arcount;   /* Additional count */
} dns_header_t;

/* Build a DNS A-record query for the given domain.
 * Returns the length of the query written into buf. */
int build_dns_query(const char *domain, uint8_t *buf, size_t buflen) {
    if (buflen < 512) return -1;

    dns_header_t *hdr = (dns_header_t *)buf;
    hdr->id      = htons(0x1234);
    hdr->flags   = htons(0x0100);  /* RD=1 (recursion desired) */
    hdr->qdcount = htons(1);
    hdr->ancount = 0;
    hdr->nscount = 0;
    hdr->arcount = 0;

    uint8_t *ptr = buf + sizeof(dns_header_t);

    /* Encode domain name: split on '.' and write length-prefixed labels */
    const char *src = domain;
    while (*src) {
        const char *dot = strchr(src, '.');
        size_t label_len = dot ? (size_t)(dot - src) : strlen(src);
        if (label_len > 63) return -1;
        *ptr++ = (uint8_t)label_len;
        memcpy(ptr, src, label_len);
        ptr += label_len;
        src  = dot ? dot + 1 : src + label_len;
        if (!dot) break;
    }
    *ptr++ = 0;  /* Root label */

    /* QTYPE = A (1), QCLASS = IN (1) */
    *ptr++ = 0; *ptr++ = 1;
    *ptr++ = 0; *ptr++ = 1;

    return (int)(ptr - buf);
}

void demo_raw_udp_dns(const char *domain) {
    uint8_t buf[512];
    int qlen = build_dns_query(domain, buf, sizeof(buf));
    if (qlen < 0) { fprintf(stderr, "  build_dns_query failed\n"); return; }

    printf("\n[Raw UDP DNS] A record for '%s' via 8.8.8.8:53\n", domain);
    printf("  Query size: %d bytes\n", qlen);

    int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock < 0) { perror("  socket"); return; }

    /* Set 3-second timeout */
    struct timeval tv = { .tv_sec = 3, .tv_usec = 0 };
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    struct sockaddr_in server = {0};
    server.sin_family      = AF_INET;
    server.sin_port        = htons(53);
    server.sin_addr.s_addr = inet_addr("8.8.8.8");

    ssize_t sent = sendto(sock, buf, qlen, 0,
                          (struct sockaddr *)&server, sizeof(server));
    if (sent < 0) { perror("  sendto"); close(sock); return; }

    uint8_t resp[512];
    ssize_t rlen = recvfrom(sock, resp, sizeof(resp), 0, NULL, NULL);
    close(sock);

    if (rlen < 0) { perror("  recvfrom (timeout?)"); return; }

    printf("  Response: %zd bytes received\n", rlen);

    dns_header_t *rhdr = (dns_header_t *)resp;
    uint16_t rflags  = ntohs(rhdr->flags);
    uint16_t ancount = ntohs(rhdr->ancount);
    uint16_t rcode   = rflags & 0x000F;

    printf("  RCODE    : %u (%s)\n", rcode, rcode == 0 ? "NOERROR" : "ERROR");
    printf("  Answers  : %u\n", ancount);

    if (rcode != 0 || ancount == 0) { return; }

    /* Skip the question section to find answers */
    uint8_t *p = resp + sizeof(dns_header_t);
    uint8_t *end = resp + rlen;

    /* Skip question name */
    while (p < end && *p != 0) {
        if ((*p & 0xC0) == 0xC0) { p += 2; goto skip_qtype; }
        p += *p + 1;
    }
    p++;  /* null byte */
skip_qtype:
    p += 4;  /* QTYPE + QCLASS */

    /* Parse answers */
    for (uint16_t i = 0; i < ancount && p + 12 <= end; i++) {
        /* Skip name (may be a pointer) */
        if ((*p & 0xC0) == 0xC0) p += 2;
        else { while (p < end && *p) p += *p + 1; p++; }

        if (p + 10 > end) break;
        uint16_t rtype    = ntohs(*(uint16_t *)(p + 0));
        uint32_t ttl      = ntohl(*(uint32_t *)(p + 4));
        uint16_t rdlength = ntohs(*(uint16_t *)(p + 8));
        p += 10;

        if (rtype == 1 && rdlength == 4 && p + 4 <= end) {
            /* A record */
            char ip_str[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, p, ip_str, sizeof(ip_str));
            printf("  A record : %s  (TTL=%us)\n", ip_str, ttl);
        } else if (rtype == 28 && rdlength == 16 && p + 16 <= end) {
            /* AAAA record */
            char ip_str[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, p, ip_str, sizeof(ip_str));
            printf("  AAAA     : %s  (TTL=%us)\n", ip_str, ttl);
        }
        p += rdlength;
    }
}

/* ─────────────────────────────────────────────────────────
 * PART 5: Check /etc/resolv.conf
 * ───────────────────────────────────────────────────────── */

void show_resolv_conf(void) {
    printf("\n[/etc/resolv.conf]\n");
    FILE *f = fopen("/etc/resolv.conf", "r");
    if (!f) { perror("  fopen"); return; }
    char line[256];
    while (fgets(line, sizeof(line), f)) {
        if (line[0] != '#' && line[0] != '\n') {
            printf("  %s", line);
        }
    }
    fclose(f);
}

/* ─────────────────────────────────────────────────────────
 * Main
 * ───────────────────────────────────────────────────────── */

int main(int argc, char *argv[]) {
    printf("╔══════════════════════════════════════════╗\n");
    printf("║        DNS Resolver Demo in C            ║\n");
    printf("╚══════════════════════════════════════════╝\n");

    /* If a domain is passed as argument, just look that up */
    if (argc == 2) {
        demo_getaddrinfo(argv[1]);
        demo_raw_udp_dns(argv[1]);
        return 0;
    }

    /* Part 1: Forward resolution */
    printf("\n═══ PART 1: getaddrinfo() — Forward DNS ═══");
    const char *domains[] = {"github.com", "google.com", "cloudflare.com", NULL};
    for (int i = 0; domains[i]; i++) {
        demo_getaddrinfo(domains[i]);
    }

    /* Part 2: Reverse DNS */
    printf("\n═══ PART 2: getnameinfo() — Reverse DNS ═══");
    const char *ips[] = {"8.8.8.8", "1.1.1.1", "140.82.114.4", NULL};
    for (int i = 0; ips[i]; i++) {
        demo_reverse_dns(ips[i]);
    }

    /* Part 3: Latency measurement */
    printf("\n═══ PART 3: DNS Latency ═══\n");
    const char *latency_domains[] = {
        "github.com", "google.com", "stackoverflow.com", "python.org", NULL
    };
    for (int i = 0; latency_domains[i]; i++) {
        measure_latency(latency_domains[i]);
    }

    /* Part 4: Raw UDP DNS */
    printf("\n═══ PART 4: Raw UDP DNS Packet ═══");
    demo_raw_udp_dns("github.com");

    /* Part 5: Show DNS config */
    printf("\n═══ PART 5: System DNS Config ═══");
    show_resolv_conf();

    printf("\nDone.\n");
    return 0;
}
