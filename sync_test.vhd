library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_test is
Port (   clk  : in  STD_LOGIC;
			sw   : in  STD_LOGIC_VECTOR (2 downto 0);
			rgb  : out STD_LOGIC_VECTOR (2 downto 0);
			hsn  : out  STD_LOGIC;
			vsn  : out  STD_LOGIC );
end sync_test;

architecture Behavioral of sync_test is

	COMPONENT sync_mod
	PORT( clk            : IN std_logic;
			reset          : IN std_logic;
			start          : IN std_logic;          
			y_control      : OUT std_logic_vector(9 downto 0);
			x_control      : OUT std_logic_vector(9 downto 0);
			h_s            : OUT std_logic;
			v_s            : OUT std_logic;
			video_on       : OUT std_logic );
	END COMPONENT;

	--buffer
	signal sw_next:STD_LOGIC_VECTOR (2 downto 0);
	signal video:std_logic;
begin
	process(clk)
	begin
		if clk'event and clk='1' then
			sw_next <=sw;
		end if;
	end process;

	Inst_sync_mod: sync_mod PORT MAP( clk => clk, reset => '0', start => '1', y_control => open, x_control => open,
												  h_s => hsn, v_s => vsn, video_on => video );
	
	rgb<= "000"  when video = '0' else
	sw_next ;        

end Behavioral;
