#pragma once

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
	void MoveCursor(void);

	void ResetBuffer(void);

	public:
	Display(COLOUR colour);

	void PrintF(char *string, ...);
	void Clear(void);

	void SetColour(COLOUR colour);

	COLOUR GetColour(void);
};
}
