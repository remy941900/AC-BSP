/* ============================================================================
 * FILE     : STM32H753ZI.ld
 * PROJECT  : AERO-CORE / AC-BSP
 * TARGET   : STM32H753ZI — Cortex-M7 @ 480 MHz
 *
 * BRIEF    : Linker script — memory regions and section placement.
 *            Symbols referenced by startup.s Reset_Handler.
 *
 * STANDARD : DO-178C DAL C
 * TICKET   : AC-BSP-002
 *
 * REF      : [1] RM0433 Rev8 — STM32H7 Reference Manual
 *            [2] GNU LD       — Linker script documentation
 *
 * HISTORY  :
 *   v0.1.0  2026-04-18  R.Phonesavanh  Initial creation [AC-BSP-002]
 * ============================================================================ */

/* Entry point for debugger (GDB/OpenOCD) — does not affect hardware boot */
ENTRY(Reset_Handler)

/* ----------------------------------------------------------------------------
 * Memory symbols
 * _estack          : initial SP value — top of AXI SRAM (RM0433 §2.3)
 * _Min_Stack_Size  : minimum stack reservation — linker error if exceeded
 * _Min_Heap_Size   : minimum heap reservation  — malloc forbidden (DO-178C)
 * ---------------------------------------------------------------------------- */
_estack         = ORIGIN(RAM) + LENGTH(RAM);  /* 0x24080000                  */
_Min_Stack_Size = 0x1000;                     /* 4KB                         */
_Min_Heap_Size  = 0x800;                      /* 2KB                         */

/* ----------------------------------------------------------------------------
 * MEMORY — physical memory regions
 * Source : RM0433 Rev8 §2.3 — Memory map
 *
 * FLASH : 2MB  @ 0x08000000 — rx  (read, execute)
 * RAM   : 512KB @ 0x24000000 — xrw (execute, read, write) — AXI SRAM
 * ---------------------------------------------------------------------------- */
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 2048K
    RAM   (xrw) : ORIGIN = 0x24000000, LENGTH = 512K
}

/* ----------------------------------------------------------------------------
 * SECTIONS — section placement in memory
 * ---------------------------------------------------------------------------- */
SECTIONS
{
    /* .isr_vector : interrupt vector table
     * Must be first in Flash at 0x08000000 — read by CPU on reset
     * KEEP prevents linker from discarding it as unused                       */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >FLASH

    /* .text : executable code
     * All compiled C and assembly instructions                                */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.glue_7)                  /* ARM-to-Thumb interworking glue          */
        *(.glue_7t)                 /* Thumb-to-ARM interworking glue          */
        *(.eh_frame)
        KEEP(*(.init))
        KEEP(*(.fini))
        . = ALIGN(4);
        _etext = .;                 /* end of code in Flash                    */
    } >FLASH

    /* .rodata : read-only data (constants, lookup tables, string literals)    */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } >FLASH

    /* .ARM : exception handling tables — required by some libc functions      */
    .ARM.extab :
    {
        . = ALIGN(4);
        *(.ARM.extab* .gnu.linkonce.armextab.*)
        . = ALIGN(4);
    } >FLASH

    .ARM :
    {
        . = ALIGN(4);
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
        . = ALIGN(4);
    } >FLASH

    /* Source address of .data image in Flash
     * Reset_Handler reads from here to copy .data to RAM                      */
    _sidata = LOADADDR(.data);

    /* .data : initialized variables
     * Stored in Flash (LMA), copied to RAM at boot by Reset_Handler
     * int x = 5  →  value 5 stored in Flash, variable lives in RAM           */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;                 /* start of .data in RAM                   */
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;                 /* end of .data in RAM                     */
    } >RAM AT> FLASH

    /* .bss : zero-initialized variables
     * No Flash image — Reset_Handler writes 0 from _sbss to _ebss
     * int flag;  →  reserved in RAM, zeroed at boot                           */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;                  /* start of .bss in RAM                    */
        __bss_start__ = _sbss;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;                  /* end of .bss in RAM                      */
        __bss_end__ = _ebss;
    } >RAM

    /* Heap and stack size check
     * Build-time verification — linker error if RAM is insufficient           */
    ._user_heap_stack :
    {
        . = ALIGN(8);
        PROVIDE(end = .);
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        . = ALIGN(8);
    } >RAM

    /* Discard unused library sections to reduce Flash usage                   */
    /DISCARD/ :
    {
        libc.a   (*)
        libm.a   (*)
        libgcc.a (*)
    }
}