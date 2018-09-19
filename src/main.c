/**
  ******************************************************************************
  * @file    07_PWM_EdgeAligned/main.c 
  * @author  MCD Application Team
  * @version V1.2.0
  * @date    19-June-2015
  * @brief   This code example shows how to configure the timer 
  *          to generate a PWM edge aligned signal. 
  *
 ===============================================================================
                    #####       MCU Resources     #####
 ===============================================================================
  - RCC
  - TIMx
  - GPIO PA8 for TIM1_CH1
  - GPIO PC8 and PC9 for LEDs

 ===============================================================================
                    ##### How to use this example #####
 ===============================================================================
    - this file must be inserted in a project containing  the following files :
      o system_stm32f0xx.c, startup_stm32f072xb.s
      o stm32f0xx.h to get the register definitions
      o CMSIS files
 ===============================================================================
                    ##### How to test this example #####
 ===============================================================================
    - This example configures the TIM1 in order to generate a PWM edge aligned 
      on OC1 (channel 1)with a period of 9 microseconds and a 4/9 duty cycle.
      The GPIO PA8, corresponding to TIM1_CH1, is configured as alternate function 
      and the AFR2 is selected.
    - To test this example, the user must monitor the signal on PA8.
    - This example can be easily ported on any other timer by modifying TIMx 
      definition. The corresponding GPIO must be also adapted according to 
      the datasheet.
    - The green LED is switched on.

  *
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; COPYRIGHT 2015 STMicroelectronics</center></h2>
  *
  * Licensed under MCD-ST Liberty SW License Agreement V2, (the "License");
  * You may not use this file except in compliance with the License.
  * You may obtain a copy of the License at:
  *
  *        http://www.st.com/software_license_agreement_liberty_v2
  *
  * Unless required by applicable law or agreed to in writing, software 
  * distributed under the License is distributed on an "AS IS" BASIS, 
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include "stm32f0xx.h"
/** @addtogroup STM32F0_Snippets
  * @{
  */



/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/

/* Define the Timer to be configured */
#define TIMx TIM3
#define TIMx_BASE TIM3_BASE


/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
void ConfigureTIMxAsPWM_EdgeAligned(void);
/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Main program.
  * @param  None
  * @retval None
  */
int main(void)
{
  /*!< At this stage the microcontroller clock setting is already configured, 
       this is done through SystemInit() function which is called from startup
       file (startup_stm32f072xb.s) before to branch to application main.
       To reconfigure the default setting of SystemInit() function, refer to
       system_stm32f0xx.c file
     */
  ConfigureTIMxAsPWM_EdgeAligned();
  char *str;

   /* Initial memory allocation */
  str = (char *) malloc(15);

  /* Reallocating memory */
  str = (char *) realloc(str, 25);

  free(str);
  while (1)
  {
    __WFI();
  }
}


/**
  * @brief  This function configures the TIMx as PWM mode 1
  *         and enables the peripheral clock on TIMx and on GPIOA.
  *         It configures GPIO PA8 as Alternate function for TIM1_CH1
  *         To use another timer, channel or GPIO, the RCC and GPIO configuration 
  *         must be adapted according to the datasheet.
  *         In case of other timer, the interrupt sub-routine must also be renamed
  *         with the right handler and the NVIC configured correctly.
  * @param  None
  * @retval None
  */
__INLINE void ConfigureTIMxAsPWM_EdgeAligned(void)
{
  /* (1) Enable the peripheral clock of GPIOC */

  RCC->AHBENR |= RCC_AHBENR_GPIOCEN; /* (1) */

  /* (1) Enable the peripheral clock of Timer x */
  /* (2) Enable the peripheral clock of GPIOC */
  /* (3) Select alternate function mode on GPIOC pin 8 */
  /* (4) Select AF2 on PC8 in AFRH for TIM3_CH3 */

  RCC->APB1ENR |= RCC_APB1ENR_TIM3EN; /* (1) */
  RCC->AHBENR |= RCC_AHBENR_GPIOCEN; /* (2) */
  GPIOC->MODER = (GPIOC->MODER &
      ~(GPIO_MODER_MODER9 | GPIO_MODER_MODER8)) |
    (GPIO_MODER_MODER9_1 | GPIO_MODER_MODER8_1); /* (3) */
  GPIOC->AFR[1] |= 0x02; /* (4) */

  /* (1) Set prescaler to 47999, so APBCLK/48 i.e 1kHz */ 
  /* (2) Set ARR = 1000, as timer clock is 1kHz the period is 1000 ms */
  /* (3) Set CCRx = 500, , the signal will be high during 500 ms */
  /* (4) Select PWM mode 1 on OC3  (OC3M = 110),
         enable preload register on OC3 (OC3PE = 1) */
  /* (5) Select PWM mode 1 on OC4  (OC4M = 111),
         enable preload register on OC3 (OC3PE = 1) */
  /* (6) Select active high polarity on OC3 and OC4 (CC3P = 0, CC4P = 0, reset value),
         enable the output on OC3 and OC4 (CC3E = 1, CC4E = 1)*/
  /* (7) Enable output (MOE = 1)*/
  /* (8) Enable counter (CEN = 1)
         select edge aligned mode (CMS = 00, reset value)
         select direction as upcounter (DIR = 0, reset value) */  
  /* (9) Force update generation (UG = 1) */

  TIMx->PSC = 47999; /* (1) */
  TIMx->ARR = 1000; /* (2) */
  TIMx->CCR4 = 500; /* (3) */
  TIMx->CCR3 = 500; /* (3) */
  TIMx->CCMR2 |= TIM_CCMR2_OC3M_2 | TIM_CCMR2_OC3M_1 | TIM_CCMR2_OC3PE; /* (4) */
  TIMx->CCMR2 |= TIM_CCMR2_OC4M | TIM_CCMR2_OC4PE; /* (5) */
  TIMx->CCER |= TIM_CCER_CC3E | TIM_CCER_CC4E; /* (6) */
  TIMx->BDTR |= TIM_BDTR_MOE; /* (7) */
  TIMx->CR1 |= TIM_CR1_CEN; /* (8) */
  TIMx->EGR |= TIM_EGR_UG; /* (9) */
}





/******************************************************************************/
/*            Cortex-M0 Processor Exceptions Handlers                         */
/******************************************************************************/

/**
  * @brief  This function handles NMI exception.
  * @param  None
  * @retval None
  */
void NMI_Handler(void)
{
}

/**
  * @brief  This function handles Hard Fault exception.
  * @param  None
  * @retval None
  */
void HardFault_Handler(void)
{
  /* Go to infinite loop when Hard Fault exception occurs */
  while (1)
  {
  }
}

/**
  * @brief  This function handles SVCall exception.
  * @param  None
  * @retval None
  */
void SVC_Handler(void)
{
}

/**
  * @brief  This function handles PendSVC exception.
  * @param  None
  * @retval None
  */
void PendSV_Handler(void)
{
}

/**
  * @brief  This function handles SysTick Handler.
  * @param  None
  * @retval None
  */
void SysTick_Handler(void)
{
}

/******************************************************************************/
/*                 STM32F0xx Peripherals Interrupt Handlers                   */
/*  Add here the Interrupt Handler for the used peripheral(s) (PPP), for the  */
/*  available peripheral interrupt handler's name please refer to the startup */
/*  file (startup_stm32f072xb.s).                                               */
/******************************************************************************/



/**
  * @}
  */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
