----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.06.2024 10:52:18
-- Design Name: 
-- Module Name: numeric_oscillator - Behavioral
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



entity numeric_oscillator is
  
	Port
	(
		clk:in std_logic;
		flush_register:in std_logic;
		reset_n:in std_logic; 
		frequency_register:in unsigned(31 downto 0); 
		digital_phase:out unsigned(7 downto 0)
	);
end numeric_oscillator;

architecture behav of numeric_oscillator is

signal phase_accumulator_register:unsigned (31 downto 0); --this is the phase accumulator

begin

	process (clk,reset_n) is
		variable test:signed(31 downto 0);
		begin
		if (reset_n='0') then 
			phase_accumulator_register<=to_unsigned(0,32);
			digital_phase<=to_unsigned(0,8);
		else
			if(clk'event and clk='1') then 
			    if(flush_register = '1') then
			    phase_accumulator_register<=to_unsigned(0,32);
			    else
			    phase_accumulator_register<=phase_accumulator_register+frequency_register;
			    end if;
				digital_phase<=phase_accumulator_register(31 downto 24);
			end if;
		end if;
	end process;
end architecture behav;

