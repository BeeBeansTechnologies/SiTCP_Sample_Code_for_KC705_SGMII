module
	RBCP(
		input	wire		CLK_200M,	//in
		input	wire[ 2:0]	DIP,		//in
		input	wire		RBCP_WE,	//in
		input	wire		RBCP_RE,	//in
		input	wire[ 7:0]	RBCP_WD,	//in
		input	wire[31:0]	RBCP_ADDR,	//in
		output	reg	[ 7:0]	RBCP_RD,	//out
		output	reg			RBCP_ACK	//out
	);
	reg		[ 7:0]	x00Reg;
	reg		[ 7:0]	x01Reg;
	reg		[ 7:0]	x02Reg;
	reg		[ 7:0]	x03Reg;
	//for pipeline
	reg				P1WE;
	reg				P0WE;
	reg				P1RE;
	reg				P0RE;
	reg		[15:0]	ADDR_U;//�A�h���X����
	reg		[13:0]	ADDR_D;//�A�h���X����
	reg		[ 1:0]	P0RE_ADDR;//�A�h���X����2bit
	reg		[ 1:0]	P1RE_ADDR;//�A�h���X����2bit
	reg		[ 1:0]	ADDR_RW;//�������ݓǂݍ��݃A�h���X����
	reg				WR_ADDR;//ACK�ԓ��p
	always@(posedge CLK_200M )begin
		//�p�C�v���C����
		//��i��
		P0WE			<=	RBCP_WE;
		P0RE			<=	RBCP_RE;
		ADDR_U[15:0]	<=	RBCP_ADDR[31:16];
		ADDR_D[13:0]	<=	RBCP_ADDR[15: 2];
		P0RE_ADDR[ 1:0]	<=	RBCP_ADDR[ 1: 0];
		//��i��
		P1WE			<=	P0WE;
		P1RE			<=	P0RE;
		P1RE_ADDR[1:0]	<=	P0RE_ADDR[1:0];
		ADDR_RW[1]		<=	(ADDR_U[15:0] == 16'd0);
		ADDR_RW[0]		<=	(ADDR_D[13:0] == 14'd0);
		//�O�i��
		//���W�X�^�ւ̋L�q
		x00Reg[7:0]	<=	{5'd0,DIP[2:0]};//read DIPswitch
		x01Reg[7:0]	<=	((&ADDR_RW[1:0]) & (P1RE_ADDR[1:0] == 2'd1)& P1WE)?	RBCP_WD[7:0]:x01Reg[7:0];
		x02Reg[7:0]	<=	((&ADDR_RW[1:0]) & (P1RE_ADDR[1:0] == 2'd2)& P1WE)?	RBCP_WD[7:0]:x02Reg[7:0];
		x03Reg[7:0]	<=	((&ADDR_RW[1:0]) & (P1RE_ADDR[1:0] == 2'd3)& P1WE)?	RBCP_WD[7:0]:x03Reg[7:0];//write value in reg

		//���W�X�^�l�ǂݏo��
		RBCP_RD[ 7:0] 	<=	(
			(((&ADDR_RW[1:0]) & P1RE_ADDR[1:0] == 2'd0)?	x00Reg[7:0]:8'd0)|
			(((&ADDR_RW[1:0]) & P1RE_ADDR[1:0] == 2'd1)?	x01Reg[7:0]:8'd0)|
			(((&ADDR_RW[1:0]) & P1RE_ADDR[1:0] == 2'd2)?	x02Reg[7:0]:8'd0)|
			(((&ADDR_RW[1:0]) & P1RE_ADDR[1:0] == 2'd3)?	x03Reg[7:0]:8'd0)
		);
		//ACK�ԓ�
		RBCP_ACK  	<= 	(&ADDR_RW[1:0]) & (P1RE | P1WE);
	end
endmodule

	