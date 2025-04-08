// Copyright 2017 ETH Zurich and University of Bologna.
// Licensed under the Solderpad Hardware License, Version 0.51.
`include "axi_bus.sv"
`include "debug_bus.sv"
`include "config.sv"

`define AXI_ADDR_WIDTH         32
`define AXI_DATA_WIDTH         32
`define AXI_ID_MASTER_WIDTH     2
`define AXI_ID_SLAVE_WIDTH      4
`define AXI_USER_WIDTH          1

module pulpino_top
  #(
    parameter USE_ZERO_RISCY  = 0,
    parameter RISCY_RV32F     = 0,
    parameter ZERO_RV32M      = 1,
    parameter ZERO_RV32E      = 0
  )
  (
    // Clock and Reset
    input  logic              clk,        
    input  logic              rst_n,     


    input  logic              clk_sel_i,
    input  logic              clk_standalone_i,
    input  logic              testmode_i,
    input  logic              fetch_enable_i,
    input  logic              scan_enable_i,


    output logic              uart_tx,
    input  logic              uart_rx,

    input  logic      [7:0]   gpio_in,
    output logic      [7:0]   gpio_out,
    output logic      [7:0]   gpio_dir,
    output logic [7:0][5:0]   gpio_padcfg,


    input  logic              tck_i,
    input  logic              trstn_i,
    input  logic              tms_i,
    input  logic              tdi_i,
    output logic              tdo_o,


  clk_rst_gen clk_rst_gen_i (
      .clk_i            ( clk              ),
      .rstn_i           ( rst_n            ),
      .clk_sel_i        ( clk_sel_i        ),
      .clk_standalone_i ( clk_standalone_i ),
      .testmode_i       ( testmode_i       ),
      .scan_i           ( 1'b0             ),
      .scan_o           (                  ),
      .scan_en_i        ( scan_enable_i    ),
      .fll_req_i        ( cfgreq_fll_int   ),
      .fll_wrn_i        ( cfgweb_n_fll_int ),
      .fll_add_i        ( cfgad_fll_int    ),
      .fll_data_i       ( cfgd_fll_int     ),
      .fll_ack_o        ( cfgack_fll_int   ),
      .fll_r_data_o     ( cfgq_fll_int     ),
      .fll_lock_o       ( lock_fll_int     ),
      .clk_o            ( clk_int          ),
      .rstn_o           ( rstn_int         )
  );


  peripherals
  #(
    .AXI_ADDR_WIDTH      ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH      ( `AXI_DATA_WIDTH      ),
    .AXI_SLAVE_ID_WIDTH  ( `AXI_ID_SLAVE_WIDTH  ),
    .AXI_MASTER_ID_WIDTH ( `AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH      ( `AXI_USER_WIDTH      )
  )
  peripherals_i (
    .clk_i           ( clk_int           ),
    .rst_n           ( rstn_int          ),

    .debug           ( debug             ),

    .uart_tx         ( uart_tx           ),
    .uart_rx         ( uart_rx           ),


    .gpio_in         ( gpio_in           ),
    .gpio_out        ( gpio_out          ),
    .gpio_dir        ( gpio_dir          ),
    .gpio_padcfg     ( gpio_padcfg       ),

    .slave           ( slaves[2]         ),
    .core_busy_i     ( core_busy_int     ),
    .irq_o           ( irq_to_core_int   ),
    .fetch_enable_i  ( fetch_enable_i    ),
    .fetch_enable_o  ( fetch_enable_int  ),
    .clk_gate_core_o ( clk_gate_core_int ),
    .fll1_req_o      ( cfgreq_fll_int    ),
    .fll1_wrn_o      ( cfgweb_n_fll_int  ),
    .fll1_add_o      ( cfgad_fll_int     ),
    .fll1_wdata_o    ( cfgd_fll_int      ),
    .fll1_ack_i      ( cfgack_fll_int    ),
    .fll1_rdata_i    ( cfgq_fll_int      ),
    .fll1_lock_i     ( lock_fll_int      ),
    .pad_cfg_o       ( pad_cfg_o         ),
    .pad_mux_o       ( pad_mux_o         ),
    .boot_addr_o     ( boot_addr_int     )
  );


  axi_node_intf_wrap
  #(
    .NB_MASTER      ( 3                    ),
    .NB_SLAVE       ( 3                    ),
    .AXI_ADDR_WIDTH ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( `AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH   ( `AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH ( `AXI_USER_WIDTH      )
  )
  axi_interconnect_i (
    .clk         ( clk_int    ),
    .rst_n     ( rstn_int   ),
    .test_en_i ( testmode_i ),
    .master    ( slaves     ),
    .slave     ( masters    ),
    .start_addr_i ( { 32'h1A10_0000, 32'h0010_0000, 32'h0000_0000 } ),
    .end_addr_i   ( { 32'h1A11_FFFF, 32'h001F_FFFF, 32'h000F_FFFF } )
  );

endmodule
