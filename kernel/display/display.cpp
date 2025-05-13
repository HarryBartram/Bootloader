#include "display.hpp"
#include "../hardware/ports.hpp"

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

void Display::UpdateCursor(void)
{
	Word pos = reinterpret_cast<Word>(buffer-0xB8000)/2;

	hardware::OutByte(CRTC_ADDRESS_PORT, 0x0F);
	hardware::OutByte(CRTC_DATA_PORT, (pos & 0xFF));
	hardware::OutByte(CRTC_ADDRESS_PORT, 0x0E);
	hardware::OutByte(CRTC_DATA_PORT, ((pos >> 8) & 0xFF));
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

	this->UpdateCursor();
}

void Display::DisableCursor()
{
	hardware::OutByte(CRTC_ADDRESS_PORT, 0x0A);
	hardware::OutByte(CRTC_DATA_PORT, 0x20);
}

void Display::EnableCursor(Byte cursorStart, Byte cursorEnd)
{
	hardware::OutByte(CRTC_ADDRESS_PORT, 0x0A);
	hardware::OutByte(CRTC_DATA_PORT, (hardware::InByte(CRTC_DATA_PORT) & 0xC0) | cursorStart);

	hardware::OutByte(CRTC_ADDRESS_PORT, 0x0B);
	hardware::OutByte(CRTC_DATA_PORT, (hardware::InByte(CRTC_DATA_PORT) & 0xE0) | cursorEnd);
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
