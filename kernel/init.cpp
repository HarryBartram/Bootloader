#include "display/display.hpp"
#include "data/datatypes.hpp"
#include "hardware/ports.hpp"

void kmain()
{
	char *str = "Entered Protected Mode: %i!";
	int number = -123456;

	display::Display d(display::COLOUR::GREEN);

	d.Clear();
	d.PrintF(str, number);
}