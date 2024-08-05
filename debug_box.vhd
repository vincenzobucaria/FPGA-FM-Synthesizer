----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.06.2024 10:36:12
-- Design Name: 
-- Module Name: debug_box - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debug_box is
port(
clk:in std_logic;
reset_n:in std_logic;
fc_word:in std_logic_vector(31 downto 0);
sound_enable:in std_logic;
led_enable:out std_logic;
led_frequency:out std_logic;
led_freq_440:out std_logic;
fm_word:in std_logic_vector(31 downto 0)
);
end debug_box;

architecture Behavioral of debug_box is

signal u_fc_word: unsigned(31 downto 0);

begin

u_fc_word<=unsigned(fc_word);

process(clk, reset_n)
begin
if (reset_n='0') then 
			led_frequency<='0';
			led_freq_440<='0';
			led_enable<='0';
		else
			if(clk'event and clk='1') then
                if u_fc_word = 18898 then
                    -- 440 HZ
                    led_freq_440<='1';
                else
                    led_freq_440<='0';
                end if;
                if u_fc_word > 1 then
                    led_frequency<='1';
                else 
                    led_frequency<='0';
                end if;
                if sound_enable = '1' then
                    led_enable <= '1' ;
                else
                    led_enable <='0';
                end if;
                end if;
                end if;
                end process;
end Behavioral;
