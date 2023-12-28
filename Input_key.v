module Input_key(en,last_valid,circ,clk,row);
input clk;					//扫描一列的周期
input  [3:0]row;			//连接键盘中的行，用以检测是否按下
output [3:0]circ;			//选择检测矩阵键盘的列
output [3:0]last_valid;	//输出上一个有效的键
output en;					//是否有键被按下

//与output连接
reg en;						
reg [3:0]circ;
reg [3:0]last_valid;

//中间量
reg [3:0]key;				//当前被按下的键（可能是抖动产生）
reg [6:0]repeat_times;	//某个键重复的周期数（扫描过程有其他键会中断）
reg [1:0]col;				//对应键盘的列的二进制数
reg [5:0]null_times;		//没有被按下任何键持续的周期数
reg [3:0]pre;				//上一个被按下的键


parameter Col_Wid = 4;			//有多少列
parameter Is_Press_Down = 0;	//被按下时的值
parameter Valid_Times =4;		//认为键有效需要的重复周期

//------注意---------
//规定col大到col小 列数增大
//row小到 row大 行数增大

//在clk上升沿的是否扫描一列
always @(posedge clk)
begin
		//检测本列哪一行被按下了
	if(row[0] == Is_Press_Down)	//0
	begin
		key = col;
		null_times = 0;
		//根据key是否和上次相等，改变repeat_times
		case(key)
			pre:
				repeat_times = repeat_times+1;
			default: 
				begin 
				//en =0;
				repeat_times = 0;
				pre = key;
				end
		endcase
	end
	else if(row[1] == Is_Press_Down)//1
	begin
		key = Col_Wid + col;
		null_times = 0;
	//根据key是否和上次相等，改变repeat_times
		case(key)
			pre:
				repeat_times = repeat_times+1;
			default: 
				begin 
				//en =0;
				repeat_times = 0;
				pre = key;
				end
		endcase
	end
	else if(row[2] == Is_Press_Down)//2
	begin
		key = Col_Wid*2 + col;
		null_times = 0;
		//根据key是否和上次相等，改变repeat_times
		case(key)
			pre:
				repeat_times = repeat_times+1;
			default: 
				begin 
				///en = 0;
				repeat_times = 0;
				pre = key;
				end
		endcase
	end
	else if(row[3] == Is_Press_Down)//3
	begin
		key =Col_Wid*3 + col;
		null_times = 0;
		//根据key是否和上次相等，改变repeat_times
		case(key)
			pre:
				repeat_times = repeat_times+1;
			default: 
				begin 
				//en = 0;
				repeat_times = 0;
				pre = key;
				end
		endcase
	end
	
	
	else	null_times = null_times+1;//本次扫描没有发现
	//如果repeat_times>=Valid_Times,en=1
	if(repeat_times >= Valid_Times)
		begin
		en = 1;
		last_valid = key;
		
		case(key)
		4'b0000: last_valid=4'd12;
		4'b0001: last_valid=4'd11;
		4'b0010: last_valid=4'd10;
		4'b0011: last_valid=4'd0;
		4'b0100: last_valid=4'd15;
		4'b0101: last_valid=4'd9;
		4'b0110: last_valid=4'd8;
		4'b0111: last_valid=4'd7;
		4'b1000: last_valid=4'd15;
		4'b1001: last_valid=4'd6;
		4'b1010: last_valid=4'd5;
		4'b1011: last_valid=4'd4;
		4'b1100: last_valid=4'd15;
		4'b1101: last_valid=4'd3;
		4'b1110: last_valid=4'd2;
		4'b1111: last_valid=4'd1;
		endcase
		
		end
	//如果null_times>=4*Valid_Times,en=0
	if(null_times >= Valid_Times<<1)
	begin
		en = 0;
		repeat_times = 0;
	end


	//上一扫描完毕，准备扫描下一列
	//不能提前到刚always就改col，否则会因为电路延迟导致col和circ改变得太慢而bug
	col = col+1;
	circ = 4'b1111 - (8>>(3-col));
end

endmodule