/**
 * @file main.c
 * @brief S32K566 Hello World App
 *
 * Prints "Hello World!" every 1 second via UART.
 * Built for Zephyr OS, targets S32K5XXCVB board.
 */

#include <zephyr/kernel.h>

/* Sleep duration: 1 second */
#define SLEEP_MS 1000

void main(void)
{
	printk("S32K566 Hello World App started!\n");
	printk("Board: %s\n", CONFIG_BOARD);
	printk("Build time: %s %s\n\n", __DATE__, __TIME__);

	uint32_t count = 0;
	while (1) {
		printk("Hello World! - count: %u\n", ++count);
		k_msleep(SLEEP_MS);
	}
}
