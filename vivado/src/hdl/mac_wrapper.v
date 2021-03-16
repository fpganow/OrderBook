`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2021 06:57:40 PM
// Design Name: 
// Module Name: udp_wrapper
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


module mac_wrapper(
    input wire clk,
    input wire reset,

//    // FIFO 0 to MicroBlaze
//    input   wire [31:0]  axi_str_rxd_tdata,
//    input   wire         axi_str_rxd_tlast,
//    output  wire         axi_str_rxd_tready,
//    input   wire         axi_str_rxd_tvalid,

//    output  wire  [31:0]  axi_str_txd_tdata,
//    output  wire          axi_str_txd_tlast,
//    input   wire          axi_str_txd_tready,
//    output  wire          axi_str_txd_tvalid,

    // FIFO 1 to MicroBlaze
//    input   wire [31:0]  axi_str_rxd_1_tdata,
//    input   wire         axi_str_rxd_1_tlast,
//    output  wire         axi_str_rxd_1_tready,
//    input   wire         axi_str_rxd_1_tvalid,

//    output  wire  [31:0]  axi_str_txd_1_tdata,
//    output  wire          axi_str_txd_1_tlast,
//    input   wire          axi_str_txd_1_tready,
//    output  wire          axi_str_txd_1_tvalid,

    output  wire          end_of_frame_out,
    output  wire          data_valid_out,
    output  wire  [31:0]  data_out,
//    assign axi_str_txd_tlast = end_of_frame;
//    assign axi_str_txd_tvalid = data_valid;
//    assign axi_str_txd_tdata = data;

    // These are the PHY MII pins
    // phy_rx_clk is driven by the PHY and is:
    //  2.5 MHz for 10 Mbit/s
    //  25 MHz for 100 Mbit/s
    input   wire       phy_col,
    input   wire       phy_crs,
    input   wire       phy_rx_clk,
    input   wire       phy_dv,
    input   wire       phy_rx_er,
    input   wire[3:0]  phy_rx_data,
    input   wire       phy_tx_clk
//    output  wire       phy_rst_n,
//    output  wire       phy_tx_en,
//    output  wire[3:0]  phy_tx_data

    // These are the signals for the LabVIEW IP
//    input wire ip_clk_40,
//    input wire ip_clk_83_33,
//    input wire ip_btn_1_in,
//    input wire ip_btn_2_in,
//    input wire ip_btn_3_in,
//    input wire ip_btn_4_in,
//    output wire ip_btn_1_out,
//    output wire ip_btn_2_out,
//    output wire ip_btn_3_out,
//    output wire ip_btn_4_out
    );

    wire          Transmitting;
    reg           sending = 0;
    assign        Transmitting = sending;
    reg           done_sending = 0;

    wire [1:0]    StateData;
    wire          StateIdle;
    wire          StatePreamble;
    wire          StateSFD; 
    wire          StateDrop;

    wire MRxDEqD;
    wire MRxDEq5;
    assign MRxDEqD = phy_rx_data == 4'hd;  
    assign MRxDEq5 = phy_rx_data == 4'h5;

    wire IFGCounterEq24;
    wire ByteCntMaxFrame;
    assign IFGCounterEq24 = 1;
    assign ByteCntMaxFrame = 0;

    eth_rxstatem ETH_MAC_STATE(
        .MRxClk(phy_rx_clk),
        .Reset(~reset),
        .MRxDV(phy_dv),
        .Transmitting(Transmitting),
        .MRxDEq5(MRxDEq5),
        .MRxDEqD(MRxDEqD), 
        .IFGCounterEq24(IFGCounterEq24),
        .ByteCntMaxFrame(ByteCntMaxFrame),
        .StateData(StateData),
        .StateIdle(StateIdle),
        .StatePreamble(StatePreamble),
        .StateSFD(StateSFD), 
        .StateDrop(StateDrop)
    );

//    //  | Clock Frequency  |  Period  |  Interval  |
//    //  | 100MHz           |  10ns    |  5ns       |
//    //  | 50MHz            |  20ns    |  10ns      |
//    //  | 20MHz            |  25ns    |  12.5ns    |
//    // duration for each bit = 20 * timescale = 20 * 1 ns = 20 ns
//    // # of clock periods to wait in between each AXI packet is sent
//    // Ideally I want this to be once per second.
////    localparam CONS_PACKET_PERIOD = 83333333;
////    localparam CONS_PACKET_PERIOD = 833_333_333;
////    localparam CONS_NUM_PACKETS = 3;
////    localparam CONS_PACKET_LENGTH = 5;


    localparam MAX_NUM_PACKETS = 1;
    reg[7:0] packet_buffer  [0:MAX_NUM_PACKETS-1][0:500];
//    reg      packet_good    [0:MAX_NUM_PACKETS-1];
//    reg      packet_bad     [0:MAX_NUM_PACKETS-1];

    integer packet_to_read;
    integer packet_to_read_i;
    integer packet_to_read_length;

    integer packet_to_send;
    integer packet_to_send_i;
    integer packet_to_send_length;

    reg         data_valid;
    reg[31:0]   data;
    reg         end_of_frame;

    // This loop sets the variables for the output interface which should
    // go to the LabVIEW code
    // phy_rx_clk and phy_tx_clk are driven by eth_ref_clk, which is generated
    // by the block design
    always @ (posedge phy_rx_clk)
    begin
        if(~reset)
            begin
                sending = 0;

                packet_to_read = 0;
                packet_to_read_i = 0;
                packet_to_read_length = 0;
                packet_to_send_length = 0;
            end
//        else if(axi_str_txd_tready == 1'b0)
//            begin
//                // Collect packets only if MicroBlaze is ready.
//            end
        else
            begin
            if(sending == 1 && done_sending == 1)
                begin
                    sending = 0;

                    packet_to_read = 0;
                    packet_to_read_i = 0;
                    packet_to_read_length = 0;
                    packet_to_send_length = 0;
                end
            else if(sending == 0)
                begin
                    // StatePreamble -> StateSFD -> (StateData0 | StateData1) -> StateIdle
                            // This means that there is no valid data.  If we enable CRC checking
                            // we could probably tell if the frame was good or bad.
                            // So we want to mark the packet as ready to send and save the length
                            // We want to know if we have just read in packet data
                    // StatePreamble -> StateSFD -> StateDrop -> StateIdle
                    if(StateIdle)
                        begin
                        // End of good frame, but only if first time here
                            if(packet_to_read_i > 0)
                            begin
                                sending = 1;
                                packet_to_read_length = packet_to_read_i;
                                packet_to_send_length = packet_to_read_i;
                                packet_to_read_i = 0;
                            end
                        end
                    else if(StateDrop)
                        begin
                        // End of bad frame, but only if first time here
                            //packet_to_read_length = 0;
                            //packet_to_send_length = 0;
                            packet_to_read_i = 0;
                        end    
                    else if(StatePreamble | StateSFD)
                        begin
                            // Start of a new frame
                            packet_to_read = 0;
                            packet_to_read_length = 0;
                            packet_to_send_length = 0;
                            packet_to_read_i = 0;
                        end
                    else if(StateData[0] == 1'b1)
                        begin
                            // ok, how do we know this is the first nibble of a new packett?
                            // Write to packet buffer # packet_to_send at location packet_to_send_i
                            //packet_buffer[packet_to_read][packet_to_read_i]  <=  (phy_rx_data << 4);
                            packet_buffer[packet_to_read][packet_to_read_i]  <=  phy_rx_data;
                        end
                    else if(StateData[1] == 1'b1)
                        begin
                            // Do we know if this is the last niddle of the last byte?
                            // We don't care because we save it to memory
                            // We read in existing packet buffer #packet_to_send at location #packet_to_send_i shift it 4 bits
                            // left and OR it with the new data
                            //packet_buffer[packet_to_read][packet_to_read_i] <= (packet_buffer[packet_to_read][packet_to_read_i] | phy_rx_data);
                            packet_buffer[packet_to_read][packet_to_read_i] <= (packet_buffer[packet_to_read][packet_to_read_i]) | (phy_rx_data << 4);
                            packet_to_read_i = packet_to_read_i + 1;
                        end
                end
            end
    end

    always @ (posedge clk)
    begin
        if(~reset)
            begin
                done_sending = 0;

                packet_to_send = 0;
                packet_to_send_i = 0;

                data_valid = 1'b0;
                data = 32'hAAAA0001;
                end_of_frame = 1'b0;
            end
//        else if(axi_str_txd_tready == 1'b0)
//            begin
//                data_valid = 1'b0;
//            end
        else if(sending == 0 && done_sending == 1)
            begin
                done_sending = 0;

                data_valid = 1'b0;
                data = 32'hAAAA0002;
                end_of_frame = 1'b0;
            end
        else if(sending == 1 && done_sending == 0)
            begin
                if(packet_to_send_i == packet_to_send_length)
                    begin
                        done_sending = 1;

                        data = 32'hAAAA0003;
                        data_valid = 1'b0;
                        end_of_frame = 1'b0;

                        packet_to_send_i = 0;
                    end
                else if(packet_to_send_i + 1 == packet_to_send_length)
                    begin
                        data = packet_buffer[packet_to_send][packet_to_send_i];
                        //data = (packet_to_send_i << 24) | (8'h62 << 16) | (data);
                        //data = (packet_to_send_i);
                        //data = (packet_to_send_i << 16) | (8'h72 << 8) | (packet_buffer[packet_to_send][packet_to_send_i]);
//                        data = packet_buffer[packet_to_send][packet_to_send_i];
                        data_valid = 1'b1;
                        end_of_frame = 1'b1;

                        packet_to_send_i = packet_to_send_i + 1;
                    end
                else
                    begin
                        data = packet_buffer[packet_to_send][packet_to_send_i];
                        //data = (packet_to_send_i);
                        //data = (packet_to_send_i << 16) | (8'h71 << 8) | (packet_buffer[packet_to_send][packet_to_send_i]);
//                        data = packet_buffer[packet_to_send][packet_to_send_i];
                        data_valid = 1'b1;
                        end_of_frame = 1'b0;

                        packet_to_send_i = packet_to_send_i + 1;
                    end
            end
        else
            begin
                // This is the idle state when we are not sending to the AXI host.
                data = 32'hAAAA0004;
                data_valid = 1'b0;
                end_of_frame = 1'b0;
            end
    end

// Common Code
//    assign axi_str_txd_tdata = data;
//    assign axi_str_txd_tlast = end_of_frame;
//    assign axi_str_txd_tvalid = data_valid;

//    assign axi_str_rxd_tready = 0;

    assign  data_out = data;
    assign  end_of_frame_out = end_of_frame;
    assign  data_valid_out = data_valid;
endmodule