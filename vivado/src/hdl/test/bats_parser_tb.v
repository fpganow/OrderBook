`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2021 09:23:26 PM
// Design Name: 
// Module Name: bats_parser_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bats_parser_tb;

    // 10ns = 100 MHz
    // 20ns = 50 MHz
    // 25ns = 40MHz
    // duration for each bit = 20 * timescale = 20 * 1 ns = 20 ns
    localparam period = 20;
    localparam duty_cycle = period / 2;

    reg clk;

    always
    begin
        clk = 1'b1;
        #duty_cycle;

        clk = 1'b0;
        #duty_cycle;
    end

    // UDP Payload related signals/registers
    reg data_valid_in;
    reg [7:0]data2_in;
    reg[7:0] bats_data;
    wire [15:0] orderbook_command;
    wire orderbook_command_valid;
    wire [63:0] symbol;


    NiFpgaIPWrapper_bats_parser_ip UUT (
		.reset(0),
        .enable_in(1),
        .enable_out(),
        .enable_clr(0),
        .ctrlind_00_Ready_for_OrderBook_Command(1),
        .ctrlind_01_OrderBook_Command_Valid(orderbook_command_valid),      // out std_logic_vector(0 downto 0);
        .ctrlind_02_Cancelled_Quantity_U32(),       // out std_logic_vector(31 downto 0);
        .ctrlind_03_Executed_Quantity_U32(),        // out std_logic_vector(31 downto 0);
        .ctrlind_04_Price_U64(),                    // out std_logic_vector(63 downto 0);
        .ctrlind_05_Symbol_U64(symbol),                   // out std_logic_vector(63 downto 0);
        .ctrlind_06_Quantity_U32(),                 // out std_logic_vector(31 downto 0);
        .ctrlind_07_Order_Id_U64(),                 // out std_logic_vector(63 downto 0);
        .ctrlind_08_Side_U8(),                      // out std_logic_vector(7 downto 0);
        .ctrlind_09_OrderBook_Command(orderbook_command),            // out std_logic_vector(15 downto 0);
        .ctrlind_10_data_valid(data_valid_in),  // in std_logic_vector(0 downto 0);
        .ctrlind_11_data(bats_data),              // in std_logic_vector(7 downto 0);
        .ctrlind_12_reset(0),                   // in std_logic_vector(0 downto 0);
        .ctrlind_13_Ready_for_Udp_Input(), // out std_logic_vector(0 downto 0);
        .Clk40Derived2x1I0MHz(clk)
    );


    integer fptr;
    integer scan_faults;
    
    //reg[7:0] bats_data [0:7];

    initial
    begin
        fptr = $fopen("raw.pitch.dat", "rb");
        if(fptr == 0)
        begin
            $display("raw.pitch.dat was NULL");
            $finish;
        end
        while (!$feof(fptr))
        begin
            scan_faults = $fread(bats_data, fptr);
            data2_in = bats_data;
            data_valid_in = 1'b1;
            //data2_in = 8'b11101001;
            #period;           
        end
        $fclose(fptr); // Close file before finish

        $finish;
    end

//    always @(posedge clk)
//    begin
//        data_valid_in = 1'b1;
//    end
endmodule