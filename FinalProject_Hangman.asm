#Final Project: Hangman

#We will recreate the classic children's game "hangman." The objective of the game is to guess the word before the entire stick figure
#("the hangman") is drawn. Player 1 chooses a word. Our program prints out underscores for each letter in the word. Player 2 must try to figure
#out what the word is by guessing one letter at a time. If Player 2 guesses a correct letter, the corresponding underscore(s) will be replaced 
#with that letter. If Player 2 guesses the word incorrectly, another limb (e.g. arm, torso, leg) will be added to the hangman. Player 2 can also
#guess the entire word to finish the game, but if they get it wrong any correct letters within the word will be ignored. 

#Athena Ballensky, Scott Baroni, Adam Mitchell, William Mo
#4/18/2025
#CS 2610.02

.data
#strings in MARS are just an array of characters
#even though this looks like one string, we will be able to access it character by character 
alphabet: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
underscore: .asciiz "_"

.text
#CODE LATER: Player 1 enters a word

#CODE LATER: Loop to print 1 underscore per 1 letter in Player 1's word

#CODE NOW: Print underscores for our hard-coded word

#Get Player 2's one letter guess
#	- if they type 1 instead of a letter, jump to the code for guessing a word
#	- if they guess a correct letter, replace appropriate underscore(s) with that letter
#	- if they guess an incorrect letter, add limb to the hangman bitmap 

#Get Player 2's word guess
#	- verify that they entered a word of the correct length, print an error message and prompt them again if they didn't 
#	- if they guess a correct word, print you win and exit
#	- if they guess an incorrect word, return to prompting them for single letter guesses 

#Bitmap stuff

#End of program
exit:
	li $v0, 10
	syscall