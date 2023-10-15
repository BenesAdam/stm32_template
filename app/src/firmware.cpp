extern "C"
{
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>
}

void project_delay(uint32_t arg_iterations)
{
  volatile uint32_t i = 0U;
  while(i < arg_iterations)
  {
    i++;
  }
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