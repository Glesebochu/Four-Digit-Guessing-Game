#include <iostream>
#include <iomanip>
using namespace std;

extern "C" {
    extern char row_val;
}

int main() {
    int col_width (10);
    char special_char = '-';


    int rows = static_cast<int>(row_val);
    //the guesses, N and P array will have to be sent in a similar manner.

    //number of rows can also alternatively be calculated by counting either of the guesses or N or P array.
    cout << "Number of rows: " << rows << std::endl;


    //For displaying all accumulated guesses, N & P
        cout << left;
        //Divider line
        cout << setfill(special_char) << setw(3*col_width) << special_char << endl;
        //Title row 
        cout << setfill(' ');
        cout << setw(col_width) << "Guesses";
        cout << setw(col_width) << "N";
        cout << setw(col_width) << "P";
        cout << endl;
        //Divider line
        cout << setfill(special_char) << setw(3*col_width) << special_char << endl;


     for (int i = 0; i <= rows; i++){
            cout << " | ";
            cout << setw(col_width) << guesses[i];
            cout << " | ";
            cout << setw(col_width) << N[i];
            cout << " | ";
            cout << setw(col_width) << P[i];
            cout << endl;
        }


    return 0;
}
