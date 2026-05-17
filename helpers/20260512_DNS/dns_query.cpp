/*
 * dns_query.cpp — DNS queries in modern C++ using POSIX sockets.
 *
 * Compile:
 *   g++ -std=c++17 -Wall -o dns_query dns_query.cpp
 *
 * Usage:
 *   ./dns_query                    # runs all demos
 *   ./dns_query github.com         # lookup specific domain
 */

#include <iostream>
#include <iomanip>
#include <string>
#include <string_view>
#include <vector>
#include <chrono>
#include <stdexcept>
#include <cstring>
#include <cstdint>

#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <unistd.h>

using namespace std::string_literals;

// ─────────────────────────────────────────────────────────────
// Utility: print section header
// ─────────────────────────────────────────────────────────────

void section(std::string_view title) {
    std::cout << "\n\033[1;36m══ " << title << " ══\033[0m\n";
}

// ─────────────────────────────────────────────────────────────
// PART 1: Forward DNS using getaddrinfo()
// ─────────────────────────────────────────────────────────────

struct DnsResult {
    std::string ip;
    std::string family;  // "IPv4" or "IPv6"
};

std::vector<DnsResult> resolve(const std::string &hostname,
                                int ai_family = AF_UNSPEC) {
    addrinfo hints{}, *res = nullptr;
    hints.ai_family   = ai_family;
    hints.ai_socktype = SOCK_STREAM;

    int status = getaddrinfo(hostname.c_str(), nullptr, &hints, &res);
    if (status != 0) {
        throw std::runtime_error(gai_strerror(status));
    }

    std::vector<DnsResult> results;
    char buf[INET6_ADDRSTRLEN];

    for (addrinfo *p = res; p; p = p->ai_next) {
        DnsResult dr;
        if (p->ai_family == AF_INET) {
            auto *s = reinterpret_cast<sockaddr_in *>(p->ai_addr);
            inet_ntop(AF_INET, &s->sin_addr, buf, sizeof(buf));
            dr.family = "IPv4";
        } else {
            auto *s = reinterpret_cast<sockaddr_in6 *>(p->ai_addr);
            inet_ntop(AF_INET6, &s->sin6_addr, buf, sizeof(buf));
            dr.family = "IPv6";
        }
        dr.ip = buf;
        results.push_back(std::move(dr));
    }
    freeaddrinfo(res);
    return results;
}

void demo_forward_dns() {
    section("PART 1: Forward DNS — getaddrinfo()");

    std::vector<std::string> domains = {
        "github.com", "google.com", "stackoverflow.com",
        "cloudflare.com", "python.org"
    };

    for (const auto &domain : domains) {
        std::cout << "\n  \033[33m" << domain << "\033[0m\n";
        try {
            auto results = resolve(domain);
            for (const auto &r : results) {
                std::cout << "    [" << r.family << "] " << r.ip << "\n";
            }
        } catch (const std::exception &e) {
            std::cout << "    ERROR: " << e.what() << "\n";
        }
    }
}

// ─────────────────────────────────────────────────────────────
// PART 2: Reverse DNS — getnameinfo()
// ─────────────────────────────────────────────────────────────

std::string reverse_dns(const std::string &ip_str) {
    sockaddr_in sa{};
    sa.sin_family = AF_INET;
    if (inet_pton(AF_INET, ip_str.c_str(), &sa.sin_addr) != 1) {
        return "(invalid IP)";
    }

    char hostname[NI_MAXHOST];
    int status = getnameinfo(reinterpret_cast<sockaddr *>(&sa), sizeof(sa),
                             hostname, sizeof(hostname),
                             nullptr, 0, NI_NAMEREQD);
    if (status == 0) return hostname;
    return "(no PTR: "s + gai_strerror(status) + ")";
}

void demo_reverse_dns() {
    section("PART 2: Reverse DNS — getnameinfo()");

    std::vector<std::pair<std::string, std::string>> ips = {
        {"8.8.8.8",       "Google DNS"},
        {"8.8.4.4",       "Google DNS 2"},
        {"1.1.1.1",       "Cloudflare DNS"},
        {"140.82.114.4",  "GitHub"},
        {"9.9.9.9",       "Quad9"},
    };

    for (const auto &[ip, label] : ips) {
        std::string host = reverse_dns(ip);
        std::cout << "  " << std::left << std::setw(18) << ip
                  << " (" << std::setw(14) << label << ") → "
                  << host << "\n";
    }
}

// ─────────────────────────────────────────────────────────────
// PART 3: Measure DNS latency with std::chrono
// ─────────────────────────────────────────────────────────────

void demo_latency() {
    section("PART 3: DNS Lookup Latency");

    std::vector<std::string> domains = {
        "github.com", "google.com", "amazon.com",
        "netflix.com", "wikipedia.org"
    };

    std::cout << "\n  " << std::left
              << std::setw(28) << "Domain"
              << std::setw(20) << "IP"
              << "Latency\n";
    std::cout << "  " << std::string(60, '-') << "\n";

    for (const auto &domain : domains) {
        auto t0 = std::chrono::high_resolution_clock::now();
        std::string ip = "(error)";
        try {
            auto results = resolve(domain, AF_INET);
            if (!results.empty()) ip = results[0].ip;
        } catch (...) {}
        auto t1 = std::chrono::high_resolution_clock::now();

        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        std::cout << "  " << std::left
                  << std::setw(28) << domain
                  << std::setw(20) << ip
                  << std::fixed << std::setprecision(2) << ms << " ms\n";
    }
}

// ─────────────────────────────────────────────────────────────
// PART 4: Raw DNS UDP query (A record)
// ─────────────────────────────────────────────────────────────

// DNS wire-format header
#pragma pack(push, 1)
struct DnsHeader {
    uint16_t id;
    uint16_t flags;
    uint16_t qdcount;
    uint16_t ancount;
    uint16_t nscount;
    uint16_t arcount;
};
#pragma pack(pop)

// Encode a domain name into DNS wire format (length-prefixed labels + null)
std::vector<uint8_t> encode_domain(const std::string &domain) {
    std::vector<uint8_t> out;
    size_t start = 0;
    while (start < domain.size()) {
        size_t dot = domain.find('.', start);
        if (dot == std::string::npos) dot = domain.size();
        size_t len = dot - start;
        if (len > 63) throw std::runtime_error("label too long");
        out.push_back(static_cast<uint8_t>(len));
        for (size_t i = start; i < dot; i++) out.push_back(domain[i]);
        start = dot + 1;
    }
    out.push_back(0);  // root label
    return out;
}

std::vector<uint8_t> build_query(const std::string &domain, uint16_t qtype = 1) {
    std::vector<uint8_t> pkt(sizeof(DnsHeader));
    DnsHeader *hdr = reinterpret_cast<DnsHeader *>(pkt.data());
    hdr->id      = htons(0xBEEF);
    hdr->flags   = htons(0x0100);  // RD=1
    hdr->qdcount = htons(1);
    hdr->ancount = 0;
    hdr->nscount = 0;
    hdr->arcount = 0;

    auto name = encode_domain(domain);
    pkt.insert(pkt.end(), name.begin(), name.end());

    // QTYPE
    pkt.push_back(0); pkt.push_back(static_cast<uint8_t>(qtype));
    // QCLASS = IN (1)
    pkt.push_back(0); pkt.push_back(1);

    return pkt;
}

void demo_raw_dns_query(const std::string &domain) {
    section("PART 4: Raw UDP DNS Packet");

    std::cout << "  Querying A record for '" << domain << "' via 8.8.8.8:53\n";

    auto query = build_query(domain, 1 /*A*/);
    std::cout << "  Query size: " << query.size() << " bytes\n";

    int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock < 0) { perror("  socket"); return; }

    timeval tv{3, 0};  // 3-second timeout
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    sockaddr_in server{};
    server.sin_family      = AF_INET;
    server.sin_port        = htons(53);
    server.sin_addr.s_addr = inet_addr("8.8.8.8");

    ssize_t sent = sendto(sock, query.data(), query.size(), 0,
                          reinterpret_cast<sockaddr *>(&server), sizeof(server));
    if (sent < 0) { perror("  sendto"); close(sock); return; }

    uint8_t resp[512];
    ssize_t rlen = recvfrom(sock, resp, sizeof(resp), 0, nullptr, nullptr);
    close(sock);

    if (rlen < 0) { perror("  recvfrom (timeout?)"); return; }

    std::cout << "  Response: " << rlen << " bytes\n";

    auto *rhdr    = reinterpret_cast<DnsHeader *>(resp);
    uint16_t rcode   = ntohs(rhdr->flags) & 0x000F;
    uint16_t ancount = ntohs(rhdr->ancount);

    std::cout << "  RCODE  : " << rcode
              << " (" << (rcode == 0 ? "NOERROR" : "ERROR") << ")\n";
    std::cout << "  Answers: " << ancount << "\n";

    if (rcode != 0 || ancount == 0) return;

    // Skip question section
    uint8_t *p   = resp + sizeof(DnsHeader);
    uint8_t *end = resp + rlen;

    while (p < end && *p) {
        if ((*p & 0xC0) == 0xC0) { p += 2; goto after_name; }
        p += *p + 1;
    }
    p++;
after_name:
    p += 4;  // QTYPE + QCLASS

    for (uint16_t i = 0; i < ancount && p + 12 <= end; i++) {
        // Skip name
        if ((*p & 0xC0) == 0xC0) p += 2;
        else { while (p < end && *p) p += *p + 1; if (p < end) p++; }

        if (p + 10 > end) break;
        uint16_t rtype    = ntohs(*reinterpret_cast<uint16_t *>(p));
        uint32_t ttl      = ntohl(*reinterpret_cast<uint32_t *>(p + 4));
        uint16_t rdlength = ntohs(*reinterpret_cast<uint16_t *>(p + 8));
        p += 10;

        if (rtype == 1 && rdlength == 4 && p + 4 <= end) {
            char ip[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, p, ip, sizeof(ip));
            std::cout << "  A record : " << ip << "  (TTL=" << ttl << "s)\n";
        } else if (rtype == 28 && rdlength == 16 && p + 16 <= end) {
            char ip[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, p, ip, sizeof(ip));
            std::cout << "  AAAA     : " << ip << "  (TTL=" << ttl << "s)\n";
        }
        p += rdlength;
    }
}

// ─────────────────────────────────────────────────────────────
// PART 5: TCP connection attempt (port 80/443) after DNS resolve
// Demonstrates: resolve → connect (the full flow a browser does)
// ─────────────────────────────────────────────────────────────

void demo_resolve_and_connect(const std::string &hostname, uint16_t port) {
    section("PART 5: Resolve + TCP Connect (browser simulation)");

    std::cout << "  Connecting to " << hostname << ":" << port << "\n";

    addrinfo hints{}, *res = nullptr;
    hints.ai_family   = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    std::string port_str = std::to_string(port);
    int status = getaddrinfo(hostname.c_str(), port_str.c_str(), &hints, &res);
    if (status != 0) {
        std::cerr << "  getaddrinfo error: " << gai_strerror(status) << "\n";
        return;
    }

    auto t_dns_start = std::chrono::high_resolution_clock::now();
    // (DNS already done above, but measure from resolve call)
    char ip_str[INET_ADDRSTRLEN];
    inet_ntop(AF_INET,
              &reinterpret_cast<sockaddr_in *>(res->ai_addr)->sin_addr,
              ip_str, sizeof(ip_str));
    auto t_dns_end = std::chrono::high_resolution_clock::now();

    std::cout << "  Resolved to: " << ip_str << "\n";

    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) { perror("  socket"); freeaddrinfo(res); return; }

    timeval tv{5, 0};
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    auto t_conn_start = std::chrono::high_resolution_clock::now();
    int connected = connect(sock, res->ai_addr, res->ai_addrlen);
    auto t_conn_end = std::chrono::high_resolution_clock::now();

    double conn_ms = std::chrono::duration<double, std::milli>(t_conn_end - t_conn_start).count();

    if (connected == 0) {
        std::cout << "  TCP connect: SUCCESS (" << std::fixed
                  << std::setprecision(2) << conn_ms << " ms)\n";
    } else {
        std::cout << "  TCP connect: FAILED (port may be filtered)\n";
    }

    close(sock);
    freeaddrinfo(res);
}

// ─────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────

int main(int argc, char *argv[]) {
    std::cout << "╔══════════════════════════════════════════╗\n"
              << "║       DNS Query Demo in C++17            ║\n"
              << "╚══════════════════════════════════════════╝\n";

    std::string target = (argc == 2) ? argv[1] : "";

    if (!target.empty()) {
        // Single-domain mode
        section("Forward DNS");
        try {
            for (const auto &r : resolve(target))
                std::cout << "  [" << r.family << "] " << r.ip << "\n";
        } catch (const std::exception &e) {
            std::cerr << "  ERROR: " << e.what() << "\n";
        }
        demo_raw_dns_query(target);
        return 0;
    }

    demo_forward_dns();
    demo_reverse_dns();
    demo_latency();
    demo_raw_dns_query("github.com");
    demo_resolve_and_connect("github.com", 443);

    std::cout << "\n\033[1;32mDone!\033[0m\n";
    return 0;
}
