module MainDecoder (
    input [6:0] opcode,
    output reg [1:0] aluOP,
    output reg [1:0] resultSrc,
    output reg [1:0] aluSrcA,
    output reg [2:0] immSrc,
    output reg branch,
    output reg memWrite,
    output reg memRead,
    output reg aluSrcB,
    output reg regWrite,
    output reg jump
);
    //Arithmetic
    localparam R_TYPE  = 7'b011_0011;
    localparam I_TYPE  = 7'b001_0011;
    //Memory
    localparam STORE   = 7'b010_0011;
    localparam LOAD    = 7'b000_0011;
    //Control
    localparam B_TYPE  = 7'b110_0011;
    localparam JAL     = 7'b110_1111;
    localparam JALR    = 7'b110_0111;
    //Other
    localparam AUIPC   = 7'b001_0111;
    localparam LUI     = 7'b011_0111;


    always @(*) begin
        case (opcode)
            R_TYPE: begin   
                regWrite   = 1;          
                immSrc    = 3'b000;
                aluSrcA   = 2'b00;      
                aluSrcB   = 0;
                memWrite  = 0;
                memRead   = 0;          
                resultSrc = 2'b00;
                branch    = 0;          
                aluOP     = 2'b10; 
                jump      = 0;
            end
            I_TYPE: begin   
                regWrite  = 1;          
                immSrc    = 3'b000;
                aluSrcA   = 2'b00;      
                aluSrcB   = 1;
                memWrite  = 0;
                memRead   = 0;                    
                resultSrc = 2'b00;  
                branch    = 0;          
                aluOP     = 2'b10;
                jump      = 0;
            end
            STORE: begin   
                regWrite  = 0;          
                immSrc    = 3'b001;
                aluSrcA   = 2'b00;      
                aluSrcB   = 1;
                memWrite  = 1;
                memRead   = 0;                    
                resultSrc = 2'b11;  // x
                branch    = 0;          
                aluOP     = 2'b00;
                jump      = 0;
            end
            LOAD: begin   
                regWrite  = 1;
                immSrc    = 3'b000;
                aluSrcA   = 2'b00;
                aluSrcB   = 1;
                memWrite  = 0;
                memRead   = 1;                    
                resultSrc = 2'b01;
                branch    = 0;          
                aluOP     = 2'b00;
                jump      = 0;          
            end
            B_TYPE: begin   
                regWrite  = 0;          
                immSrc    = 3'b010;
                aluSrcA   = 2'b00;      
                aluSrcB   = 0;
                memWrite  = 0;
                memRead   = 0;                    
                resultSrc = 2'b11;  
                branch    = 1;          
                aluOP     = 2'b01;
                jump      = 0;
            end
            JAL: begin   
                regWrite  = 1;          
                immSrc    = 3'b011;
                aluSrcA   = 2'b10;      
                aluSrcB   = 1;
                memWrite  = 0;
                memRead   = 0;                    
                resultSrc = 2'b10;  
                branch    = 0;          
                aluOP     = 2'b00;
                jump      = 1;
            end
            JALR: begin   
                regWrite  = 1;          
                immSrc    = 3'b000;
                aluSrcA   = 2'b00;      
                aluSrcB   = 1;
                memWrite  = 0;
                memRead   = 0;                    
                resultSrc = 2'b10;  
                branch    = 0;          
                aluOP     = 2'b00;
                jump      = 1;
            end
            AUIPC: begin
                regWrite  = 1;          
                immSrc    = 3'b100;
                aluSrcA   = 2'b10;      
                aluSrcB   = 1;
                memWrite  = 0;
                memRead   = 0;                    
                resultSrc = 2'b00;  
                branch    = 0;          
                aluOP     = 2'b00;
                jump      = 0;
            end
            LUI: begin   
                regWrite  = 1;          
                immSrc    = 3'b100;
                aluSrcA   = 2'b01;      
                aluSrcB   = 1;
                memWrite  = 0;
                memRead   = 0;                    
                resultSrc = 2'b00;  
                branch    = 0;          
                aluOP     = 2'b00;
                jump      = 0;
            end
            default:    begin   
                regWrite  = 0;          
                immSrc    = 3'b000;
                aluSrcA   = 2'b00;      
                aluSrcB   = 0;
                memWrite  = 0;
                memRead   = 0;                    
                resultSrc = 0;
                branch    = 0;          
                aluOP     = 2'b00;
                jump      = 0;
            end
        endcase
    end
endmodule