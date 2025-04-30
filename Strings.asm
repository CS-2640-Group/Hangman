# String Utility Macros

# Prints a string literal
# Params:
# 	%stringLiteral - The string to print
# Used Registers: $v0, $a0
.macro printLiteral(%stringLiteral)
	.data
		str: .asciiz %stringLiteral
	.text
	li $v0, 4
	la $a0, str
	syscall
.end_macro

# Prints a string from a label
# Params:
# 	%stringLabel - The label where the string is stored
# Used Registers: $v0, $a0
.macro printLabel(%stringLabel)
	li $v0, 4
	la $a0, %stringLabel
	syscall
.end_macro

# Prints a string from an address stored in a register
# Params:
# 	%stringAddress - A register where the string address is stored
# Used Register: $v0, $a0
.macro printAddress(%stringAddress)
	li $v0, 4
	la $a0, (%stringAddress)
	syscall
.end_macro

# Prints a character (a single byte)
# Params:
#	%char - A register containing a valid byte
# Used Registers: $v0, $a0
.macro printChar(%char)
	li $v0, 11
	move $a0, %char
	syscall
.end_macro

# Prints an Integer
# Params:
# 	%int - A register containing an int or a literal
# Used Registers: $v0, $a0, $0
.macro printInt(%int)
	li $v0, 1
	add $a0, $0, %int
	syscall
.end_macro

# Prints a blank space
# Used Registers: $v0, $a0
.macro printSpace
	li $v0, 11
	li $a0, 32
	syscall
.end_macro

# Takes a string input from the user
# When user presses the enter key, a newline character is inserted
# Params:
# 	%buffer - The label of the .space buffer
# 	%length - An int literal for the length of the string
#		  The length should be (desired length) + 1 as null terminator is included
# Used Registers: $v0, $a0, $a1
.macro readString(%buffer, %length)
	li $v0, 8
	la $a0, %buffer
	li $a1, %length
	syscall
.end_macro

# Takes a character from the user
# Params:
# 	%saveRegister - The register to save the input to
# Used Registers: $v0
.macro readChar(%saveRegister)
	li $v0, 12
	syscall
	move %saveRegister, $v0
.end_macro

# Gets the length of a string, not including the null terminator
# Includes newline characters
# Ex. "string\n" has length of 7
# Params:
# 	%stringAddress - A register with the address of the string
# 	%saveRegister - A register to save the length to
# Used Registers: $0, $t0, $t1, $t2
.macro stringGetLength(%stringAddress, %saveRegister)
	# Counter
	move $t2, $0
	
	# Save the address
	move $t0, %stringAddress
	
	loop:
		# Load the byte (character)
		lb $t1, 0($t0)
	
		# If the character is a null terminator, return
		beq $t1, $0, return
		# If the character is a new line, return
		# beq $t1, 10, return
		
		# Else increment counter and address
		# And loop
		addi $t2, $t2, 1 # Increment counter
		addi $t0, $t0, 1 # Increment address
		
		b loop
	
	return:
		move %saveRegister, $t2
.end_macro

# Loops through a string to check if the string contains the given character byte
# Params:
# 	%stringAddress - A register with the address of the string
# 	%characterByte - A register with the character byte
# 	%saveRegister - A register to save the boolean result to
#		      - 0 for false, 1 for true
# Used Registers: $0, $t0, $t1, $t2, $t3
.macro stringContains(%stringAddress, %characterByte, %saveRegister)
	# Save the address
	move $t0, %stringAddress
	# Save the byte
	move $t1, %characterByte
	# Set up return value
	move $t2, $0
	
	loop:
		# Load the byte (character)
		lb $t3, 0($t0)
		
		# If character is equal to the character byte, set return value to 1
		# And return
		beq $t3, $t1, returnTrue
		
		# If the character is a null terminator, return
		beq $t3, $0, return
		
		# Else increment address
		addi $t0, $t0, 1
		
		b loop
		
	returnTrue:
		# Set return value to 1
		li $t2, 1
	return:
		move %saveRegister, $t2
.end_macro

# Gets the value of the first byte in a given string
# Params:
# 	%stringAddress - A register with the string address
# 	%saveRegister - A register to save the byte to
# Used Registers: None
.macro getAddressByte(%stringAddress, %saveRegister)
	lb %saveRegister, (%stringAddress)
.end_macro

# Turns a character byte to the uppercase counterpart
# Does range checking, so characters that is not a-z will have no effect
# Replaces the given register with the uppercase counterpart
# Params:
# 	%characterByte - A register with the byte
# Used Registers: None
.macro toUpperCaseByte(%characterByte)
	# If the character is less than the lowercase a, don't do anything
	blt %characterByte, 97, return
	# Else If the character is greater than lowercase z, don't do anything
	bgt %characterByte, 122, return
	
	# Difference between upper case and lower case is 32
	# Else offset the lowercase character by 32
	# To get the uppercase counterpart
	subi %characterByte, %characterByte, 32
	
	return:
	
.end_macro

# Replaces all lowercase characters in a string with uppercase counterparts
# Params:
# 	%stringAddress - A register with the string address
# Used Registers: $0, $t0, $t1
.macro toUpperCase(%stringAddress)
	# Save address
	move $t0, %stringAddress
	
	loop:
		# Load the byte from address
		lb $t1, 0($t0)
		
		# If the character is a null terminator, return
		beq $t1, $0, return
		
		toUpperCaseByte($t1)
		
		# Replace the character in the string
		sb $t1, 0($t0)
		
		# Increment address
		addi $t0, $t0, 1
		b loop
	return:
		
.end_macro
