/* Linker script for the Stellaris LM3S6965EVB (256K Flash, 64K SRAM (doesn't need refresh like DRAM, faster, lower power) (64 * 1024 bytes = 65,536 bytes)) */
/* Adapted for QEMU's lm3s6965evb model */

/* Define Memory Regions */
MEMORY
{
  FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 256K /* Read, Execute */
  SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 64K  /* Read, Write, Execute */
}

/* Define Symbols */
ENTRY(Reset_Handler) /* Entry point is the Reset_Handler function */

/* Define stack size and location */
_STACK_SIZE = 0x400; /* 1KB stack */
_STACK_TOP = ORIGIN(SRAM) + LENGTH(SRAM); /* Stack grows down from top of SRAM */

/* Define Sections */
SECTIONS
{
    /* Vector table: MUST be at the beginning of FLASH */
    .isr_vector : ALIGN(4)
    {
        KEEP(*(.isr_vector)) /* Keep the vector table section */
    } > FLASH /* Place in FLASH */

    /* Code section */
    .text : ALIGN(4)
    {
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections */
        *(.rodata)         /* .rodata sections (constants) */
        *(.rodata*)        /* .rodata* sections */
        . = ALIGN(4);
        _etext = .;        /* Symbol marking end of code/read-only data */
    } > FLASH /* Place in FLASH */

    /* Initialized data section */
    /* Stored in FLASH, loaded into SRAM at startup */
    .data : ALIGN(4)
    {
        _sdata = .;        /* Start of initialized data in SRAM */
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */
        . = ALIGN(4);
        _edata = .;        /* End of initialized data in SRAM */
    } > SRAM AT > FLASH /* Place in SRAM, Load Address (AT) in FLASH after .text */

    _sidata = LOADADDR(.data); /* Start address of initialized data in FLASH */

    /* Uninitialized data section (BSS) */
    .bss : ALIGN(4)
    {
        _sbss = .;         /* Start of .bss section in SRAM */
        *(.bss)            /* .bss sections */
        *(.bss*)           /* .bss* sections */
        *(COMMON)          /* COMMON symbols */
        . = ALIGN(4);
        _ebss = .;         /* End of .bss section in SRAM */
    } > SRAM /* Place in SRAM */

    /* Ensure stack space is reserved (optional, but good practice) */
    ._user_heap_stack (NOLOAD) : ALIGN(8)
    {
        . = ALIGN(8);
        PROVIDE ( end = . ); /* Symbol 'end' marks end of used SRAM (before stack) */
        PROVIDE ( _end = . );
        . = . + _STACK_SIZE; /* Reserve stack space */
         . = ALIGN(8);
       _stack_bottom = .; /* Symbol for bottom of stack space (lowest address) */
    } > SRAM

    /* Discard unused sections */
    /DISCARD/ :
    {
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }

    .ARM.attributes 0 : { *(.ARM.attributes) }
}