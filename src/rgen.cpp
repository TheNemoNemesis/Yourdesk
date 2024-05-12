#include <random>

std::random_device rd;
std::mt19937 gen(rd());
std::uniform_int_distribution<uint32_t> dist;

extern "C" long long generatenumber(void) {
    return dist(gen);
}
