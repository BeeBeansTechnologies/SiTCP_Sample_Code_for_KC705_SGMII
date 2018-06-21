


set_property IOSTANDARD LVCMOS25 [get_ports GMII_MDC]
set_property IOSTANDARD LVCMOS25 [get_ports GMII_MDIO]
set_property IOSTANDARD LVCMOS25 [get_ports GMII_RSTn]
set_property IOSTANDARD LVCMOS25 [get_ports I2C_SDA]
set_property IOSTANDARD LVCMOS25 [get_ports I2C_SCL]
set_property IOSTANDARD LVDS [get_ports SYSCLK_200MP_IN]
set_property IOSTANDARD LVDS [get_ports SYSCLK_200MN_IN]
set_property IOSTANDARD LVCMOS25 [get_ports GPIO_SWITCH_0]
set_property IOSTANDARD LVCMOS15 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS15 [get_ports SW_N]


set_property PACKAGE_PIN AD11 [get_ports SYSCLK_200MN_IN]
set_property PACKAGE_PIN AD12 [get_ports SYSCLK_200MP_IN]
set_property PACKAGE_PIN L20 [get_ports GMII_RSTn]
set_property PACKAGE_PIN J21 [get_ports GMII_MDIO]
set_property PACKAGE_PIN R23 [get_ports GMII_MDC]
set_property PACKAGE_PIN L21 [get_ports I2C_SDA]
set_property PACKAGE_PIN K21 [get_ports I2C_SCL]
set_property PACKAGE_PIN G8 [get_ports SGMII_CLK_P]
set_property PACKAGE_PIN G7 [get_ports SGMII_CLK_N]
set_property PACKAGE_PIN H5 [get_ports SGMII_RXN]
set_property PACKAGE_PIN H6 [get_ports SGMII_RXP]
set_property PACKAGE_PIN J3 [get_ports SGMII_TXN]
set_property PACKAGE_PIN J4 [get_ports SGMII_TXP]
set_property PACKAGE_PIN AA12 [get_ports SW_N]
set_property PACKAGE_PIN AB8 [get_ports {LED[0]}]
set_property PACKAGE_PIN AA8 [get_ports {LED[1]}]
set_property PACKAGE_PIN AC9 [get_ports {LED[2]}]
set_property PACKAGE_PIN AB9 [get_ports {LED[3]}]
set_property PACKAGE_PIN AE26 [get_ports {LED[4]}]
set_property PACKAGE_PIN G19 [get_ports {LED[5]}]
set_property PACKAGE_PIN E18 [get_ports {LED[6]}]
set_property PACKAGE_PIN F16 [get_ports {LED[7]}]
set_property PACKAGE_PIN Y29 [get_ports GPIO_SWITCH_0]

create_clock -period 5.000 -name SYSCLK_200MP_IN -waveform {0.000 2.500} [get_ports SYSCLK_200MP_IN]
create_clock -period 8.000 -name SGMII_CLK_P -waveform {0.000 4.000} [get_ports SGMII_CLK_P]


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 6 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_max_delay 5.000 -datapath_only -from [get_pins -hier -filter {name =~ */gpcs_pma_inst/*/SGMII_SPEED_reg*/C}] -to [get_pins {SGMII_LINK*/D}] 

set_false_path -through [get_nets SiTCP_RESET]

set_property IOB false [get_cells -hierarchical -filter {name =~ */GMII_RXCNT/IOB_RD_*}]
set_property IOB false [get_cells -hierarchical -filter {name =~ */GMII_RXCNT/IOB_RDV}]
set_property IOB false [get_cells -hierarchical -filter {name =~ */GMII_RXCNT/IOB_RERR}]


set_max_delay -from [get_port GMII_MDIO] 10
set_min_delay -from [get_port GMII_MDIO] 0
set_max_delay -from [get_port I2C_SDA] 10
set_min_delay -from [get_port I2C_SDA] 0

#set_property IOB true [get_cells -hierarchical -filter {name =~ */GMII_TXCNT/IOB_TD_*}]
#set_property IOB true [get_cells -hierarchical -filter {name =~ */GMII_TXCNT/IOB_TEN}]


set_max_delay -datapath_only -from [get_clocks SYSCLK_200MP_IN] -to [get_port GMII_MDC] 10
set_max_delay -datapath_only -from [get_clocks SYSCLK_200MP_IN] -to [get_port GMII_MDIO] 10
set_max_delay -datapath_only -from [get_clocks SYSCLK_200MP_IN] -to [get_port GMII_RSTn] 10
set_max_delay -datapath_only -from [get_clocks SYSCLK_200MP_IN] -to [get_port I2C_SCL] 10
set_max_delay -datapath_only -from [get_clocks SYSCLK_200MP_IN] -to [get_port I2C_SDA] 10

