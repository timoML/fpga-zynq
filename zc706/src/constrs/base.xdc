set_property IOSTANDARD LVDS [get_ports SYSCLK_P]
set_property PACKAGE_PIN H9 [get_ports SYSCLK_P]
set_property PACKAGE_PIN G9 [get_ports SYSCLK_N]
set_property IOSTANDARD LVDS [get_ports SYSCLK_N]
#set_property PACKAGE_PIN H9 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 5.000 -name SYSCLK_P -waveform {0.000 2.500} -add [get_ports SYSCLK_P]


# _t_dev uart, GPIO PMOD J58
# aka J58 PMOD1_0
set_property -dict {PACKAGE_PIN AJ21 IOSTANDARD LVCMOS25} [get_ports uart0_rxd_out]
# aka J58 PMOD1_1
set_property -dict {PACKAGE_PIN AK21 IOSTANDARD LVCMOS25} [get_ports uart0_txd_in]
# aka J58 PMOD1_2
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS25} [get_ports uart1_rxd_out]
# aka J58 PMOD1_3
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS25} [get_ports uart1_txd_in]


