.data 
	#############  Message Prompts  ############# 
	introMessage: .asciiz "Hello, welcome to the game of Battlesnake! Please create your custom board.\n\n"
	selectCoordinateP1: .asciiz "\nPlayer 1, please select where you would like to place your ship with coordinates(#,#): \n"
	selectCoordinateP2: .asciiz "\nPlayer 2, please select where you would like to place your ship with coordinates(#,#): \n"
	startMovePrompt: .asciiz "\nNow each player can move 5 spaces\n"
	movePromptP1: .asciiz "\nPlayer 1 would you like to move left(L), right(R), down(D), or up(U)? \n"
	movetoP2message: .asciiz "Onto Player 2's move now\n"
	movePromptP2: .asciiz "\nPlayer 2 would you like to move left(L), right(R), down(D), or up(U)? \n"
	attackMessageP1: .asciiz "\nPlayer 1's turn to attack\n"
	attackMessageP2: .asciiz "\nPlayer 2's turn to attack\n"
	attackPrompt: .asciiz "Please select where on the board you would like to fire(x,x): "
	hitMessage: .asciiz "That was a hit!\n"
	
	winMessageP1: .asciiz "\nPlayer 1 you win!"
	winMessageP2: .asciiz "\nPlayer 2 you win!"
	
	scoreMessageP1: .asciiz "Your score was: "
	scoreMessageP2: .asciiz "Your score was: "
	hitsMessage: .asciiz " hits"
	
	turnMessage: .asciiz "Let's decide which player attacks first"
	
	enterBackgroundChar: .asciiz "Players, please enter background character"
	
	
	##MISC Messages##
	newLine: .asciiz "\n"
	comma: .asciiz ","
	
	################ Data ##############
	
	boardGridP1: .space  100
	
	boardGridP2: .space  100
		
	size:		.word 10 	# Change this for size of board side (10 x 10 sized board with 10 for example)
	
	replaceSpace: .space 1   	# Read in char to be used by player
	shipHead: .byte '<'
	shipBody: .byte '='
	leftCheck: .byte 'L'
	rightCheck: .byte 'R'
	downCheck: .byte 'D'
	upCheck: .byte 'U'
	duration: .byte 50
	
	
.text

main:

	jal showGrid
	
	
	#Simulate multiple turns
	mainForloop:
		
		jal attackShip 
		jal steerShip 
		
		j mainForloop
		
	endMainloop:
	
	
	#End the program#
	li $v0, 10
	syscall
		
		
showGrid:
		#Intro Message
		li $v0, 4
		la $a0, introMessage # Print intro message
		syscall 
		
		############################ FOR CREATING CUSTOM BOARD
		li $v0, 4
		la $a0, enterBackgroundChar	# Display message for asking for user input	
		syscall
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		li $v0, 12 			# Read input for player 1's background character
		syscall
		
		move $t5, $v0 			# Move input to temporary variable
		
		la $a1, replaceSpace 		# load in space for background character
		sb $t5, 0($a1)			# Store character into allocated space
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		
		addi $sp, $sp, -4 # Allocate space to store $ra
		sw $ra, 0($sp) # Store $ra in the stack before jal
		jal populateBoardP1 # Populate P1 board with desired character
		lw $ra, 0($sp) # Restore $ra from the stack before jal
		addi $sp, $sp, 4 # Restore stack
		
		addi $sp, $sp, -4 # Allocate space to store $ra
		sw $ra, 0($sp) # Store $ra in the stack before jal
		jal populateBoardP2 # Populate P2 board with desired character
		lw $ra, 0($sp) # Restore $ra from the stack before jal
		addi $sp, $sp, 4 # Restore stack
		
		############################ END OF CREATING CUSTOM BOARD
		
		
		addi $sp, $sp, -4 # Allocate space to store $ra
		sw $ra, 0($sp) # Store $ra in the stack before jal
		jal printBoardP1 # Use P1 board for starting board reference
		lw $ra, 0($sp) # Restore $ra from the stack before jal
		addi $sp, $sp, 4 # Restore stack
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		addi $sp, $sp, -4 # Allocate space to store $ra
		sw $ra, 0($sp) # Store $ra in the stack before jal
		jal printBoardP2 # Use P2 board for starting board reference
		lw $ra, 0($sp) # Restore $ra from the stack before jal
		addi $sp, $sp, 4 # Restore stack
		
		
		############Get Coordinates for player 1 #####################
		li $v0, 4
		la $a0, selectCoordinateP1 # load in and print message for coordinated for P1
		syscall
		
		
		###### USED TO STORE VARIABLES FOR COORDINATES TO THE STACK ######
		addi $sp, $sp, -32
		###### END SPACE ALLOCATION ######
		
		li $v0, 5 # Read input form player
		syscall
		move $t6, $v0 # $t6 holds coordinate 1 for P1
		
		sw $t6, 4($sp) ########## USED TO STORE COORDINATE 1 FOR P1
		
		li $v0, 4
		la $a0, comma # load in comma and print it to separate coordinates
		syscall
		
		li $v0, 5 # Read input from player
		syscall
		move $t7, $v0 # $t7 holds coordinate 2 for P1
		
		sw $t7, 8($sp) ######### USED TO STORE COORDINATE 2 FOR P2
		
		### To put ship where coordinates are stated ###
		la $a1, boardGridP1
		
		lw $t1, size # $t1 = column size
		add $t2, $zero, $t6 # $t2 = rowIndex, which in this case is coordinate 1
		add $t3, $zero, $t7 # $t3 = colIndex, which in this case is coordinate 2
		
		# Calculate location of coordinates selected for player 1 (boardGridP1[coordinate1][coordinate2])
		mul $t4, $t2, $t1 	# rowIndex * colSize
		add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
		mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
		add $t4, $a1, $t4 	# previous equation + baseAddress
		
		lb $a2, shipHead 	# load bit'<' into $a2
		lb $a3, shipBody	# load bit '=' into $a3
		
		add $a1, $zero, $t4 	# to add precise location to array (also replacing $t4 below with $a0)
		
		sb $a2, 0($a1)		# store $a2 ('<') into location address ## Similar in C to shipPlaceP1[initialPlace1_P1][initialPlace2_P1] = '<';
		sb $a3, 1($a1)		# store $a3 ('=') into location address 1 byte next to head ## Similar in C to shipPlaceP1[initialPlace1_P1][initialPlace2_P1+1] = '=';
		
		
		
		############## 	END OF PLACING SHIP 1 ############
		
		
		
		##### Print updated board with ship location for player 1 #####

		sw $ra, 0($sp) # Store $ra in the stack before jal
		jal printBoardP1 # Show current P1 board
		lw $ra, 0($sp) # Restore $ra from the stack before jal


		## End get coordinates for P1 ###############################
		
		
		
		############Get Coordinates for player 2 #####################
		li $v0, 4
		la $a0, selectCoordinateP2 # load in and print message for coordinate for P2
		syscall
		
		li $v0, 5 # Read input form player
		syscall
		move $t6, $v0 # $t6 holds coordinate 1 for P2
		
		sw $t6, 12($sp) ########## USED TO STORE COORDINATE 1 FOR P2
		
		li $v0, 4
		la $a0, comma # load in comma and print it to seperate coordinates
		syscall
		
		li $v0, 5 # Read input form player
		syscall
		move $t7, $v0 # $t7 holds coordinate 2 for P2
		
		sw $t7, 16($sp) ########## USED TO STORE COORDINATE 2 FOR P2
		
		### To put ship where coordinates are stated ###
		la $a1, boardGridP2
		
		lw $t1, size # $t1 = column size
		add $t2, $zero, $t6 # $t2 = rowIndex, which in this case is coordinate 1
		add $t3, $zero, $t7 # $t3 = colIndex, which in this case is coordinate 2
		
		# Calculate location of coordinates selected for player 2 (boardGridP2[coordinate1][coordinate2])
		mul $t4, $t2, $t1 	# rowIndex * colSize
		add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
		mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
		add $t4, $a1, $t4 	# previous equation + baseAddress
		
		lb $a2, shipHead 	# load bit '<' into $a2
		lb $a3, shipBody	# load bit '=' into $a3
		
		add $a0, $zero, $t4 	# to add precise location to array (also replacing $t4 below with $a0)
		
		sb $a2, 0($a0)		# store $a2 ('<') into location address ## Similar in C to shipPlaceP2[initialPlace1_P2][initialPlace2_P2] = '<';
		sb $a3, 1($a0)		# store $a3 ('=') into location address 1 byte next to head ## Similar in C to shipPlaceP1[initialPlace1_P2][initialPlace2_P2+1] = '=';
			
		
		############## 	END OF PLACING SHIP 2 ############
		
		##### Print updated board with ship location for player 2 #####

		sw $ra, 0($sp) # Store $ra in the stack before jal
		jal printBoardP2 # Show current P2 board
		lw $ra, 0($sp) # Restore $ra from the stack before jal

		
		###Return back to main###
		jr $ra
		
	

steerShip:


		li $v0, 4
		la $a0, startMovePrompt # Print prompt to start moving ship
		syscall 
		
		addi $t8, $zero, 0 # k = 0
		addi $t9, $zero, 5 # TURNS = 5
		
		### HAVE LOOP START P1 ###
		player1Move:
				bge $t8, $t9, endPlayer1move # k >= TURNS or 5 (k < 5 in C for five turns)
				
				li $v0, 4
				la $a0, movePromptP1 # Print prompt to start moving ship
				syscall 
			
				li $v0, 12 # Read input for direction(L,R,U,D)
				syscall
			
				move $t0, $v0 # move direction input into variable for checking
			
				la $a0, newLine		# Print new line
				li $v0, 4
				syscall			# Will isuse system call to print new line same as printf("\n");
			

				lb $t4, leftCheck 	# load in address of char 'L'
				lb $t5, rightCheck 	# load in address of char 'R'
				lb $t6, downCheck	# load in address of char 'D'
				lb $t7, upCheck 	# load in address of char 'U'
						
			
				moveShipleftP1:

					bne $t0, $t4, moveShiprightP1 # If input does not equal 'L' then branch to right
				
					lw $t2, 4($sp) ########## USED TO LOAD COORDINATE 1 FOR P1 (ROW INDEX)
					lw $t3, 8($sp) ########## USED TO LOAD COORDINATE 2 FOR P1 (COLUMN INDEX)
			
					### To find ship where coordinates are stated ###
					la $a1, boardGridP1
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 1 (boardGridP1[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
				
					addi $a1, $a1, -1	# shift focus on 1 spot left of ship to shift it once left
				
					sb $a2, 0($a1)		# store head of ship in new left spot
					sb $a3, 1($a1)		# store body of ship behind head
					sb $a0, 2($a1)		# store background char where body would've been
				
					sw $t2, 4($sp)		# Store new rowIndex coordinate (should be same)
				
					addi $t3, $t3, -1	# New coordinate for colIndex should be -1
					sw $t3, 8($sp)		# Store new colIndex coordinate
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP1 	# Show current P1 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal
							

				
					
					addi $t8, $t8, 1 # k = k + 1
				

					j player1Move # jump to beginning of move turn
			
				moveShiprightP1:
		
					bne $t0, $t5, moveShipdownP1 # If input does not equal 'R' then branch to down
				
					lw $t2, 4($sp) ########## USED TO LOAD COORDINATE 1 FOR P1 (ROW INDEX)
					lw $t3, 8($sp) ########## USED TO LOAD COORDINATE 2 FOR P1 (COLUMN INDEX)
			
				
					### To find ship where coordinates are stated ###
					la $a1, boardGridP1
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 1 (boardGridP1[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndex * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
				
					addi $a1, $a1, 1	# shift focus on 1 spot right of ship to shift it once right
				
					sb $a2, 0($a1)		# store head of ship in new right spot
					sb $a3, 1($a1)		# store body of ship behind head
					sb $a0, -1($a1)		# store background char where body would've been
				
					sw $t2, 4($sp)		# Store new rowIndex coordinate (should be same)
				
					addi $t3, $t3, 1	# New coordinate for colIndex should be 1
					sw $t3, 8($sp)		# Store new colIndex coordinate
				
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP1 	# Show current P1 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal
				
 
				
					
					addi $t8, $t8, 1 # k = k + 1
				

					j player1Move # jump to beginning of move turn
			
					
				moveShipdownP1:

					bne $t0, $t6, moveShipupP1 # If input does not equal 'D' then branch to up
				
				
					lw $t2, 4($sp) ########## USED TO LOAD COORDINATE 1 FOR P1 (ROW INDEX)
					lw $t3, 8($sp) ########## USED TO LOAD COORDINATE 2 FOR P1 (COLUMN INDEX)
					
					beq $t2, 9, player1Move 	# If ship is near bottom of the board then force player to choose move again so ship doesn't go out of index
			
					### To find ship where coordinates are stated ###
					la $a1, boardGridP1
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 1 (boardGridP1[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
				
					sb $a0, 0($a1)		# Replace where previous head was with board spot
					sb $a0, 1($a1)		# Replace where previous body was with board spot
				
					#### Find new row below ####

					addi $a1, $a1, 10	# Move to 10 spots to land right below previous ship spot
				
												
					sb $a2, 0($a1)		# store head of ship in new left spot
					sb $a3, 1($a1)		# store body of ship behind head
				
					addi $t2, $t2, 1 	# New rowIndex coordinate
					sw $t2, 4($sp)		# Store new rowIndex coordinate
				

					sw $t3, 8($sp)		# Store new colIndex coordinate (should be same)
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP1 	# Show current P1 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal
				
								
				
					
					addi $t8, $t8, 1 # k = k + 1
				

					j player1Move # jump to beginning of move turn
				
				
				moveShipupP1:

				
					lw $t2, 4($sp) ########## USED TO LOAD COORDINATE 1 FOR P1 (ROW INDEX)
					lw $t3, 8($sp) ########## USED TO LOAD COORDINATE 2 FOR P1 (COLUMN INDEX)
					
					beq $t2, 0, player1Move # If ship is near the top of the board then force player to choose direction again so ship doesn't go out of index
			
					### To find ship where coordinates are stated ###
					la $a1, boardGridP1
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 1 (boardGridP1[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
				
					sb $a0, 0($a1)		# Replace where previous head was with board spot
					sb $a0, 1($a1)		# Replace where previous body was with board spot
				
					#### Find new row below ####

					addi $a1, $a1, -10
				
					sb $a2, 0($a1)		# store head of ship in new left spot
					sb $a3, 1($a1)		# store body of ship behind head
					
					addi $t2, $t2, -1 	# New rowIndex coordinate
					sw $t2, 4($sp)		# Store new rowIndex coordinate
				
					sw $t3, 8($sp)		# Store new colIndex coordinate (should be same)			
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP1 	# Show current P1 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal
			
										
					
					addi $t8, $t8, 1 # k = k + 1
				

					j player1Move # jump to beginning of move turn
			
			
			
		### LOOP END P1 ##########
		endPlayer1move:
		
		
		li $v0, 4
		la $a0, movetoP2message # Print statement for moving to player 2
		syscall
		
		
		### HAVE LOOP START P2 ###		
			
		addi $t8, $zero, 0 # k = 0
		addi $t9, $zero, 5 # TURNS = 0
		
		### HAVE LOOP START P2 ###
		player2Move:
				bge $t8, $t9, endPlayer2move # k >= TURNS or 5 (k < 5 in C for five turns)
				
				li $v0, 4
				la $a0, movePromptP2 # Print prompt to start moving ship
				syscall 
			
				li $v0, 12 # Read input for direction(L,R,U,D)
				syscall
			
				move $t0, $v0 # move direction input into variable for checking
			
				la $a0, newLine		# Print new line
				li $v0, 4
				syscall			# Will isuse system call to print new line same as printf("\n");
			

				lb $t4, leftCheck # load in address of char 'L'
				lb $t5, rightCheck # load in address of char 'R'
				lb $t6, downCheck # load in address of char 'D'
				lb $t7, upCheck # load in address of char 'U'

						
				moveShipleftP2:
				
					bne $t0, $t4, moveShiprightP2 # If input does not equal 'L' then branch to right
				
					lw $t2, 12($sp) ########## USED TO LOAD COORDINATE 1 FOR P2 (ROW INDEX)
					lw $t3, 16($sp) ########## USED TO LOAD COORDINATE 2 FOR P2 (COLUMN INDEX)
			
					### To find ship where coordinates are stated ###
					la $a1, boardGridP2
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 2 (boardGridP2[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
					
					addi $a1, $a1, -1	# shift focus on 1 spot left of ship to shift it once left
				
					sb $a2, 0($a1)		# store head of ship in new left spot
					sb $a3, 1($a1)		# store body of ship behind head
					sb $a0, 2($a1)		# store background char where body would've been
				
					sw $t2, 12($sp)		# Store new rowIndex coordinate (should be same)
				
					addi $t3, $t3, -1	# New coordinate for colIndex should be -1
					sw $t3, 16($sp)		# Store new colIndex coordinate
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP2 	# Show current P2 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal
				
				
				
					
					addi $t8, $t8, 1 # k = k + 1
				

					j player2Move # jump to beginning of move turn
			
				moveShiprightP2:
				
					bne $t0, $t5, moveShipdownP2 # If input does not equal 'R' then branch to down
				
					lw $t2, 12($sp) ########## USED TO LOAD COORDINATE 1 FOR P2 (ROW INDEX)
					lw $t3, 16($sp) ########## USED TO LOAD COORDINATE 2 FOR P2 (COLUMN INDEX)
			
				
					### To find ship where coordinates are stated ###
					la $a1, boardGridP2
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 2 (boardGridP2[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndex * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
				
					addi $a1, $a1, 1	# shift focus on 1 spot right of ship to shift it once right
				
					sb $a2, 0($a1)		# store head of ship in new right spot
					sb $a3, 1($a1)		# store body of ship behind head
					sb $a0, -1($a1)		# store background char where body would've been
				
					sw $t2, 12($sp)		# Store new rowIndex coordinate (should be same)
				
					addi $t3, $t3, 1	# New coordinate for colIndex should be 1
					sw $t3, 16($sp)		# Store new colIndex coordinate
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP2 	# Show current P2 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal
				
				
					#### RETURN TO MAIN ####
					addi $t8, $t8, 1 # k = k + 1
				

					j player2Move # jump to beginning of move turn
			
			
			
				moveShipdownP2:
				
					bne $t0, $t6, moveShipupP2 # If input does not equal 'D' then branch to up
				
					lw $t2, 12($sp) ########## USED TO LOAD COORDINATE 1 FOR P2 (ROW INDEX)
					lw $t3, 16($sp) ########## USED TO LOAD COORDINATE 2 FOR P2 (COLUMN INDEX)
					
					beq $t2, 9, player2Move 	# If ship is near bottom of the board then force player to choose move again so ship doesn't go out of index
			
					### To find ship where coordinates are stated ###
					la $a1, boardGridP2
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 2 (boardGridP1[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
				
					sb $a0, 0($a1)		# Replace where previous head was with board spot
					sb $a0, 1($a1)		# Replace where previous body was with board spot
				
					#### Find new row below ####

					addi $a1, $t4, 10
				
					sb $a2, 0($a1)		# store head of ship in new left spot
					sb $a3, 1($a1)		# store body of ship behind head
					
					addi $t2, $t2, 1 	# New rowIndex coordinate
					sw $t2, 12($sp)		# Store new rowIndex coordinate
				
					sw $t3, 16($sp)		# Store new colIndex coordinate (should be same)		
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP2 	# Show current P1 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal
				
									
				
					
					addi $t8, $t8, 1 # k = k + 1
				

					j player2Move # jump to beginning of move turn
			
			
				moveShipupP2:
				
					lw $t2, 12($sp) ########## USED TO LOAD COORDINATE 1 FOR P2 (ROW INDEX)
					lw $t3, 16($sp) ########## USED TO LOAD COORDINATE 2 FOR P2 (COLUMN INDEX)
					
					beq $t2, 0, player2Move # If ship is near the top of the board then force player to choose direction again so ship doesn't go out of index
			
					### To find ship where coordinates are stated ###
					la $a1, boardGridP2
		
					lw $t1, size # $t1 = column size
		
					# Calculate location of coordinate of ship for player 2 (boardGridP2[coordinate1][coordinate2])
					mul $t4, $t2, $t1 	# rowIndex * colSize
					add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
					mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
					add $t4, $a1, $t4 	# previous equation + baseAddress
				
					add $a1, $zero, $t4	# to add precise location of ship to array for use
				
					lb $a0, replaceSpace	# load new background char (X for example)
					lb $a2, 0($a1)		# load front of ship to $a2
					lb $a3, 1($a1)		# load body of ship to $a3
				
					sb $a0, 0($a1)		# Replace where previous head was with board spot
					sb $a0, 1($a1)		# Replace where previous body was with board spot
				
					#### Find new row below ####

					addi $a1, $a1, -10
				
					sb $a2, 0($a1)		# store head of ship in new left spot
					sb $a3, 1($a1)		# store body of ship behind head
					
					addi $t2, $t2, -1 	# New rowIndex coordinate
					sw $t2, 12($sp)		# Store new rowIndex coordinate
				
					sw $t3, 16($sp)		# Store new colIndex coordinate (should be same)			
				
					sw $ra, 0($sp) 		# Store $ra in the stack before jal
					jal printBoardP2 	# Show current P1 board
					lw $ra, 0($sp) 		# Restore $ra from the stack before jal

				
				
				
					
					addi $t8, $t8, 1 # k = k + 1
				

					j player2Move # jump to beginning of move turn
			
			
			
		### LOOP END P2 ##########
		endPlayer2move:
		

		jr $ra


attackShip:
		li $v0, 4
		la $a0, newLine
		syscall
		
		li $v0, 4
		la  $a0, turnMessage
		syscall
		

		#### CODE FOR RANDOM NUMBER GENERATOR TO DECIDE WHICH PLAYER GOES FIRST (0 for player 1, 1 for player 2) ####
		
		li $v0, 42	# Random Number generator (stored in $a0)
		la $a1, 2	# bounds for random number
		syscall
		
		sw $a0, 20($sp)	# store random number in stack to use later
		beq $a0, 1, player2Attack	#branch to player 2's attack if random number is 1
		
		#### Code for where to select where shots are fired for P1 ####
		player1Attack:
						
		li $v0, 4
		la $a0, attackMessageP1 # Print message where player 1 would like to attack
		syscall
		
		li $a3, 0 # Initialize $a3 for use as hit counter
		lw $a3, 24($sp) # Load in value of hit counter of P1
		
		

				lw $t2, 12($sp) ########## USED TO LOAD COORDINATE 1 FOR P2 (ROW INDEX)
				lw $t3, 16($sp) ########## USED TO LOAD COORDINATE 2 FOR P2 (COLUMN INDEX)
				
				### To find ship where coordinates are stated ###
				la $a1, boardGridP2
		
				lw $t1, size # $t1 = column size
		
				# Calculate location of coordinate of ship for player 2 (boardGridP1[coordinate1][coordinate2])
				mul $t4, $t2, $t1 	# rowIndex * colSize
				add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
				mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
				add $t4, $a1, $t4 	# previous equation + baseAddress
				
				add $a1, $zero, $t4	# to add precise location of ship to array for use
				
				addi $s2, $a1, 0 # to temporarily hold location of ship head in $s2
				addi $s3, $a1, 1 # to temporarily hold location of ship body in $s3
				
				li $v0, 4
				la $a0, attackPrompt # load address of message to prompt for attack coordinates
				syscall
				
				li $v0, 5 # Read input form player
				syscall
				move $s0, $v0 # for coordinate 1 of attack to be stored in $s0
		
				li $v0, 4
				la $a0, comma # load in comma and print it to seperate coordinates
				syscall
		
				li $v0, 5 # Read input form player
				syscall
				move $s1, $v0 # for coordinate 2 of attack to be stored in $s1
				
				#### TO FIND WHAT IS AT THE CHOSEN ATTACK COORDINATES ####
				la $a1, boardGridP2
		
				lw $t1, size # $t1 = column size
		
				# Calculate location of coordinate of ship for player 1 (boardGridP1[coordinate1][coordinate2])
				mul $t4, $s0, $t1 	# rowIndex * colSize
				add $t4, $t4, $s1	# (rowIndex * colSize) + colIndex
				mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
				add $t4, $a1, $t4 	# previous equation + baseAddress
				
				add $a1, $zero, $t4 	# location of place of board chosen
				


			checkHitforP2:

				lb $a0, replaceSpace	# load new background char (X for example)
				beq $s2, $a1, replaceHeadP2	# To replace head of P1's ship with background char
				beq $s3, $a1, replaceBodyP2	# To replace body of P1's ship with background char 
				j endAttackP1
				
				replaceHeadP2:
				
					sb $a0, 0($a1)		# Replace where previous head was with board spot for hit spot on board
					j endCheckhitP2
					
				replaceBodyP2:
					
					sb $a0, 0($a1)		# Replace where previous body was with board spot for hit spot on board
					
				endCheckhitP2:
					j attackAlertP1
				
			endReplaceforP2:
								
				addi $a3, $a3, 1 # $a3 (hit counter) = $a3 + 1 for every hit



				beq  $a3, 2, hitScoreCallP1 # If $a3 (hit counter) is equal to 2 then will jump to hitScore to end game
				j endAttackP1
				
				hitScoreCallP1:
				
					jal hitScoreP1
			
		
		endAttackP1:
		#############		END PLAYER 1 ATTACK	###############
		
		sw $a3, 24($sp) # If player did not get 2 hits then the value of $a1 (hit counter) will be stored in the stack for later use for player 1
		
		sw $ra, 0($sp) 		# Store $ra in the stack before jal
		jal printBoardP2 	# Show current P2 board
		lw $ra, 0($sp) 		# Restore $ra from the stack before jal
		
		lw $a0, 20($sp)		# Get random number from stack
		beq $a0, 0, player2Attack	# branch to player 2's attack if player 1 went first
		
		jr $ra
		
		
		#### Code for where to select where shots are fired for P2 ####
		player2Attack:
				
		li $v0, 4
		la $a0, attackMessageP2 # Print message where player 2 would like to attack
		syscall
		
		li $a3, 0 # Initialize $a3 for use as hit counter
		lw $a3, 32($sp) # Load in value of hit counter of P2
		

				lw $t2, 4($sp) ########## USED TO LOAD COORDINATE 1 FOR P1 (ROW INDEX)
				lw $t3, 8($sp) ########## USED TO LOAD COORDINATE 2 FOR P1 (COLUMN INDEX)
				
				### To find ship where coordinates are stated ###
				la $a1, boardGridP1
		
				lw $t1, size # $t1 = column size
		
				# Calculate location of coordinate of ship for player 1 (boardGridP1[coordinate1][coordinate2])
				mul $t4, $t2, $t1 	# rowIndex * colSize
				add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
				mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
				add $t4, $a1, $t4 	# previous equation + baseAddress
				
				add $a1, $zero, $t4	# to add precise location of ship to array for use
				
				addi $s6, $a1, 0 # to temporarily hold location of ship head in $s2
				addi $s7, $a1, 1 # to temporarily hold location of ship body in $s3
				
				li $v0, 4
				la $a0, attackPrompt # load address of message to prompt for attack coordinates
				syscall
				
				li $v0, 5 # Read input form player
				syscall
				move $s4, $v0 # for coordinate 1 of attack to be stored in $s0
		
				li $v0, 4
				la $a0, comma # load in comma and print it to seperate coordinates
				syscall
		
				li $v0, 5 # Read input form player
				syscall
				move $s5, $v0 # for coordinate 2 of attack to be stored in $s1
				
				#### TO FIND WHAT IS AT THE CHOSEN ATTACK COORDINATES ####
				la $a1, boardGridP1
		
				lw $t1, size # $t1 = column size
		
				# Calculate location of coordinate of ship for player 1 (boardGridP1[coordinate1][coordinate2])
				mul $t4, $s4, $t1 	# rowIndex * colSize
				add $t4, $t4, $s5	# (rowIndex * colSize) + colIndex
				mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
				add $t4, $a1, $t4 	# previous equation + baseAddress
				
				add $a1, $zero, $t4 	# location of place of board chosen
				
			
			checkHitforP1:

				lb $a0, replaceSpace	# load new background char (X for example)
				beq $s6, $a1, replaceHeadP1	# To replace head of P1's ship with background char
				beq $s7, $a1, replaceBodyP1	# To replace body of P1's ship with background char 
				j endAttackP2
				
				replaceHeadP1:
				
					sb $a0, 0($a1)		# Replace where previous head was with board spot for hit spot on board
					j endCheckhitP1
					
				replaceBodyP1:
				
					sb $a0, 0($a1)		# Replace where previous body was with board spot for hit spot on board
					
				endCheckhitP1:
					j attackAlertP2
				
			endReplaceforP1:
				
				addi $a3, $a3, 1 # $a3 (hit counter) = $a3 + 1 for every hit
 
				beq  $a3, 2, hitScoreCallP2 # If $a3 (hit counter) is equal to 2 then will jump to hitScore to end game
				j endAttackP2
				
				hitScoreCallP2:
				
					jal hitScoreP2
						
		
		endAttackP2:
		#############		END PLAYER 2 ATTACK	###############
		
		sw $a3, 32($sp) # If player did not get 2 hits then the value of $a1 (hit counter) will be stored in the stack for later use for player 2
		
		sw $ra, 0($sp) 		# Store $ra in the stack before jal
		jal printBoardP1 	# Show current P1 board
		lw $ra, 0($sp) 		# Restore $ra from the stack before jal

		lw $a0, 20($sp)		# Get value of random number from stack
		beq $a0, 1, player1Attack	# branch back to player 1's turn to attack if player 2 attacked first

		jr $ra


hitScoreP1:


		
		#### if(hitPointsP1 = 2) ####
		li $v0, 4
		la $a0, winMessageP1 # Print message to say player 1 won
		syscall
		
		la $a0, newLine		# Print new line
		li $v0, 4
		syscall
		
		
		li $v0, 4 
		la $a0, scoreMessageP1	# Display "Your score was: "
		syscall
		
		li $v0, 1
		la $a0, ($a3) 		# Display number of hits in total
		syscall
		
		li $v0, 4
		la $a0, hitsMessage	# Display "hits" after number of hits
		syscall 
		########## END #############
		
		#To end the game#
		li $v0, 10
		syscall
		
	
		
hitScoreP2:
		
		#### if(hitPointsP2 = 2) ####
		li $v0, 4
		la $a0, winMessageP2 # Print message to say player 2 won
		syscall
		
		la $a0, newLine		# Print new line
		li $v0, 4
		syscall
		
		li $v0, 4
		la $a0, scoreMessageP2 # Display "Your score was: "
		syscall
		
		li $v0, 1
		la $a0, ($a3)  # Display number of hits in total
		syscall
		
		li $v0, 4
		la $a0, hitsMessage # Display "hits" after number of hits
		syscall
		########## END #############
		
		
		
		#To end the game#
		li $v0, 10
		syscall
		


# For Player 1's board	
printBoardP1:

#B1 = Board #1

		###### Display board #####
		
		la $a1, boardGridP1
		lw $t0, size # i max bound # use size in case game board size changes
		lw $t1, size # j max bound # use size in case game board size changes
		
		addi $t2, $zero, 0 # i = 0
	B1forLoopi:
			bge $t2, $t0, B1loopiEnd # i >= 10 or (i < 10 in C)
		
			addi $t3, $zero, 0 # j = 0
		B1forLoopj:
				bge $t3, $t1, B1loopjEnd # j >= 10 or (j < 10 in C)
		
				### value = baseAddress + ((rowIndexS * colSize) + colIndex) + dataSize ###
				mul $t4, $t2, $t1 	# rowIndex * colSize
				add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
				mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
				add $t4, $a1, $t4 	# previous equation + baseAddress
		
				li $v0, 11		# Call to print char
				lb $a0, 0($t4)		# Loads byte from char array
				syscall			# Will issue system call to print char same as printf("%c", shipPlaceP1[i][j]);
				addi $t3, $t3, 1	# j++
				
		
				j B1forLoopj
		B1loopjEnd:
			addi $t2, $t2, 1	# i++
			la $a0, newLine		# Print new line
			li $v0, 4
			syscall			# Will isuse system call to print new line same as printf("\n");
		
			j B1forLoopi
		
	B1loopiEnd:
		jr $ra
		
		
# For Player 2's board	
printBoardP2:

# B2 = Board #2
		###### #Diplay board ######
		
		la $a1, boardGridP2
		lw $t0, size # i max bound # use size in case game board size changes
		lw $t1, size # j max bound # use size in case game board size changes
		
		addi $t2, $zero, 0 # i = 0
	B2forLoopi:
			bge $t2, $t0, B2loopiEnd # i >= 10 or (i < 10 in C)
		
			addi $t3, $zero, 0 # j = 0
		B2forLoopj:
				bge $t3, $t1, B2loopjEnd # j >= 10 or (j < 10 in C)
		
				### value = baseAddress + ((rowIndex * colSize) + colIndex) + dataSize ###
				mul $t4, $t2, $t1 	# rowIndex * colSize
				add $t4, $t4, $t3	# (rowIndex * colSize) + colIndex
				mul $t4, $t4, 1 	# ((rowIndez * colSize) + colIndex) + dataSize ## Technically don't need since dataSize = 1 for char
				add $t4, $a1, $t4 	# previous equation + baseAddress
		
				li $v0, 11		# Call to print char
				lb $a0, 0($t4)		# Loads byte from char array
				syscall			# Will issue system call to print char same as printf("%c", shipPlaceP2[i][j]);
				addi $t3, $t3, 1	# j++
		
				j B2forLoopj
		B2loopjEnd:
			addi $t2, $t2, 1	# i++
			la $a0, newLine		# Print new line
			li $v0, 4
			syscall			# Will isuse system call to print new line same as printf("\n");
		
			j B2forLoopi
		
	B2loopiEnd:
		jr $ra
		

attackAlertP1:

		la $a0, hitMessage 	# Display hit message for each player 1 hit
		li $v0, 4
		syscall
				
		li $v0, 31 		# To play hit sound
		la $a1, duration 	# To load hit sound duration
		syscall	

		j endReplaceforP2
	
attackAlertP2:

		la $a0, hitMessage 	# Displat hit message for each player 2 hit
		li $v0, 4
		syscall
						
		li $v0, 31 		# To play hit sound
		la $a1, duration 	# To load hit sound duration
		syscall	

		j endReplaceforP1
		
		
		
		
populateBoardP1:

		###### Create board #####
		
		la $a1, boardGridP1
		lw $t0, size 		# i max bound # use size in case game board size changes
		lw $t1, size 		# j max bound # use size in case game board size changes
		la $a0, replaceSpace	# load address of custom character
		lb $t5, 0($a0)		# load actual custom character
		
		addi $t2, $zero, 0 # i = 0
	populateB1forLoopi:
			bge $t2, $t0, populateB1loopiEnd # i >= 10 or (i < 10 in C)
		
			addi $t3, $zero, 0 # j = 0
		populateB1forLoopj:
				bge $t3, $t1, populateB1loopjEnd # j >= 10 or (j < 10 in C)

				sb $t5, 0($a1)		# Store custom character into P1 board
				addi $t3, $t3, 1	# j++
				
				addi $a1, $a1, 1	# Iterate P1 board
				
		
				j populateB1forLoopj
		populateB1loopjEnd:
			addi $t2, $t2, 1	# i++
			
		
			j populateB1forLoopi
		
	populateB1loopiEnd:
		jr $ra
		
		
		
		
		
		
		
populateBoardP2:

		###### Create board #####
		
		la $a1, boardGridP2
		lw $t0, size 		# i max bound # use size in case game board size changes
		lw $t1, size 		# j max bound # use size in case game board size changes
		la $a0, replaceSpace 	# load address of custom character
		lb $t5, 0($a0)		# load actual custom character
		
		addi $t2, $zero, 0 # i = 0
	populateB2forLoopi:
			bge $t2, $t0, populateB2loopiEnd # i >= 10 or (i < 10 in C)
		
			addi $t3, $zero, 0 # j = 0
		populateB2forLoopj:
				bge $t3, $t1, populateB2loopjEnd # j >= 10 or (j < 10 in C)
				
				sb $t5, 0($a1)		# Store custom character into P2 board
				addi $t3, $t3, 1	# j++
				
				addi $a1, $a1, 1	# Iterate P2 board
				
		
				j populateB2forLoopj
		populateB2loopjEnd:
			addi $t2, $t2, 1	# i++
			
			
			j populateB2forLoopi
		
	populateB2loopiEnd:
		jr $ra	
		
