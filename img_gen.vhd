library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity img_gen is
GENERIC(
    counter_size  :  INTEGER := 19); --counter size (19 bits gives 10.5ms with 50MHz clock)
	Port ( clk         : in  STD_LOGIC;
			 x_control   : in  STD_LOGIC_VECTOR(9 downto 0);
			 button_l    : in STD_LOGIC;
			 button_r    : in STD_LOGIC;
			 y_control   : in STD_LOGIC_VECTOR(9 downto 0);
			 video_on    : in  STD_LOGIC;
			 rgb         : out  STD_LOGIC_VECTOR(2 downto 0);
			 button      : in std_LOGIC ); --input signal to be debounced
			--result  : OUT STD_LOGIC); --debounced signal 
			 
end img_gen;

architecture Behavioral of img_gen is

	--wall
	constant wall_l:integer :=10;--the distance between wall and left side of screen
	constant wall_t:integer :=10;--the distance between wall and top side of screen
	constant wall_k:integer :=10;--wall thickness
	signal wall_on:std_logic; 
	signal rgb_wall:std_logic_vector(2 downto 0); 
	
	--bar
	signal   bar_l,bar_l_next,bps:integer :=100; --the distance between bar and left side of screen
	constant bar_t:integer :=420;--the distance between bar and top side of screen
	constant bar_k:integer :=10;--bar thickness
	constant bar_w:integer:=30;--bar width
	constant bar_v:integer:=5;--velocity of the bar
	signal bar_on:std_logic;
	signal rgb_bar:std_logic_vector(2 downto 0); 
	
	--debouncing
  SIGNAL flipflops   : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops
  SIGNAL counter_set : STD_LOGIC;                    --sync reset to zero
  SIGNAL counter_out : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); --counter output
  SIGNAL result_buff : std_LOGIC;
	
	
	--bullet
	signal ball_l,ball_l_next:integer :=160;--the distance between ball and left side of screen
	signal ball_t,ball_t_next:integer :=bar_t-20; --the distance between ball and top side of screen
	constant ball_w:integer :=10;--ball Height
	constant ball_u:integer :=10;--ball width
	constant x_v,y_v:integer:=3;-- horizontal and vertical speeds of the ball 
	signal ball_on:std_logic;
	signal rgb_ball:std_logic_vector(2 downto 0);
	signal shoot: integer :=0;
	signal count: std_LOGIC :='0'; -- for the shooting button
	signal count_next : std_LOGIC :='0';
	
	--asteroid
	signal ast_l,ast_l_next:integer :=100;--the distance between asteroid and left side of screen
	signal ast_t,ast_t_next:integer :=100; --the distance between asteroid and top side of screen
	constant ast_w:integer :=50;--asteroid Height
	constant ast_u:integer :=50;--asteroid width
	constant xa_v,ya_v:integer:=1;-- horizontal and vertical speeds of the asteroid 
	signal ast_on:std_logic;
	signal rgb_ast:std_logic_vector(2 downto 0);
	
	--asteroid1
	signal ast_l1,ast_l1_next:integer :=100;--the distance between asteroid and left side of screen
	signal ast_t1,ast_t1_next:integer :=100; --the distance between asteroid and top side of screen
	constant ast_w1:integer :=50;--asteroid Height
	constant ast_u1:integer :=50;--asteroid width
	constant xa1_v,ya1_v:integer:=1;-- horizontal and vertical speeds of the asteroid 
	signal ast1_on:std_logic;
	signal rgb_ast1:std_logic_vector(2 downto 0);
	
	--array for asteroid dropdown
	type ast_dropdown_l is array (0 to 9) of integer ;
	signal rahul : ast_dropdown_l := (170,410,230,410,170,350,290,410,170,290);
	--(170,230,290,350,410,)	
	signal i : integer :=0;
	signal i_next : integer:=0;
	signal rahul1 : ast_dropdown_l := (290,170,410,290,350,170,410,230,410,170);
	signal i1 : integer :=0;
	signal i1_next : integer:=0;
	
	--lives
	signal live1_on : std_LOGIC;
	signal live2_on : std_LOGIC;
	signal live3_on : std_LOGIC;
	signal live1sig_on : std_LOGIC :='1';
	signal live2sig_on : std_LOGIC :='1';
	signal live3sig_on : std_LOGIC :='1';
	signal rgb_live1:std_logic_vector(2 downto 0);
	signal rgb_live2:std_logic_vector(2 downto 0);
	signal rgb_live3:std_logic_vector(2 downto 0);

	
	
	
	--refreshing(1/60)
	signal refresh_reg,refresh_next:integer;
	constant refresh_constant:integer:=830000;
	signal refresh_tick:std_logic;
	
	--bullet animation
	signal xv_reg,xv_next:integer:=3;--variable of the horizontal speed
	signal yv_reg,yv_next:integer:=3;--variable of the vertical speed
	
	--asteroid animation
	signal xva_reg,xva_next:integer:=1;--variable of the horizontal speed
	signal yva_reg,yva_next:integer:=1;--variable of the vertical speed
	
	--asteroid1 animation
	signal xva1_reg,xva1_next:integer:=1;--variable of the horizontal speed
	signal yva1_reg,yva1_next:integer:=1;--variable of the vertical speed
	
	--x,y pixel cursor
	signal x,y:integer range 0 to 650;
	
	--mux 
	signal vdbt:std_logic_vector(7 downto 0);
	
	--buffer
	signal rgb_reg,rgb_next:std_logic_vector(2 downto 0);

begin

	--x,y pixel cursor
	x <=conv_integer(x_control);
	y <=conv_integer(y_control );

	--refreshing
	process(clk)
	begin
		if clk'event and clk='1' then
			refresh_reg<=refresh_next;       
		end if;
	end process;
	refresh_next<= 0 when refresh_reg= refresh_constant else
	               refresh_reg+1;
	refresh_tick<= '1' when refresh_reg = 0 else
	               '0';
	--register part
	process(clk)
	begin
		if clk'event and clk='1' then
			ball_l<=ball_l_next;
			ball_t<=ball_t_next;
			ast_l<=ast_l_next;
			ast_t<=ast_t_next;
			ast_l1<=ast_l1_next;
			ast_t1<=ast_t1_next;
			i<=i_next;
			i1<=i1_next;
			xv_reg<=xv_next;
			yv_reg<=yv_next;
			bar_l<=bar_l_next;
		end if;
	end process;

	--bar animation
	process(bar_l,refresh_tick,button_r,button_l)
	begin
		bar_l_next<=bar_l;
		if refresh_tick= '1' then
--			if bar_l+30 > ast_l and bar_l+30 < ast_l+50 and ast_t > bar_t and ast_t< bar_t + 2 and live1sig_on='1' and live2sig_on='1' and live3sig_on='1' then
--				live3sig_on <= '0';
--			elsif bar_l+30 > ast_l and bar_l+30 < ast_l+50 and ast_t > bar_t and ast_t< bar_t + 2 and live1sig_on='1' and live2sig_on='1'and live3sig_on='0' then
--					live2sig_on <= '0';
--			elsif bar_l+30 > ast_l and bar_l+30 < ast_l+50 and ast_t > bar_t and ast_t< bar_t + 2 and live1sig_on='1' and live2sig_on='0'and live3sig_on='0' then
--					live1sig_on <= '0';
--			end if;	
			if button_l='1' and bar_l > bar_v then 
				bar_l_next<=bar_l- bar_v;
			elsif button_r='1' and bar_l < (639- bar_v-bar_w) then
				bar_l_next<=bar_l+ bar_v;
			end if;
		end if;
	end process;
	
	-- debouncing
	counter_set <= flipflops(0) xor flipflops(1);   --determine when to start/reset counter
	
  PROCESS(clk)
  BEGIN
    IF(clk'EVENT and clk = '1') THEN
      flipflops(0) <= button;
      flipflops(1) <= flipflops(0);
      If(counter_set = '1') THEN                  --reset counter because input is changing
        counter_out <= (OTHERS => '0');
      ELSIF(counter_out(counter_size) = '0') THEN --stable input time is not yet met
        counter_out <= counter_out + 1;
      ELSE                                        --stable input time is met
        result_buff <= flipflops(1);
      END IF;    
    END IF;
  END PROCESS;
	
	--bullet animation
	process(refresh_tick,ball_l,ball_t,yv_reg)
	begin
		ball_l_next <=ball_l;
		ball_t_next <=ball_t;
		yv_next<=yv_reg;
		--count_next <= count;
		
		--if bullet = '1' then
					--wait for 1 ms ;
					--count <= '1';
				--end if;
				
		if refresh_tick= '1' then
			bps<=bar_l+15;
			
			
--				while ball_t > 100 loop
--					ball_t_next <=ball_t-yv_reg; 
--					end loop;
--			ball_t_next<=bar_t-20;
--			ball_l_next<=bps;
--			end if;
			if result_buff = '1' then
				shoot <= 1;
			--else 
				--shoot<= 0;
			end if;

			--if result_buff = '1' then
			if shoot = 1 then
				if ball_t < bar_t - 350 or (ball_t < ast_t and (ball_l>ast_l and ball_l<ast_l+ast_u)) then --comment this para 
					ball_t_next<=bar_t-20;                                                                  --and uncomment following one		
					ball_l_next<=bps;
					shoot <=0; 																												--for using button to shoot
					else                                                                                    --   
					ball_t_next <=ball_t-yv_reg;                                                            --			
				end if;
			else
				ball_t_next<=bar_t-20;
				ball_l_next<=bps; 
			end if;
					
					
--				if count_next='1' then
--					if ball_t < bar_t - 350 then
--						count_next<='0';
--						count<='0';
--						ball_t_next<=bar_t-20;
--						ball_l_next<=bps;
--					else 
--						ball_t_next <=ball_t-yv_reg;
--					end if;
--				end if;
		end if;
	end process;
	
	
	-- asteroid animation
	process(refresh_tick,ast_l,ast_t,yva_reg)
	begin
		ast_l_next <=ast_l;
		ast_t_next <=ast_t;
		yva_next<=yva_reg;
		i_next<=i;
		if refresh_tick= '1' then
			if (ast_t > ball_t-50 and (ball_l>ast_l and ball_l<ast_l+ast_u)) or (ast_t > 420) then
				ast_t_next<=100;
				live3sig_on<='0';
				ast_l_next<=rahul(i);
				i_next<=i+1;
				--ball_t_next<=bar_t-20; -- for sending bullet back
				--ball_l_next<=bps;
			else
				ast_t_next<= ast_t + yva_reg;
			end if;	
		end if;
	end process;
	
--	-- asteroid1 animation
	process(refresh_tick,ast_l1,ast_t1,yva1_reg)
	begin
		ast_l1_next <=ast_l1;
		ast_t1_next <=ast_t1;
		yva1_next<=yva1_reg;
		i1_next<=i1;
		if refresh_tick= '1' then
			if (ast_t1 > ball_t-50 and (ball_l>ast_l1 and ball_l<ast_l1+ast_u1)) or (ast_t1 > 420) then
				ast_t1_next<=100;
				ast_l1_next<=rahul(i1);
				i1_next<=i1+1;
				--ball_t_next<=bar_t-20; -- for sending bullet back
				--ball_l_next<=bps;
			else
				ast_t1_next<= ast_t1 + yva1_reg;
			end if;	
		end if;
	end process;
		
--	--ball animation
--	process(refresh_tick,ball_l,ball_t,xv_reg,yv_reg)
--	begin
--		ball_l_next <=ball_l;
--		ball_t_next <=ball_t;
--		xv_next<=xv_reg;
--		yv_next<=yv_reg;
--		if refresh_tick = '1' then
--			if ball_t> 400 and ball_l > (bar_l -ball_u) and ball_l < (bar_l +120)  then --top bar'a değdiği zaman
--				yv_next<= -y_v ;
--			elsif ball_t< 35  then--The ball hits the wall
--				yv_next<= y_v;
--			end if;
--			if ball_l < 10 then --The ball hits the left side of the screen
--				xv_next<= x_v;
--				elsif ball_l> 600 then                
--				xv_next<= -x_v ; --The ball hits the right side of the screen
--			end if; 
--			ball_l_next <=ball_l +xv_reg;
--			ball_t_next <=ball_t+yv_reg;               
--		end if;
--	end process;

	--wall object
	wall_on <= '1'  when x > wall_l and x < (640-wall_l) and y> wall_t and y < (wall_t+ wall_k)   else
		       '0'; 
	rgb_wall<="000";--Black


	--bar object
	bar_on <= '1' when x > bar_l and x < (bar_l+bar_w) and y> bar_t and y < (bar_t+ bar_k) else
             '0'; 
	rgb_bar<="001";--blue

	--bullet object
	ball_on <= '1' when x > ball_l and x < (ball_l+ball_u) and y> ball_t and y < (ball_t+ ball_w) else
				  '0'; 
	rgb_ball<="010";  --Green

	--asteroid object
	ast_on <= '1' when x > ast_l and x < (ast_l+ast_u) and y> ast_t and y < (ast_t+ ast_w) else
				  '0'; 
	rgb_ast<="100";  --yellow
	
	--asteroid1 object
	ast1_on <= '1' when x > ast_l1 and x < (ast_l1+ast_u1) and y> ast_t1 and y < (ast_t1+ ast_w1) else
				  '0'; 
	rgb_ast1<="101";  --yellow
	
	--live1 object
	live1_on <= '1' when live1sig_on='1' and x > 60 and x < 65 and y> 100 and y < 105 else
				  '0'; 
	rgb_live1<="001";  --yellow	
	
	--live2 object
	live2_on <= '1' when live2sig_on='1' and  x > 60 and x < 65 and y> 110 and y < 115 else
				  '0'; 
	rgb_live2<="001";  --yellow	
		
	--live3 object
	live3_on <= '1' when live3sig_on='1' and x > 60 and x < 65 and y> 120 and y < 125 else
				  '0'; 
	rgb_live3<="001";  --yellow	
	

	--buffer
	process(clk)
	begin
		if clk'event and clk='1' then
			rgb_reg<=rgb_next;
		end if;
	end process;

	--mux
	vdbt<=video_on & wall_on & bar_on &ball_on & ast_on & live1_on & live2_on & live3_on ;--& ast1_on;
	with vdbt select
		rgb_next <= "000"            when "10000000",--0",--000",--Background of the screen is red  
		            rgb_wall         when "11000000",--0",--000",
		            --rgb_wall         when "11010",--0",--000",
						rgb_wall         when "11011000",--0",--000",
						rgb_wall         when "11010000",--1",--000",
						--rgb_wall         when "11011",
						rgb_wall         when "11001000",--0",--000",
						--rgb_wall         when "11000",--1",--000",
						--rgb_wall         when "11001",
		            rgb_bar          when "10100000",--0",--000",
		            rgb_bar          when "10110000",--0",--000",
						rgb_bar          when "10111000",--0",--000",
						--rgb_bar          when "10110",--1",--000",
						--rgb_bar          when "10111",--d
						rgb_bar          when "10101000",
						--rgb_bar          when "10100",
						--rgb_bar          when "10101",
		            rgb_ball         when "10010000",--0",--000",
						rgb_ball         when "10011000",--0",--000",
						--rgb_ball         when "10010",--1",--000",
						--rgb_ball         when "10011",
						rgb_ast			  when "10001000",--0",--000",
						--rgb_ast1			  when "10000",--1",--000",
						
						rgb_live1        when "10000100",
						rgb_live2		  when "10000010",
						rgb_live3        when "10000001",
						--rgb_live1        when "11010100",
						--rgb_live2		  when "11010110",
						--rgb_live3        when "11010111",
						--rgb_live1        when "11001100",
						--rgb_live1        when "11000100",
						--rgb_live2		  when "11001110",
						--rgb_live2		  when "11000110",
						--rgb_live3        when "11001111",
						--rgb_live3        when "11000111",
						--rgb_ast			  when "10011",
	               "000"            when others;
	--output
	 rgb<=rgb_reg;

end Behavioral;
