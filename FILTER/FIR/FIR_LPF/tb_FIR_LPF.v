`timescale 1ns/1ps
module tb_FIR_LPF;

    localparam SIM_TIME = 24000000;     // Simulation time

    reg                     clk;        // clock
    reg                     clk_1;
    reg	                    rst;        // asynchonus reset
    reg                     s_clk;      // func_gen sampling clock
    reg                     f_s;
    wire                    f_s_1;        // Low pass filter sampling clock

    reg             [1:0]   sel;        // Select wave_a or wave_b or sum_wave
    reg             [18:0]  f_set_a;    // wave_a freq
    reg             [18:0]  f_set_b;    // wave_b freq
    reg             [18:0]  f_set_c;
    reg                     w_set_a;    // wave_a type (sin or cos)
    reg                     w_set_b;    // wave_b type 
    reg                     w_set_c;    // wave_c type 
    reg             [2:0]   a_set_a;    // wave_a amplitude
    reg             [2:0]   a_set_b;    // wave_b amplitude
    reg             [2:0]   a_set_c;    // wave_c amplitude 

    wire	        [11:0]	uwave_a;    // func_gen_a output wave (unsigned)
    wire            [11:0]  uwave_b;    // func_gen_b output wave

    wire    signed	[11:0]	swave_a;    // signed wave_a
    wire    signed	[11:0]	swave_b;    // signed wave_b
    wire    signed	[11:0]	swave_c;    // signed wave_c
    wire    signed	[12:0]	sum_wave;   // swave_a + swave_b
    wire    signed  [13:0]  sub_wave;

    wire	signed  [11:0]	di_fir;     // FIR LPF input
    wire	signed  [11:0]	do_fir_lpf; // FIR LPF output


    // Function generator A instant
    func_gen func_gen_a
    (   
        // INPUT
        .clk(clk)               ,
        .s_clk(s_clk)           ,
        .rst(rst)               ,
        .f_set(f_set_a)         ,
        .w_set(w_set_a)         ,
        .a_set(a_set_a)         ,

        // OUTPUT
        .wave(swave_a)       
    );  

    // Function generator B instant
    func_gen func_gen_b
    (   
        // INPUT
        .clk(clk)               ,
        .s_clk(s_clk)           ,
        .rst(rst)               ,
        .f_set(f_set_b)         ,
        .w_set(w_set_b)         ,
        .a_set(a_set_b)         ,

        // OUTPUT
        .wave(swave_b)       
    );  

    // Function generator C instant
    func_gen func_gen_c
    (   
        // INPUT
        .clk(clk)               ,
        .s_clk(s_clk)           ,
        .rst(rst)               ,
        .f_set(f_set_c)         ,
        .w_set(w_set_c)         ,
        .a_set(a_set_c)         ,

        // OUTPUT
        .wave(swave_c)       
    );

    //assign swave_a  = {~uwave_a[11], uwave_a[10:0]};
    //ssign swave_b  = {~uwave_b[11], uwave_b[10:0]};
    assign sum_wave = (swave_a + swave_b);
    assign sub_wave = (swave_a - swave_b - swave_c);
    assign di_fir = (sel == 2'd0) ? swave_a :
                    (sel == 2'd1) ? swave_b :
                    (sel == 2'd2) ? swave_c :
                    sub_wave[13:2];

    // FIR Low pass filter instant
    FIR_LPF FIR_LPF
    (   
        //INPUT 
        .clk(clk)               ,
        .rst(rst)               ,
        .f_s(f_s_1)               ,
        .din(di_fir)            ,

        // OUTPUT
        .dout(do_fir_lpf)
    );
    
    clk_20k_gen clk_20k_gen
    (
        .clk(clk_1)               ,
        .rst(rst)               ,

        .clk_20k(f_s_1)       
    );

    // Clock generate
    always #50      clk_1 = ~clk_1;
    always #250     clk = ~clk;           // 100MHz
    always #500     s_clk = ~s_clk;       // 1MHz
    always #25000   f_s = ~f_s;             // 20kHz

    // Set initial values
    initial begin
        rst = 1'b1;
        clk = 1'b0;
        clk_1 = 1'b0;
        s_clk = 1'b0;
        f_s = 1'b0;
        
        f_set_a = 19'd200;
        f_set_b = 19'd1600;
        f_set_c = 19'd2000;
        w_set_a = 1'b0;         // sin
        w_set_b = 1'b0;         // sin
        w_set_c = 1'b1;         // cos
        a_set_a = 3'd5;         // 4V   
        a_set_b = 3'd5;         // 5V
        a_set_c = 3'd5;         // 10V
        sel = 2'd0;

        #10
        rst = 1'b0;
        #10
        rst = 1'b1;

        #8550000
        sel = 2'd1;
        #8000000
        sel = 2'd2;
    end

    //creat dump file
    initial begin
        $dumpfile("FIR_LPF.vcd");
        $dumpvars(0, tb_FIR_LPF);

        #(SIM_TIME);
        $finish;
    end

endmodule