#include <iostream>
#include <windows.h>
#include <bitset>
#include <vector>
#include <ctime>

using namespace std;

bool debug = true;
#define M 2
#define S "Computer Networks"//"Hamming Code"

enum console_color_t {
	WHITE = 15, GREEN = 10, RED = 4, CYAN = 11
};

void setConsoleColor(int color = WHITE) {
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), static_cast<WORD>(color));
}

void printDataBlock(const string &s, int m);

void printHammingCodedColoredString(const string &s);

void printHammingCodedDataString(const string &s, int m);

string convertToBinaryString(const string &s);

int nhamming_redundant_bits(int m);

string hammingPaddedString(const string &s, int m);

char hammingEvenParity(const string &s, int rpos);

char hammingOddParity(const string &s, int rpos);

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
	m = 8 * m;
	cout << "Data string after padding: \"" << s << "\" (" << s.length() << ")" << endl;
	cout << endl;

	cout << "Data block:" << endl;
	printDataBlock(convertToBinaryString(s), m);
	cout << endl;

	cout << "Data block after adding check bits:" << endl;
	printHammingCodedDataString(convertToBinaryString(s), m);
	cout << endl;

	return 0;
}

string convertToBinaryString(const string &s) {
	string binStr;
	for (const auto &c:s) {
		binStr += (bitset<8>(static_cast<unsigned long long int>(c))).to_string();
	}
	return binStr;
}

void printDataBlock(const string &s, int m) {
	for (int i = 0; i < s.length();) {
		cout << s[i];
		if (++i % (m) == 0) cout << endl;
	}
}

int nhamming_redundant_bits(int m) {
	int r = 0;
	while ((1 << r) < m + r + 1) ++r; // 1<<r == 1*2^r
	return r;
}

double randomFactor() {
	static bool isSeeded = false;
	if (!isSeeded) isSeeded = true, srand(time(nullptr));
	double fact = rand();
	return fact / RAND_MAX;
}

void printHammingCodedDataString(const string &s, int m) {
	int n = s.length() / m;
	for (int i = 0; i < n; ++i) {
		printHammingCodedColoredString(hammingPaddedString(string(s, i * m, m), m));
	}
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

	/// setting parity @check_bits
	for (int rpos = 0; rpos < r; ++rpos) {
		str[(1 << rpos) - 1] = hammingOddParity(str, rpos);
	}
	return std::string(str);
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

