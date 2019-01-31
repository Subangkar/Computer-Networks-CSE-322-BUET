#include <iostream>
#include <windows.h>
#include <bitset>
#include <ctime>

#include "HammingUtils.h"
#include "CRCUtils.h"

using namespace std;

bool debug = true;
#define M 1
#define S "a"//"Hamming Code"
#define P 0.1

enum console_color_t {
	WHITE = 15, GREEN = 10, RED = 4, CYAN = 11
};

void setConsoleColor(int color = WHITE) {
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), static_cast<WORD>(color));
}

void printDataBlock(const string &s, int m);

void printHammingCodedColoredString(const string &s);

string convertToBinaryString(const string &s);

string convertFromBinaryString(const string &s);

string serializeColmWise(const string &s, int nChars_per_row);

string deserializeColmWise(const string &s, int nChars_per_row);

string corruptDataBlockAndPrint(const string &s, double corruptionFactor = 0.0);

/// returns a random value between [0,1]
double randomFactor();

int main() {
	int m = M;
	string s = S;
	cout << "Enter #data_bytes in a row (m): ";
	if (!debug)cin >> m;
	else cout << m << endl;
	fflush(stdin);
	cout << "Enter data string: ";
	if (!debug)getline(cin, s);
	else cout << s << endl;
	while (s.length() % m != 0) s.append("~");
	m *= 8;
	cout << "Data string after padding: \"" << s << "\" (" << s.length() << ")" << endl;
	cout << endl;

	int r = nhamming_redundant_bits(m);// from HammingUtils.h
	string binaryDataBlock = convertToBinaryString(s);
	string hammingDataBlock = convertToHammingPaddedDataBlock(binaryDataBlock, m);
	string serializeColmWiseDataBits = serializeColmWise(hammingDataBlock, m + r);

	cout << "Data block:" << " (" << binaryDataBlock.length() << ")" << endl;
	printDataBlock(binaryDataBlock, m);
	cout << endl;

	cout << "Data block after adding check bits:" << " (" << hammingDataBlock.length() << ")" << endl;
	printHammingCodedDataBlock(hammingDataBlock, m);
	cout << endl;

	cout << "Data bits after column-wise serialization:" << " (" << serializeColmWiseDataBits.length() << ")" << endl;
	cout << serializeColmWiseDataBits << endl;

	cout << "Data bits after corruption:" << endl;
	string corruptedSerialBlock = corruptDataBlockAndPrint(serializeColmWiseDataBits, P);
	string corruptHammingDataBlock = deserializeColmWise(corruptedSerialBlock, m + r);
	string correctedDataBlock = convertFromHammingPaddedDataBlock(corruptHammingDataBlock, m);
	string correctedDataString = convertFromBinaryString(correctedDataBlock);

	cout << "Data bits after deserialization:" << " (" << corruptHammingDataBlock.length() << ")" << endl;
	printHammingCodedDataBlock(corruptHammingDataBlock, m);

	cout << "Data block after removing check bits:" << " (" << correctedDataBlock.length() << ")" << endl;
	printDataBlock(correctedDataBlock, m);
	cout << endl;


//	printDataBlock(convertFromHammingPaddedDataBlock(hammingDataBlock, m), m);
//	if (hammingDataBlock != deserializeColmWise(serializeColmWiseDataBits, m + r))cerr << "NOT SAME" << endl;
//	if (binaryDataBlock != convertFromHammingPaddedDataBlock(hammingDataBlock, m))cerr << "error" << endl;

//	cout << corr
	cout << "Recoverd data string: " << correctedDataString << endl;
	return 0;
}

string convertToBinaryString(const string &s) {
	string binStr;
	for (const auto &c:s) {
		binStr += (bitset<8>(static_cast<unsigned long long int>(c))).to_string();
	}
	return binStr;
}

string convertFromBinaryString(const string &s) {
	string asciiStr;
	for (int i = 0; i * 8 < s.length(); ++i) {
		asciiStr += (char) bitset<8>(string(s, i * 8, 8)).to_ullong();
	}
	return asciiStr;
}

void printHammingCodedColoredString(const string &s) {
	for (int pos = 1; pos <= s.length(); ++pos) {
		if (isPowerOf_2(pos)) {
			setConsoleColor(GREEN);
		}
		cout << s[pos - 1];
		setConsoleColor(WHITE);
	}
	setConsoleColor(WHITE);
	cout << endl;
}

void printDataBlock(const string &s, int m) {
	for (int i = 0; i < s.length();) {
		cout << s[i];
		if (++i % (m) == 0) cout << endl;
	}
}

double randomFactor() {
	static bool isSeeded = false;
	if (!isSeeded) isSeeded = true, srand(time(nullptr));
	double fact = rand();
	return fact / RAND_MAX;
}

string serializeColmWise(const string &s, int nChars_per_row) {
	string serialStr;
	int nChars_per_colm = s.length() / nChars_per_row;
	for (int c = 0; c < nChars_per_row; ++c) {
		for (int r = 0; r < nChars_per_colm; ++r) {
			serialStr += s[r * nChars_per_row + c];
		}
	}
	return serialStr;
}

string deserializeColmWise(const string &s, int nChars_per_row) {
	string origStr;
	int nChars_per_colm = s.length() / nChars_per_row;
	for (int r = 0; r < nChars_per_row; ++r) {
		for (int c = 0; c < nChars_per_colm; ++c) {
			origStr += s[c * nChars_per_colm + r];
		}
	}
	return origStr;
}

string corruptDataBlockAndPrint(const string &s, double corruptionFactor) {
	string corrupted = s;
	for (auto &c:corrupted) {
		if (randomFactor() < corruptionFactor) {
			c = !(c - '0') + '0';
			setConsoleColor(RED);
		}
		cout << c;
		setConsoleColor(WHITE);
	}
	cout << endl;
	return corrupted;
}



