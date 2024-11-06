









`timescale 1ns/100ps





//`include "./packet_parameter.v"
//`include "./error_reconcilation_parameter.v"



module tb_top_AB_ER ();
    parameter CLK_PERIOD = 10;

    reg clk;
    reg rst_n;
    reg start_switch;
    

    wire sifted_key_addr_index;
    assign sifted_key_addr_index = 1'b0;

//	initial begin
//		$dumpfile("ER.vcd");
//		$dumpvars(0,tb_top_AB_ER);
//	end
    // ===== Clk fliping ===== //
	initial begin
		clk = 1;
		forever #(CLK_PERIOD/2) clk = ~clk;
	end

	initial begin
        rst_n = 1;
        #(CLK_PERIOD*2000) rst_n = 0;
        #(CLK_PERIOD*1000) rst_n = 1;  
	end


    initial begin
        start_switch = 0;
		wait (rst_n == 0);
		wait (rst_n == 1);
        #(CLK_PERIOD*40);
        @(negedge clk);
        start_switch = 1;
    end



    wire Areconciledkey_clka;
    wire Areconciledkey_ena;
    wire Areconciledkey_wea;
    wire [14:0] Areconciledkey_addra;
    wire [63:0] Areconciledkey_dina;


    wire Breconciledkey_clka;
    wire Breconciledkey_ena;
    wire Breconciledkey_wea;
    wire [14:0] Breconciledkey_addra;
    wire [63:0] Breconciledkey_dina;

    wire [`FRAME_LEAKED_INFO_WIDTH-1:0] single_frame_leaked_info;
    wire [`FRAME_ERROR_COUNT_WIDTH-1:0] single_frame_error_count;
    wire single_frame_parameter_valid;

    wire A_single_frame_error_verification_fail;         //A error verification is fail
    wire B_single_frame_error_verification_fail;         //B error verification is fail

    wire finish_A_ER;
    wire finish_B_ER;



//    top_AB_ER top_AB_ER_test (
//        .clk(clk),                                      // Connect to clock
//        .rst_n(rst_n),                                  // Connect to reset

//        .start_switch(start_switch),                    // Start switch signal

//        .finish_A_ER(finish_A_ER),
//        .finish_B_ER(finish_B_ER),

//        .sifted_key_addr_index(sifted_key_addr_index),  // Address index input

//        .Areconciledkey_clka(Areconciledkey_clka),      // Alice reconciled key clock
//        .Areconciledkey_ena(Areconciledkey_ena),        // Alice reconciled key enable
//        .Areconciledkey_wea(Areconciledkey_wea),        // Alice reconciled key write enable
//        .Areconciledkey_addra(Areconciledkey_addra),    // Alice reconciled key address
//        .Areconciledkey_dina(Areconciledkey_dina),      // Alice reconciled key data input

//        .Breconciledkey_clka(Breconciledkey_clka),      // Bob reconciled key clock
//        .Breconciledkey_ena(Breconciledkey_ena),        // Bob reconciled key enable
//        .Breconciledkey_wea(Breconciledkey_wea),        // Bob reconciled key write enable
//        .Breconciledkey_addra(Breconciledkey_addra),    // Bob reconciled key address
//        .Breconciledkey_dina(Breconciledkey_dina),      // Bob reconciled key data input

//        .single_frame_leaked_info(single_frame_leaked_info),            // Output for leaked info
//        .single_frame_error_count(single_frame_error_count),            // Output for error count
//        .single_frame_parameter_valid(single_frame_parameter_valid),    // Output for parameter validity
//        .A_single_frame_error_verification_fail(A_single_frame_error_verification_fail), // Alice error verification status
//        .B_single_frame_error_verification_fail(B_single_frame_error_verification_fail)  // Bob error verification status
//    );

    top_AB_ER_Bram_interface top_AB_ER_test (
        .clk(clk),                                      // Connect to clock
        .rst_n(rst_n),                                  // Connect to reset

        .start_switch(start_switch),                    // Start switch signal

        .finish_A_ER(finish_A_ER),
        .finish_B_ER(finish_B_ER),

        .sifted_key_addr_index(sifted_key_addr_index),  // Address index input

        .Areconciledkey_clka(Areconciledkey_clka),      // Alice reconciled key clock
        .Areconciledkey_ena(Areconciledkey_ena),        // Alice reconciled key enable
        .Areconciledkey_wea(Areconciledkey_wea),        // Alice reconciled key write enable
        .Areconciledkey_addra(Areconciledkey_addra),    // Alice reconciled key address
        .Areconciledkey_dina(Areconciledkey_dina),      // Alice reconciled key data input

        .Breconciledkey_clka(Breconciledkey_clka),      // Bob reconciled key clock
        .Breconciledkey_ena(Breconciledkey_ena),        // Bob reconciled key enable
        .Breconciledkey_wea(Breconciledkey_wea),        // Bob reconciled key write enable
        .Breconciledkey_addra(Breconciledkey_addra),    // Bob reconciled key address
        .Breconciledkey_dina(Breconciledkey_dina),      // Bob reconciled key data input

        .single_frame_leaked_info(single_frame_leaked_info),            // Output for leaked info
        .single_frame_error_count(single_frame_error_count),            // Output for error count
        .single_frame_parameter_valid(single_frame_parameter_valid),    // Output for parameter validity
        .A_single_frame_error_verification_fail(A_single_frame_error_verification_fail), // Alice error verification status
        .B_single_frame_error_verification_fail(B_single_frame_error_verification_fail)  // Bob error verification status
    );

    integer A_reconciledkey_out;
    initial A_reconciledkey_out = $fopen("../../../../HW_sim_result/top_A_reconciledkey_out.txt", "w");

    always @(*) begin
        if (Areconciledkey_wea&&Areconciledkey_ena) begin
            $fdisplay(A_reconciledkey_out,"%h",Areconciledkey_dina);
        end
    end

    integer B_reconciledkey_out;
    initial B_reconciledkey_out = $fopen("../../../../HW_sim_result/top_B_reconciledkey_out.txt", "w");

    always @(*) begin
        if (Breconciledkey_wea&&Breconciledkey_ena) begin
            $fdisplay(B_reconciledkey_out,"%h",Breconciledkey_dina);
        end
    end



    integer leakedinfo_out;
    initial leakedinfo_out = $fopen("../../../../HW_sim_result/top_leakedinfo_out.txt", "w");

    always @(*) begin
        if (single_frame_parameter_valid) begin
            $fdisplay(leakedinfo_out,"%0d",single_frame_leaked_info);
        end
    end


    integer est_errorcount_out;
    initial est_errorcount_out = $fopen("../../../../HW_sim_result/top_est_errorcount_out.txt", "w");

    always @(*) begin
        if (single_frame_parameter_valid) begin
            $fdisplay(est_errorcount_out,"%0d",single_frame_error_count);
        end
    end

















    reg A_finish, B_finish;
    always @(posedge clk ) begin
        if (~rst_n) begin
            A_finish <= 1'b0;
        end
        else if (finish_A_ER) begin
            A_finish <= 1'b1;
        end
        else begin
            A_finish <= A_finish;
        end
    end

    always @(posedge clk ) begin
        if (~rst_n) begin
            B_finish <= 1'b0;
        end
        else if (finish_B_ER) begin
            B_finish <= 1'b1;
        end
        else begin
            B_finish <= B_finish;
        end
    end

    always @(*) begin
        if (B_finish && A_finish) begin
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            $display("[FINISH]");
            #(CLK_PERIOD);
            $fclose(A_reconciledkey_out);
            $fclose(B_reconciledkey_out);
            $finish;
        end
    end
endmodule