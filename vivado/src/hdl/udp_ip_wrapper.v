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

module udp_ip_wrapper(
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

// Wires coming from Ethernet MAC
//  last_out <= IP ignores this
//  valid_out
//  data_out


 
endmodule