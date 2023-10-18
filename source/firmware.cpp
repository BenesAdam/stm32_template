extern "C"
{
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>
}

#include "project_delay.hpp"
#include "morse_beep.hpp"

int main(void)
{
  rcc_clock_setup_pll(&rcc_hse_configs[RCC_CLOCK_HSE8_72MHZ]);

  // Inicializace portu C a pinu 13
  rcc_periph_clock_enable(RCC_GPIOC);
  gpio_set_mode(GPIOC, GPIO_MODE_OUTPUT_2_MHZ, GPIO_CNF_OUTPUT_PUSHPULL, GPIO13);

  while (1)
  {
    // S
    morse_short();
    morse_short();
    morse_short();

    // O
    morse_long();
    morse_long();
    morse_long();

    // S
    morse_short();
    morse_short();
    morse_short();

    // Mezi písmeny
    project_delay(3000000);
  }

  return 0;
}