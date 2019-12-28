---
title: Getting started with the STM32F4 and FreeRTOS
date: 2019-12-27
---

In this post, I'll simply share a few observations on setting up a FreeRTOS
project for the STM32F4 Discovery board. This guide is based on the
[berfr/stm32f4discovery](https://git.sr.ht/~berfr/stm32f4discovery) repository
which is fully configured and ready to use. The specific commands mentioned in
this post are noted in the `README` or the `CMakeLists` files of the project.

## Hardware

The STM32F4 Discovery board has the following core components:

- STM32F407VGT6 Microcontroller
    - 32-bit ARM Corex-M4 with FPU Core
        - ARMv7E-M Architecture
        - Thumb-1, Thumb-2, DSP, FPU (Single Precision) instruction sets
        - Single Precision FPU: fpv4-sp-d16
    - 16 MHz High Speed Internal (HSI) RC Oscillator
- ST-LINK/V2 used for programming and debugging
- 8 MHz High Speed External (HSE) Oscillator

## Clock configuration

On start up, the 16 MHz internal oscillator is selected as CPU clock. Through
software, we can select to use an external oscillator as clock source. This
clock source is fed to a phase lock loop (PLL) which can increase the frequency
up to 168 MHz. The clock is set up using the `SystemCoreClockUpdate` function
from the `system_stm32f4xx.c` file. By default, for this MCU, the clock speed is
configured using the HSE and PLL to output 168 MHz. However, the default HSE
value is 25 MHz and so we need to modify it to 8 MHz. The `PLL_M` is also
modified from 25 to 8. The calculation for the `SYSCLK` value is as follows:

```
SYSCLK = ((HSE_VALUE / PLL_M) * PLL_N) / PLL_P
SYSCLK = ((8000000 / 8) * 336) / 2
SYSCLK = 168000000 = 168 MHz
```

One of the reasons that an external oscillator is available and used is that
having the high speed signal outside of the MCU reduces the noise inside it.
Once the signal is in, it can be scaled up easily with a simple PLL circuit.
Also, this setup for setting the clock speed is simple enough that it can be
called to configure a lower clock speed whenever needed to reduce energy
consumption. Once set up, the `SystemCoreClock` variable can be used throughout
the code to know what the clock speed is. It is important to remember that if
the value of `HSE_VALUE` does not reflect the real on board hardware, the value
of `SystemCoreClock` will not be the correct MCU frequency.

## Startup sequence

The startup sequence of the MCU depends on the configuration of the boot pins.
On the Discovery board, BOOT0 is set to low. According to the boot modes table
in the reference manual, whenever BOOT0 is set to low, the main flash memory is
selected as the memory location to boot from. This memory location is
`0x8000000`. It is possible to find this both in the memory organization in the
reference manual and the linker script included in the reference project.
Another observation is that the linker script places the Interrupt Vector Table
at the beginning of the flash address space. This vector table is located in the
assembly startup code file:

```assembly
g_pfnVectors:
  .word  _estack
  .word  Reset_Handler
  .word  NMI_Handler
...
```

It is possible to see this table is in accordance to the vector table found in
the reference manual. So the routine which is called on reset is `Reset_Handler`
which is also found in the assembly startup code. This method, initializes
memory, calls `SystemInit`, `__libc_init_array` and finally `main`.

## Firmware size

In order to reduce the firmware size for the MCU, it is necessary to pass the
`-fdata-sections -ffunction-sections` options to the compiler as well as the
`--gc-sections` to the linker. These flags will strip out the unused data and
functions from the output binary. It is possible to see the size difference with
the `size` command.

```console
# Here is the output size with the unused code removed:
$ arm-none-eabi-size main.elf
 text    data     bss     dec     hex filename
11524    1104   78800   91428   16524 main.elf

# Here it is without unused code stripped:
$ arm-none-eabi-size main.elf
 text    data     bss     dec     hex filename
92584    1152   78804  172540   2a1fc main.elf

# That is an 88% or 81 KB size decrease with the flags.
```

# FreeRTOS time slicing

In the reference project, two tasks with the same priority are started and it is
the responsibility of the real time kernel to run them both concurrently. It
does so by switching back and forth between each task at a rate of
`configTICK_RATE_HZ` which is defined in `FreeRTOSConfig.h`. The default value
is 1000 Hz which does not seem high since our MCU is running at 168 MHz.
However, it is important to know that this context switching between tasks is
not free. Also, by using delay functions such as `vTaskDelay`, a task can hand
over its time to another task depending on the context. By using different
priority levels in different tasks, it is possible to put more importance on
certain tasks according to the application needs.

# Chip programming and debugging

The [texane/stlink](https://github.com/texane/stlink) project offers convenient
tools to program and debug the MCU. For programming, it is necessary to create a
binary file from the output `elf` file using `arm-none-eabi-objcopy`. This
process strips out the "starting" address of `0x8000000` but it is specified in
the `st-flash` command parameters so that the resulting binary is placed at the
correct address. To debug, the `st-util` command is used. It starts a `gdb`
server which can be connected to using `arm-none-eabi-gdb` and the created `elf`
file. This `elf` file contains the necessary symbols to ease the debugging
process. Standard `gdb` commands can then be used to step through code and
observe CPU registers.

# Future investigations

In future posts, I would like to investigate further the following aspects:

- CPU DSP instructions
- FreeRTOS memory management
- FreeRTOS task communication and synchronization
- Various on-board devices
- Firmware programming in Rust
- Firmware programming in Golang
