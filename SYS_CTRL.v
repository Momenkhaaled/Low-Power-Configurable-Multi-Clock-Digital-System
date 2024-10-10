module SYS_CTRL(
input wire CLK,RST,
input wire [7:0] UART_RX_DATA,
input wire UART_RX_VLD,
input wire FIFO_FULL,
input wire RF_RdData_VLD,
input wire [7:0] RF_RdData,
input wire [15:0] ALU_OUT,
input wire ALU_OUT_VLD,
output reg RF_WrEn,RF_RdEn,CLKG_EN,CLKDIV_EN,ALU_EN,
output reg [3:0] RF_Address,
output reg [7:0] RF_WrData,
output reg [3:0] ALU_FUN,
output reg [7:0] UART_TX_DATA,
output reg  UART_TX_VLD
);

localparam    idle=4'b0000,
              decode1=4'b0001, 
              decode2=4'b0010,
              decode3=4'b0011,
              decode4=4'b0100,
              wr_add=4'b0101,
              wr_data=4'b0110,
              rd_add=4'b0111,
              rf_fifo=4'b1000,
              alu_fun=4'b1001,
              alu_fifo=4'b1010,
              opA=4'b1011,
              opB=4'b1100;
              
reg [3:0] current_state,next_state;

always @(posedge CLK,negedge RST)
begin
  if(!RST)
    current_state<=idle;
  else
    current_state<=next_state;
end  

//////////for states/////////////////////

always @(*)
begin
  case(current_state)
	idle:begin
	 if(UART_RX_VLD && UART_RX_DATA==8'hAA)
	 next_state=decode1;
	 else if(UART_RX_VLD && UART_RX_DATA==8'hBB)
	 next_state=decode2;
	 else if(UART_RX_VLD && UART_RX_DATA==8'hDD)
	 next_state=decode3;
	 else if(UART_RX_VLD && UART_RX_DATA==8'hCC)
	 next_state=decode4;
	 else
	 next_state=idle;
  end
	
  decode1:begin
    if(UART_RX_VLD)
      next_state=wr_add;
    else
      next_state=decode1;
	end
	
	decode2:begin
    if(UART_RX_VLD)
      next_state=rd_add;
    else
      next_state=decode2;
	end
	
	decode3:begin
    if(UART_RX_VLD)
      next_state=ALU_FUN;
    else
      next_state=decode3;
	end
	
	decode4:begin
    if(UART_RX_VLD)
      next_state=opA;
    else
      next_state=decode4;
	end
	
	
	wr_add:begin
	 if(UART_RX_VLD)
	 next_state=wr_data;
	 else
	 next_state=wr_add;
	end
	
	wr_data:begin
	 next_state=idle;
	end
	
	rd_add:begin
	 if(RF_RdData_VLD)
	 next_state=rf_fifo;
	 else
	 next_state=rd_add;
	end
	
	rf_fifo:begin
	 if(!FIFO_FULL )
	 next_state=idle;
	 else
	 next_state=rf_fifo;
	end
	
	alu_fun:begin
	 if(ALU_OUT_VLD)
	 next_state=alu_fifo;
	 else
	 next_state=alu_fun;
	end
	
	alu_fifo:begin
	 if(!FIFO_FULL )
	 next_state=idle;
	 else
	 next_state=alu_fifo;
	end
	
	opA:begin
	 if(UART_RX_VLD)
	 next_state=opB;
	 else
	 next_state=opA;
	end
	
	opB:begin
	 if(UART_RX_VLD)
	 next_state=alu_fun;
	 else
	 next_state=opB;
	end
	
	default:begin
	 next_state=idle;
	 end
  
  endcase
end

/////////////////////for outputs///////////////////////

always @(*)
begin
RF_WrEn=0;
RF_RdEn=0;
ALU_EN=0;
UART_TX_VLD=0;
CLKG_EN=0;
CLKDIV_EN=1;

  case(current_state)
	idle:begin
	 RF_WrEn=0;
     RF_RdEn=0;
     ALU_EN=0;
     UART_TX_VLD=0;
     CLKG_EN=1;
     CLKDIV_EN=1;
    end
	
  decode1:begin
     RF_WrEn=0;
     RF_RdEn=0;
     ALU_EN=0;
     UART_TX_VLD=0;
     CLKG_EN=0;
     CLKDIV_EN=1;
	end
	
   decode2:begin
     RF_WrEn=0;
     RF_RdEn=0;
     ALU_EN=0;
     UART_TX_VLD=0;
     CLKG_EN=0;
     CLKDIV_EN=1;
	end
	
   decode3:begin
     RF_WrEn=0;
     RF_RdEn=0;
     ALU_EN=0;
     UART_TX_VLD=0;
     CLKG_EN=1;
     CLKDIV_EN=1;
	end
	
   decode4:begin
     RF_WrEn=0;
     RF_RdEn=0;
     ALU_EN=0;
     UART_TX_VLD=0;
     CLKG_EN=0;
     CLKDIV_EN=1;
	end
	
	wr_add:begin
	 RF_Address=UART_RX_DATA;
	end
	
	wr_data:begin
	 RF_WrEn=1;
	 RF_WrData=UART_RX_DATA;
	end
	
	rd_add:begin
	 RF_RdEn=1;
	 RF_Address=UART_RX_DATA;
	end
	
	rf_fifo:begin
	 UART_TX_VLD=1;
	 UART_TX_DATA=RF_RdData;
	end
	
	alu_fun:begin
	 ALU_EN=1;
	 ALU_FUN=UART_RX_DATA;
	 CLKG_EN=1;
	end
	
	alu_fifo:begin
	 UART_TX_DATA=ALU_OUT;
	 UART_TX_VLD=1;
	 CLKG_EN=1;
	end
	
	opA:begin
	 RF_WrEn=1;
	 RF_Address=0000;
	 RF_WrData=UART_RX_DATA;
	end
	
	opB:begin
	 RF_WrEn=1;
	 RF_Address=0001;
	 RF_WrData=UART_RX_DATA;
	 CLKG_EN=1;
	end
	
	default:begin
	 RF_WrEn=0;
     RF_RdEn=0;
     ALU_EN=0;
     UART_TX_VLD=0;
     CLKG_EN=0;
     CLKDIV_EN=1;
     RF_WrData=0;
     RF_Address=0;
     ALU_FUN=0;
     UART_TX_DATA=0;
	 end
  
  endcase
end          

endmodule
