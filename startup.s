/* Startup code for Cortex-M3 (compatible with lm3s6965evb) */

/* Define syntax */
    .syntax unified /* Use modern unified ARM/Thumb syntax */
    .arch armv7-m   /* Target architecture (Cortex-M3 is ARMv7-M) */
    .thumb          /* Use Thumb instruction set */

/* Global symbols */
    .global Reset_Handler
    .global Default_Handler

/* Linker script symbols (defined in linker.ld) */
    .extern _sidata    /* Start address of initialized data in FLASH */
    .extern _sdata     /* Start address of initialized data in SRAM */
    .extern _edata     /* End address of initialized data in SRAM */
    .extern _sbss      /* Start address of BSS section in SRAM */
    .extern _ebss      /* End address of BSS section in SRAM */
    .extern _STACK_TOP /* Top address of the stack (highest address + 1) */
    .extern main       /* Entry point of our C code */

/* Vector Table */
    .section .isr_vector, "a", %progbits /* Place in .isr_vector section */
    .type isr_vector, %object
    .size isr_vector, . - isr_vector

isr_vector:
    .word _STACK_TOP      /* 0: Initial Stack Pointer */
    .word Reset_Handler   /* 1: Reset Handler */
    .word Default_Handler /* 2: NMI Handler */
    .word Default_Handler /* 3: HardFault Handler */
    .word Default_Handler /* 4: MemManage Handler */
    .word Default_Handler /* 5: BusFault Handler */
    .word Default_Handler /* 6: UsageFault Handler */
    .word 0               /* 7: Reserved */
    .word 0               /* 8: Reserved */
    .word 0               /* 9: Reserved */
    .word 0               /* 10: Reserved */
    .word Default_Handler /* 11: SVCall Handler */
    .word Default_Handler /* 12: Debug Monitor Handler */
    .word 0               /* 13: Reserved */
    .word Default_Handler /* 14: PendSV Handler */
    .word Default_Handler /* 15: SysTick Handler */
    /* Add more Default_Handler entries here for device-specific interrupts if needed */

/* Reset Handler: Executed on processor reset */
    .section .text.Reset_Handler, "ax", %progbits
    .type Reset_Handler, %function
Reset_Handler:
    /* Disable interrupts globally */
    cpsid i

    /* --- Initialize Data Section --- */
    /* Copy .data section from FLASH to SRAM */
    ldr r0, =_sidata  /* r0 = address of .data section in FLASH */
    ldr r1, =_sdata   /* r1 = address of .data section in SRAM */
    ldr r2, =_edata   /* r2 = end address of .data section in SRAM */
copy_data_loop:
    cmp r1, r2        /* Compare current SRAM address (r1) with end address (r2) */
    bhs copy_data_end /* Branch if r1 >= r2 (copy finished) */
    ldr r3, [r0], #4  /* Load word from FLASH address (r0), post-increment r0 */
    str r3, [r1], #4  /* Store word to SRAM address (r1), post-increment r1 */
    b copy_data_loop  /* Loop back */
copy_data_end:

    /* --- Initialize BSS Section --- */
    /* Zero out the .bss section in SRAM */
    ldr r0, =_sbss    /* r0 = start address of .bss section in SRAM */
    ldr r1, =_ebss    /* r1 = end address of .bss section in SRAM */
    movs r2, #0       /* r2 = 0 */
zero_bss_loop:
    cmp r0, r1        /* Compare current BSS address (r0) with end address (r1) */
    bhs zero_bss_end  /* Branch if r0 >= r1 (zeroing finished) */
    str r2, [r0], #4  /* Store zero (r2) to SRAM address (r0), post-increment r0 */
    b zero_bss_loop   /* Loop back */
zero_bss_end:

    /* Optional: Call SystemInit() from CMSIS if you were using it */
    /* bl SystemInit */

    /* Enable interrupts globally (optional here, might do later in main) */
    /* cpsie i */

    /* Branch to the C main function */
    bl main

    /* Should never return from main in a bare-metal system */
loop_forever:
    b loop_forever

    .size Reset_Handler, . - Reset_Handler

/* Default Handler: Used for unhandled interrupts/exceptions */
    .section .text.Default_Handler, "ax", %progbits
    .type Default_Handler, %function
Default_Handler:
    /* Simple infinite loop */
    b .
    .size Default_Handler, . - Default_Handler
