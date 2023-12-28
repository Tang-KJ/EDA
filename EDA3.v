
module EDA3
(
	input clk,						//连晶振
	input [3:0]row,				//与键盘行相连
	
	output wire [3:0]circ,		//选择检测矩阵键盘的列
	output wire[3:0]dig,			//选择显示的数码管dig
	output wire[6:0]eight,		//给dig的七段显示
	//output wire m_clk,
	output wire key_mesg,		//for debug
	output reg[1:0]state,			//状态
	output wire buzz				//蜂鸣器
);
	
	wire [3:0]key;		//键盘输入的键的编码
	reg [3:0]key0;		//输出到dig0的数
	reg [3:0]key1;		//输出到dig1的数
	reg [3:0]key2;		//输出到dig2的数
	reg [3:0]key3;		//输出到dig3的数
	reg [3:0]enable;	//选择显示dig中的哪几位的
	reg [6:0]times_last_test_input;	//距离上一次探测msg的周期数
	reg play_music;	//是否播放音乐
	
	
	reg [4:0]num_temp;	//计算使用中间量
	reg [10:0]time_count;	//计算时间和周期的计数量
	reg [10:0]time_second;//time_count累计的秒数
	parameter second_count = 11'd252;	//周期计数量和秒的换算关系，需要调整参数
	
	wire m_clk;			//分频后的时钟信号
	
	
	// Declare state register
//	reg [1:0]state;
	reg [1:0]next_state;
	
	
//	wire key_mesg;		//对键盘输入键编码完毕的信号
	
//	parameter enable = 4'b1111;//测试LED使用enable
//	parameter number = 4'b0000;//测试LED使用

	
	//将晶振分频
	//具体数值根据模块内参数ntimes决定
	Divide_double_ntimes div_clk(	
	.div(m_clk),
	.clk(clk)
	);
	
	//连接键盘输入，通过对circ进行修改,检测row来检测键盘输入，已防抖
	//给core提供key_mesg和key，key_mesg代表键盘有效输入，key为对应键值
	//-------------------对应关系说明----------------------------
	//circ（1110代表0列，0111代表3列），row[i]代表第i行，key=列数*4+行数
	//---------------------------------------------------------
	Input_key minput(		
	.clk(m_clk),
	.row(row),
	.circ(circ),
	.last_valid(key),
	.en(key_mesg)
	);
	
	//输入clk决定扫描一个的时间，enable代表是否显示，numi代表在digi上显示多少数字（一位16进制）
	//输出gid连接到gid使能端，abcdefg连接到七段显示数码管
	Output_Leds moutput(		//将key输出到dig上
	.enable(enable),
	.clk(m_clk),
	.num0(key0),
	.num1(key1),
	.num2(key2),
	.num3(key3),
	.dig(dig),
	.abcdefg(eight)
	);

	//根据play_music控制是否播放音乐，播放音乐在music.v里
	//clk要接精准的，更改clk的频率后要改music.v里single模块的参数
	music m_music(
	.play(play_music),
	.clk(clk),
	.buzz(buzz),
	.play_show(),
	.sound_work()
	);

	// Declare states
	parameter S_Init = 0, S_Input = 1, S_Count = 2, S_Start = 3;
	//S0代表初始状态
	//S1代表输入状态(开始状态)
	//S2代表计时状态
	
	/*
	//输入输出测试
	always @(posedge key_mesg)
	begin
	key3 = key2;
	key2 = key1;
	key1 = key0;
	key0 = key;
	end
	*/
	initial
	begin
		key0 = 0;
		key1 = 0;
		key2 = 0;
		key3 = 0;
		time_count = 0;
	end

	//当clk到来时响应
	always @(posedge m_clk)
	begin
	//输入一次后要等这么久才能再输入
	case(times_last_test_input)
	7'b1111111:;
	default:times_last_test_input = times_last_test_input+1;
	endcase
	
		//根据状态响应
		case(state)
		S_Init://如果S_Init,有输入但未开始
		begin
			
			//如果此刻有输入，且输入为start，变换状态为输入
			if(key == 4'd10 &&  key_mesg == 1)
			begin
			state = S_Input;
			times_last_test_input = 0;		//记录下本次输入，在一定的时间内不接受输入
			end
		end
		
		S_Input:	//如果S1,此刻为输入状态
		begin
			
			//如果不符合输入要求，直接跳出
			if(times_last_test_input != 7'b1111111 || key_mesg==0 || key==4'd15);	
			//符合输入要求，才考虑
			else
			begin
			times_last_test_input = 0;	//是一个有效的输入，开始计时
				case(key)
				4'd10:;//如果是开始键，啥也不干
				4'd11://如果是清零键，进入开始状态
					begin
					key0 = 0;
					key1 = 0;
					key2 = 0;
					key3 = 0;	
					state = S_Start;
					end
				4'd12:state = S_Count;//如果是确认键，进入计时模式
				default://如果都不是，那就是数字键
					begin
					//先输入进去
					key3 = key2;
					key2 = key;
					num_temp = key2<<1;			//先看低位
					if(num_temp > 9)				//如果低位乘2后大于9
						begin
						key0 = (num_temp -10);	//key0要减10
						key1 = (key3<<1) +1;		//key1要进1
						end
					else
						begin
						key0 = num_temp;			//如果低位乘2后小于9，直接赋值
						key1 = (key3<<1);
						end
					//计算完毕后，检测是否溢出
					case(key3)
						4'b0000:;
						4'b0001:;
						4'b0010:
							begin
							case(key2)
							4'b0000:;
							default:
								begin
								key3 = 4'b0010;
								key2 = 4'b0000;
								key1 = 4'b0100;
								key0 = 4'b0000;								
								end
							endcase
							end
						default:
							begin
							key3 = 4'b0010;
							key2 = 4'b0000;
							key1 = 4'b0100;
							key0 = 4'b0000;
							end
					endcase
					end						
				endcase
			end
		end
		
		S_Count:	//进入计数状态
		begin
		//如果key2和key3都是0，就不必了
		if(key2!=0 || key3!=0)
		begin
			//根据time_count计算
			case(time_count)
			second_count:			//如果到达约为1秒边界，将key2减一
				begin
				time_count = 0;	//重新开始计数
				case(key2)
					4'b0000://如果key2为0
						begin
						key2 = 4'b1001;	//key2换为9
						key3 = key3 - 1;	//key3减一						
						end
					default:	key2 = key2-1; //否则key2不为0，key2减一(由于提前判断了两个为0的情况，不会溢出)
				endcase
				case(key0)
					4'b0000://如果key0为0
						begin
						key0 = 4'b1000;	//key0换为8
						key1 = key1 - 1;	//key1减一						
						end
					default:	key0 = key0-2; //否则key2不为0，key2减一(由于提前判断key2,key3了两个为0的情况，不会溢出)
				endcase				
				
				end
			default:	time_count = time_count+1;
			endcase
		end
		else	//如果key3和key2都是0，变换状态
		begin
		play_music = 1;		//充完电播放音乐
		state = S_Start;		//转到Start状态，等待输入
		time_count = 0;		//初始化
		end
		end
		//如果是开始状态
		S_Start:
		begin
			//才进入的时候可能需要防抖
			//进入后过一段时间再检测是否有输入的键
			case(times_last_test_input)
			7'b1111111:
				begin
				case(key_mesg)	//看是否有输入，有输入就跳到S_Input，
				1:begin
					play_music = 0;
					state = S_Input; end
				default:;
				endcase
				end
			default:;	//这里不需要再加1了，开头会加
			endcase
			//计算在Start状态呆的时间
			case(time_count)
			second_count:			//如果到达约为1秒边界，将key2减一
				begin
				time_count = 0;	//重新开始计数
				time_second = time_second +1;	//多一秒
				end
			default:
				begin
				time_count = time_count+1;	//如果没有到，就count加1
				end
			endcase
			//根据在Start呆的时间判断是否需要回到initial
			case(time_second)
			60:
				begin
					play_music = 0;	//init不播放音乐
					time_second = 0;	//初始化
					time_count = 0;	//初始化
					state = S_Init;	//回到初始状态
				end
				default:;	//没到10second啥也不干
			endcase
			
		end
		endcase
		
	end

	// Output depends only on the state
	//当状态变化的时候触发
	always @ (state) begin
		case (state)
			S_Init:
			begin
				enable = 4'b0000;
			end
			S_Input:
			begin
				enable = 4'b1111;
			end
			S_Count:
			begin
				enable = 4'b1111;
			end
			S_Start:
			begin
				enable = 4'b1111;
			end
			default:
				;
		endcase
	end
	


endmodule

