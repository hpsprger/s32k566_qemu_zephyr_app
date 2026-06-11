/**
 * @file main.c
 * @brief S32K566 Hello World App
 *
 * Prints "Hello World!" every 1 second via UART.
 * Built for Zephyr OS, runs on QEMU s32k566 emulation.
 */

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/uart.h>

/* Sleep duration: 1 second */
#define SLEEP_MS 1000

void main(void)
{
	const struct device *uart_dev = DEVICE_DT_GET(DT_CHOSEN(zephyr_console));

	if (!device_is_ready(uart_dev)) {
		printk("UART device not ready!\n");
		return;
	}

	printk("S32K566 Hello World App started!\n");
	printk("Board: %s\n", CONFIG_BOARD);
	printk("Build time: %s %s\n\n", __DATE__, __TIME__);

	uint32_t count = 0;
	while (1) {
		printk("Hello World! - count: %u\n", ++count);
		k_msleep(SLEEP_MS);
	}
}
