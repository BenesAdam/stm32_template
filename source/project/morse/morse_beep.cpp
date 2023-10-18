#include "morse_beep.hpp"
#include "project_delay.hpp"

extern "C"
{
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>
}

void morse_short(void)
{
  gpio_clear(GPIOC, GPIO13); // Rozsvítíme LED (nastavením pinu na LOW, protože je zapojena aktivně)
  project_delay(1000000);            // Krátká prodleva
  gpio_set(GPIOC, GPIO13);   // Zhasneme LED (nastavením pinu na HIGH)
  project_delay(1000000);            // Krátká prodleva
}

void morse_long(void)
{
  gpio_clear(GPIOC, GPIO13);
  project_delay(3000000); // Dlouhá prodleva
  gpio_set(GPIOC, GPIO13);
  project_delay(1000000); // Krátká prodleva
}
