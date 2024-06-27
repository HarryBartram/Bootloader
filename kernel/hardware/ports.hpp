#pragma once

#include "../data/datatypes.hpp"

namespace hardware {
	enum Port : unsigned short {NOPORT = 0x00};

	inline void OutByte(Port port, Byte data) { asm("outb %%al, %%dx" : : "d"(port), "a"(data)); }
	inline Byte InByte(Port port) { asm("inb %%dx, %%al" : : "d"(port)); }
};
