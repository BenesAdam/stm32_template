#include "project_delay.hpp"

void project_delay(uint32_t arg_iterations)
{
  volatile uint32_t i = 0U;
  while(i < arg_iterations)
  {
    i++;
  }
}
