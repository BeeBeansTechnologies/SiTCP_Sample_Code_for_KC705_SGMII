//-------------------------------------------------------------------//
//
//		Copyright (c) 2012 BeeBeans Technologies
//			All rights reserved
//
//	System      : KC705
//
//	Module      : KC705 Evaluation Board
//
//	Description : Top Module of KC705 Evaluation Board
//
//	file	: KC705 Evaluation Board
//
//	Note	:
//
//
//-------------------------------------------------------------------//

module
	kc705sitcp(
	// System
		input	wire			SYSCLK_200MP_IN	,	// From 200MHz Oscillator module
		input	wire			SYSCLK_200MN_IN	,	// From 200MHz Oscillator module
	// EtherNet
		input	wire			SGMII_CLK_P		,
		input	wire			SGMII_CLK_N		,
		output	wire			GMII_RSTn		,
		output	wire			SGMII_TXP		,	// out	: Tx signal line
		output	wire			SGMII_TXN		,	// out	: 
		input	wire			SGMII_RXP		,	// in	: Rx signal line
		input	wire			SGMII_RXN		,	// in	: 

		inout	wire			GMII_MDIO		,
		output	wire			GMII_MDC		,
	// reset switch
		input	wire			SW_N			,
	
		input	wire			GPIO_SWITCH_0	,
		output	wire	[7:0]	LED				,
	//connect EEPROM
		inout	wire			I2C_SDA			,
		output	wire			I2C_SCL
	);


//------------------------------------------------------------------------------
//	Buffers
//------------------------------------------------------------------------------
	wire			GMII_MDIO_IN	;
	wire			GMII_MDIO_OE	;
	wire			GMII_MDIO_OUT	;
	wire			SGMII_CLK;				// in : Tx clock
	wire			GMII_TX_EN;		// out: Tx enable
	wire	[7:0]	GMII_TXD;		// out: Tx data[7:0]
	wire			GMII_TX_ER;		// out: TX error
	wire			GMII_RX_CLK;	// in : Rx clock
	wire			GMII_RX_DV;		// in : Rx data valid
	wire	[7:0]	GMII_RXD;		// in : Rx data[7:0]
	wire			GMII_RX_ER;		// in : Rx error
	wire	[15:0]	STATUS_VECTOR;	// out: Core status.[15:0]	
	wire			SiTCP_RST		;
	wire			TCP_OPEN_ACK	;
	wire			TCP_CLOSE_REQ	;
	wire			TCP_RX_WR		;
	wire	[7:0]	TCP_RX_DATA		;
	wire			TCP_TX_FULL		;
	wire	[31:0]	RBCP_ADDR		;
	wire	[7:0]	RBCP_WD			;
	wire			RBCP_WE			;
	wire			RBCP_RE			;
	reg				TCP_CLOSE_ACK	;
	wire	[7:0]	TCP_TX_DATA		;
	reg				RBCP_ACK		;
	reg		[7:0]	RBCP_RD			;
	
	wire			CLK_200M		;
	reg		[31:0]	OFFSET_TEST		;
	wire	[11:0]	FIFO_DATA_COUNT	;
	wire			FIFO_RD_VALID	;
	reg				SYS_RSTn		;
	reg		[29:0]	INICNT			;
	wire			SDI				;
	wire			SDO				;
	wire			SDT				;
	wire			SCLK			;
	wire			MUX_SDO			;
	wire			MUX_SDT			;
	wire			MUX_SCLK		;
	wire			ROM_SDO			;
	wire			ROM_SDT			;
	wire			ROM_SCLK		;
	wire			RST_I2Cselector	;
	wire			Duplex_mode;
	wire	[ 1:0]	LED_LINKSpeed;
	wire			Link_Status;
	wire			userclk;
	wire			userclk2;
	wire			sgmii_clk_en;
	wire			sgmii_clk_r;
	wire			sgmii_clk_f;
	reg				SLCT_LINK1G;
	reg				SLCT_LINK100M;
	reg				SLCT_LINK10M;
	reg		[ 1:0]	SGMII_LINK;


	IBUFDS #(.IOSTANDARD ("LVDS"))		LVDS_BUF(.O(CLK_200M), .I(SYSCLK_200MP_IN), .IB(SYSCLK_200MN_IN));

	//SYS_RSTn->off//
	always@(posedge CLK_200M)begin
		if (SW_N) begin
			INICNT[29:0]	<=	30'd0;
			SYS_RSTn		<= 1'b0;
		end else begin
			INICNT[29:0]	<=	INICNT[29]? INICNT[29:0]:	(INICNT[29:0] + 30'd1);
			SYS_RSTn		<=	INICNT[29];
			
			SGMII_LINK[1:0]			<=	(
				((STATUS_VECTOR[11:10]==2'b10)?	2'b00:	2'b00)|
				((STATUS_VECTOR[11:10]==2'b01)?	2'b11:	2'b00)|
				((STATUS_VECTOR[11:10]==2'b00)?	2'b10:	2'b00)
			);
		end
	end

	assign	Link_Status			= STATUS_VECTOR[15];
	assign	Duplex_mode			= STATUS_VECTOR[12];
	assign	LED_LINKSpeed[1:0]	= STATUS_VECTOR[11:10];

	assign		LED[7]		=	~SYS_RSTn;
	assign		LED[6]		=	 1'b0;
	assign		LED[5:2]	=	{LED_LINKSpeed[1:0], Link_Status, Duplex_mode};
	assign		LED[1]		=	 1'b0;
	assign		LED[0]		=	 RST_I2Cselector;

//------------------------------------------------------------------------------
//     PCA9548A(8ch_I2C_switch) This device switch to EEPROM.
//
//     System sequence
//     Phase1:            Phase2:
//     Switcher    ->    EEPROM  & SiTCP
//
//------------------------------------------------------------------------------

	IOBUF	sda_buf( .O(SDI), .I(0), .T(SDT | SDO), .IO(I2C_SDA) );
	OBUF	obufiic( .O(I2C_SCL), .I(SCLK));

	//PCA9548A channel select
	PCA9548A #(
		.SYSCLK_FREQ_IN_MHz	(200			),
		.ADDR				(7'd116			),
		.CHANNEL			(8'b1000		)
	) PCA9548A (
		.SYSCLK_IN			(CLK_200M		), 	//in : system clock

		.I2C_SCLK			(MUX_SCLK		),	//out
		.SDO_I2CS			(MUX_SDO		),	//out
		.SDI_I2CS			(SDI			),	//in
		.SDT_I2CS			(MUX_SDT		),	//out

		.RESET_IN			(~SYS_RSTn		),	//in
		.RESET_OUT			(RST_I2Cselector)	//out
	);

	//switch from PCA9548A to EEPROM
	assign SCLK		=		(RST_I2Cselector == 1) ? ROM_SCLK: MUX_SCLK;
	assign SDO		=		(RST_I2Cselector == 1) ? ROM_SDO : MUX_SDO;
	assign SDT		=		(RST_I2Cselector == 1) ? ROM_SDT : MUX_SDT;


	AT93C46_M24C08 #(.SYSCLK_FREQ_IN_MHz(200)) AT93C46_M24C08(
		.AT93C46_CS_IN		(CS),
		.AT93C46_SK_IN		(SK),
		.AT93C46_DI_IN		(DI),
		.AT93C46_DO_OUT		(DO),

		.M24C08_SCL_OUT		(ROM_SCLK),
		.M24C08_SDA_OUT		(ROM_SDO),
		.M24C08_SDA_IN		(SDI),
		.M24C08_SDAT_OUT	(ROM_SDT),

		.RESET_IN			(~RST_I2Cselector),
		.SiTCP_RESET_OUT	(SiTCP_RESET),

		.SYSCLK_IN			(CLK_200M)
	);

	assign	GMII_MDIO	= (GMII_MDIO_OE	?	GMII_MDIO_OUT : 1'bz)	;


	WRAP_SiTCP_GMII_XC7K_32K	#(
		.TIM_PERIOD			(8'd200)					// = System clock frequency(MHz), integer only
	)
	SiTCP	(
		.CLK				(CLK_200M),					// in	: System Clock (MII: >15MHz, GMII>129MHz)
		.RST				(SiTCP_RESET),				// in	: System reset
	// Configuration parameters
		.FORCE_DEFAULTn		(GPIO_SWITCH_0),			// in	: Load default parameters
		.EXT_IP_ADDR		(32'h0000_0000),			// in	: IP address[31:0]
		.EXT_TCP_PORT		(16'h0000),					// in	: TCP port #[15:0]
		.EXT_RBCP_PORT		(16'h0000),					// in	: RBCP port #[15:0]
		.PHY_ADDR			(5'b0_0111),				// in	: PHY-device MIF address[4:0]
	// EEPROM
		.EEPROM_CS			(CS			),				// out	: Chip select
		.EEPROM_SK			(SK			),				// out	: Serial data clock
		.EEPROM_DI			(DI			),				// out	: Serial write data
		.EEPROM_DO			(DO			),				// in	: Serial read data
	// user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
		.USR_REG_X3C		(),							// out	: Stored at 0xFFFF_FF3C
		.USR_REG_X3D		(),							// out	: Stored at 0xFFFF_FF3D
		.USR_REG_X3E		(),							// out	: Stored at 0xFFFF_FF3E
		.USR_REG_X3F		(),							// out	: Stored at 0xFFFF_FF3F
	// MII interface
		.GMII_RSTn			(GMII_RSTn),				// out	: PHY reset
		.GMII_1000M			(1'b1				),		// in	: GMII mode (0:MII, 1:GMII)
		// TX
		.GMII_TX_CLK		(SGMII_CLK),				// in	: Tx clock
		.GMII_TX_EN			(GMII_TX_EN),				// out	: Tx enable
		.GMII_TXD			(GMII_TXD[7:0]),			// out	: Tx data[7:0]
		.GMII_TX_ER			(GMII_TX_ER),				// out	: TX error
		// RX
		.GMII_RX_CLK		(SGMII_CLK),				// in	: Rx clock
		.GMII_RX_DV			(GMII_RX_DV),				// in	: Rx data valid
		.GMII_RXD			(GMII_RXD[7:0]),			// in	: Rx data[7:0]
		.GMII_RX_ER			(GMII_RX_ER),				// in	: Rx error
		.GMII_CRS			(1'b0),					// in	: Carrier sense
		.GMII_COL			(1'b0),					// in	: Collision detected
		// Management IF
		.GMII_MDC			(GMII_MDC),					// out	: Clock for MDIO
		.GMII_MDIO_IN		(GMII_MDIO),				// in	: Data
		.GMII_MDIO_OUT		(GMII_MDIO_OUT),			// out	: Data
		.GMII_MDIO_OE		(GMII_MDIO_OE),				// out	: MDIO output enable
	// User I/F
		.SiTCP_RST			(SiTCP_RST),				// out	: Reset for SiTCP and related circuits
		// TCP connection control
		.TCP_OPEN_REQ		(1'b0),						// in	: Reserved input, shoud be 0
		.TCP_OPEN_ACK		(TCP_OPEN_ACK),				// out	: Acknowledge for open (=Socket busy)
		.TCP_ERROR			(),							// out	: TCP error, its active period is equal to MSL
		.TCP_CLOSE_REQ		(TCP_CLOSE_REQ),			// out	: Connection close request
		.TCP_CLOSE_ACK		(TCP_CLOSE_REQ),			// in	: Acknowledge for closing
		// FIFO I/F
		.TCP_RX_WC			({4'b1111,FIFO_DATA_COUNT[11:0]}),					// in	: Rx FIFO write count[15:0] (Unused bits should be set 1)
		.TCP_RX_WR			(TCP_RX_WR),				// out	: Write enable
		.TCP_RX_DATA		(TCP_RX_DATA[7:0]),			// out	: Write data[7:0]
		.TCP_TX_FULL		(TCP_TX_FULL),				// out	: Almost full flag
		.TCP_TX_WR			(FIFO_RD_VALID),			// in	: Write enable
		.TCP_TX_DATA		(TCP_TX_DATA[7:0]),			// in	: Write data[7:0]
	// RBCP
		.RBCP_ACT			(		),					// out	: RBCP active
		.RBCP_ADDR			(RBCP_ADDR[31:0]),			// out	: Address[31:0]
		.RBCP_WD			(RBCP_WD[7:0]),				// out	: Data[7:0]
		.RBCP_WE			(RBCP_WE),					// out	: Write enable
		.RBCP_RE			(RBCP_RE),					// out	: Read enable
		.RBCP_ACK			(RBCP_ACK),					// in	: Access acknowledge
		.RBCP_RD			(RBCP_RD[7:0])				// in	: Read data[7:0]
	);


//FIFO
	fifo_generator_v11_0 fifo_generator_v11_0(
	  .clk			(CLK_200M				),//in	:
	  .rst			(~TCP_OPEN_ACK			),//in	:
	  .din			(TCP_RX_DATA[7:0]		),//in	:
	  .wr_en		(TCP_RX_WR				),//in	:
	  .full			(						),//out	:
	  .dout			(TCP_TX_DATA[7:0]		),//out	:
	  .valid		(FIFO_RD_VALID			),//out	:active hi
	  .rd_en		(~TCP_TX_FULL			),//in	:
	  .empty		(						),//out	:
	  .data_count	(FIFO_DATA_COUNT[11:0]	)//out	:[11:0]
	);

	BUFGCE	BUF_SGMII(.O(SGMII_CLK), .CE(sgmii_clk_en), .I(userclk2));
	
	// See this ip/gig_ethernet_pcs_pma_0/gig_ethernet_pcs_pma_0.veo
	gig_ethernet_pcs_pma_0 gig_ethernet_pcs_pma_0 (
		.gtrefclk_p				(SGMII_CLK_P),		// input
		.gtrefclk_n				(SGMII_CLK_N),		// input
		.gtrefclk_out			(),					// output
		.gtrefclk_bufg_out		(),					// output
		.txn					(SGMII_TXN),		// output
		.txp					(SGMII_TXP),		// output
		.rxn					(SGMII_RXN),		// input
		.rxp					(SGMII_RXP),		// input
		.independent_clock_bufg	(CLK_200M),			// input
		.userclk_out			(),					// output
		.userclk2_out			(userclk2),			// output
		.rxuserclk_out			(),					// output
		.rxuserclk2_out			(),					// output
		.resetdone				(),					// output
		.pma_reset_out			(),					// output
		.mmcm_locked_out		(),					// output
		
		.sgmii_clk_r			(),					// output
		.sgmii_clk_f			(),					// output
		.sgmii_clk_en			(sgmii_clk_en),		// output
		.gmii_txd				(GMII_TXD[7:0]),	// input
		.gmii_tx_en				(GMII_TX_EN),		// input
		.gmii_tx_er				(GMII_TX_ER),		// input
		.gmii_rxd				(GMII_RXD[7:0]),	// output
		.gmii_rx_dv				(GMII_RX_DV),		// output
		.gmii_rx_er				(GMII_RX_ER),		// output
		.gmii_isolate			(),					// output
		
		.configuration_vector	(5'b1_0000),		// input
		.an_interrupt			(),					// output
		.an_adv_config_vector	(16'd1),			// input
		.an_restart_config		(1'b0),				// input
		.speed_is_10_100		(SGMII_LINK[1]),	// input
		.speed_is_100			(SGMII_LINK[0]),	// input
		.status_vector			(STATUS_VECTOR[15:0]),// output
		.reset					(~SYS_RSTn),		// input
		.signal_detect			(1'b1),				// input
		.gt0_qplloutclk_out		(),					// output
		.gt0_qplloutrefclk_out	()					// output
	);


//RBCP_test
	always@(posedge CLK_200M)begin
		if(RBCP_WE)begin
			OFFSET_TEST[31:0]  <= {RBCP_ADDR[31:2],2'b00}+{RBCP_WD[7:0],RBCP_WD[7:0],RBCP_WD[7:0],RBCP_WD[7:0]};
		end
		RBCP_RD[7:0]	<=  (
			((RBCP_ADDR[7:0]==8'h00)?	OFFSET_TEST[ 7: 0]:	8'h00)|
			((RBCP_ADDR[7:0]==8'h01)?	OFFSET_TEST[15: 8]:	8'h00)|
			((RBCP_ADDR[7:0]==8'h02)?	OFFSET_TEST[23:16]:	8'h00)|
			((RBCP_ADDR[7:0]==8'h03)?	OFFSET_TEST[31:24]:	8'h00)
		);
		RBCP_ACK  <= RBCP_RE | RBCP_WE;
	end


endmodule
