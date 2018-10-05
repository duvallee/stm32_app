/*
 * File: sensor_spi2.c
 *
 * Written by duvallee in 2018
 *
 */
#include "main.h"
#include "sensor_spi2.h"

// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
static SPI_HandleTypeDef g_spi2_sensor_Handle;

enum SPI2_CHIP_CS
{
   SPI2_CHIP_UNSELECT                                    = 0,
   SPI2_CHIP_SELECT                                      = 1,
};

// LSM6DSL A+GIMU            LSM6DS33_CS (PA8)
// LIS2MDL Magnetometer      LIS2MDL_CS (PB2)
// LPS22HD Pressure Sensor   LPS22HB_CS (PC13)

// ***************************************************************************
// Fuction      : Chip_Select_LSM6DSL()
// Description  : 
// 
//
// ***************************************************************************
static void Chip_Select_LSM6DSL(enum SPI2_CHIP_CS cs)
{
   (cs == SPI2_CHIP_SELECT) ? HAL_GPIO_WritePin(GPIOA, GPIO_PIN_8, GPIO_PIN_RESET) : HAL_GPIO_WritePin(GPIOA, GPIO_PIN_8, GPIO_PIN_SET);
}

// ***************************************************************************
// Fuction      : Chip_Select_LIS2MDL()
// Description  : 
// 
//
// ***************************************************************************
static void Chip_Select_LIS2MDL(enum SPI2_CHIP_CS cs)
{
   (cs == SPI2_CHIP_SELECT) ? HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_RESET) : HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_SET);
}

// ***************************************************************************
// Fuction      : Chip_Select_LIS2MDL()
// Description  : 
// 
//
// ***************************************************************************
static void Chip_Select_LPS22HD(enum SPI2_CHIP_CS cs)
{
   (cs == SPI2_CHIP_SELECT) ? HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET) : HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
}


// ***************************************************************************
// Fuction      : Sensor_SPI2_Init()
// Description  : 
// 
//
// ***************************************************************************
void Sensor_SPI2_Init(void)
{
   GPIO_InitTypeDef GPIO_InitStruct;
   __GPIOA_CLK_ENABLE();
   __GPIOB_CLK_ENABLE();
   __GPIOC_CLK_ENABLE();

   HAL_GPIO_WritePin(GPIOA, GPIO_PIN_8, GPIO_PIN_SET);
   HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_SET);
   HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);

   // CS : LSM6DSL
   GPIO_InitStruct.Pin                                   = GPIO_PIN_8;
   GPIO_InitStruct.Mode                                  = GPIO_MODE_OUTPUT_PP;
   GPIO_InitStruct.Pull                                  = GPIO_NOPULL;
   GPIO_InitStruct.Speed                                 = GPIO_SPEED_HIGH;
   GPIO_InitStruct.Alternate                             = 0;
   HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
   HAL_GPIO_WritePin(GPIOA, GPIO_PIN_8, GPIO_PIN_SET);

   // CS : LIS2MDL
   GPIO_InitStruct.Pin                                   = GPIO_PIN_2;
   GPIO_InitStruct.Mode                                  = GPIO_MODE_OUTPUT_PP;
   GPIO_InitStruct.Pull                                  = GPIO_NOPULL;
   GPIO_InitStruct.Speed                                 = GPIO_SPEED_HIGH;
   GPIO_InitStruct.Alternate                             = 0;
   HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
   HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_SET);

   // CS : LPS22HD
   GPIO_InitStruct.Pin                                   = GPIO_PIN_13;
   GPIO_InitStruct.Mode                                  = GPIO_MODE_OUTPUT_PP;
   GPIO_InitStruct.Pull                                  = GPIO_NOPULL;
   GPIO_InitStruct.Speed                                 = GPIO_SPEED_HIGH;
   GPIO_InitStruct.Alternate                             = 0;
   HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
   HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);

   g_spi2_sensor_Handle.Instance                         = SPI2;
   g_spi2_sensor_Handle.Init.Mode                        = SPI_MODE_MASTER;
   g_spi2_sensor_Handle.Init.Direction                   = SPI_DIRECTION_1LINE;
   g_spi2_sensor_Handle.Init.DataSize                    = SPI_DATASIZE_8BIT;
   g_spi2_sensor_Handle.Init.CLKPolarity                 = SPI_POLARITY_HIGH;
   g_spi2_sensor_Handle.Init.CLKPhase                    = SPI_PHASE_2EDGE;
   g_spi2_sensor_Handle.Init.NSS                         = SPI_NSS_SOFT;
   g_spi2_sensor_Handle.Init.FirstBit                    = SPI_FIRSTBIT_MSB;
   g_spi2_sensor_Handle.Init.TIMode                      = SPI_TIMODE_DISABLED;
   g_spi2_sensor_Handle.Init.CRCPolynomial               = 7;
   g_spi2_sensor_Handle.Init.BaudRatePrescaler           = SPI_BAUDRATEPRESCALER_16;
   g_spi2_sensor_Handle.Init.CRCCalculation              = SPI_CRCCALCULATION_DISABLED;

   if (HAL_SPI_Init(&g_spi2_sensor_Handle) != HAL_OK)
   {
      _Error_Handler(__FILE__, __LINE__);
   }

   SPI_1LINE_TX(&g_spi2_sensor_Handle);
   __HAL_SPI_ENABLE(&g_spi2_sensor_Handle);

}



