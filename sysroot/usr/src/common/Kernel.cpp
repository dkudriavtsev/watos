#include <stddef.h>
#include <stdint.h>

#include "drivers/Console.h"
#include "common/kstdlib.h"
#include "common/cpu.h"

using namespace Devices;

extern "C" /* Use C linkage for kernel_main. */
[[noreturn]] void kernel_main(void) {
	Console console;
	console.set_color((uint8_t) 0x0F);
	console.write("[", 1);
	console.set_color((uint8_t) 0x02);
	console.write("INFO", 4);
	console.set_color((uint8_t) 0x0F);
	console.writestring("] Initialized early console\n");

	char* cpuid = get_cpuid();

	char* test = (char*) malloc(13);
	memcpy(test, cpuid, 12);
	test[12] = '\0';

	console.writestring("Hello, world!\n");
	console.write(test, 12);

	while(true);
}

extern "C"
void not_multiboot(void) {
	Console console;
	console.set_color(VGA_COLOR_RED);
	console.writestring("Error: ");
	console.set_color(VGA_COLOR_LIGHT_GREY);
	console.writestring("Kernel was booted with a non-Multiboot bootloader.\n");
	console.writestring("Please boot with a compatible loader, such as GRUB.\n");
	while(true);
}
