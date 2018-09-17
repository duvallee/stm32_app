/**
  ******************************************************************************
  * File Name          : stm32f4xx_hal_msp.c
  * Description        : This file provides code for the MSP Initialization 
  *                      and de-Initialization codes.
  ******************************************************************************
  * This notice applies to any and all portions of this file
  * that are not between comment pairs USER CODE BEGIN and
  * USER CODE END. Other portions of this file, whether 
  * inserted by the user or by software development tools
  * are owned by their respective copyright owners.
  *
  * Copyright (c) 2018 STMicroelectronics International N.V. 
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without 
  * modification, are permitted, provided that the following conditions are met:
  *
  * 1. Redistribution of source code must retain the above copyright notice, 
  *    this list of conditions and the following disclaimer.
  * 2. Redistributions in binary form must reproduce the above copyright notice,
  *    this list of conditions and the following disclaimer in the documentation
  *    and/or other materials provided with the distribution.
  * 3. Neither the name of STMicroelectronics nor the names of other 
  *    contributors to this software may be used to endorse or promote products 
  *    derived from this software without specific written permission.
  * 4. This software, including modifications and/or derivative works of this 
  *    software, must execute solely and exclusively on microcontroller or
  *    microprocessor devices manufactured by or for STMicroelectronics.
  * 5. Redistribution and use of this software other than as permitted under 
  *    this license is void and will automatically terminate your rights under 
  *    this license. 
  *
  * THIS SOFTWARE IS PROVIDED BY STMICROELECTRONICS AND CONTRIBUTORS "AS IS" 
  * AND ANY EXPRESS, IMPLIED OR STATUTORY WARRANTIES, INCLUDING, BUT NOT 
  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
  * PARTICULAR PURPOSE AND NON-INFRINGEMENT OF THIRD PARTY INTELLECTUAL PROPERTY
  * RIGHTS ARE DISCLAIMED TO THE FULLEST EXTENT PERMITTED BY LAW. IN NO EVENT 
  * SHALL STMICROELECTRONICS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
  * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************
  */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

// ***************************************************************************
// Fuction      : HAL_MspInit()
// Description  : 
// 
//
// ***************************************************************************
void HAL_MspInit(void)
{
   HAL_NVIC_SetPriorityGrouping(NVIC_PRIORITYGROUP_4);

   // System interrupt init
   // MemoryManagement_IRQn interrupt configuration
   HAL_NVIC_SetPriority(MemoryManagement_IRQn, 0, 0);

   // BusFault_IRQn interrupt configuration
   HAL_NVIC_SetPriority(BusFault_IRQn, 0, 0);

   // UsageFault_IRQn interrupt configuration
   HAL_NVIC_SetPriority(UsageFault_IRQn, 0, 0);

   // SVCall_IRQn interrupt configuration
   HAL_NVIC_SetPriority(SVCall_IRQn, 0, 0);

   // DebugMonitor_IRQn interrupt configuration
   HAL_NVIC_SetPriority(DebugMonitor_IRQn, 0, 0);

   // PendSV_IRQn interrupt configuration
   HAL_NVIC_SetPriority(PendSV_IRQn, 0, 0);

   // SysTick_IRQn interrupt configuration
   HAL_NVIC_SetPriority(SysTick_IRQn, 0, 0);
}


// ***************************************************************************
// Fuction      : HAL_UART_MspInit()
// Description  : 
// 
//
// ***************************************************************************
void HAL_UART_MspInit(UART_HandleTypeDef* huart)
{
   GPIO_InitTypeDef GPIO_InitStruct;
   if (huart->Instance == USART1)
   {
      __HAL_RCC_USART1_CLK_ENABLE();
      // Peripheral clock enable
      __HAL_RCC_GPIOA_CLK_ENABLE();

      GPIO_InitStruct.Pin                                = UART_DEBUG_RX_PIN | UART_DEBUG_TX_PIN;
      GPIO_InitStruct.Mode                               = GPIO_MODE_AF_PP;
      GPIO_InitStruct.Pull                               = GPIO_NOPULL;
      GPIO_InitStruct.Speed                              = GPIO_SPEED_FREQ_LOW;
      GPIO_InitStruct.Alternate                          = GPIO_AF7_USART2;
      HAL_GPIO_Init(UART_DEBUG_RX_GPIO_PORT, &GPIO_InitStruct);
   }
}

// ***************************************************************************
// Fuction      : HAL_UART_MspDeInit()
// Description  : 
// 
//
// ***************************************************************************
void HAL_UART_MspDeInit(UART_HandleTypeDef* huart)
{
   if (huart->Instance == USART1)
   {
      __HAL_RCC_USART1_CLK_DISABLE();

      // USART1 GPIO Configuration
      // PA9     ------> USART1_TX
      // PA10     ------> USART1_RX 
      HAL_GPIO_DeInit(GPIOA, GPIO_PIN_9 | GPIO_PIN_10);

      HAL_NVIC_DisableIRQ(USART1_IRQn);
   }
}

// ***************************************************************************
// Fuction      : HAL_PCD_MspInit()
// Description  : 
// 
//
// ***************************************************************************
void HAL_PCD_MspInit(PCD_HandleTypeDef* pcdHandle)
{
   GPIO_InitTypeDef GPIO_InitStruct;
   if (pcdHandle->Instance == USB_OTG_FS)
   {
      __HAL_RCC_GPIOA_CLK_ENABLE();
      GPIO_InitStruct.Pin                                = GPIO_PIN_11 | GPIO_PIN_12;
      GPIO_InitStruct.Mode                               = GPIO_MODE_AF_PP;
      GPIO_InitStruct.Pull                               = GPIO_NOPULL;
      GPIO_InitStruct.Speed                              = GPIO_SPEED_FREQ_VERY_HIGH;
      GPIO_InitStruct.Alternate                          = GPIO_AF10_OTG_FS;
      HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

      // Peripheral clock enable
      __HAL_RCC_USB_OTG_FS_CLK_ENABLE();

      /* Peripheral interrupt init */
      HAL_NVIC_SetPriority(OTG_FS_IRQn, 7, 0);
      HAL_NVIC_EnableIRQ(OTG_FS_IRQn);
   }
  
}

void HAL_PCD_MspDeInit(PCD_HandleTypeDef* pcdHandle)
{
   if (pcdHandle->Instance == USB_OTG_FS)
   {
      // Peripheral clock disable
      __HAL_RCC_USB_OTG_FS_CLK_DISABLE();
      HAL_GPIO_DeInit(GPIOA, GPIO_PIN_11 | GPIO_PIN_12);

      // Peripheral interrupt Deinit
      HAL_NVIC_DisableIRQ(OTG_FS_IRQn);
   }
}



