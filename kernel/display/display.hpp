#pragma once

#include "../data/datatypes.hpp"

#define CRTC_ADDRESS_PORT 	0x3D4
#define CRTC_DATA_PORT		0x3D5

namespace display {
enum COLOUR : char {BLACK, BLUE, GREEN, CYAN, RED};

class Display {
	private:
	char *buffer;
	COLOUR colour;
	
	void PrintS(char *string);
	void PrintC(char character);
	void PrintI(int number);
	void PrintU(unsigned int number);

	void MoveBufferNextLine(void);
	void UpdateCursor(void);

	void ResetBuffer(void);

	public:
	Display(COLOUR colour);

	void PrintF(char *string, ...);
	void Clear(void);

	void DisableCursor(void);
	void EnableCursor(Byte cursorStart, Byte cursorEnd);

	void SetColour(COLOUR colour);

	COLOUR GetColour(void);
};
}
