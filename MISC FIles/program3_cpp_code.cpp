// Use reg3 for all counters
// Load pattern into reg1
// Load current byte into reg2

int byte_counter = 0;		// part a.) reg3
int number_bytes = 0;		// part b.)
int string_counter = 0;		// part c.)

int pattern = mem[32]		// reg1

// Part a.)
for(int i = 0; i < 32; i++){  // Loop for all 32 bytes(8 bits wide)
	curr_byte = mem[i]	// reg2
	
	for(int j = 0; j < 3; j++){ // Loop for all consecutive 5-bits in a byte
		
		pattern << j; // Shifts bits over to left(REQUIRES pattern reloading for each byte)
		OR
		curr_byte >> j // Shifts bits over to right (REQUIRES right shift command)
		
		if(curr_byte == pattern){ // And operation store in reg4 -> reg4 = curr_byte & pattern
			byte_counter++;		 // reg3 += reg4
		}
	}
	
}

int pattern = mem[32]		// reg1

// Part b.)
for(int i = 0; i < 32; i++){  // Loop for all 32 bytes(8 bits wide)
	
	curr_byte = mem[i]	// reg2
	
	for(int j = 0; j < 3; j++){ // Loop for all consecutive 5-bits in a byte
		
		pattern << j; // Shifts bits over to left (REQUIRES pattern reloading for each byte)
		OR
		curr_byte >> j // Shifts bits over to right (REQUIRES right shift command)
		
		if(curr_byte == pattern){ // And operation store in reg4 -> reg4 = curr_byte & pattern
			number_counter++;	  // reg3 += reg4
			break; // breaks from nested loop
		}
	}
	
}


// Part c.)

for(int i = 0; i < 32; i++){
	
	
}
