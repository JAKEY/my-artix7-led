module top (
    input        clk,       // 50MHz 外部時鐘
    input  [3:0] key,       // key[0] 按下為 0
    output [3:0] led,
    // 以下為 XDC 中定義的其他 IO，設為高阻態避免短路
    output       uart_txd,
    input        uart_rxd,
    inout  [33:0] inf0,
    inout  [33:0] inf1
);

    // 50MHz 時鐘下，25,000,000 次計數等於 0.5 秒
    parameter CNT_MAX = 26'd25_000_000; 

    reg [25:0] count;
    reg [2:0]  state;
    reg [3:0]  led_logic;

    // 狀態跳轉與計數邏輯
    always @(posedge clk or negedge key[0]) begin
        if (!key[0]) begin  // Key[0] 按下時同步復位
            count <= 26'd0;
            state <= 3'd0;
        end else begin
            if (count >= CNT_MAX - 1) begin
                count <= 26'd0;
                if (state >= 3'd5) 
                    state <= 3'd0;
                else 
                    state <= state + 3'd1;
            end else begin
                count <= count + 26'd1;
            end
        end
    end

    // 狀態機定義 LED 亮滅 (1為亮邏輯)
    always @(*) begin
        case(state)
            3'd0: led_logic = 4'b0101; // 1 & 3 亮 (對應 led[0] & led[2])
            3'd1: led_logic = 4'b1010; // 2 & 4 亮 (對應 led[1] & led[3])
            3'd2: led_logic = 4'b0001; // 1 亮
            3'd3: led_logic = 4'b0010; // 2 亮
            3'd4: led_logic = 4'b0100; // 3 亮
            3'd5: led_logic = 4'b1000; // 4 亮
            default: led_logic = 4'b0000;
        endcase
    end

    // 硬體實際驅動：0 為亮，所以取反輸出
    assign led = ~led_logic;

    // 未使用的引腳處理
    assign uart_txd = 1'b1;  // 串口發送端保持高電位 (Idle)
    assign inf0 = 34'bz;     // 擴展埠設為高阻態
    assign inf1 = 34'bz;

endmodule