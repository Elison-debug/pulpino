// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`timescale 1ns / 1ps

module sram_wrapper
  #(
    // RAM_SIZE: 32KB
    parameter RAM_SIZE   = 32768,
    parameter DATA_WIDTH = 32,
    parameter NUM_WORDS  = RAM_SIZE / (DATA_WIDTH/8),
    parameter ADDR_WIDTH = $clog2(NUM_WORDS)
  )
  (
    input  logic                    clk,       
    input  logic                    rst_n,     
    input  logic [ADDR_WIDTH-1:0]   addr,     
    input  logic [DATA_WIDTH/8-1:0] byte_en,   
    input  logic [DATA_WIDTH-1:0]   wdata,     
    input  logic                    we,       
    output logic [DATA_WIDTH-1:0]   rdata      
  );

 
  logic [7:0] mem0 [0:NUM_WORDS-1]; 
  logic [7:0] mem1 [0:NUM_WORDS-1]; 
  logic [7:0] mem2 [0:NUM_WORDS-1]; 
  logic [7:0] mem3 [0:NUM_WORDS-1];

  
  always_ff @(posedge clk) begin
    rdata <= { mem3[addr], mem2[addr], mem1[addr], mem0[addr] };
  end


  always_ff @(posedge clk) begin
    if (we) begin
      if (byte_en[0])
        mem0[addr] <= wdata[7:0];
      if (byte_en[1])
        mem1[addr] <= wdata[15:8];
      if (byte_en[2])
        mem2[addr] <= wdata[23:16];
      if (byte_en[3])
        mem3[addr] <= wdata[31:24];
    end
  end

endmodule
