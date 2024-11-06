









`timescale 1ns/100ps





`include "./packet_parameter.v"
`include "./error_reconcilation_parameter.v"



module tb_AB_single_frame_ER ();
    parameter CLK_PERIOD = 5;

    reg clk;
    reg rst_n;
    reg start_switch;
    
    wire [`FRAME_ROUND_WIDTH-1:0] frame_round;  //0~63
    assign frame_round = `FRAME_ROUND_WIDTH'd0;

    wire sifted_key_addr_index;
    assign sifted_key_addr_index = 1'b0;

    // ===== Clk fliping ===== //
	initial begin
		clk = 1;
		forever #(CLK_PERIOD/2) clk = ~clk;
	end

	initial begin
        rst_n = 1;
        #(CLK_PERIOD*20) rst_n = 0;
        #(CLK_PERIOD*10) rst_n = 1;  
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

    wire [`FRAME_LEAKED_INFO_WIDTH-1:0] A_er_leaked_info;
    wire [`FRAME_ERROR_COUNT_WIDTH-1:0] A_er_error_count;
    wire A_er_parameter_valid;

    wire A_error_verification_fail;         //A error verification is fail
    wire A_finish_error_reconciliation;      //A error reconsiliation is done

    wire B_error_verification_fail;         //B error verification is fail
    wire B_finish_error_reconciliation;      //B error reconsiliation is done



    AB_single_frame_ER test_sf_ER(

        .clk(clk),

        .rst_n(rst_n),

        .start_switch(start_switch),
        
        .frame_round(frame_round),

        .sifted_key_addr_index(sifted_key_addr_index),

        .Areconciledkey_clka(Areconciledkey_clka),
        .Areconciledkey_ena(Areconciledkey_ena),
        .Areconciledkey_wea(Areconciledkey_wea),
        .Areconciledkey_addra(Areconciledkey_addra),
        .Areconciledkey_dina(Areconciledkey_dina),


        .Breconciledkey_clka(Breconciledkey_clka),
        .Breconciledkey_ena(Breconciledkey_ena),
        .Breconciledkey_wea(Breconciledkey_wea),
        .Breconciledkey_addra(Breconciledkey_addra),
        .Breconciledkey_dina(Breconciledkey_dina),

        .A_er_leaked_info(A_er_leaked_info),
        .A_er_error_count(A_er_error_count),
        .A_er_parameter_valid(A_er_parameter_valid),

        .A_error_verification_fail(A_error_verification_fail),         //A error verification is fail
        .A_finish_error_reconciliation(A_finish_error_reconciliation),      //A error reconsiliation is done

        .B_error_verification_fail(B_error_verification_fail),         //B error verification is fail
        .B_finish_error_reconciliation(B_finish_error_reconciliation)      //B error reconsiliation is done
    );



    integer A_reconciledkey_out;
    initial A_reconciledkey_out = $fopen("../../../../HW_sim_result/A_single_frame_reconciledkey_out.txt", "w");


    always @(*) begin
        if (Areconciledkey_wea&&Areconciledkey_ena) begin
            $fdisplay(A_reconciledkey_out,"%h",Areconciledkey_dina);
        end
    end

    integer B_reconciledkey_out;
    initial B_reconciledkey_out = $fopen("../../../../HW_sim_result/B_single_frame_reconciledkey_out.txt", "w");


    always @(*) begin
        if (Breconciledkey_wea&&Breconciledkey_ena) begin
            $fdisplay(B_reconciledkey_out,"%h",Breconciledkey_dina);
        end
    end


    reg A_finish, B_finish;
    always @(posedge clk ) begin
        if (~rst_n) begin
            A_finish <= 1'b0;
        end
        else if (A_finish_error_reconciliation) begin
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
        else if (B_finish_error_reconciliation) begin
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