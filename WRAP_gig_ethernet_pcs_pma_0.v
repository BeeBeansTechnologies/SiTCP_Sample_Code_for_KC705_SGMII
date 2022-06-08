

module
	WRAP_gig_ethernet_pcs_pma_0	(
		input	wire			SYS_CLK			,
		input	wire			RESET_IN		,

		input	wire			SGMII_CLK_P		,
		input	wire			SGMII_CLK_N		,
		output	wire			SGMII_TXP		,
		output	wire			SGMII_TXN		,
		input	wire			SGMII_RXP		,
		input	wire			SGMII_RXN		,

		output	wire			GMII_CLK		,
		input	wire			GMII_TX_EN		,
		input	wire	[7:0]	GMII_TXD		,
		input	wire			GMII_TX_ER		,
		output	wire			GMII_RX_DV		,
		output	wire	[7:0]	GMII_RXD		,
		output	wire			GMII_RX_ER		,
		
		output	wire	[15:0]	STATUS_VECTOR	
	);
endmodule
