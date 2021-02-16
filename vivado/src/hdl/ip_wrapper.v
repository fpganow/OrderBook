`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2021 08:38:51 PM
// Design Name: 
// Module Name: ip_wrapper
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

module ip_wrapper(
    input    wire        clock,
    input    wire        data_in, // : in std_logic_vector(7 downto 0);
	input    wire        data_valid_in, // : in std_logic_vector(0 downto 0);
	input    wire        end_of_frame_in, // : in std_logic_vector(0 downto 0);
    output   wire[7:0]   data_out,
    output   wire        last_out,
    output   wire        valid_out,

    input    wire[47:0]  mac_in,
    input    wire[31:0]  ip_in,
    input    wire[15:0]  port_in
);

    NiFpgaIPWrapper_fpga_top LabVIEW(
		.reset(0), // : in std_logic;
		.enable_in(1), // : in std_logic;
		.enable_out(), // : out std_logic;
		.enable_clr(), // : in std_logic;
		.ctrlind_00_tlast(last_out), // : out std_logic_vector(0 downto 0);
		.ctrlind_01_tvalid(valid_out), // : out std_logic_vector(0 downto 0);
		.ctrlind_02_tdata(data_out), // : out std_logic_vector(7 downto 0);
		.ctrlind_03_MAC_Address(mac_in), // : in std_logic_vector(47 downto 0);
		.ctrlind_04_IP_Address(ip_in), // : in std_logic_vector(31 downto 0);
		.ctrlind_05_Dest_Port(port_in), // : in std_logic_vector(15 downto 0);
		.ctrlind_06_data_in(data_in), // : in std_logic_vector(7 downto 0);
		.ctrlind_07_data_valid_in(data_valid_in), // : in std_logic_vector(0 downto 0);
		.ctrlind_08_end_of_frame_in(end_of_frame_in), // : in std_logic_vector(0 downto 0);
		.ctrlind_09_out_2(), // : out std_logic_vector(0 downto 0);
		.ctrlind_10_out_1(), // : out std_logic_vector(0 downto 0);
		.ctrlind_11_in_2(1), // : in std_logic_vector(0 downto 0);
		.ctrlind_12_in_1(1), // : in std_logic_vector(0 downto 0);
		.Clk40Derived2x1I0MHz(clock) // : in std_logic
		);
endmodule