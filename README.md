# Hangman

This project is a recreation of the classic paper and pencil Hangman game into a MIPS assembly program. It involves two players: Player 1 will enter the word to be guessed, and Player 2 enters a character for each guess or can choose to guess the word. Player 2 gets 7 incorrect guesses before they lose the game. Each incorrect guess adds to the Hangman stick figure drawing using the Bitmap Display Tool in MARS.

# Getting Started

## Installing

* Clone this repository from GitHub: https://github.com/CS-2640-Group/Hangman.git
* Ensure you have MARS 4.5 installed or some other way to run MIPS assembly programs with a Bitmap Display Tool
* Ensure all `.asm` files are downloaded.

## Executing program

* Open all the files in your application of choice
* Open the Bitmap Display Tool and set the following options:
   - Base Address: 0x10010000 (static data)
   - *For a small screen:* 
   - Both Unit Width and Height in Pixels: 1
   - Both Display Width and Height: 256
   - *For a big screen:*
   - Both Unit Width and Height in Pixels: 2
   - Both Display Width and Height: 512

* Select `Connect to MIPS ` and then run the program file: `FinalProject_Hangman.asm`
* The text part of the game will be played in the output window and the Bitmap Display will have the drawing after player 1 inputs their word

# Authors

* Clarence Ballensky
  - GitHub: [ClarenceBallensky](https://github.com/ClarenceBallensky)
* Scott Baroni  
  - GitHub: [ArcaneWorm](https://github.com/ArcaneWorm)
* Adam Mitchell
  - GitHub: [trouDev](https://github.com/trouDev)
* William Mo
  - GitHub: [Water-Bottl3](https://github.com/Water-Bottl3)
