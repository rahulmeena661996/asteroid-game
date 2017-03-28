library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_control is
     Port ( clk            : in  STD_LOGIC;
               -- start      : in  STD_LOGIC;
               --reset        : in  STD_LOGIC;
					 test: out STD_LOGIC;
                button_l   : IN std_logic;
                button_r   : IN std_logic;
                rgb            : out  STD_LOGIC_VECTOR (2 downto 0);
                h_s           : out  STD_LOGIC;
                v_s            : out  STD_LOGIC;
					 bullet        : in std_LOGIC);
      end vga_control;

architecture Behavioral of vga_control is

COMPONENT img_gen
    PORT( clk              : IN std_logic;
                 x_control    : IN std_logic_vector(9 downto 0);
                 button_l     : IN std_logic;
                 button_r     : IN std_logic;
                 y_control     : IN std_logic_vector(9 downto 0);
                 video_on   : IN std_logic;          
                rgb              : OUT std_logic_vector(2 downto 0);
					 bullet      : in std_LOGIC );
  END COMPONENT;

COMPONENT sync_mod
PORT( clk            : IN std_logic;
              reset        : IN std_logic;
              start      : IN std_logic;          
             y_control   : OUT std_logic_vector(9 downto 0);
              x_control   : OUT std_logic_vector(9 downto 0);
              h_s           : OUT std_logic;
              v_s            : OUT std_logic;
              video_on   : OUT std_logic );
END COMPONENT;

signal x,y:std_logic_vector(9 downto 0);
signal video:std_logic;

begin
 U1: img_gen PORT MAP( clk =>clk ,  x_control => x, button_l =>not button_l  , button_r => not button_r, y_control => y,video_on =>video , rgb => rgb ,bullet => bullet);

 U2: sync_mod PORT MAP( clk => clk, reset => '0', start => '1', y_control => y, x_control =>x , h_s => h_s ,v_s => v_s, video_on =>video );
 --put a switch at start and not of push button at reset OR a using a single switch, reset<= not start_switch , start<= start_switch (debouncing not required)
end Behavioral;
