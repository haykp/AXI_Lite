
module TB_AXI_Lite ();

// Clock signal
bit                   clock;
// Reset signal
bit                   reset;

axil_itf itf (.aclk(clock), .aresetn(reset) );

axis_lite_m  inst_axil_m ( 
			  /**************** System Signals *******************************/
			 .aclk 				(	itf.aclk			),
			 .aresetn			(	itf.aresetn			),
			 /**************** Write Address Channel Signals ******************/
			 .m_axi_awaddr		(	itf.m_axi_awaddr	),
			 .m_axi_awprot		(	itf.m_axi_awprot	),
			 .m_axi_awvalid		(	itf.m_axi_awvalid  	),
			 .m_axi_awready		(	itf.m_axi_awready  	),
			  /**************** Write Data Channel Signals *******************/
			 .m_axi_wdata		(	itf.m_axi_wdata		),
			 .m_axi_wstrb		(	itf.m_axi_wstrb		),
			 .m_axi_wvalid		(	itf.m_axi_wvalid	),
			 .m_axi_wready		(	itf.m_axi_wready	),
			  /**************** Write Response Channel Signals ***************/
			 .m_axi_bresp		(	itf.m_axi_bresp		),
			 .m_axi_bvalid		(	itf.m_axi_bvalid   	),
			 .m_axi_bready		(	itf.m_axi_bready   	),
			  /**************** Read Address Channel Signals ****************/
			 .m_axi_araddr		(	itf.m_axi_araddr	),
			 .m_axi_arprot		(	itf.m_axi_arprot	),
			 .m_axi_arvalid		(	itf.m_axi_arvalid  	),
			 .m_axi_arready		(	itf.m_axi_arready  	),
			  /**************** Read Data Channel Signals ********************/
			 .m_axi_rdata		(	itf.m_axi_rdata		),
			 .m_axi_rresp		(	itf.m_axi_rresp    	),
			 .m_axi_rvalid		(	itf.m_axi_rvalid   	),
			 .m_axi_rready		(	itf.m_axi_rready   	),
			  /**************** User Signals *******************************/
			 .app_waddr			(	itf.app_waddr		),
			 .app_wdata			(	itf.app_wdata		),
			 .app_wen			(	itf.app_wen			),	
			 .app_wdone 		(	itf.app_wdone		),
			 
			 .app_raddr			(	itf.app_raddr		),
			 .app_ren			(	itf.app_ren			),	
			 .app_rdata			(	itf.app_rdata		),
			 .app_rdone 		(	itf.app_rdone		)
			);

axi_vip_0 inst_axil_s (
			  .aclk				(itf.aclk),                    // input wire aclk
			  .aresetn			(itf.aresetn),              // input wire aresetn
			  .s_axi_awaddr		(itf.axi_awaddr),    // input wire [31 : 0] s_axi_awaddr
			  .s_axi_awprot		(itf.axi_awprot),    // input wire [2 : 0] s_axi_awprot
			  .s_axi_awvalid	(itf.axi_awvalid),  // input wire s_axi_awvalid
			  .s_axi_awready	(itf.axi_awready),  // output wire s_axi_awready
			  .s_axi_wdata		(itf.axi_wdata),      // input wire [31 : 0] s_axi_wdata
			  .s_axi_wstrb		(itf.axi_wstrb),      // input wire [3 : 0] s_axi_wstrb
			  .s_axi_wvalid		(itf.axi_wvalid),    // input wire s_axi_wvalid
			  .s_axi_wready		(itf.axi_wready),    // output wire s_axi_wready
			  .s_axi_bresp		(itf.axi_bresp),      // output wire [1 : 0] s_axi_bresp
			  .s_axi_bvalid		(itf.axi_bvalid),    // output wire s_axi_bvalid
			  .s_axi_bready		(itf.axi_bready),    // input wire s_axi_bready
			  .s_axi_araddr		(itf.axi_araddr),    // input wire [31 : 0] s_axi_araddr
			  .s_axi_arprot		(itf.axi_arprot),    // input wire [2 : 0] s_axi_arprot
			  .s_axi_arvalid	(itf.axi_arvalid),  // input wire s_axi_arvalid
			  .s_axi_arready	(itf.axi_arready),  // output wire s_axi_arready
			  .s_axi_rdata		(itf.axi_rdata),      // output wire [31 : 0] s_axi_rdata
			  .s_axi_rresp		(itf.axi_rresp),      // output wire [1 : 0] s_axi_rresp
			  .s_axi_rvalid		(itf.axi_rvalid),    // output wire s_axi_rvalid
			  .s_axi_rready		(itf.axi_rready)    // input wire s_axi_rready
);
   
	
task write_data ( axil_itf itf );
	$display ("[INFO] Calling write_data task");
	
	itf.app_waddr <= 32'haaaa_bbbb;
	itf.app_wdata <= 32'h5aa5_a55a;
	@ ( posedge itf.aclk);
	itf.app_wen <= 1'b1;
	@ ( posedge itf.aclk);
	itf.app_wen <= 1'b0;
	@ ( posedge itf.app_wdone);
	@ ( posedge itf.aclk);

endtask

task read_data ( axil_itf itf	);
	$display ("[INFO]Calling read_data task");
	
	itf.app_raddr <= 32'haaaa_bbbb;
	@ ( posedge itf.aclk);
	itf.app_ren <= 1'b1;
	@ ( posedge itf.app_rdone);	
	@ ( posedge itf.aclk);

endtask	
	
////// MAIN	////
  initial begin
    reset <= 1'b1;
    repeat (5) @(negedge clock);
  end

    always #10 clock <= ~clock;	
	
	
	initial
	begin
		@ ( posedge reset);
		@ ( posedge itf.aclk);
		@ ( posedge itf.aclk);
		
		write_data (itf);
	end
	
endmodule
