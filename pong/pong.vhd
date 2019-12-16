----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:10:10 11/24/2019 
-- Design Name: 
-- Module Name:    coe758project2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity coe758project2 is
port(
	clk 		: in std_logic;
	SW0,SW1,SW2,SW3 : in std_logic;
	DAC_CLK : out std_logic;
	H,V : out std_logic;
	Rout,Gout,Bout : out std_logic_vector(7 downto 0)
	);
end coe758project2;

architecture Behavioral of coe758project2 is
signal control: STD_LOGIC_VECTOR (35 DOWNTO 0);
signal ila_data : STD_LOGIC_VECTOR (26 DOWNTO 0);
signal trig : STD_LOGIC_VECTOR(7 DOWNTO 0);
component ila
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CLK : IN STD_LOGIC;
    DATA : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));

end component;
component icon
  PORT (
    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));

end component;

signal vSync,hSync,bounds :integer:=0;
signal hSig,vSig,d_Clk : std_logic := '0';
signal left_paddle_ypos,right_paddle_ypos :integer:=265;
signal ball_xdirection, ball_ydirection :integer:=1;
signal ball_xpos :integer:=320;
signal ball_ypos :integer:=240;
signal left_paddle_delay,right_paddle_delay,ball_delay :integer;
signal r,g,b : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin
		process(clk)
		begin
			if(clk'Event and clk = '1') then
				d_Clk <= NOT(d_Clk);
			end if;
		end process;
		process(d_Clk)
		begin
		if(d_clk'Event and d_clk = '1') then
			if(hSync < 800) then
				hSync <= hSync + 1;
			else
				hSync <=0;
				if(vSync < 525) then
						vSync <= vSync + 1;
				else
						vSync <=0;
				end if;
			end if;
		end if;
		end process;
		process(d_Clk)
		begin
			if((hSync < 640 + 16) OR (hsync > 640 + 16 + 96)) then
				hsig <= '1';
			else
				hsig <= '0';
			end if;
			if((vSync < 480 + 10) OR (vsync > 480 + 10 + 2)) then
				vsig <= '1';
			else
				vsig <= '0';
			end if;
		end process;
process (d_Clk)
	begin
			if (hSync < 640 AND vSync < 480) then 
				--draw the white boarder
				if((hsync >= 0 AND hsync < 640) AND (vsync >= 0 AND vsync < 11)) then --Top border
					r <= "11111111";
					g <= "11111111";
					b <= "11111111";							
				elsif((hsync >= 0 AND hsync < 640) AND (vsync >= 470 AND vsync < 480)) then --Bottom border
					r <= "11111111";
					g <= "11111111";
					b <= "11111111";
				elsif((hsync >= 0 AND hsync < 11) AND (vsync >= 0 AND vsync < 190)) then --Top left border
					r <= "11111111";
					g <= "11111111";
					b <= "11111111";
				elsif((hsync >= 0 AND hsync < 11) AND (vsync >= 290 AND vsync < 480)) then --Bottom left border
					r <= "11111111";
					g <= "11111111";
					b <= "11111111";
				elsif((hsync >= 630 AND hsync < 640) AND (vsync >= 0 AND vsync < 190)) then --Top right border
					r <= "11111111";
					g <= "11111111";
					b <= "11111111";
				elsif((hsync >= 630 AND hsync < 640) AND (vsync >= 290 AND vsync < 480)) then --Bottom right border
					r <= "11111111";
					g <= "11111111";
					b <= "11111111";
				elsif((hsync >= 318 AND hsync <= 322) AND (vsync >= 11 AND vsync < 470)) then --Center Line
					r <= "00000000";
					g <= "00000000";
					b <= "00000000";
				elsif((hsync >= 15 AND hsync < 21) AND (vsync >= (left_paddle_ypos - 25) AND vsync <= (left_paddle_ypos + 25))) then --Left Paddle
					r <= "00000000";
					g <= "00000000";
					b <= "11111111";
				elsif((hsync >= 620 AND hsync <= 625) AND (vsync >= (right_paddle_ypos - 25) AND vsync <= (right_paddle_ypos + 25))) then --Right Paddle
					r <= "11111111";
					g <= "00010100";
					b <= "10010011";
				elsif((hsync >= (ball_xpos - 5) AND hsync <= (ball_xpos + 5)) AND (vsync >= (ball_ypos - 5) AND vsync <= (ball_ypos + 5))) then --Ball
					if(bounds <= 1) then
						r <= "11111111";
						g <= "11111111";
						b <= "00000000";
					else
						r <= "11111111";
						g <= "00000000";
						b <= "00000000";
					end if;
				else --Green for everything else
					r <= "00000000";
					g <= "11111111";
					b <= "00000000";
				end if;
		else --Black outside the active region
			r <= "00000000";
			g <= "00000000";
			b <= "00000000";
		end if;
	end process;
	process(d_clk) --Left paddle movement
	begin
		if(d_clk'Event and d_clk = '1') then
			left_paddle_delay <= left_paddle_delay +1;
			if(left_paddle_delay >= 150000) then
				left_paddle_delay <= 0;
				if((SW0 = '1' AND SW1 = '0') AND (left_paddle_ypos - 25) > 12) then -- doesnt hit top border
					left_paddle_ypos <= left_paddle_ypos -1;
				elsif((SW0 = '0' AND SW1 = '1') AND (left_paddle_ypos + 25) < 470) then --doesnt hit bottom border
					left_paddle_ypos <= left_paddle_ypos +1;
				end if;
			end if;
		end if;
	end process;
	process(d_clk) --Right paddle movement
	begin
		if(d_clk'Event and d_clk = '1') then
			right_paddle_delay <= right_paddle_delay +1;
			if(right_paddle_delay >= 150000) then
				right_paddle_delay <= 0;
				if((SW2 = '1' AND SW3 = '0') AND (right_paddle_ypos - 25) > 12) then -- doesnt hit top border
					right_paddle_ypos <= right_paddle_ypos -1;
				elsif((SW2 = '0' AND SW3 = '1') AND (right_paddle_ypos + 25) < 470) then -- doesnt hit bottom border
					right_paddle_ypos <= right_paddle_ypos +1;
				end if;
			end if;
		end if;
	end process;
	process (d_clk)
	begin
		if(d_clk'Event and d_clk = '1') then
			ball_delay <= ball_delay +1;
			if(ball_delay >= 250000) then
				ball_delay <= 0;
				if((ball_ypos - 5) < 11) then --If the ball hits the top border
					ball_ydirection <= 1;
				elsif((ball_ypos + 5) > 470) then --If the ball hits the bottom border
					ball_ydirection <= -1;
				elsif(((ball_xpos - 5) < 11) AND (((ball_ypos + 5) < 190) OR ((ball_ypos - 5) > 290))) then --If the ball hits the top left or bottom left border
					ball_xdirection <= 1;
				elsif(((ball_xpos + 5) > 630) AND (((ball_ypos + 5) < 190) OR ((ball_ypos - 5) > 290))) then --If the ball hits the top right or bottom right border
					ball_xdirection <= -1;
				elsif((ball_xpos < 11 ) AND (((ball_ypos - 5) > 190) AND ((ball_ypos + 5) < 290))) then --If the ball goes through the hole on the left side
					bounds <= 10;
				elsif((ball_xpos > 630 ) AND (((ball_ypos - 5) > 190) AND ((ball_ypos + 5) < 290))) then --If the ball goes through the hole on the right side
					bounds <= 10;
				elsif(((ball_xpos -5) < 21) AND (((ball_ypos +5) < (left_paddle_ypos +25) ) AND ((ball_ypos -5) > (left_paddle_ypos -25)))) then --If the ball hits left paddle
					ball_xdirection <= 1;
				elsif(((ball_xpos +5) >= 620) AND (((ball_ypos +5) < (right_paddle_ypos +25) ) AND ((ball_ypos -5) > (right_paddle_ypos -25)))) then --If the ball hits right paddle
					ball_xdirection <= -1;
				end if;
				if(bounds <= 1) then
					ball_xpos <= ball_xpos + ball_xdirection; -- changing x position of ball depending on border hit
					ball_ypos <= ball_ypos + ball_ydirection; -- changing y position of ball dependign on border hit
				else
					ball_xpos <= 320; -- reset ball position to cneter after ball has gone through goal post
					ball_ypos <= 240;
					bounds <= 0;
				end if;
			end if;
		end if;
	end process;
	
	coe758project2ila : ila
  port map (
    CONTROL => control,
    CLK => clk,
    DATA => ila_data,
    TRIG0 => trig);
	 
	coe758project2icon : icon
  port map (
    CONTROL0 => control);
	 
	DAC_CLK <= d_Clk;
	H	  <= hsig;
	V	  <= vsig;
	Rout <= r;
	Gout <= g;
	Bout <= b;
	ila_data(0) <= d_Clk;
	ila_data(1) <= hsig;
	ila_data(2) <= vsig;
	ila_data(10 DOWNTO 3) <= r;
	ila_data(18 DOWNTO 11) <= g;
	ila_data(26 DOWNTO 19) <= b;
end Behavioral;
