/*
 * File: main.c
 *
 * Written by duvallee.lee in 2018
 *
 */
#include "main.h"
#if defined(USE_USB)
#include "usb_device.h"
#endif

#if defined(STM32F401CC)
#include "led.h"
#include "battery_gauge.h"
#include "motor.h"

#if defined(TIM2_MOTOR)
#include "motor_ext_esc.h"
#endif

#if defined(TIM2_REMOTE_CONTROL)
#include "remote_controller.h"
#endif

#include "blue_nrg_spi1.h"
#include "sensor_spi2.h"

#endif

#if defined(STM32H743XI)
// ==========================================================================
static volatile int delay_count                          = 0;

/* --------------------------------------------------------------------------
 * Name : ns_10_delay()
 *
 *
 * -------------------------------------------------------------------------- */
void ns_10_delay(int n_10_sec)
{
   int i;
   int j;
   for (i = 0; i < n_10_sec; i++)
   {
      for(j = 0; j < 3; j++)
      {
         delay_count                                     = j;
      }
   }
}

/* --------------------------------------------------------------------------
 * Name : us_delay()
 *
 *
 * -------------------------------------------------------------------------- */
void us_delay(int usec)
{
   int i;
   int j;
   for (i = 0; i < usec; i++)
   {
      for(j = 0; j < 196; j++)
      {
         delay_count                                     = j;
      }
   }
}

/* --------------------------------------------------------------------------
 * Name : ms_delay()
 *
 *
 * -------------------------------------------------------------------------- */
void ms_delay(int msec)
{
   int i;
   int j;
   for (i = 0; i < msec; i++)
   {
      for(j = 0; j < 200000; j++)
      {
         delay_count                                     = j;
      }
   }
}

/* --------------------------------------------------------------------------
 * Name : CPU_CACHE_Enable()
 *
 *  @ brief  CPU L1-Cache enable.
 *  @ param  None
 *  @ retval None
 *
 * -------------------------------------------------------------------------- */
static void CPU_CACHE_Enable(void)
{
   // Enable I-Cache
   SCB_EnableICache();

   // Enable D-Cache
   SCB_EnableDCache();
}

/* --------------------------------------------------------------------------
 * Name : debug_break()
 *
 *
 * -------------------------------------------------------------------------- */
int __attribute__ ((noinline)) debug_break(int data)
{
static volatile int debug_break_count                    = 0;
   UNUSED(debug_break_count);

   debug_break_count                                     = data;
   return 0;
}
#endif

#if defined(USER_POWER_KEY)
/* --------------------------------------------------------------------------
 * Name : power_on()
 *
 *
 * -------------------------------------------------------------------------- */
void power_on(void)
{
   GPIO_InitTypeDef GPIO_InitStruct;

   __HAL_RCC_GPIOJ_CLK_ENABLE();

   GPIO_InitStruct.Pin                                   = GPIO_PIN_5;
   GPIO_InitStruct.Mode                                  = GPIO_MODE_OUTPUT_PP;
   GPIO_InitStruct.Pull                                  = GPIO_NOPULL;
   GPIO_InitStruct.Speed                                 = GPIO_SPEED_FREQ_LOW;
   HAL_GPIO_Init(GPIOJ, &GPIO_InitStruct);
   HAL_GPIO_WritePin(GPIOJ, GPIO_PIN_5, GPIO_PIN_SET);
}
#endif

/* --------------------------------------------------------------------------
 * Name : main()
 *
 *
 * -------------------------------------------------------------------------- */
int main(void)
{
   // Configure the MPU attributes as Write Through
#if defined(STM32H743XI)
   CPU_CACHE_Enable();
#endif
   // Reset of all peripherals, Initializes the Flash interface and the Systick.
   HAL_Init();

   // Configure the system clock
   SystemClock_Config();

#if defined(USER_POWER_KEY)
   power_on();
#endif

#if defined(UART_DEBUG_OUTPUT)
   uart_debug_init();
#endif

   scheduler_init();

   debug_output_info("=============================================== \r\n");
   debug_output_info("%s Ver%d.%d.%d \r\n", PROGRAM_NAME, VERSION_MAIN, VERSION_MINOR, VERSION_SUB);
   debug_output_info("Build Date : %s %s (%s) \r\n", __DATE__, __TIME__, __VERSION__);
   debug_output_info("=============================================== \r\n\r\n");

#if defined(STM32F401CC)
   led_init();
   set_led_1_mode(LED_BLINK_MODE);
   Battery_Gauge_Init();
   Motor_Init();

#if defined(TIM2_MOTOR)
   Motor_Ext_Init();
#endif   // TIM2_MOTOR

#if defined(TIM2_REMOTE_CONTROL)
   RemoteController_Init();
#endif   // TIM2_REMOTE_CONTROL

   BLUE_NRG_SPI1_Init();
   Sensor_SPI2_Init();
#endif   // STM32F401CC

#if defined(USE_USB)
   usb_device_init();
#endif


   while (1)
   {
      scheduler_run();
   }
}


/* --------------------------------------------------------------------------
 * Name : _Error_Handler()
 *
 *
 * -------------------------------------------------------------------------- */
void _Error_Handler(char *file, int line)
{
   // User can add his own implementation to report the HAL error return state
   debug_output_error("Error_Handler() Lock : %s-%d \r\n", file, line);

   while(1)
   {
   }
}

#if defined(USE_FULL_ASSERT)
/* --------------------------------------------------------------------------
 * Name : assert_failed()
 *
 *
 * -------------------------------------------------------------------------- */
void assert_failed(uint8_t* file, uint32_t line)
{ 
   // User can add his own implementation to report the file name and line number,
   // tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line)
}
#endif   // USE_FULL_ASSERT


