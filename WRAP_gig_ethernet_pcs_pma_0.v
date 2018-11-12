

module
	WRAP_gig_ethernet_pcs_pma_0	(
	// System
		input	wire			SYS_CLK			,
		input	wire			RESET_IN		,
	// EtherNet
		input	wire			SGMII_CLK_P		,
		input	wire			SGMII_CLK_N		,
		output	wire			SGMII_TXP		,	// out	: Tx signal line
		output	wire			SGMII_TXN		,	// out	: 
		input	wire			SGMII_RXP		,	// in	: Rx signal line
		input	wire			SGMII_RXN		,	// in	: 

		output	wire			GMII_CLK		,	// in : Tx clock
		input	wire			GMII_TX_EN		,	// out: Tx enable
		input	wire	[7:0]	GMII_TXD		,	// out: Tx data[7:0]
		input	wire			GMII_TX_ER		,	// out: TX error
		output	wire			GMII_RX_DV		,	// in : Rx data valid
		output	wire	[7:0]	GMII_RXD		,	// in : Rx data[7:0]
		output	wire			GMII_RX_ER		,	// in : Rx error
		
		output	wire	[15:0]	STATUS_VECTOR		// out: Core status.[15:0]	
	);
endmodule
