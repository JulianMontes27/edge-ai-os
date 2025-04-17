#include <stdint.h> // Optional for basic types, good practice

/* The entry point for your C code, called by startup.s. For this minimal example, it does nothing but loop forever, representing the idle state of the system before any tasks or interrupts are configured. */

// To verify your OS is working by seeing some actual output, you'd need to implement UART/serial communication. For the LM3S6965EVB board that you're emulating, you could add code to write to the UART registers.
#define UART0_BASE 0x4000C000
#define UART0_DR (*((volatile uint32_t *)(UART0_BASE + 0x000)))
#define UART0_FR (*((volatile uint32_t *)(UART0_BASE + 0x018)))
#define UART0_FR_TXFF 0x20 // UART Transmit FIFO Full

// Simple function to send a character to UART0
void uart_putc(char c)
{
    // Wait until there's space in the FIFO
    while (UART0_FR & UART0_FR_TXFF)
        ;
    // Write the character to the data register
    UART0_DR = c;
};

// Function to send a string
void uart_puts(const char *str)
{
    while (*str)
    {
        uart_putc(*str++);
    };
};

int main(void)
{
    // Send a "Hello World" message to the UART
    uart_puts("Hello from my OS!\r\n");

    // Your OS initialization code would go here later.
    // For now, just loop forever.
    while (1)
    {
        // Prevent loop from being optimized away
        volatile int i = 0;
        (void)i; // Use i to prevent unused variable warning
    }

    // This should never be reached in a bare-metal system
    return 0;
}