set_property IOSTANDARD LVDS [get_ports SYSCLK_P]
set_property PACKAGE_PIN H9 [get_ports SYSCLK_P]
set_property PACKAGE_PIN G9 [get_ports SYSCLK_N]
set_property IOSTANDARD LVDS [get_ports SYSCLK_N]
#set_property PACKAGE_PIN H9 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 5.000 -name SYSCLK_P -waveform {0.000 2.500} -add [get_ports SYSCLK_P]


# _t_dev uart, GPIO PMOD J58
set_property -dict {PACKAGE_PIN AJ21 IOSTANDARD LVCMOS25} [get_ports uart0_rxd_out]
set_property -dict {PACKAGE_PIN AK21 IOSTANDARD LVCMOS25} [get_ports uart0_txd_in]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS25} [get_ports uart1_rxd_out]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS25} [get_ports uart1_txd_in]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 16384 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list system_i/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[0]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[1]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[2]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[3]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[4]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[5]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[6]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[7]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[8]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[9]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[10]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[11]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[12]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[13]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[14]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[15]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[16]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[17]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[18]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[19]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[20]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[21]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[22]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[23]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[24]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[25]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[26]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[27]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[28]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[29]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[30]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mtvec[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[0]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[1]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[2]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[3]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[4]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[5]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[6]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[7]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[8]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[9]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[10]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[11]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[12]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[13]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[14]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[15]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[16]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[17]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[18]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[19]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[20]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[21]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[22]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[23]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[24]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[25]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[26]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[27]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[28]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[29]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[30]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mepc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[0]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[1]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[2]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[3]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[4]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[5]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[6]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[7]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[8]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[9]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[10]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[11]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[12]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[13]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[14]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[15]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[16]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[17]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[18]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[19]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[20]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[21]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[22]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[23]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[24]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[25]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[26]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[27]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[28]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[29]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[30]} {top/FPGAZynqTop_CowPeripherals/tile/core/csr/reg_mcause[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[0]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[1]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[2]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[3]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[4]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[5]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[6]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[7]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[8]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[9]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[10]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[11]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[12]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[13]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[14]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[15]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[16]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[17]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[18]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[19]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[20]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[21]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[22]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[23]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[24]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[25]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[26]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[27]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[28]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[29]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[30]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_raw_inst[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[0]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[1]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[2]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[3]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[4]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[5]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[6]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[7]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[8]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[9]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[10]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[11]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[12]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[13]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[14]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[15]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[16]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[17]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[18]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[19]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[20]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[21]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[22]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[23]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[24]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[25]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[26]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[27]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[28]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[29]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[30]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[0]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[1]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[2]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[3]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[4]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[5]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[6]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[7]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[8]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[9]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[10]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[11]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[12]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[13]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[14]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[15]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[16]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[17]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[18]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[19]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[20]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[21]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[22]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[23]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[24]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[25]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[26]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[27]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[28]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[29]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[30]} {top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_cause[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list top/FPGAZynqTop_CowPeripherals/tile/core/csr/io_interrupts_meip]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list top/FPGAZynqTop_CowPeripherals/tile/core/csr/io_interrupts_msip]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list IOBUF_1_help_1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list IOBUF_1_help_2]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list IOBUF_1_help_o_ie]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list IOBUF_1_I]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list IOBUF_1_O]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list top/FPGAZynqTop_CowPeripherals/tile/core/wb_reg_xcpt]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_FCLK_CLK0]
