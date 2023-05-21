def convert(inFile, outFile1, outFile2):
	assembly_file = open(inFile, 'r')
	machine_file = open(outFile1, 'w')
	lut_file = open(outFile2, 'w')
	assembly = list(assembly_file.read().split('\n'))

	#keep track of index and file line number
	lineNum = 0;
	labelsNum = 0;

	#dictionaries to ease conversion of opcodes/operands to binary
	opcodes = {'AND' : '000', 'ADD' : '001', 'XOR' : '010', 'BNE' : '011',
	'LS' : '100', 'RS' : '101', 'LW' : '110', 'STR' : '111'}
    
	registers = {'r0' : '00', 'r1' : '01', 'r2' : '10', 'r3' : '11'}
	
	#reads through assembly and collects labels to populate lookup table
	lut = {}
	for line in assembly:
		instr = line.split();
		lineNum += 1
		#check if it is a label or not
		if instr[0] not in opcodes:
			lut[instr[0].replace(':', '')] = labelsNum
			lut_file.write(str(lineNum) + '\n')
			labelsNum += 1
	
	#reads through file to convert instructions to machine code
	for line in assembly:
		output = ""
		instr = line.split(); #split to get instruction and different operands
		#make sure it is an instruction, skip over labels
		if instr[0] in opcodes:
			output += opcodes[instr[0]]		
			del instr[0]
			if output == '000': # AND r1, r2, r3
				instr[0] = instr[0].replace(',', '').strip()
				if instr[0] in registers:
					output += registers[instr[0]]
					instr[1] = instr[1].replace(',', '').strip()
					if instr[1] in registers:
						output += registers[instr[1]]
					if instr[2] in registers:
						output += registers[instr[2]]

				
			elif output == '001': # Add r3, r2, #1
				instr[0] = instr[0].replace(',', '').strip()
				if instr[0] in registers:
					output += registers[instr[0]]
					instr[1] = instr[1].replace(',', '').strip()
					if instr[1] in registers:
						output += registers[instr[1]]
						imm = instr[2].replace('#', '')
						imm = bin(int(imm))[2:]
						imm = imm.zfill(2)
						output += imm
					
			elif output == '010': # XOR
				instr[0] = instr[0].replace(',', '').strip()  
				
				if instr[0] in registers:
					output += registers[instr[0]]
					instr[1] = instr[1].replace(',', '').strip()
					if instr[1] in registers:
						output += registers[instr[1]]
					
					if instr[2] in registers: 
						output += registers[instr[2]]; 
				
			elif output == '011': # BNE r1, r2, r3
				instr[0] = instr[0].replace(',', '').strip()  
				
				if instr[0] in registers:
					output += registers[instr[0]]
					instr[1] = instr[1].replace(',', '').strip()
					if instr[1] in registers:
						output += registers[instr[1]]
					
					if instr[2] in registers: 
						output += registers[instr[2]]; 				
			
			elif output == '100': # LS r4, #4
				instr[0] = instr[0].replace(',', '').strip()
				if instr[0] in registers:
					output += registers[instr[0]]
					imm = instr[1].replace('#', '')  # remove '#' symbol
					imm = bin(int(imm))[2:]  # convert immediate to binary
					imm = imm.zfill(4)  # pad to 4 bits
					output += imm  # add leading zero

				
			elif output == '101': # RS
				instr[0] = instr[0].replace(',', '').strip()
				if instr[0] in registers:
					output += registers[instr[0]]
					imm = instr[1].replace('#', '')  # remove '#' symbol
					imm = bin(int(imm))[2:]  # convert immediate to binary
					imm = imm.zfill(4)  # pad to 4 bits
					output += imm  # add leading zero 
						
			elif output == '110': # LOAD r1, r2
				instr[0] = instr[0].replace(',', '').strip()  
				
				if instr[0] in registers:
					output += registers[instr[0]]

					instr[1] = instr[1].strip()			

					if instr[1] in registers:
						output += registers[instr[1]]
							
					output += '00'
	
			elif output == '111': # STORE r1, r2
				instr[0] = instr[0].replace(',', '').strip()   
				
				if instr[0] in registers:
					output += registers[instr[0]]

					instr[1] = instr[1].strip()

					if instr[1] in registers:
						output += registers[instr[1]]
								
					output += '00' 
	
			else:
				pass
				
			machine_file.write(str(output) + '\t// ' + line + '\n')

	assembly_file.close()
	machine_file.close()

#convert("assembly.txt", "machine.txt", "lut.txt")
# convert("stringmatch.txt", "sm_machine.txt", "sm_lut.txt")
# convert("cordic.txt", "c_machine.txt", "c_lut.txt")
# convert("division.txt", "d_machine.txt", "d_lut.txt")
convert("Assembler\Program1.txt", "Assembler\out.txt", "Assembler\out2.txt")