#include "Vbutton_test.h"

#include <thread>
#include <chrono>
#include <iostream>
#include <bitset>
#include <thread>

#include <nvboard.h>

static void tick(Vbutton_test& top) {
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
    nvboard_update();
}

static void reset(Vbutton_test& top) {
    top.rst = 1; top.eval();
    tick(top);
    top.rst = 0; top.eval();
}



int main() {
  Vbutton_test top{};

  void nvboard_bind_all_pins(Vbutton_test*);
  nvboard_bind_all_pins(&top);
  nvboard_init();

  reset(top);

  while(true){
    tick(top);
  }
}
