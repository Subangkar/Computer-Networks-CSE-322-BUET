#include <iostream>
#include <windows.h>
#include <bitset>
#include <vector>
#include <ctime>

using namespace std;

bool debug = true;
#define M 2
#define S "Computer Networks"//"Hamming Code"
#define P 0.1

enum console_color_t {
	WHITE = 15, GREEN = 10, RED = 4, CYAN = 11
};

void setConsoleColor(int color = WHITE) {
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), static_cast<WORD>(color));
}

void printDataBlock(const string &s, int m);

void printHammingCodedColoredString(const string &s);

void printHammingCodedDataBlock(const string &s, int m);

string convertToBinaryString(const string &s);

string convertFromBinaryString(const string &s);

string convertToHammingPaddedDataBlock(const string &s, int m);

string convertFromHammingPaddedDataBlock(const string &s, int m);

int nhamming_redundant_bits(int m);

string computeHammingString(const string &s, int r);

string hammingPaddedString(const string &s, int m);

string hammingUnPaddedString(const string &s);

char hammingEvenParity(const string &s, int rpos);

char hammingOddParity(const string &s, int rpos);

string appendChecksumCRC(const string &s);

string serializeColmWise(const string &s, int nChars_per_row);

string corruptDataBlockAndPrint(const string &s, double corruptionFactor = 0.0);

/// returns a random value between [0,1]
double randomFactor();

// for positive number only
bool isPowerOf_2(int n) {
	return n > 0 && (n & (n - 1)) == 0;
}

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

	int r = nhamming_redundant_bits(m);
	string binaryDataBlock = convertToBinaryString(s);
	string hammingDataBlock = convertToHammingPaddedDataBlock(binaryDataBlock, m);
	string serializeColmWiseDataBits = serializeColmWise(hammingDataBlock, m + r);

	cout << "Data block:" << " (" << binaryDataBlock.length() << ")" << endl;
	printDataBlock(binaryDataBlock, m);
	cout << endl;

	cout << "Data block after adding check bits:" << " (" << hammingDataBlock.length() << ")" << endl;
	printHammingCodedDataBlock(hammingDataBlock, m);
	cout << endl;

//	cout << "Data bits after column-wise serialization:" << " (" << serializeColmWiseDataBits.length() << ")" << endl;
//	cout << serializeColmWiseDataBits << endl;

	printDataBlock(convertFromHammingPaddedDataBlock(hammingDataBlock, m), m);
//	if (binaryDataBlock != convertFromHammingPaddedDataBlock(hammingDataBlock, m))cerr << "error" << endl;

//	string corruptedSerialBlock = corruptDataBlockAndPrint(serializeColmWiseDataBits, P);

//	cout << "Recoverd data string: " << convertFromBinaryString(binaryDataBlock) << endl;
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

string convertToHammingPaddedDataBlock(const string &s, int m) {
	string hammingBlock;
	int n = s.length() / m;//string is a multiple of m
	for (int i = 0; i < n; ++i) {
		hammingBlock += (hammingPaddedString(string(s, i * m, m), m));
	}
	return hammingBlock;
}

string convertFromHammingPaddedDataBlock(const string &s, int m) {
	string normalBlock;
	int r = nhamming_redundant_bits(m);
	int n = s.length() / m;//string is a multiple of m
	for (int i = 0; i < n; ++i) {
		normalBlock += (hammingUnPaddedString(string(s, i * (m + r), m + r)));
	}
	return normalBlock;
}

void printDataBlock(const string &s, int m) {
	for (int i = 0; i < s.length();) {
		cout << s[i];
		if (++i % (m) == 0) cout << endl;
	}
}

void printHammingCodedDataBlock(const string &s, int m) {
	int r = nhamming_redundant_bits(m);
	for (int i = 0; i * (m + r) < s.length(); ++i) {
		printHammingCodedColoredString(string(s, i * (m + r), m + r));
	}
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

int nhamming_redundant_bits(int m) {
	int r = 0;
	while ((1 << r) < m + r + 1) ++r; // 1<<r == 1*2^r
	return r;
}

string hammingPaddedString(const string &s, int m) {
	int r = nhamming_redundant_bits(m);
	char str[s.length() + r + 1];// +1 for NULL
	memset(str, '\0', s.length() + r + 1);

	/// adding check bits @pos = 2^x
	for (int i = 0, j = 0; i < s.length() + r; ++i) {
		if (isPowerOf_2(i + 1)) str[i] = '0';
		else str[i] = s[j++];
	}

	cout << "-----------" << endl;
	cout << computeHammingString(str, r) << endl << computeHammingString(computeHammingString(str, r), r) << endl;
	cout << "-----------" << endl;
//	/// setting parity @check_bits
//	for (int rpos = 0; rpos < r; ++rpos) {
//		str[(1 << rpos) - 1] = hammingOddParity(str, rpos);
//	}
	return computeHammingString(str, r);
}

string hammingUnPaddedString(const string &s) {
	string str;
	/// deleting check bits @pos = 2^x
	for (int i = 0; i < s.length(); ++i) {
		if (!isPowerOf_2(i + 1)) str += s[i];
	}
	return str;
}

char hammingEvenParity(const string &s, int rpos) {
	int n1s = 0;
	for (int pos = 1; pos <= s.length(); ++pos) {
		if ((pos & (1 << rpos)) && s[pos - 1] == '1') ++n1s;
	}
//	cout << (rpos + 1) << " >> " << n1s << " <" << endl;
	return !(n1s % 2) + '0';
}

char hammingOddParity(const string &s, int rpos) {
	return hammingEvenParity(s, rpos) == '1' ? '0' : '1';
}

double randomFactor() {
	static bool isSeeded = false;
	if (!isSeeded) isSeeded = true, srand(time(nullptr));
	double fact = rand();
	return fact / RAND_MAX;
}

string serializeColmWise(const string &s, int nChars_per_row) {
	string serialStr;
	int n = s.length() / nChars_per_row;
	for (int c = 0; c < nChars_per_row; ++c) {
		for (int r = 0; r < n; ++r) {
			serialStr += s[r * nChars_per_row + c];
		}
	}
	return serialStr;
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

string computeHammingString(const string &s, int r) {
	string str = s;
	/// setting parity @check_bits
	for (int rpos = 0; rpos < r; ++rpos) {
		str[(1 << rpos) - 1] = hammingOddParity(str, rpos);
	}
	return str;
}


