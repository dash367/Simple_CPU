module simple_comp(clock,pc,ir,mbr,ac,mar);
//define the input 
input clock;
//define the output, PC:program counter, 
//IR:instruction register, MBR:memory buffer register, AC:accumulator, 
//MAR:memory address register, outdx: output devices
output pc,ir,mbr,ac,mar; 
//define the registers
reg [15:0] ir,mbr,ac;
reg [11:0] pc,mar;
reg [15:0] memory [0:63];//memory of 64 words, each word is 2 bytes
reg [2:0] state;
//provide opcodes for the instructions
parameter load = 4'b0011,store=4'b1011,add=4'b0111,jump=4'b0001;

initial begin 
//instruction memory
memory[10]=16'h3020; //load location 32 from memory to AC
memory[11]=16'h7021; //add AC with location 33 and save to AC
memory[12]=16'hB012; //store AC in location 12


//data memory
memory[32]=16'd7; //store number in location 12 in memory
memory[33]=16'd5; //store number in location 13 in memory
pc=10; //start with PC = 10, so first instruction will be the one that in location 10 (16'h300a)
state=0;//state in indicate to each state : instruction fetch, instruction decode, operand fetch, excution
end

always @ (posedge clock) begin // loop one time for each clock rising edge
case (state)
0:begin //initialization of MAR to get the instruction from memory
  mar <= pc; //store PC to MAR because when we want to access the memory, we should store the address in MAR
  state=1; //go to next step next clock
  end
1:begin//instruction fetch
  mbr <= memory[mar]; //store the instuction in IR
  pc <= pc+1; //go one instruction a head
  state=2;
  end
2:begin//instruction fetch
  ir <= mbr; //store the instuction in IR
  state=3;
  end
3:begin //instruction decode
  mar <= ir[11:0];//store the address in MAR to access the memory in the next step in case the instruction is Load or Store
  state=4;
  end
4:begin //operand fetch
  state=5;
  case (ir[15:12]) // fill the value of MBR with the correct pattern in each operation type
    load : mbr <= memory[mar];
    add  : mbr <= memory[mar];
    store: mbr <= ac;
    jump : mbr <= mar;
  endcase
  end     
5:begin //excution
  if(ir[15:12]==4'h7)begin //addition
    ac <= ac+mbr;
    state=0;  
  end
  else if(ir[15:12]==4'h3)begin //load
    ac <= mbr;
    state=0;
  end
  else if(ir[15:12]==4'hb)begin //store
    memory[mar] <= mbr;
    state=0;
  end
  else if(ir[15:12]==4'h1)begin //jump
    pc <= mbr;
    state=0;
  end
 end
endcase
end
endmodule  