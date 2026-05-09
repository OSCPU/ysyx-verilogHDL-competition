#include "Vseg_test.h"

#include <thread>
#include <chrono>
#include <iostream>
#include <bitset>
#include <thread>

#ifdef HAS_NVBOARD
#include <nvboard.h>
#endif

constexpr auto DELAY {std::chrono::milliseconds(500)};
constexpr std::string_view SEGS {"PGFEDCBA"};


static void print_leds(uint8_t led) {
    std::bitset<8> bits {led};
    for (size_t i = 0; i < SEGS.size(); ++i) {
        std::cout << SEGS[i] << " = " << (bits[i]) << "; ";
    }
    std::cout << std::endl;
}

static void tick(Vseg_test& top) {
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();

#ifdef HAS_NVBOARD
    nvboard_update();
#endif
}

static void reset(Vseg_test& top) {
    top.rst = 1; top.eval();
    tick(top);
    top.rst = 0; top.eval();
}

static void incr_every(std::chrono::milliseconds interval, Vseg_test& top) {
  static std::chrono::steady_clock::time_point last_time {};
  auto now {std::chrono::steady_clock::now()};
  if (now - last_time >= interval) {
      top.incr = 1; top.eval();
      tick(top);
      top.incr = 0; top.eval();
      last_time = now;
  }
}



int main() {
  Vseg_test top{};

#ifdef HAS_NVBOARD
  void nvboard_bind_all_pins(Vseg_test* top);
  nvboard_bind_all_pins(&top);
  nvboard_init();
#endif

  reset(top);

  while(true){
    incr_every(DELAY, top);
    tick(top);
  }
}
