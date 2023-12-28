
// Quartus II Verilog Template
// 4-State Moore state machine

// A Moore machine's outputs are dependent only on the current state.
// The output is written only when the state changes.  (State
// transitions are synchronous.)

module Core_moore
(
	input reset,					//reset键，将恢复初始状态
	input clk,						//连晶振
	input [3:0]row,				//与键盘行相连
	
	output wire[3:0]circ,		//选择检测矩阵键盘的列
	output wire delay_start,	//可以用作给逻辑运算部分，输入的触发
	output wire[3:0]dig,			//选择显示的数码管dig
	output wire[6:0]eight		//给dig的七段显示

);
	
	reg [3:0]key;		//键盘输入的键
	reg [3:0]key0;		//输出到dig0的数
	reg [3:0]key1;		//输出到dig1的数
	reg [3:0]key2;		//输出到dig2的数
	reg [3:0]key3;		//输出到dig3的数
	reg [3:0]enable;	//选择显示dig中的哪几位的
	
	wire[3:0]word;		//将键盘输入编码后的输出
	wire m_clk;			//分频后的时钟信号
	wire en;				//键盘输入键的信号
	wire word_mesg;		//对键盘输入键编码完毕的信号
	
	
	/*
	//将晶振分频
	//具体数值根据模块内参数ntimes决定
	Divide_double_ntimes div_clk(	
	.div(m_clk),
	.clk(clk)
	);
	
	//连接键盘输入，通过对circ进行修改,检测row来检测键盘输入，已防抖
	//给core提供en和key，en代表键盘有效输入，key为对应键值
	//-------------------对应关系说明----------------------------
	//circ（1110代表0列，0111代表3列），row[i]代表第i行，key=列数*4+行数
	//---------------------------------------------------------
	Input_key minput(		
	.clk(m_clk),
	.row(row),
	.circ(circ),
	.last_valid(key),
	.en(en)
	);
	
	//输入clk决定扫描一个的时间，enable代表是否显示，numi代表在digi上显示多少数字（一位16进制）
	//输出gid连接到gid使能端，abcdefg连接到七段显示数码管
	Output_Leds moutput(		//将key输出到dig上
	.enable(enab),
	.clk(m_clk),
	.num0(key0),
	.num1(key1),
	.num2(key2),
	.num3(key3),
	.gid(gid),
	.abcdefg(eight)
	);

	// Declare state register
	reg [1:0]state;
	reg [4:0]num_temp;
	reg bigger_ten;

	// Declare states
	parameter S_Init = 0, S_Input = 1, S_Count = 2, S3 = 3;
	//S0代表初始状态
	//S1代表输入状态
	//S2代表计时状态
	*/
/*
	//当输入word时响应
	always @(posedge word_mesg)
	begin
	if(word != 2'd15)
	begin
	//如果word不是15才进行下面的语句
		//根据状态响应word
		case(state)
		S_Init://如果S0,有输入但未开始
		begin
			if(word == 2'd10)	//只有输入为start时变换状态为输入，其他不变
			state = S_Input;
		end
		S_Input:	//如果S1,此刻为输入状态
		begin
			if(word == 2'd10) ;	//如果是开始键，啥也不干
			else if(word == 2'd11)	//如果是清零键，把所有都清零
			begin 
				out3 = 0;
				out2 = 0;
				out1 = 0;
				out0 = 0;
			end
			else if(word == 2'd12)	//如果是确定键，转到计时状态
			begin
				state = S_Count;
			end
			else		//如果都不是，那就是数字键
			begin
				out3 = out2;	//左二移到左一
				out2 = word;	//左二换为word
				//接下来判断是否超max
				if(out3*2'd10 + out2 > 2'd20)	//如果超了，out为20
				begin
					out3 = 2'd4;
					out2 = 0;
				end
				//进行乘2操作
				num_temp = out2<<1;	//先看低位
				if(num_temp >= 10)	//如果低位乘2后大于10
				begin
					out0 = num_temp -10;	//out0要减10
					out1 = (out3<<1) +1;	//out1要进1
				end
				else
				begin
					out0 = num_temp;		//否则直接赋值
					out1 = (out3<<1);
				end	
			end
		end	
		S_Count:;	//暂时不涉及
		S3:;			//也不涉及
		endcase
	end
	end
	
	// Output depends only on the state
	always @ (state) begin
		case (state)
			S_Init:
				;
			S_Input:
				;
			S_Count:
				;
			S3:
				;
			default:
				;
		endcase
	end
*/
	// Determine the next state
	/*
	always @ (posedge clk or posedge reset) begin
		if (reset)
			state <= S_Init;
		else
			case (state)
				S0:
					state <= S1;
				S1:
					if (in)
						state <= S2;
					else
						state <= S1;
				S2:
					if (in)
						state <= S3;
					else
						state <= S1;
				S3:
					if (in)
						state <= S2;
					else
						state <= S3;
			endcase
	end
	*/

endmodule

