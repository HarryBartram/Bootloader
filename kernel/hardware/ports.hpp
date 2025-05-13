#pragma once

#include "../data/datatypes.hpp"

namespace hardware {
	inline void OutByte(Word port, Byte data) { asm("outb %%al, %%dx" : : "d"(port), "a"(data)); }
	inline Byte InByte(Word port) { Byte data; asm("inb %%dx, %%al" : "=d"(data) : "d"(port)); return data; }
};
