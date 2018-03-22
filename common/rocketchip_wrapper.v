`timescale 1 ps / 1 ps
`include "clocking.vh"

module rocketchip_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    // _t_dev, for routing sifive uart out to header via xdc file
    uart0_rxd_out,
    uart0_txd_in,
    uart1_rxd_out,
    uart1_txd_in,
`ifndef differential_clock
    clk);
`else
    SYSCLK_P,
    SYSCLK_N);
`endif

  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;

  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;

  inout uart0_rxd_out;
  inout uart0_txd_in;
  inout uart1_rxd_out;
  inout uart1_txd_in;

`ifndef differential_clock
  input clk;
`else
  input SYSCLK_P;
  input SYSCLK_N;
`endif

  wire FCLK_RESET0_N;
  
  wire [31:0]M_AXI_araddr;
  wire [1:0]M_AXI_arburst;
  wire [7:0]M_AXI_arlen;
  wire M_AXI_arready;
  wire [2:0]M_AXI_arsize;
  wire M_AXI_arvalid;
  wire [31:0]M_AXI_awaddr;
  wire [1:0]M_AXI_awburst;
  wire [7:0]M_AXI_awlen;
  wire [3:0]M_AXI_wstrb;
  wire M_AXI_awready;
  wire [2:0]M_AXI_awsize;
  wire M_AXI_awvalid;
  wire M_AXI_bready;
  wire M_AXI_bvalid;
  wire [31:0]M_AXI_rdata;
  wire M_AXI_rlast;
  wire M_AXI_rready;
  wire M_AXI_rvalid;
  wire [31:0]M_AXI_wdata;
  wire M_AXI_wlast;
  wire M_AXI_wready;
  wire M_AXI_wvalid;
  wire [11:0] M_AXI_arid, M_AXI_awid; // outputs from ARM core
  wire [11:0] M_AXI_bid, M_AXI_rid;   // inputs to ARM core

  wire S_AXI_arready;
  wire S_AXI_arvalid;
  wire [31:0] S_AXI_araddr;
  wire [5:0]  S_AXI_arid;
  wire [2:0]  S_AXI_arsize;
  wire [7:0]  S_AXI_arlen;
  wire [1:0]  S_AXI_arburst;
  wire S_AXI_arlock;
  wire [3:0]  S_AXI_arcache;
  wire [2:0]  S_AXI_arprot;
  wire [3:0]  S_AXI_arqos;
  //wire [3:0]  S_AXI_arregion;

  wire S_AXI_awready;
  wire S_AXI_awvalid;
  wire [31:0] S_AXI_awaddr;
  wire [5:0]  S_AXI_awid;
  wire [2:0]  S_AXI_awsize;
  wire [7:0]  S_AXI_awlen;
  wire [1:0]  S_AXI_awburst;
  wire S_AXI_awlock;
  wire [3:0]  S_AXI_awcache;
  wire [2:0]  S_AXI_awprot;
  wire [3:0]  S_AXI_awqos;
  //wire [3:0]  S_AXI_awregion;

  wire S_AXI_wready;
  wire S_AXI_wvalid;
  wire [7:0]  S_AXI_wstrb;
  wire [63:0] S_AXI_wdata;
  wire S_AXI_wlast;

  wire S_AXI_bready;
  wire S_AXI_bvalid;
  wire [1:0] S_AXI_bresp;
  wire [5:0] S_AXI_bid;

  wire S_AXI_rready;
  wire S_AXI_rvalid;
  wire [1:0]  S_AXI_rresp;
  wire [5:0]  S_AXI_rid;
  wire [63:0] S_AXI_rdata;
  wire S_AXI_rlast;

  wire reset, reset_cpu;
  wire host_clk;
  wire gclk_i, gclk_fbout, host_clk_i, mmcm_locked;

  // _t_dev, for routing sifive uart out to header 
  // compare to sifive freedom arty fe310 
  // IOBUF for uart0 tx
  wire  IOBUF_1_help_2; // aka sifive _t72
  wire  IOBUF_1_I;
  wire  IOBUF_1_O;
  wire  IOBUF_1_help_1; // aka sifive _t80
  wire  IOBUF_1_help_o_ie;
  // _o_valid driven by rocket to 1

  // IOBUF for uart0 rx
  wire  IOBUF_2_help_2;
  wire  IOBUF_2_I;
  wire  IOBUF_2_O;
  wire  IOBUF_2_help_1; // aka sifive _t77
  wire  IOBUF_2_help_o_ie;

  // IOBUF for uart1 rx
  wire  IOBUF_3_help_2;
  wire  IOBUF_3_I;
  wire  IOBUF_3_O;
  wire  IOBUF_3_help_1; 
  wire  IOBUF_3_help_o_ie;

  // IOBUF for uart1 rx
  wire  IOBUF_4_help_2;
  wire  IOBUF_4_I;
  wire  IOBUF_4_O;
  wire  IOBUF_4_help_1; 
  wire  IOBUF_4_help_o_ie;

  // logic to wire up 
  assign IOBUF_1_help_1 = IOBUF_1_O & IOBUF_1_help_o_ie;
  assign IOBUF_1_T = ~ IOBUF_1_help_2;

  assign IOBUF_2_help_1 = IOBUF_2_O & IOBUF_2_help_o_ie;
  assign IOBUF_2_T = ~ IOBUF_2_help_2;

  assign IOBUF_3_help_1 = IOBUF_3_O & IOBUF_3_help_o_ie;
  assign IOBUF_3_T = ~ IOBUF_3_help_2;

  assign IOBUF_4_help_1 = IOBUF_4_O & IOBUF_4_help_o_ie;
  assign IOBUF_4_T = ~ IOBUF_4_help_2;

  // uart0_txd
  IOBUF IOBUF_1 (
    .T(IOBUF_1_T),
    .I(IOBUF_1_I),
    .IO(uart0_txd_in),
    .O(IOBUF_1_O)
  );

  // uart0_rxd
  IOBUF IOBUF_2 (
    .T(IOBUF_2_T),
    .I(IOBUF_2_I),
    .IO(uart0_rxd_out),
    .O(IOBUF_2_O)
  );

  // uart1_txd
  IOBUF IOBUF_3 (
    .T(IOBUF_3_T),
    .I(IOBUF_3_I),
    .IO(uart1_txd_in),
    .O(IOBUF_3_O)
  );

  // uart1_rxd
  IOBUF IOBUF_4 (
    .T(IOBUF_4_T),
    .I(IOBUF_4_I),
    .IO(uart1_rxd_out),
    .O(IOBUF_4_O)
  );
  
  

  system system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FCLK_RESET0_N(FCLK_RESET0_N),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),

        // master AXI interface (zynq = master, fpga = slave)
        .M_AXI_araddr(M_AXI_araddr),
        .M_AXI_arburst(M_AXI_arburst), // burst type
        .M_AXI_arcache(),
        .M_AXI_arid(M_AXI_arid),
        .M_AXI_arlen(M_AXI_arlen), // burst length (#transfers)
        .M_AXI_arlock(),
        .M_AXI_arprot(),
        .M_AXI_arqos(),
        .M_AXI_arready(M_AXI_arready),
        .M_AXI_arregion(),
        .M_AXI_arsize(M_AXI_arsize), // burst size (bits/transfer)
        .M_AXI_arvalid(M_AXI_arvalid),
        //
        .M_AXI_awaddr(M_AXI_awaddr),
        .M_AXI_awburst(M_AXI_awburst),
        .M_AXI_awcache(),
        .M_AXI_awid(M_AXI_awid),
        .M_AXI_awlen(M_AXI_awlen),
        .M_AXI_awlock(),
        .M_AXI_awprot(),
        .M_AXI_awqos(),
        .M_AXI_awready(M_AXI_awready),
        .M_AXI_awregion(),
        .M_AXI_awsize(M_AXI_awsize),
        .M_AXI_awvalid(M_AXI_awvalid),
        //
        .M_AXI_bid(M_AXI_bid),
        .M_AXI_bready(M_AXI_bready),
        .M_AXI_bresp(2'b00),
        .M_AXI_bvalid(M_AXI_bvalid),
        //
        .M_AXI_rdata(M_AXI_rdata),
        .M_AXI_rid(M_AXI_rid),
        .M_AXI_rlast(M_AXI_rlast),
        .M_AXI_rready(M_AXI_rready),
        .M_AXI_rresp(),
        .M_AXI_rvalid(M_AXI_rvalid),
        //
        .M_AXI_wdata(M_AXI_wdata),
        .M_AXI_wlast(M_AXI_wlast),
        .M_AXI_wready(M_AXI_wready),
        .M_AXI_wstrb(M_AXI_wstrb),
        .M_AXI_wvalid(M_AXI_wvalid),

        // slave AXI interface (fpga = master, zynq = slave) 
        // connected directly to DDR controller to handle test chip mem
        .S_AXI_araddr(S_AXI_araddr),
        .S_AXI_arburst(S_AXI_arburst),
        .S_AXI_arcache(S_AXI_arcache),
        .S_AXI_arid(S_AXI_arid),
        .S_AXI_arlen(S_AXI_arlen),
        .S_AXI_arlock(S_AXI_arlock),
        .S_AXI_arprot(S_AXI_arprot),
        .S_AXI_arqos(S_AXI_arqos),
        .S_AXI_arready(S_AXI_arready),
        .S_AXI_arregion(4'b0),
        .S_AXI_arsize(S_AXI_arsize),
        .S_AXI_arvalid(S_AXI_arvalid),
        //
        .S_AXI_awaddr(S_AXI_awaddr),
        .S_AXI_awburst(S_AXI_awburst),
        .S_AXI_awcache(S_AXI_awcache),
        .S_AXI_awid(S_AXI_awid),
        .S_AXI_awlen(S_AXI_awlen),
        .S_AXI_awlock(S_AXI_awlock),
        .S_AXI_awprot(S_AXI_awprot),
        .S_AXI_awqos(S_AXI_awqos),
        .S_AXI_awready(S_AXI_awready),
        .S_AXI_awregion(4'b0),
        .S_AXI_awsize(S_AXI_awsize),
        .S_AXI_awvalid(S_AXI_awvalid),
        //
        .S_AXI_bid(S_AXI_bid),
        .S_AXI_bready(S_AXI_bready),
        .S_AXI_bresp(S_AXI_bresp),
        .S_AXI_bvalid(S_AXI_bvalid),
        //
        .S_AXI_rid(S_AXI_rid),
        .S_AXI_rdata(S_AXI_rdata),
        .S_AXI_rlast(S_AXI_rlast),
        .S_AXI_rready(S_AXI_rready),
        .S_AXI_rresp(S_AXI_rresp),
        .S_AXI_rvalid(S_AXI_rvalid),
        //
        .S_AXI_wdata(S_AXI_wdata),
        .S_AXI_wlast(S_AXI_wlast),
        .S_AXI_wready(S_AXI_wready),
        .S_AXI_wstrb(S_AXI_wstrb),
        .S_AXI_wvalid(S_AXI_wvalid),
        .ext_clk_in(host_clk)
        );

  assign reset = !FCLK_RESET0_N || !mmcm_locked;

  wire [31:0] mem_araddr;
  wire [31:0] mem_awaddr;

  // Memory given to Rocket is the upper 256 MB of the 512 MB DRAM
  assign S_AXI_araddr = {4'd1, mem_araddr[27:0]};
  assign S_AXI_awaddr = {4'd1, mem_awaddr[27:0]};

  Top top(
   .clock(host_clk),
   .reset(reset),

   .io_ps_axi_slave_aw_ready (M_AXI_awready),
   .io_ps_axi_slave_aw_valid (M_AXI_awvalid),
   .io_ps_axi_slave_aw_bits_addr (M_AXI_awaddr),
   .io_ps_axi_slave_aw_bits_len (M_AXI_awlen),
   .io_ps_axi_slave_aw_bits_size (M_AXI_awsize),
   .io_ps_axi_slave_aw_bits_burst (M_AXI_awburst),
   .io_ps_axi_slave_aw_bits_id (M_AXI_awid),
   .io_ps_axi_slave_aw_bits_lock (1'b0),
   .io_ps_axi_slave_aw_bits_cache (4'b0),
   .io_ps_axi_slave_aw_bits_prot (3'b0),
   .io_ps_axi_slave_aw_bits_qos (4'b0),

   .io_ps_axi_slave_ar_ready (M_AXI_arready),
   .io_ps_axi_slave_ar_valid (M_AXI_arvalid),
   .io_ps_axi_slave_ar_bits_addr (M_AXI_araddr),
   .io_ps_axi_slave_ar_bits_len (M_AXI_arlen),
   .io_ps_axi_slave_ar_bits_size (M_AXI_arsize),
   .io_ps_axi_slave_ar_bits_burst (M_AXI_arburst),
   .io_ps_axi_slave_ar_bits_id (M_AXI_arid),
   .io_ps_axi_slave_ar_bits_lock (1'b0),
   .io_ps_axi_slave_ar_bits_cache (4'b0),
   .io_ps_axi_slave_ar_bits_prot (3'b0),
   .io_ps_axi_slave_ar_bits_qos (4'b0),

   .io_ps_axi_slave_w_valid (M_AXI_wvalid),
   .io_ps_axi_slave_w_ready (M_AXI_wready),
   .io_ps_axi_slave_w_bits_data (M_AXI_wdata),
   .io_ps_axi_slave_w_bits_strb (M_AXI_wstrb),
   .io_ps_axi_slave_w_bits_last (M_AXI_wlast),

   .io_ps_axi_slave_r_valid (M_AXI_rvalid),
   .io_ps_axi_slave_r_ready (M_AXI_rready),
   .io_ps_axi_slave_r_bits_id (M_AXI_rid),
   .io_ps_axi_slave_r_bits_resp (M_AXI_rresp),
   .io_ps_axi_slave_r_bits_data (M_AXI_rdata),
   .io_ps_axi_slave_r_bits_last (M_AXI_rlast),

   .io_ps_axi_slave_b_valid (M_AXI_bvalid),
   .io_ps_axi_slave_b_ready (M_AXI_bready),
   .io_ps_axi_slave_b_bits_id (M_AXI_bid),
   .io_ps_axi_slave_b_bits_resp (M_AXI_bresp),

   .io_mem_axi_ar_valid (S_AXI_arvalid),
   .io_mem_axi_ar_ready (S_AXI_arready),
   .io_mem_axi_ar_bits_addr (mem_araddr),
   .io_mem_axi_ar_bits_id (S_AXI_arid),
   .io_mem_axi_ar_bits_size (S_AXI_arsize),
   .io_mem_axi_ar_bits_len (S_AXI_arlen),
   .io_mem_axi_ar_bits_burst (S_AXI_arburst),
   .io_mem_axi_ar_bits_cache (S_AXI_arcache),
   .io_mem_axi_ar_bits_lock (S_AXI_arlock),
   .io_mem_axi_ar_bits_prot (S_AXI_arprot),
   .io_mem_axi_ar_bits_qos (S_AXI_arqos),
   .io_mem_axi_aw_valid (S_AXI_awvalid),
   .io_mem_axi_aw_ready (S_AXI_awready),
   .io_mem_axi_aw_bits_addr (mem_awaddr),
   .io_mem_axi_aw_bits_id (S_AXI_awid),
   .io_mem_axi_aw_bits_size (S_AXI_awsize),
   .io_mem_axi_aw_bits_len (S_AXI_awlen),
   .io_mem_axi_aw_bits_burst (S_AXI_awburst),
   .io_mem_axi_aw_bits_cache (S_AXI_awcache),
   .io_mem_axi_aw_bits_lock (S_AXI_awlock),
   .io_mem_axi_aw_bits_prot (S_AXI_awprot),
   .io_mem_axi_aw_bits_qos (S_AXI_awqos),
   .io_mem_axi_w_valid (S_AXI_wvalid),
   .io_mem_axi_w_ready (S_AXI_wready),
   .io_mem_axi_w_bits_strb (S_AXI_wstrb),
   .io_mem_axi_w_bits_data (S_AXI_wdata),
   .io_mem_axi_w_bits_last (S_AXI_wlast),
   .io_mem_axi_b_valid (S_AXI_bvalid),
   .io_mem_axi_b_ready (S_AXI_bready),
   .io_mem_axi_b_bits_resp (S_AXI_bresp),
   .io_mem_axi_b_bits_id (S_AXI_bid),
   .io_mem_axi_r_valid (S_AXI_rvalid),
   .io_mem_axi_r_ready (S_AXI_rready),
   .io_mem_axi_r_bits_resp (S_AXI_rresp),
   .io_mem_axi_r_bits_id (S_AXI_rid),
   .io_mem_axi_r_bits_data (S_AXI_rdata),
   .io_mem_axi_r_bits_last (S_AXI_rlast),
   // _t_dev sifive uart, connect Top with wrapper
   // OLD, when uart ports instead of IOBUF out of rocket
   //.io_uart_0_txd (uart0_txd_in),
   //.io_uart_0_rxd (uart0_rxd_out)
   //.io_uart_1_txd(io_uart_1_txd),
   //.io_uart_1_rxd(io_uart_1_rxd)
   // NEW, connect to IOBUF pins in rocket
   // IOBUF1 uart0_txd
   .io_iobuf_uart0_txd_i_ival(IOBUF_1_help_1),
   .io_iobuf_uart0_txd_o_oval(IOBUF_1_I),
   .io_iobuf_uart0_txd_o_oe(IOBUF_1_help_2),
   .io_iobuf_uart0_txd_o_ie(IOBUF_1_help_o_ie),
   // IOBUF2 uart0_rxd
   .io_iobuf_uart0_rxd_i_ival(IOBUF_2_help_1),
   .io_iobuf_uart0_rxd_o_oval(IOBUF_2_I),
   .io_iobuf_uart0_rxd_o_oe(IOBUF_2_help_2),
   .io_iobuf_uart0_rxd_o_ie(IOBUF_2_help_o_ie),
    // IOBUF3 uart1_txd
   .io_iobuf_uart1_txd_i_ival(IOBUF_3_help_1),
   .io_iobuf_uart1_txd_o_oval(IOBUF_3_I),
   .io_iobuf_uart1_txd_o_oe(IOBUF_3_help_2),
   .io_iobuf_uart1_txd_o_ie(IOBUF_3_help_o_ie),
    // IOBUF4 uart1_rxd
   .io_iobuf_uart1_rxd_i_ival(IOBUF_4_help_1),
   .io_iobuf_uart1_rxd_o_oval(IOBUF_4_I),
   .io_iobuf_uart1_rxd_o_oe(IOBUF_4_help_2),
   .io_iobuf_uart1_rxd_o_ie(IOBUF_4_help_o_ie)
  );
`ifndef differential_clock
  IBUFG ibufg_gclk (.I(clk), .O(gclk_i));
`else
  IBUFDS #(.DIFF_TERM("TRUE"), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT")) clk_ibufds (.O(gclk_i), .I(SYSCLK_P), .IB(SYSCLK_N));
`endif
  BUFG  bufg_host_clk (.I(host_clk_i), .O(host_clk));

  MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT_F(`RC_CLK_MULT),
    .CLKFBOUT_PHASE(0.0),
    .CLKIN1_PERIOD(`ZYNQ_CLK_PERIOD),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT0_DIVIDE_F(`RC_CLK_DIVIDE),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(0.0),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_PHASE(0.0),
    .CLKOUT6_PHASE(0.0),
    .CLKOUT4_CASCADE("FALSE"),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.0),
    .STARTUP_WAIT("FALSE")
  ) MMCME2_BASE_inst (
    .CLKOUT0(host_clk_i),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(gclk_fbout),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked),
    .CLKIN1(gclk_i),
    .PWRDWN(1'b0),
    .RST(1'b0),
    .CLKFBIN(gclk_fbout));

 

endmodule
