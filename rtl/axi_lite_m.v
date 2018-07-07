// Simple AXI-Stream Master
// Takes the data and sends it through the AXIS interface
// When send posedge happens, sends the data


`timescale 1us/1us

module axis_lite_m ( 
			  /**************** System Signals *******************************/
			  input  wire                            aclk,
			  input  wire                            aresetn,
			 /**************** Write Address Channel Signals ******************/
			  output wire [32-1:0]         			 m_axi_awaddr,
			  output wire [3-1:0]                    m_axi_awprot,
			  output   	                             m_axi_awvalid,
			  input  wire                            m_axi_awready,
			  /**************** Write Data Channel Signals *******************/
			  output wire [32-1:0]      			 m_axi_wdata,
			  output wire [32/8-1:0]    			 m_axi_wstrb,
			  output 	                             m_axi_wvalid,
			  input  wire                            m_axi_wready,
			  /**************** Write Response Channel Signals ***************/
			  input  wire [2-1:0]                    m_axi_bresp,
			  input  wire                            m_axi_bvalid,
			  output 	                             m_axi_bready,
			  /**************** Read Address Channel Signals ****************/
			  output wire [32-1:0]       			 m_axi_araddr,
			  output wire [3-1:0]                    m_axi_arprot,
			  output 	                             m_axi_arvalid,
			  input  wire                            m_axi_arready,
			  /**************** Read Data Channel Signals ********************/
			  input  wire [32-1:0]      			 m_axi_rdata,
			  input  wire [2-1:0]                    m_axi_rresp,
			  input  wire                            m_axi_rvalid,
			  output 	                             m_axi_rready,
			  /**************** User Signals *******************************/
			  input	wire [32-1:0]					 app_waddr,
			  input	wire [32-1:0]					 app_wdata,
			  input	wire         					 app_wen,
			  
			  input	wire [32-1:0]					 app_raddr,
			  input	wire         					 app_ren,
			  output reg [32-1:0]					 app_rdata,
			  output                                 app_wdone ,
			  output                                 app_werror ,
			  output                                 app_rdone ,
			  output                                 app_rerror
			);



/**************** Write Channel ******************/
wire waddr_done,wdata_done,wresp_slave, wresp_slave_final;
axis_m axis_waddr ( .areset_n(aresetn), .aclk(aclk), 
					.data		(app_waddr), 
					.send		(app_wen),
					
					.tready		(m_axi_awready), 
					.tvalid		(m_axi_awvalid),
					.tlast		(m_axi_awvalid), 
					.tdata		(m_axi_awaddr),
					
					.finish		(waddr_done)
			);
			
assign m_axi_awprot = 3'o0;
// wdata
axis_m axis_wdata ( .areset_n(aresetn), .aclk(aclk), 
					.data		(app_wdata), 
					.send		(app_wen),
					
					.tready		(m_axi_wready), 
					.tvalid		(m_axi_wvalid),
					.tlast		(m_axi_wvalid), 
					.tdata		(m_axi_wdata),
					
					.finish		(wdata_done)
			);
assign m_axi_wstrb = (m_axi_wvalid) ? 4'b1111 : 4'b0000; // all bytes of line contain valid data
//assign m_axi_wstrb =  4'b1111 ; // all bytes of line contain valid data

// wresponse
wire [31:0] wchnl_resp; // this is bresp of the master. Only the last 2 bits are valid bits

axis_s axis_resp ( .areset_n(aresetn), .aclk(aclk),
					.data		(wchnl_resp),
					.ready 		(app_wen), // user saying slave is ready
					
					.tready 	(m_axi_bready),
					.tvalid		(m_axi_bvalid),
					.tlast		(m_axi_bvalid),
					.tdata		( {30'b0,m_axi_bresp} ),
					
					.finish		(wresp_slave)
					);
					
assign wresp_slave_final= wresp_slave && (wchnl_resp[1:0] ==2'b00 || wchnl_resp[1:0] ==2'b01 );
					
assign app_wdone = waddr_done && wdata_done && wresp_slave_final ;
assign app_werror = wresp_slave && (wchnl_resp[1:0] ==2'b10 || wchnl_resp[1:0] ==2'b11 );

/**************** Read Channel ******************/
wire raddr_done;

assign m_axi_arprot = 1'b0;

axis_m axis_raddr ( .areset_n(aresetn), .aclk(aclk), 
					.data		(app_raddr), 
					.send		(app_ren),
					
					.tready		(m_axi_arready), 
					.tvalid		(m_axi_arvalid),
					.tlast		(m_axi_arvalid), 
					.tdata		(m_axi_araddr),
					
					.finish		(raddr_done)
			);
wire [31:0] rchnl_resp;
axis_s axis_rdata ( .areset_n(aresetn), .aclk(aclk),
					.data		(rchnl_resp),
					.ready 		(app_ren), // user saying slave is ready
					
					.tready 	(m_axi_rready),
					.tvalid		(m_axi_rvalid),
					.tlast		(m_axi_rvalid),
					.tdata		(m_axi_rdata ),
					
					.finish		(resp_slave_finish)
			);

assign app_rdone = raddr_done && resp_slave_finish && (m_axi_rresp[1:0] ==2'b00 || m_axi_rresp[1:0] ==2'b01 );
assign app_rerror = wresp_slave && (m_axi_rresp[1:0] ==2'b10 || m_axi_rresp[1:0] ==2'b11 );
	

endmodule
