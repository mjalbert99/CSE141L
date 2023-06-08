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


### Program 3
