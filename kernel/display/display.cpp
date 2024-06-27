#include "display.hpp"

#include <stdarg.h>

using namespace display;

Display::Display(COLOUR colour) : buffer{reinterpret_cast<char*>(0xB8000)}
{
	this->colour = colour;
}

//////////////////////////////////////////////////////////////////
/*			Private					*/
//////////////////////////////////////////////////////////////////

void Display::PrintS(char *string)
{
        while (*string != '\0') {
                *buffer = *string;
                *(buffer+1) = colour;

                buffer += 2;
                string++;
        }
}

void Display::PrintC(char character)
{
	*(buffer++) = character;
	*(buffer++) = colour;
}

void Display::PrintI(int number)
{
	if (number < 1) {
		number = -number;
		this->PrintC('-');
	}

	this->PrintU(static_cast<unsigned int>(number));

}

void Display::PrintU(unsigned int number)
{
	unsigned int divisor{10};
	while ((number / divisor) >= 10)
		divisor *= 10;

	for (; divisor != 1; divisor /= 10)
		this->PrintC('0' + ((number / divisor) % 10));
	this->PrintC('0' + (number % 10));
}

void Display::MoveBufferNextLine(void)
{

}

void Display::MoveCursor(void)
{

}

void Display::ResetBuffer(void)
{
	this->buffer = reinterpret_cast<char*>(0xB8000);
}

//////////////////////////////////////////////////////////////////
/*			Public					*/
//////////////////////////////////////////////////////////////////

void Display::Clear(void)
{
	this->ResetBuffer();
	for (int i = 0; i < 2000; i++) {
		this->PrintC(' ');	
	}
	this->ResetBuffer();
}

void Display::PrintF(char *string, ...)
{
	va_list args;
	va_start(args, string);

	while (*string != '\0') {
		if (*(string++) != '%')
			this->PrintC(*(string-1));
		else {
			char type = *(string++);

			switch (type) {
				case 'i':
					this->PrintI(va_arg(args, int));
					break;
				case 'u':
					this->PrintU(va_arg(args, unsigned int));
					break;
				case 's':
					this->PrintS(va_arg(args, char *));
					break;
				default:
					this->PrintS("Invalid Type In PrintF: ");
					this->PrintC(type);
			}
		}
	}
}

//////////////////////////////////////////////////////////////////
/*			Getters/Setters				*/
//////////////////////////////////////////////////////////////////

void Display::SetColour(COLOUR colour)
{
	this->colour = colour;
}

COLOUR Display::GetColour(void)
{
	return colour;
}
