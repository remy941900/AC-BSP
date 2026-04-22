/* ============================================================================
 * FILE     : startup.s
 * PROJECT  : AERO-CORE / AC-BSP
 * TARGET   : STM32H753ZI — Cortex-M7 @ 480 MHz
 *
 * BRIEF    : First code executed after hardware reset.
 *            Defines vector table, copies .data, zeros .bss,
 *            calls SystemInit() then main().
 *
 * STANDARD : DO-178C DAL C | MISRA-C:2012
 * TICKET   : AC-BSP-002
 *
 * REF      : [1] DS12110  — STM32H753ZI Datasheet
 *            [2] RM0433   — STM32H7 Reference Manual
 *            [3] DDI0489F — Cortex-M7 Technical Reference
 *
 * HISTORY  :
 *   v0.1.0  2026-04-18  R.Phonesavanh  Initial creation [AC-BSP-002]
 * ============================================================================
 */

/* --- Assembler directives ------------------------------------------------- */

    .syntax unified   /* UAL syntax — ARM/Thumb unified            */
    .cpu    cortex-m7 /* Target CPU  — DS12110 p.1                 */
    .fpu    softvfp   /* No FPU here — enabled later in SystemInit */
    .thumb            /* Thumb-2 only on Cortex-M7                 */

    .global g_pfnVectors  /* Export vector table to linker         */
    .global Reset_Handler /* Export reset entry point to linker    */

/* --- Vector Table --------------------------------------------------------- */

    .section .isr_vector, "a", %progbits
    .type    g_pfnVectors, %object

g_pfnVectors:
    /* Cortex-M7 system exceptions — order fixed by ARM DDI0403 Rev E */
    .word   _estack                     /* [0]  Initial Stack Pointer        */
    .word   Reset_Handler               /* [1]  Reset                        */
    .word   NMI_Handler                 /* [2]  Non-Maskable Interrupt       */
    .word   HardFault_Handler           /* [3]  Hard Fault                   */
    .word   MemManage_Handler           /* [4]  MPU Fault        — DO-178C   */
    .word   BusFault_Handler            /* [5]  Bus Fault                    */
    .word   UsageFault_Handler          /* [6]  Usage Fault                  */
    .word   0                           /* [7]  Reserved                     */
    .word   0                           /* [8]  Reserved                     */
    .word   0                           /* [9]  Reserved                     */
    .word   0                           /* [10] Reserved                     */
    .word   SVC_Handler                 /* [11] SVCall       — FreeRTOS      */
    .word   DebugMon_Handler            /* [12] Debug Monitor                */
    .word   0                           /* [13] Reserved                     */
    .word   PendSV_Handler              /* [14] PendSV       — FreeRTOS      */
    .word   SysTick_Handler             /* [15] SysTick      — FreeRTOS      */

    /* STM32H753ZI peripheral IRQs — RM0433 Rev8 Table 9 */

    /* Power and system control */
    .word   WWDG_IRQHandler             /* IRQ0   Window Watchdog            */
    .word   PVD_AVD_IRQHandler          /* IRQ1   Power Voltage Detector     */
    .word   TAMP_STAMP_IRQHandler       /* IRQ2   Tamper / Timestamp         */
    .word   RTC_WKUP_IRQHandler         /* IRQ3   RTC Wakeup                 */
    .word   FLASH_IRQHandler            /* IRQ4   Flash controller           */
    .word   RCC_IRQHandler              /* IRQ5   Clock controller           */

    /* External interrupts */
    .word   EXTI0_IRQHandler            /* IRQ6   EXTI Line 0                */
    .word   EXTI1_IRQHandler            /* IRQ7   EXTI Line 1                */
    .word   EXTI2_IRQHandler            /* IRQ8   EXTI Line 2                */
    .word   EXTI3_IRQHandler            /* IRQ9   EXTI Line 3                */
    .word   EXTI4_IRQHandler            /* IRQ10  EXTI Line 4                */

    /* DMA1 */
    .word   DMA1_Stream0_IRQHandler     /* IRQ11  DMA1 Stream 0              */
    .word   DMA1_Stream1_IRQHandler     /* IRQ12  DMA1 Stream 1              */
    .word   DMA1_Stream2_IRQHandler     /* IRQ13  DMA1 Stream 2              */
    .word   DMA1_Stream3_IRQHandler     /* IRQ14  DMA1 Stream 3              */
    .word   DMA1_Stream4_IRQHandler     /* IRQ15  DMA1 Stream 4              */
    .word   DMA1_Stream5_IRQHandler     /* IRQ16  DMA1 Stream 5              */
    .word   DMA1_Stream6_IRQHandler     /* IRQ17  DMA1 Stream 6              */

    /* Analog */
    .word   ADC_IRQHandler              /* IRQ18  ADC 1/2/3      — AC-DRV   */

    /* CAN FD — AC-DRIVERS / AC-ENG / AC-FCS */
    .word   FDCAN1_IT0_IRQHandler       /* IRQ19  FDCAN1 IT0                 */
    .word   FDCAN2_IT0_IRQHandler       /* IRQ20  FDCAN2 IT0                 */
    .word   FDCAN1_IT1_IRQHandler       /* IRQ21  FDCAN1 IT1                 */
    .word   FDCAN2_IT1_IRQHandler       /* IRQ22  FDCAN2 IT1                 */

    /* External interrupts */
    .word   EXTI9_5_IRQHandler          /* IRQ23  EXTI Lines 5-9             */

    /* Timers */
    .word   TIM1_BRK_IRQHandler         /* IRQ24  TIM1 Break                 */
    .word   TIM1_UP_IRQHandler          /* IRQ25  TIM1 Update                */
    .word   TIM1_TRG_COM_IRQHandler     /* IRQ26  TIM1 Trigger / Commutation */
    .word   TIM1_CC_IRQHandler          /* IRQ27  TIM1 Capture / Compare     */
    .word   TIM2_IRQHandler             /* IRQ28  TIM2           — AC-RTOS   */
    .word   TIM3_IRQHandler             /* IRQ29  TIM3                       */
    .word   TIM4_IRQHandler             /* IRQ30  TIM4                       */

    /* I2C — AC-DRIVERS / AC-COCKPIT */
    .word   I2C1_EV_IRQHandler          /* IRQ31  I2C1 Event                 */
    .word   I2C1_ER_IRQHandler          /* IRQ32  I2C1 Error                 */
    .word   I2C2_EV_IRQHandler          /* IRQ33  I2C2 Event                 */
    .word   I2C2_ER_IRQHandler          /* IRQ34  I2C2 Error                 */

    /* SPI — AC-DRIVERS */
    .word   SPI1_IRQHandler             /* IRQ35  SPI1                       */
    .word   SPI2_IRQHandler             /* IRQ36  SPI2                       */

    /* UART — AC-DRIVERS */
    .word   USART1_IRQHandler           /* IRQ37  USART1 debug               */
    .word   USART2_IRQHandler           /* IRQ38  USART2                     */
    .word   USART3_IRQHandler           /* IRQ39  USART3                     */

    /* External interrupts */
    .word   EXTI15_10_IRQHandler        /* IRQ40  EXTI Lines 10-15           */

    /* RTC */
    .word   RTC_Alarm_IRQHandler        /* IRQ41  RTC Alarm                  */

    .word   0                           /* IRQ42  Reserved                   */

    /* Timers */
    .word   TIM8_BRK_TIM12_IRQHandler   /* IRQ43  TIM8 Break / TIM12         */
    .word   TIM8_UP_TIM13_IRQHandler    /* IRQ44  TIM8 Update / TIM13        */
    .word   TIM8_TRG_COM_TIM14_IRQHandler /* IRQ45 TIM8 Trigger / TIM14      */
    .word   TIM8_CC_IRQHandler          /* IRQ46  TIM8 Capture / Compare     */

    /* DMA1 */
    .word   DMA1_Stream7_IRQHandler     /* IRQ47  DMA1 Stream 7              */

    /* Memory */
    .word   FMC_IRQHandler              /* IRQ48  FMC controller             */
    .word   SDMMC1_IRQHandler           /* IRQ49  SDMMC1                     */

    /* Timers */
    .word   TIM5_IRQHandler             /* IRQ50  TIM5           — AC-RTOS   */

    /* SPI */
    .word   SPI3_IRQHandler             /* IRQ51  SPI3                       */

    /* UART */
    .word   UART4_IRQHandler            /* IRQ52  UART4                      */
    .word   UART5_IRQHandler            /* IRQ53  UART5                      */

    /* Timers */
    .word   TIM6_DAC_IRQHandler         /* IRQ54  TIM6 / DAC                 */
    .word   TIM7_IRQHandler             /* IRQ55  TIM7                       */

    /* DMA2 */
    .word   DMA2_Stream0_IRQHandler     /* IRQ56  DMA2 Stream 0              */
    .word   DMA2_Stream1_IRQHandler     /* IRQ57  DMA2 Stream 1              */
    .word   DMA2_Stream2_IRQHandler     /* IRQ58  DMA2 Stream 2              */
    .word   DMA2_Stream3_IRQHandler     /* IRQ59  DMA2 Stream 3              */
    .word   DMA2_Stream4_IRQHandler     /* IRQ60  DMA2 Stream 4              */

    /* Ethernet */
    .word   ETH_IRQHandler              /* IRQ61  Ethernet                   */
    .word   ETH_WKUP_IRQHandler         /* IRQ62  Ethernet Wakeup            */

    /* CAN FD */
    .word   FDCAN_CAL_IRQHandler        /* IRQ63  FDCAN Calibration          */

    .word   0                           /* IRQ64  Reserved                   */
    .word   0                           /* IRQ65  Reserved                   */
    .word   0                           /* IRQ66  Reserved                   */
    .word   0                           /* IRQ67  Reserved                   */

    /* DMA2 */
    .word   DMA2_Stream5_IRQHandler     /* IRQ68  DMA2 Stream 5              */
    .word   DMA2_Stream6_IRQHandler     /* IRQ69  DMA2 Stream 6              */
    .word   DMA2_Stream7_IRQHandler     /* IRQ70  DMA2 Stream 7              */

    /* UART */
    .word   USART6_IRQHandler           /* IRQ71  USART6                     */

    /* I2C */
    .word   I2C3_EV_IRQHandler          /* IRQ72  I2C3 Event                 */
    .word   I2C3_ER_IRQHandler          /* IRQ73  I2C3 Error                 */

    /* USB OTG HS */
    .word   OTG_HS_EP1_OUT_IRQHandler   /* IRQ74  USB OTG HS EP1 Out         */
    .word   OTG_HS_EP1_IN_IRQHandler    /* IRQ75  USB OTG HS EP1 In          */
    .word   OTG_HS_WKUP_IRQHandler      /* IRQ76  USB OTG HS Wakeup          */
    .word   OTG_HS_IRQHandler           /* IRQ77  USB OTG HS                 */

    /* Camera */
    .word   DCMI_IRQHandler             /* IRQ78  DCMI                       */

    .word   0                           /* IRQ79  Reserved                   */

    /* Crypto */
    .word   RNG_IRQHandler              /* IRQ80  RNG                        */

    /* FPU */
    .word   FPU_IRQHandler              /* IRQ81  FPU exception              */

    /* UART */
    .word   UART7_IRQHandler            /* IRQ82  UART7                      */
    .word   UART8_IRQHandler            /* IRQ83  UART8                      */

    /* SPI */
    .word   SPI4_IRQHandler             /* IRQ84  SPI4                       */
    .word   SPI5_IRQHandler             /* IRQ85  SPI5                       */
    .word   SPI6_IRQHandler             /* IRQ86  SPI6                       */

    /* Audio */
    .word   SAI1_IRQHandler             /* IRQ87  SAI1                       */
    .word   LTDC_IRQHandler             /* IRQ88  LCD-TFT                    */
    .word   LTDC_ER_IRQHandler          /* IRQ89  LCD-TFT Error              */
    .word   DMA2D_IRQHandler            /* IRQ90  DMA2D                      */
    .word   SAI2_IRQHandler             /* IRQ91  SAI2                       */

    /* QuadSPI */
    .word   QUADSPI_IRQHandler          /* IRQ92  QuadSPI                    */

    /* Low power */
    .word   LPTIM1_IRQHandler           /* IRQ93  Low Power Timer 1          */
    .word   CEC_IRQHandler              /* IRQ94  HDMI-CEC                   */

    /* I2C — AC-COCKPIT (OLED SSD1306) */
    .word   I2C4_EV_IRQHandler          /* IRQ95  I2C4 Event                 */
    .word   I2C4_ER_IRQHandler          /* IRQ96  I2C4 Error                 */

    /* Audio */
    .word   SPDIF_RX_IRQHandler         /* IRQ97  SPDIF-Rx                   */

    /* USB OTG FS */
    .word   OTG_FS_EP1_OUT_IRQHandler   /* IRQ98  USB OTG FS EP1 Out         */
    .word   OTG_FS_EP1_IN_IRQHandler    /* IRQ99  USB OTG FS EP1 In          */
    .word   OTG_FS_WKUP_IRQHandler      /* IRQ100 USB OTG FS Wakeup          */
    .word   OTG_FS_IRQHandler           /* IRQ101 USB OTG FS                 */

    /* DMAMUX */
    .word   DMAMUX1_OVR_IRQHandler      /* IRQ102 DMAMUX1 Overrun            */

    /* HRTIM — AC-ENG (PWM haute resolution moteur) */
    .word   HRTIM1_Master_IRQHandler    /* IRQ103 HRTIM Master               */
    .word   HRTIM1_TIMA_IRQHandler      /* IRQ104 HRTIM Timer A              */
    .word   HRTIM1_TIMB_IRQHandler      /* IRQ105 HRTIM Timer B              */
    .word   HRTIM1_TIMC_IRQHandler      /* IRQ106 HRTIM Timer C              */
    .word   HRTIM1_TIMD_IRQHandler      /* IRQ107 HRTIM Timer D              */
    .word   HRTIM1_TIME_IRQHandler      /* IRQ108 HRTIM Timer E              */
    .word   HRTIM1_FLT_IRQHandler       /* IRQ109 HRTIM Fault                */

    /* DFSDM */
    .word   DFSDM1_FLT0_IRQHandler      /* IRQ110 DFSDM Filter 0             */
    .word   DFSDM1_FLT1_IRQHandler      /* IRQ111 DFSDM Filter 1             */
    .word   DFSDM1_FLT2_IRQHandler      /* IRQ112 DFSDM Filter 2             */
    .word   DFSDM1_FLT3_IRQHandler      /* IRQ113 DFSDM Filter 3             */

    /* Audio */
    .word   SAI3_IRQHandler             /* IRQ114 SAI3                       */

    /* SWPMI */
    .word   SWPMI1_IRQHandler           /* IRQ115 SWPMI1                     */

    /* Timers */
    .word   TIM15_IRQHandler            /* IRQ116 TIM15                      */
    .word   TIM16_IRQHandler            /* IRQ117 TIM16                      */
    .word   TIM17_IRQHandler            /* IRQ118 TIM17                      */

    /* MDIOS */
    .word   MDIOS_WKUP_IRQHandler       /* IRQ119 MDIOS Wakeup               */
    .word   MDIOS_IRQHandler            /* IRQ120 MDIOS                      */

    /* JPEG */
    .word   JPEG_IRQHandler             /* IRQ121 JPEG                       */

    /* MDMA */
    .word   MDMA_IRQHandler             /* IRQ122 MDMA                       */

    .word   0                           /* IRQ123 Reserved                   */

    /* Memory */
    .word   SDMMC2_IRQHandler           /* IRQ124 SDMMC2                     */

    /* Hardware semaphore */
    .word   HSEM1_IRQHandler            /* IRQ125 HSEM1                      */

    .word   0                           /* IRQ126 Reserved                   */

    /* Analog */
    .word   ADC3_IRQHandler             /* IRQ127 ADC3           — AC-DRV   */

    /* DMAMUX */
    .word   DMAMUX2_OVR_IRQHandler      /* IRQ128 DMAMUX2 Overrun            */

    /* BDMA */
    .word   BDMA_Channel0_IRQHandler    /* IRQ129 BDMA Channel 0             */
    .word   BDMA_Channel1_IRQHandler    /* IRQ130 BDMA Channel 1             */
    .word   BDMA_Channel2_IRQHandler    /* IRQ131 BDMA Channel 2             */
    .word   BDMA_Channel3_IRQHandler    /* IRQ132 BDMA Channel 3             */
    .word   BDMA_Channel4_IRQHandler    /* IRQ133 BDMA Channel 4             */
    .word   BDMA_Channel5_IRQHandler    /* IRQ134 BDMA Channel 5             */
    .word   BDMA_Channel6_IRQHandler    /* IRQ135 BDMA Channel 6             */
    .word   BDMA_Channel7_IRQHandler    /* IRQ136 BDMA Channel 7             */

    /* Comparator */
    .word   COMP1_IRQHandler            /* IRQ137 Comparator 1               */

    /* Low power */
    .word   LPTIM2_IRQHandler           /* IRQ138 Low Power Timer 2          */
    .word   LPTIM3_IRQHandler           /* IRQ139 Low Power Timer 3          */
    .word   LPTIM4_IRQHandler           /* IRQ140 Low Power Timer 4          */
    .word   LPTIM5_IRQHandler           /* IRQ141 Low Power Timer 5          */
    .word   LPUART1_IRQHandler          /* IRQ142 Low Power UART 1           */

    .word   0                           /* IRQ143 Reserved                   */

    /* Clock recovery */
    .word   CRS_IRQHandler              /* IRQ144 Clock Recovery System      */

    /* Audio */
    .word   SAI4_IRQHandler             /* IRQ145 SAI4                       */

    .word   0                           /* IRQ146 Reserved                   */
    .word   0                           /* IRQ147 Reserved                   */

    /* Wakeup */
    .word   WAKEUP_PIN_IRQHandler       /* IRQ148 Wakeup Pin                 */

    .size   g_pfnVectors, .-g_pfnVectors

/* --- Reset Handler -------------------------------------------------------- */

    .section .text.Reset_Handler, "ax", %progbits
    .type    Reset_Handler, %function

Reset_Handler:

    /* Step 1 : Copy .data section from Flash to SRAM
     * Source      : _sidata (image of .data in Flash)
     * Destination : _sdata  (start of .data in SRAM)
     * End         : _edata  (end of .data in SRAM)
     * Symbols defined in STM32H753ZI.ld                        */
    ldr   r0, =_sdata    /* r0 = destination start (SRAM)        */
    ldr   r1, =_edata    /* r1 = destination end   (SRAM)        */
    ldr   r2, =_sidata   /* r2 = source start      (Flash)       */
    movs  r3, #0         /* r3 = byte offset = 0                 */
    b     LoopCopyData   /* jump to loop condition first         */

CopyData:
    ldr   r4, [r2, r3]   /* read 4 bytes from Flash              */
    str   r4, [r0, r3]   /* write 4 bytes to SRAM                */
    adds  r3, r3, #4     /* advance offset by 4 bytes            */

LoopCopyData:
    adds  r4, r0, r3     /* r4 = current SRAM address            */
    cmp   r4, r1         /* reached end of .data ?               */
    bcc   CopyData       /* no  -> continue copy                 */
                         /* yes -> fall through to step 2        */

    /* Step 2 : Zero-fill .bss section in SRAM
     * Start : _sbss (start of .bss in SRAM)
     * End   : _ebss (end of .bss in SRAM)
     * Symbols defined in STM32H753ZI.ld                        */
    ldr   r2, =_sbss     /* r2 = start of .bss in SRAM          */
    ldr   r4, =_ebss     /* r4 = end of .bss in SRAM            */
    movs  r3, #0         /* r3 = 0x00000000 (value to write)    */
    b     LoopZeroBss    /* jump to loop condition first         */

ZeroBss:
    str   r3, [r2]       /* write 0 at current address          */
    adds  r2, r2, #4     /* advance to next word                */

LoopZeroBss:
    cmp   r2, r4         /* reached end of .bss ?               */
    bcc   ZeroBss        /* no  -> continue                     */
                         /* yes -> fall through to step 3       */

    /* Step 3 : Call SystemInit() to configure system clocks
     * Switches CPU from HSI 64MHz to PLL 480MHz
     * Implemented in AC-BSP-003                               */
    bl    SystemInit     /* branch with link = function call    */

    /* Step 4 : Call main() — application entry point
     * At this point :
     *   .data is ready   (copied from Flash)
     *   .bss  is ready   (zeroed)
     *   clock is ready   (480MHz)                             */
    bl    main

    /* Safety : main() should never return
     * If it does -> infinite loop caught by watchdog          */
LoopForever:
    b     LoopForever

    .size Reset_Handler, .-Reset_Handler

/* --- Default Handler ----------------------------------------------------- */

    .section .text.Default_Handler, "ax", %progbits
    .type    Default_Handler, %function

Default_Handler:
    b     Default_Handler        /* infinite loop — caught by watchdog       */
    .size Default_Handler, .-Default_Handler

/* --- Weak Aliases --------------------------------------------------------- */

/* Cortex-M7 system exceptions */
    .weak   NMI_Handler
    .thumb_set NMI_Handler,              Default_Handler

    .weak   HardFault_Handler
    .thumb_set HardFault_Handler,        Default_Handler

    .weak   MemManage_Handler
    .thumb_set MemManage_Handler,        Default_Handler

    .weak   BusFault_Handler
    .thumb_set BusFault_Handler,         Default_Handler

    .weak   UsageFault_Handler
    .thumb_set UsageFault_Handler,       Default_Handler

    .weak   SVC_Handler
    .thumb_set SVC_Handler,              Default_Handler

    .weak   DebugMon_Handler
    .thumb_set DebugMon_Handler,         Default_Handler

    .weak   PendSV_Handler
    .thumb_set PendSV_Handler,           Default_Handler

    .weak   SysTick_Handler
    .thumb_set SysTick_Handler,          Default_Handler

/* STM32H753ZI peripheral IRQs */
    .weak   WWDG_IRQHandler
    .thumb_set WWDG_IRQHandler,              Default_Handler

    .weak   PVD_AVD_IRQHandler
    .thumb_set PVD_AVD_IRQHandler,           Default_Handler

    .weak   TAMP_STAMP_IRQHandler
    .thumb_set TAMP_STAMP_IRQHandler,        Default_Handler

    .weak   RTC_WKUP_IRQHandler
    .thumb_set RTC_WKUP_IRQHandler,          Default_Handler

    .weak   FLASH_IRQHandler
    .thumb_set FLASH_IRQHandler,             Default_Handler

    .weak   RCC_IRQHandler
    .thumb_set RCC_IRQHandler,               Default_Handler

    .weak   EXTI0_IRQHandler
    .thumb_set EXTI0_IRQHandler,             Default_Handler

    .weak   EXTI1_IRQHandler
    .thumb_set EXTI1_IRQHandler,             Default_Handler

    .weak   EXTI2_IRQHandler
    .thumb_set EXTI2_IRQHandler,             Default_Handler

    .weak   EXTI3_IRQHandler
    .thumb_set EXTI3_IRQHandler,             Default_Handler

    .weak   EXTI4_IRQHandler
    .thumb_set EXTI4_IRQHandler,             Default_Handler

    .weak   DMA1_Stream0_IRQHandler
    .thumb_set DMA1_Stream0_IRQHandler,      Default_Handler

    .weak   DMA1_Stream1_IRQHandler
    .thumb_set DMA1_Stream1_IRQHandler,      Default_Handler

    .weak   DMA1_Stream2_IRQHandler
    .thumb_set DMA1_Stream2_IRQHandler,      Default_Handler

    .weak   DMA1_Stream3_IRQHandler
    .thumb_set DMA1_Stream3_IRQHandler,      Default_Handler

    .weak   DMA1_Stream4_IRQHandler
    .thumb_set DMA1_Stream4_IRQHandler,      Default_Handler

    .weak   DMA1_Stream5_IRQHandler
    .thumb_set DMA1_Stream5_IRQHandler,      Default_Handler

    .weak   DMA1_Stream6_IRQHandler
    .thumb_set DMA1_Stream6_IRQHandler,      Default_Handler

    .weak   ADC_IRQHandler
    .thumb_set ADC_IRQHandler,               Default_Handler

    .weak   FDCAN1_IT0_IRQHandler
    .thumb_set FDCAN1_IT0_IRQHandler,        Default_Handler

    .weak   FDCAN2_IT0_IRQHandler
    .thumb_set FDCAN2_IT0_IRQHandler,        Default_Handler

    .weak   FDCAN1_IT1_IRQHandler
    .thumb_set FDCAN1_IT1_IRQHandler,        Default_Handler

    .weak   FDCAN2_IT1_IRQHandler
    .thumb_set FDCAN2_IT1_IRQHandler,        Default_Handler

    .weak   EXTI9_5_IRQHandler
    .thumb_set EXTI9_5_IRQHandler,           Default_Handler

    .weak   TIM1_BRK_IRQHandler
    .thumb_set TIM1_BRK_IRQHandler,          Default_Handler

    .weak   TIM1_UP_IRQHandler
    .thumb_set TIM1_UP_IRQHandler,           Default_Handler

    .weak   TIM1_TRG_COM_IRQHandler
    .thumb_set TIM1_TRG_COM_IRQHandler,      Default_Handler

    .weak   TIM1_CC_IRQHandler
    .thumb_set TIM1_CC_IRQHandler,           Default_Handler

    .weak   TIM2_IRQHandler
    .thumb_set TIM2_IRQHandler,              Default_Handler

    .weak   TIM3_IRQHandler
    .thumb_set TIM3_IRQHandler,              Default_Handler

    .weak   TIM4_IRQHandler
    .thumb_set TIM4_IRQHandler,              Default_Handler

    .weak   I2C1_EV_IRQHandler
    .thumb_set I2C1_EV_IRQHandler,           Default_Handler

    .weak   I2C1_ER_IRQHandler
    .thumb_set I2C1_ER_IRQHandler,           Default_Handler

    .weak   I2C2_EV_IRQHandler
    .thumb_set I2C2_EV_IRQHandler,           Default_Handler

    .weak   I2C2_ER_IRQHandler
    .thumb_set I2C2_ER_IRQHandler,           Default_Handler

    .weak   SPI1_IRQHandler
    .thumb_set SPI1_IRQHandler,              Default_Handler

    .weak   SPI2_IRQHandler
    .thumb_set SPI2_IRQHandler,              Default_Handler

    .weak   USART1_IRQHandler
    .thumb_set USART1_IRQHandler,            Default_Handler

    .weak   USART2_IRQHandler
    .thumb_set USART2_IRQHandler,            Default_Handler

    .weak   USART3_IRQHandler
    .thumb_set USART3_IRQHandler,            Default_Handler

    .weak   EXTI15_10_IRQHandler
    .thumb_set EXTI15_10_IRQHandler,         Default_Handler

    .weak   RTC_Alarm_IRQHandler
    .thumb_set RTC_Alarm_IRQHandler,         Default_Handler

    .weak   TIM8_BRK_TIM12_IRQHandler
    .thumb_set TIM8_BRK_TIM12_IRQHandler,    Default_Handler

    .weak   TIM8_UP_TIM13_IRQHandler
    .thumb_set TIM8_UP_TIM13_IRQHandler,     Default_Handler

    .weak   TIM8_TRG_COM_TIM14_IRQHandler
    .thumb_set TIM8_TRG_COM_TIM14_IRQHandler, Default_Handler

    .weak   TIM8_CC_IRQHandler
    .thumb_set TIM8_CC_IRQHandler,           Default_Handler

    .weak   DMA1_Stream7_IRQHandler
    .thumb_set DMA1_Stream7_IRQHandler,      Default_Handler

    .weak   FMC_IRQHandler
    .thumb_set FMC_IRQHandler,               Default_Handler

    .weak   SDMMC1_IRQHandler
    .thumb_set SDMMC1_IRQHandler,            Default_Handler

    .weak   TIM5_IRQHandler
    .thumb_set TIM5_IRQHandler,              Default_Handler

    .weak   SPI3_IRQHandler
    .thumb_set SPI3_IRQHandler,              Default_Handler

    .weak   UART4_IRQHandler
    .thumb_set UART4_IRQHandler,             Default_Handler

    .weak   UART5_IRQHandler
    .thumb_set UART5_IRQHandler,             Default_Handler

    .weak   TIM6_DAC_IRQHandler
    .thumb_set TIM6_DAC_IRQHandler,          Default_Handler

    .weak   TIM7_IRQHandler
    .thumb_set TIM7_IRQHandler,              Default_Handler

    .weak   DMA2_Stream0_IRQHandler
    .thumb_set DMA2_Stream0_IRQHandler,      Default_Handler

    .weak   DMA2_Stream1_IRQHandler
    .thumb_set DMA2_Stream1_IRQHandler,      Default_Handler

    .weak   DMA2_Stream2_IRQHandler
    .thumb_set DMA2_Stream2_IRQHandler,      Default_Handler

    .weak   DMA2_Stream3_IRQHandler
    .thumb_set DMA2_Stream3_IRQHandler,      Default_Handler

    .weak   DMA2_Stream4_IRQHandler
    .thumb_set DMA2_Stream4_IRQHandler,      Default_Handler

    .weak   ETH_IRQHandler
    .thumb_set ETH_IRQHandler,               Default_Handler

    .weak   ETH_WKUP_IRQHandler
    .thumb_set ETH_WKUP_IRQHandler,          Default_Handler

    .weak   FDCAN_CAL_IRQHandler
    .thumb_set FDCAN_CAL_IRQHandler,         Default_Handler

    .weak   DMA2_Stream5_IRQHandler
    .thumb_set DMA2_Stream5_IRQHandler,      Default_Handler

    .weak   DMA2_Stream6_IRQHandler
    .thumb_set DMA2_Stream6_IRQHandler,      Default_Handler

    .weak   DMA2_Stream7_IRQHandler
    .thumb_set DMA2_Stream7_IRQHandler,      Default_Handler

    .weak   USART6_IRQHandler
    .thumb_set USART6_IRQHandler,            Default_Handler

    .weak   I2C3_EV_IRQHandler
    .thumb_set I2C3_EV_IRQHandler,           Default_Handler

    .weak   I2C3_ER_IRQHandler
    .thumb_set I2C3_ER_IRQHandler,           Default_Handler

    .weak   OTG_HS_EP1_OUT_IRQHandler
    .thumb_set OTG_HS_EP1_OUT_IRQHandler,    Default_Handler

    .weak   OTG_HS_EP1_IN_IRQHandler
    .thumb_set OTG_HS_EP1_IN_IRQHandler,     Default_Handler

    .weak   OTG_HS_WKUP_IRQHandler
    .thumb_set OTG_HS_WKUP_IRQHandler,       Default_Handler

    .weak   OTG_HS_IRQHandler
    .thumb_set OTG_HS_IRQHandler,            Default_Handler

    .weak   DCMI_IRQHandler
    .thumb_set DCMI_IRQHandler,              Default_Handler

    .weak   RNG_IRQHandler
    .thumb_set RNG_IRQHandler,               Default_Handler

    .weak   FPU_IRQHandler
    .thumb_set FPU_IRQHandler,               Default_Handler

    .weak   UART7_IRQHandler
    .thumb_set UART7_IRQHandler,             Default_Handler

    .weak   UART8_IRQHandler
    .thumb_set UART8_IRQHandler,             Default_Handler

    .weak   SPI4_IRQHandler
    .thumb_set SPI4_IRQHandler,              Default_Handler

    .weak   SPI5_IRQHandler
    .thumb_set SPI5_IRQHandler,              Default_Handler

    .weak   SPI6_IRQHandler
    .thumb_set SPI6_IRQHandler,              Default_Handler

    .weak   SAI1_IRQHandler
    .thumb_set SAI1_IRQHandler,              Default_Handler

    .weak   LTDC_IRQHandler
    .thumb_set LTDC_IRQHandler,              Default_Handler

    .weak   LTDC_ER_IRQHandler
    .thumb_set LTDC_ER_IRQHandler,           Default_Handler

    .weak   DMA2D_IRQHandler
    .thumb_set DMA2D_IRQHandler,             Default_Handler

    .weak   SAI2_IRQHandler
    .thumb_set SAI2_IRQHandler,              Default_Handler

    .weak   QUADSPI_IRQHandler
    .thumb_set QUADSPI_IRQHandler,           Default_Handler

    .weak   LPTIM1_IRQHandler
    .thumb_set LPTIM1_IRQHandler,            Default_Handler

    .weak   CEC_IRQHandler
    .thumb_set CEC_IRQHandler,               Default_Handler

    .weak   I2C4_EV_IRQHandler
    .thumb_set I2C4_EV_IRQHandler,           Default_Handler

    .weak   I2C4_ER_IRQHandler
    .thumb_set I2C4_ER_IRQHandler,           Default_Handler

    .weak   SPDIF_RX_IRQHandler
    .thumb_set SPDIF_RX_IRQHandler,          Default_Handler

    .weak   OTG_FS_EP1_OUT_IRQHandler
    .thumb_set OTG_FS_EP1_OUT_IRQHandler,    Default_Handler

    .weak   OTG_FS_EP1_IN_IRQHandler
    .thumb_set OTG_FS_EP1_IN_IRQHandler,     Default_Handler

    .weak   OTG_FS_WKUP_IRQHandler
    .thumb_set OTG_FS_WKUP_IRQHandler,       Default_Handler

    .weak   OTG_FS_IRQHandler
    .thumb_set OTG_FS_IRQHandler,            Default_Handler

    .weak   DMAMUX1_OVR_IRQHandler
    .thumb_set DMAMUX1_OVR_IRQHandler,       Default_Handler

    .weak   HRTIM1_Master_IRQHandler
    .thumb_set HRTIM1_Master_IRQHandler,     Default_Handler

    .weak   HRTIM1_TIMA_IRQHandler
    .thumb_set HRTIM1_TIMA_IRQHandler,       Default_Handler

    .weak   HRTIM1_TIMB_IRQHandler
    .thumb_set HRTIM1_TIMB_IRQHandler,       Default_Handler

    .weak   HRTIM1_TIMC_IRQHandler
    .thumb_set HRTIM1_TIMC_IRQHandler,       Default_Handler

    .weak   HRTIM1_TIMD_IRQHandler
    .thumb_set HRTIM1_TIMD_IRQHandler,       Default_Handler

    .weak   HRTIM1_TIME_IRQHandler
    .thumb_set HRTIM1_TIME_IRQHandler,       Default_Handler

    .weak   HRTIM1_FLT_IRQHandler
    .thumb_set HRTIM1_FLT_IRQHandler,        Default_Handler

    .weak   DFSDM1_FLT0_IRQHandler
    .thumb_set DFSDM1_FLT0_IRQHandler,       Default_Handler

    .weak   DFSDM1_FLT1_IRQHandler
    .thumb_set DFSDM1_FLT1_IRQHandler,       Default_Handler

    .weak   DFSDM1_FLT2_IRQHandler
    .thumb_set DFSDM1_FLT2_IRQHandler,       Default_Handler

    .weak   DFSDM1_FLT3_IRQHandler
    .thumb_set DFSDM1_FLT3_IRQHandler,       Default_Handler

    .weak   SAI3_IRQHandler
    .thumb_set SAI3_IRQHandler,              Default_Handler

    .weak   SWPMI1_IRQHandler
    .thumb_set SWPMI1_IRQHandler,            Default_Handler

    .weak   TIM15_IRQHandler
    .thumb_set TIM15_IRQHandler,             Default_Handler

    .weak   TIM16_IRQHandler
    .thumb_set TIM16_IRQHandler,             Default_Handler

    .weak   TIM17_IRQHandler
    .thumb_set TIM17_IRQHandler,             Default_Handler

    .weak   MDIOS_WKUP_IRQHandler
    .thumb_set MDIOS_WKUP_IRQHandler,        Default_Handler

    .weak   MDIOS_IRQHandler
    .thumb_set MDIOS_IRQHandler,             Default_Handler

    .weak   JPEG_IRQHandler
    .thumb_set JPEG_IRQHandler,              Default_Handler

    .weak   MDMA_IRQHandler
    .thumb_set MDMA_IRQHandler,              Default_Handler

    .weak   SDMMC2_IRQHandler
    .thumb_set SDMMC2_IRQHandler,            Default_Handler

    .weak   HSEM1_IRQHandler
    .thumb_set HSEM1_IRQHandler,             Default_Handler

    .weak   ADC3_IRQHandler
    .thumb_set ADC3_IRQHandler,              Default_Handler

    .weak   DMAMUX2_OVR_IRQHandler
    .thumb_set DMAMUX2_OVR_IRQHandler,       Default_Handler

    .weak   BDMA_Channel0_IRQHandler
    .thumb_set BDMA_Channel0_IRQHandler,     Default_Handler

    .weak   BDMA_Channel1_IRQHandler
    .thumb_set BDMA_Channel1_IRQHandler,     Default_Handler

    .weak   BDMA_Channel2_IRQHandler
    .thumb_set BDMA_Channel2_IRQHandler,     Default_Handler

    .weak   BDMA_Channel3_IRQHandler
    .thumb_set BDMA_Channel3_IRQHandler,     Default_Handler

    .weak   BDMA_Channel4_IRQHandler
    .thumb_set BDMA_Channel4_IRQHandler,     Default_Handler

    .weak   BDMA_Channel5_IRQHandler
    .thumb_set BDMA_Channel5_IRQHandler,     Default_Handler

    .weak   BDMA_Channel6_IRQHandler
    .thumb_set BDMA_Channel6_IRQHandler,     Default_Handler

    .weak   BDMA_Channel7_IRQHandler
    .thumb_set BDMA_Channel7_IRQHandler,     Default_Handler

    .weak   COMP1_IRQHandler
    .thumb_set COMP1_IRQHandler,             Default_Handler

    .weak   LPTIM2_IRQHandler
    .thumb_set LPTIM2_IRQHandler,            Default_Handler

    .weak   LPTIM3_IRQHandler
    .thumb_set LPTIM3_IRQHandler,            Default_Handler

    .weak   LPTIM4_IRQHandler
    .thumb_set LPTIM4_IRQHandler,            Default_Handler

    .weak   LPTIM5_IRQHandler
    .thumb_set LPTIM5_IRQHandler,            Default_Handler

    .weak   LPUART1_IRQHandler
    .thumb_set LPUART1_IRQHandler,           Default_Handler

    .weak   CRS_IRQHandler
    .thumb_set CRS_IRQHandler,               Default_Handler

    .weak   SAI4_IRQHandler
    .thumb_set SAI4_IRQHandler,              Default_Handler

    .weak   WAKEUP_PIN_IRQHandler
    .thumb_set WAKEUP_PIN_IRQHandler,        Default_Handler
