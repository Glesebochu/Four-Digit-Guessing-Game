#include <iostream>
#include <string>
#include <time.h>
#include <iomanip>
#define SIZE 20

using namespace std;

/*
The parts of our program:

Part I - Displaying the rules of the game.

Part II - Validating the user's input.

Part III - Comparing the user's guess with the magic number.

Part IV - Displaying a history of all the user's guesses and their scores.
*/

int main(){
    
    // This is the string we use to store our user's guess history.
    string guesses[SIZE];

    // This the string we use to input our user's guesses.
    string guess_str;

    // This is the string we use to store the generated secret number.
    string magic_str;

    // This is used to store the number of correct digits there are in the user's guess.
    int N[SIZE];

    // This is used to store the number of correct positions of the digits in the user's guess.
    int P[SIZE];

    // This is used to store the number of guesses the user inputs.
    int num_of_guesses(0); 

    // This the width between  the coulums. 
    int col_width (10);

    // This is a boolean variable that tell whether or not the number has been correctly guessed. 
    // Note that it is set to false.
    bool found = false;

    // This is a boolean value that we use to validate the user's guess.
    bool valid_input=true;

    // This is a boolean value that we use to check if the random number genreated is valid. 
    bool valid_magic_no=true;

    //This is the character we use to beautify our table.
    char special_char = '-';
    
    //Generate a valid random number with no repetitions.
    do{
        srand (time(NULL));
        magic_str = to_string(rand() % 9999 + 1000);
        for (int i = 0; i < 3 && valid_magic_no ; i++){

            //Check for repetition.
            for (int j = i+1; j < 4; j++){
                if(magic_str[i] == magic_str[j]){
                    valid_magic_no = false;
                    break;
                }
            }
        }     
    } while (!valid_magic_no);
        
    /*
    ================================================================================================
    Part I - Displaying the rules of the game.
    ================================================================================================
    */
    cout << "Hello! Welcome to our number guessing game!\n\n";
    cout << "You have to guess a four digit number that we will randomly generate. After every attempt, you will see the score.\n\n";
    cout << "Rules of the game: \n\n 1. You cannot repeat digits in your guess. \n 2. Your guess must be exactly 4 digits long.\n";
    
    cout << left;
    //Divider line
    cout << setfill(special_char) << setw(3*col_width) << special_char << endl;
    //title row
    cout << setfill(' ');
    cout << setw(col_width) << "Guesses";
    cout << setw(col_width) << "N";
    cout << setw(col_width) << "P";
    cout << endl;
    //Divider line
    cout << setfill(special_char) << setw(3*col_width) << special_char << endl;

    cout << "\n'N' tells you how many digits you guessed correctly.";
    cout << "\n'P' tells you how many of the correctly guessed digits are in the right position.";
    cout << "\n\nThe goal is to get a score of 4 for N and P.\n\n";
    cout << "Good Luck!\n";
    
    do{//Until it's found

        /*
        ================================================================================================
        Part II - Validating the user's input.
        ================================================================================================
        */
        do{//For validating the user's input
            valid_input = true;
            cout << "\nYour guess: ";
            cin >> guess_str;

            //Check if it's exactly four digits.
            if (guess_str.size() != 4){
                cout << "\nTey baba. Your guess has to be exactly four digits. Try again.";
                valid_input = false;
            }
            
            //Check for repetition and 
            //That it's only a positive number.
            for (int i = 0; i < 4 && valid_input ; i++){
                //Digit mehonun
                if(guess_str[i] < '0' || guess_str[i] > '9'){
                    cout<< "Asemam inde. No characters except numbers.";
                    valid_input = false;
                    break;
                }

                //Check for repetition
                for (int j = i+1; j < 4; j++){
                    if(guess_str[i] == guess_str[j]){
                        valid_input = false;
                        cout << "\nTey baba. You can't repeat digits.";
                        break;
                    }
                }
            }

        }while(!valid_input);

        //Store user's input in guesses[] array
        guesses[num_of_guesses] = guess_str;


        /*
        ================================================================================================
        Part III - Comparing the user's guess with the magic number.
        ================================================================================================
        */
        //Initialize the N & P arrays to avoid garbage values.
        N[num_of_guesses] = 0;
        P[num_of_guesses] = 0;
        //For comparing the user's guess with the magic number
        for (int i = 0; i < 4; i++){

            //For calculating the N of each guess.
            for (int j = 0; j < 4; j++){
                if(magic_str[i] == guess_str[j]){
                    N[num_of_guesses]++;
                }
            }

            //For calculating the P of each guess.
            if(magic_str[i] == guess_str[i]){
                P[num_of_guesses]++;
            }
        }

        /*
        ================================================================================================
        Part IV - Displaying a history of all the user's guesses and their scores.
        ================================================================================================
        */

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
        
        for (int i = 0; i <= num_of_guesses; i++){
            cout << setfill(' ');
            cout << setw(col_width) << guesses[i];
            cout << setw(col_width) << N[i];
            cout << setw(col_width) << P[i];
            cout << endl;
        }

        if(P[num_of_guesses]==4 && N[num_of_guesses]==4){
            found=true;
            cout << "|--------------------------------------|"<<endl;
            cout << "|CONGRATS!! You have found the number!!|"<<endl;
            cout << "|--------------------------------------|";
        }
        else if(num_of_guesses == SIZE-1){
            cout << "\nYou've reached the maximum of " << SIZE << "guesses! Tebela(s)h.";
        }
        
        num_of_guesses++; //Increment the variable holding the number of guesses.

    }while(!found && num_of_guesses < SIZE);
  
    return 0;
}