#include <iostream>
#include <windows.h>
#include <bitset>

using namespace std;

bool debug = true;
#define M 2
#define S "Hamming Code"

enum console_color_t {
	WHITE = 15, GREEN = 10, RED = 4
};

void printDataBlock(const string &s, int m);

int main() {

	int m;
	string s;
	if (!debug)cin >> m;
	else m = M;
	fflush(stdin);
	if (!debug)getline(cin, s);
	else s = S;
	while (s.length() % m != 0) s.append("~");
	cout << "data string after padding: " << s << endl;
	printDataBlock(s, m);
	for (int i = 0; i < 16; ++i) {
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), i);
//		std::cout << "i" << std::endl;
//		printf("%3d\n", i);
	}
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WHITE);
	return 0;
}

void printDataBlock(const string &s, int m) {
	for (int i = 0; i < s.length();) {
//		cout << s[i];
		cout << bitset<8>((unsigned long long int) s[i]);
		if (++i % m == 0) cout << endl;
	}
}

