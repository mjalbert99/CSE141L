We did our live demo with Elbruz on Tuesday, 06/13. 

This document is a quick overview of the ISA, top_level and corresponding modules, and the assembly logic written in plain english. Moreover, this is for grading purposes

## ISA
The ISA for this project is a 9-bit wide instruction code. We have 8 instructions (3-bits), 4 registers(2-bits each), and a combination fo 2-bit and 4-bit immediates we use based on the instruction. Theses are the following formats for each instruction (notes for each instruction will be provided underneath the format)

`AND & XOR` : `|OP CODE| dest reg| regA | regB|`
- Example `AND r1, r2, r3`  will perfom `r1 = r2 & r3`. This follows the standard convention of ARM

`ADD` : `|OP CODE| dest reg | regA | 2-bit immediate|`
- Example `ADD r1, r2, #3`  will perfom `r1 = r2  + 3`. This follows the standard convention of ARM for an immediate

`LS & RS` : `|OP CODE| dest reg| 4-bit immediate|`
- For right and left shift we treat the `dest reg` as the source and destination of data. In other words `dest reg` is the register being read from, modified, and then stored back into. Example Example `LS r1, #6`  will perfom `r1 = r1 << 6`.

`LW` : `|OP CODE| reg to load to | regA |`
- For load we use `regA` as a 8-bit address to expand the memory we can access. By using a 8-bit register instead of a 4-bit immediate it allows us more options. Example, assume r2 holds 64, `LW r1, r2` will perform `r1 = mem[r2] -> r1 = mem[64]`

`SW` : `|OP CODE| reg to write from | regA |`
- For store we use `regA` as a 8-bit address to expand the memory we can access. By using a 8-bit register instead of a 4-bit immediate it allows us more options. Example, assume r2 holds 64, `SW r1, r2` will perform `mem[r2] = r1 -> mem[64] = r1`

`BNE` : `|OP CODE| regA | regB | regC|`
- For branch not equal we treat `regA` and `regB` as the comparision registers and `regC` will hold an intege values that will be an index in a `LUT` to where to update the program counter to. Example r1 = 0, r2 = 5, r3 = 3; `BNE r1, r2, r3 -> if(0 != 5) program_ctr = LUT[3]`

All these instructions are implemented in the `alu.sv` file in system verilog

## System Verilog Code/ top_level

### Program Counter
The program counter takes in the inputs `reset`, `clk`, bit `absjump_en`, `input`, and `target`. `Reset` and `clk` are standard convention for a program counter so it wont be explained but for `absjump_en` it is an enabling bit that will tell the program counter when to use the `input` value or the `target` value to update the program counter value. `Input` is the existing program counter whereas `target` is the value coming from the LUT. So `absjump_en` allows us to branch. The output `prog_ctr` is the value of the program counter and will be fed into the instruction memory

### Instruction Memory
The instruction memory works by taking in the `prog_ctr` of the program counter and using it to index a machine code array. This machine code array is loaded from a file and stored in a variable called `core`. Once the `prog_ctr` indexes the `core` the instruction memory will output the machine code `mach_code` this represents the current line of machine code to be ran. This will be fed to the control unit and the register control.

### Control Unit
The control unit is used to control the flow of machine code and what pparts of the machine code will be used. It takes in the input `mach_code` from the instruction memory and will output signal bits `RegDst, Branch, MemWrite, ALUSrc, RegWrite, MemtoReg, ALUOp`. The control will take the top 3 bits of the machine code where the instruction bits are and use that to decide what signals need to be high or low to perform that instruction; furthermore it sets `ALUOp` to the instruction bits of the machine code. `ALUOp` will then be fed into the ALU unit. For the remaining output bits `RegDst` is sent to the register control, `Branch` is sent to the LUT and register control, `MemWrite` is sent to the register control and the data memory unit, `ALUSrc` is used in a mux to decide is to use an immediate or not (that value is fed into the ALU), `RegWrite` is fed into the register file, `MemtoReg` will be fed into the register control, the data memory unit, and be used in a mux to decide what to write back to the register file( memory or the result of the ALU).

### Register Control
Is a unit used to control what portions of the machine code will be used for immediate values, register indices to load from, register index to write to, and what portion of machine code holds the branching index. In other words it controls the flow of bits the register will use for specific instruction as well for immediate values. It takes in as inputs `RegDst, MemtoReg, MemWrite, and Branch` from the control unit and the machine code `mach_code` from the instruction memory. It will then output `inA, inB, inC, and write_adr` which will all be fed into the register file. As well as output `immediate` which will be the immedaite value that will be fed to the mux that feds into the ALU. Thi unit works by taking the control signals and using if statements to decide what part of the machine code `inA, inB, inC, write_adr, and immediate` should be.

### Register File
The register file is used to access and update register's and thier values. For us we use 4 registers. For inputs we have `dat_in` which is a value for data memory or the result of the ALU, `clk`, `write_en` which is `RegWrite`, `wr_addr` which is the index of the register to write to and is the `write_adr` from the register control, and `rd_AddrA, rd_AddrB, & rd_AddrC` which are `inA, inB, & inC`. It outputs `datA_out, datB_out, and datC_out` which are used as inputs for the ALU.

### MUX before ALU
The mux before the ALU is used to decide if the value being fed into the ALU for `inA` is an immedaite ot the `datA_out` from the register file. This allows us to use immdiate values for the `ADD, RS, and LS` operations.

### ALU
The ALU is the unit that handles all operations between registers and immediates. It has the inputs `alu_cmd` which is the `ALUOp` from the control,and `inA, inB, & inC` which are the the mux before the ALU, `datB_out` from the register file, and `datC_out` from the register file. It has the output `rslt` which is the result of the current ALU operation and `branch_pc` which is a bit used to signal when to branch. The `rslt` output is fed into data memory and the mux that decides what is fed to the register file for `dat_in`. The `branch_pc` bit is used as the input for the program counter `absjump_en`.

### Data Memory
The data memory unit is used to store and access memory of the machine. This takes as inputs `dat_in` the data to write to memory and is `datB_out` from the register file, `clk`, `wr_en` which tells it when to write to memory and is the `MemWrite` from the control, `rd_en` whihc tells it when to read from memory and is `MemtoReg` from the control, and `addr` which is the address to access and is the `rslt` of the ALU. This will then have a single output `dat_out` which is tha value from memory being loaded.

### The dat_in mux for the register file
This mux controls what data will be fed into the register file for writing this is either the result of the data memory or the ALU and is decided by `MemtoReg` from the control.

### LUT
The LUT is a case statment block that holds specific program counter values to use for the `target` for the program counter. This has the inputs `addr` for the specific index and is the `rslt` of the ALU and `branch` which is the contorl bit `Branch` and tells it when to load a target value. It has the output `target` which holds the program counter value to branch to and is fed into the program counter for the `target` input.

## Logic Behind Assembly

### Program 1
Program 1 works by us taking two consecutive bytes of memory calculating parity bits `p8, p4, p2, p1, and p0` then using those to form a new message and store it in memory. The parity bits are found by taking the existing bits from the bytes and performing XOR operations to extract a single bit. This is done by using the values 128, 64, 32, 16, 8, 4, 2, and 1 XOR'd with the byte to get a single bit. We then shift over that bit to the 0th place of the byte then XOR that with another isolated bit. Repeating this to form each parity bit. We form each parity bit in a single loop itertion and store each bit in the corresponding memory spot `p8:65, p4:66, p2:67, p1:68, and p0:69`. We then use this bits to form the new bytes. This is done by right and left shifting the orignal bits and XOR'ing with the parity bits to create the new bytes which will form a new message. To repeat this for 15 messages we store a counter variable that will also act as an index into what bytes to use. This counter will be stored in memory 64. To store the new bytes we take the current counter index and store in the current index + 30 and the current index +31. The current counter index also in incremented by two for each new message as each message has 2 bytes. We then see if the counter index is 30 and if it is not then we branch back to the begining to find the next message. Repeating until the counter is at 30 where we do not branch and set the done bit to high.

### Program 2
Program 2 starts by looping through all 15 inputs, where each iteration of the loop looks at 2 relevant bytes of memory. Starting from the LSB of the first byte all the way to the MSB of the second byte, we extract each individual bit and store it in memory (i.e p0 is at mem[130], p1 at mem[131], ... d4 at mem[137], ..., d11 at mem[145]). This is done through a series of ANDs and shifts. Afterwards, we calculate the expected parity bits based off the data we recieved in the order p0, p8, p4, p2, p1, and then also storing these at memory addresses 146-150 respectively. In the calculation of these parity bits, we also XOR them with the recieved parity bits (i.e new p8 = relevant data bits ^ received p8). This is done through a series of STORES and ADDS to get the correct memory addresses, and then XORs. We then go through a series of BRANCHs. We first check whether p0 = 1, and if so, immediately branch to the One Error Handling Case. To handle one error, we retrieve the calculated parity bits from memory (new p8 .... new p1) and through a series of XORs and LEFT SHIFTS, we build the value telling us the bad bit index. We use the value bad bit index / 8 to tell us whether the bad bit is in the first or second input byte, and then bad bit index MOD 8 (which is bad bit index AND 7) to tell us which position the bad bit is in. We then flip that bit in its memory location, build the top half of our output to start with 01 (F1 F0) as mentioned in the writeup. If p0 = 0, then we go through a loop checking whether all the other calculated parity bits are 0. If even one parity bit is 1, we branch to the Two Error case (where we simply build F1 F0 to be 10) and if none of the parity bits are 1, then we go into the No Error Case (building F1 F0 to be 00). From here, regardless of which case we branched to, the program builds the output as required using the data bits in memory.

### Program 3
Program 3 does each part (a,b,c) separately, writing the relevant result to memory after each part. In between the calculations for each part, we reset certain memory values (such as for our loop indices "i" and "j") back to 0. 

For part a, we have two loops, an outer loop dictated by an index "i" (stored at mem[128]) and an inner loop dictated by an index "j" (mem[129]). The outer loop runs from 0 to 31, where "i" is used to get the relevant input byte from memory. This byte is always stored in register r2 throughout the duration of the outer loop. The inner loop runs from 0 to 4, where we extract the bottom 5 bits of the value in r2 (using r2 AND 32), and then XOR this value with the pattern in mem[32]. If the result of the XOR is 0, then we know we have a match, and we increment the value in mem[33] through loads and stores. If the result of the XOR is 1, then we branch over the increment. Then, we right shift r2 by 1, so that on the next iteration of the inner loop, we can look at the next 5 bits. When j = 4, we would have compared all possibilities with the pattern, and so we increment i and continue on with the outer loop until finished.

Part b works similarly to part a, with the same notion of the outer and inner loops. The only difference is that when a match is found, we increment the counter in mem[34] and immediately branch to the continuation of the outer loop (where we increment i and proceed). 

Part c also has the same notion of the outer and inner loops. However, unlike in other parts, we first load the input byte mem[0] into r2, and have the outer loop range from 1 to 31. We will also store the contents of mem[i] into mem[130] where it will be manipulated throughout the inner loop. This is done because after we compare the contents of r2 with the pattern, we will modify r2 by left shifting and taking the MSB of the next byte in mem[130]. We will also left shift this next byte, and store it's contents in mem[130] so on the next iteration, we will retrieve the updated MSB. This is what enables us to count over memory boundaries. The inner loop runs from 0 to 8 (not 4), so that on every iteration of the outer loop, we would've have completely processed all of the bits in mem[i-1]. This means that since i = 31 is the last iteration of the outer loop, we will have only processed data up to mem[30]. Therefore, we will separately compare mem[31] with the pattern similar to how we do in part a. Throughout this entire process, on a match, we will be incrementing the result at mem[35].  
