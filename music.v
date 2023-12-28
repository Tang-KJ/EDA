
//实现蜂鸣器音乐
module music(
output wire buzz,	//输出，直接控制buzz
output reg play_show,
output reg sound_work,		//是否发出声音

input play,			//是否弹奏音乐
input clk			//外界时钟,要准

);


//实现1/16拍的clk数
parameter xth_clk_times = 1736111;
//以下是每个音的周期/us
parameter e = 6067,f=5727,fu=5405,g=5102,gu=4816,a =4545,au =4290,b=4050;
parameter c1=3822,c1u=3608,d1=3405,d1u=3214,e1= 3034,f1 =2863,f1u=  2703,g1 =2551,g1u= 2408,a1= 2273,a1u =2145,b1 =2025;
parameter c2 =1911,c2u =1804,d2 =1703,d2u =1607,e2 =1517,f2 =1432,f2u =1351,g2 =1276,g2u=1204,a2 =1136,a2u =1073,b2 =1012;
parameter c3 =956,c3u =902 ,d3 =851,d3u=804,e3 =758,f3 =716,f3u =676,g3 =638,g3u=602,a3 =568,a3u =536,b3 =506;
parameter c4=478,c4u=451,d4=426,d4u=402,e4=379,f4=358,f4u=338,g4=319,g4u=301,a4=284,a4u=268,b4=253;
parameter c5=239,c5u=225,d5=213,d5u=201,e5=190,f5=179,f5u=169,g5=159,g5u=150,a5=142,a5u=134,b5=127;
parameter c6=119,c6u=113,d6=106,d6u=100,e6=95,f6=89,f6u=84,g6=80,g6u=75,a6=71,a6u=67,b6=63;
parameter null = 0;


reg[22:0] count_clk;	//记录clk在1/16拍以内count了多少次
reg[10:0] rythm;		//记录节拍到了哪,ryhtm[0]为1/16拍,rythm[1]为1/8拍
reg[13:0] tune;	//对应调调的周期/us



//将buzz连接到single,之后通过sound_work和tune产生声音
//里面
single(
.buzz(buzz),
.tune_time(tune),
.clk(clk)
);


always@(posedge clk)
begin
	case(play)
	0:
		begin
		rythm <= 0;	//初始化
		count_clk <= 0;
		play_show <= 0;
		end
	1:
		begin
		play_show <= 1;
		//根绝count是多少决定是否变化rythm
		case(count_clk)
			xth_clk_times:	//如果到了需要进位的时候
				begin
				count_clk = 0;			//清零
				rythm = rythm + 1;	//加1/16拍
				end
			default:
			begin
				count_clk = count_clk +1;	//如果没到就继续数上升沿
			end
		endcase

		end
	endcase
end

always@(rythm)
begin
		//修改完此时在整个节奏中的位置，根据在整个节奏中的位置来产生音律
		case(rythm[10:4])	//看是第几个拍
			//第一小节
			8'd1:	//一拍
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd2:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = d4u;
				1:tune = a3u;
				endcase
			end	
			8'd3:tune = d4u;
			8'd4:tune = d4u;
			//第二小节
			8'd5:tune = null;
			8'd6:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end		
			8'd7:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end	
			8'd8:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = g4u;
				1:tune = f4;
				endcase
			end	
			//第三小节
			8'd9:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end	
			8'd10:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = d4u;
				1:tune = a3u;
				endcase
			end			
			8'd11:tune = c4u;
			8'd12:tune = c4u;
			//第四小节
			8'd13:tune = null;
			8'd14:tune = c5u;
			8'd15:
			begin
				case(rythm[3])	//半拍
				0:tune = c5;
				1:tune = g4u;
				endcase
			end			
			8'd16:tune = f4;
			//第5小节
			8'd17:	//一拍
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd18:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = d4u;
				1:tune = a3u;
				endcase
			end	
			8'd19:tune = d4u;
			8'd20:tune = d4u;			
			//第6小节
			8'd21:tune = null;
			8'd22:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd23:	//一拍
			begin
				case(rythm[3])	//半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end	
			8'd24:
			begin
				case(rythm[3])	//半拍
				0:tune = g4u;
				1:tune = f4;
				endcase
			end	
			//第7小节
			8'd25:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd26:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = c4u;
				endcase
			end
			8'd27:tune = a3u;	
			8'd28:tune = a3u;		
			//第8小节
			8'd29:tune = null;
			8'd30:
			begin
				case(rythm[3])	//看半拍
				0:tune = null;
				1:tune = f4;
				endcase
			end
			8'd31:
				begin tune = f4;
					case(rythm[3:0])
					4'd0:tune = null;
					default:tune = f4;
					endcase
				end
			8'd32:
			begin
				case(rythm[3:0])
				4'b1111:tune = null;
				default:tune  = f4;
				endcase
			end
			//第9小节
			8'd33:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd34:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = a3u;
				endcase
			end
			8'd35:tune = d4u;
			8'd36:tune = d4u;
			//第10小节
			8'd37:tune = null;
			8'd38:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd39:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd40:
			begin
				case(rythm[3])	//看半拍
				0:tune = g4u;
				1:tune = f4;
				endcase
			end
			//第11小节
			8'd41:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd42:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = a3u;
				endcase
			end
			8'd43:tune = c4u;
			8'd44:tune = c4u;
			//第12小节
			8'd45:tune = null;
			8'd46:tune = c5u;
			8'd47:
			begin
				case(rythm[3])	//看半拍
				0:tune = c5;
				1:tune = g4u;
				endcase
			end
			8'd48:tune = f4;
			//第13小节
			8'd49:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd50:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = a3u;
				endcase
			end
			8'd51:tune = d4u;
			8'd52:tune = d4u;
			//第14小节
			8'd53:tune = null;
			8'd54:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd55:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd56:
			begin
				case(rythm[3])	//看半拍
				0:tune = g4u;
				1:tune = f4;
				endcase
			end
			//第15小节
			8'd57:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = f4;
				endcase
			end
			8'd58:
			begin
				case(rythm[3])	//看半拍
				0:tune = d4u;
				1:tune = c4u;
				endcase
			end
			8'd59:tune = a3u;
			8'd60:tune = a3u;
			
			
			
			
			default:	tune = null;
		endcase

end

endmodule



module single(
output reg buzz,
input wire[13:0] tune_time,	//给buzz能够发出fre的电平信号的周期(输入0代表不发音)
input clk							//clk的频率很关键,假设是50MHz，假如不是，要改参数clk_repeat_time
);

//计数使用的变量

parameter clk_repeat_time = 20;	//clk的周期，注意单位，该单位为ns
reg [20:0]	count_clk_trigger;	//用来储存需要多少个clk的上升沿，使buzz反转
reg[20:0]	clk_count;				//clk已经有了多少个上升沿

parameter null = 0;

always@(posedge clk)
begin
	//计算要弹出这个调需要在多少次上升沿时反转buzz，每次都要计算是因为换频率就要换它
	//乘500而不是1000是因为两次反转才算一个周期
	count_clk_trigger = (tune_time* 500) / clk_repeat_time;
	case(tune_time)
	null:	//如果不工作(tune_time = 0是特定)，就不count，不buzz
			begin
			clk_count = 0;
			buzz = 0;
			end
	default:
		begin
			case(clk_count)
				count_clk_trigger:	//如果该反转就反转
					begin
					buzz = ~buzz;
					clk_count = 0;
					end
				default:					//不过不该反转，继续count clk
					clk_count = clk_count +1;
			endcase
			
		end
	endcase
end


endmodule