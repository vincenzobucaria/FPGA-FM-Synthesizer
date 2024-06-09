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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity numeric_oscillator is
    Generic
	(	
	   FREQ_REG_SIZE:integer:=32  
	);
	Port
	(
		clk:in std_logic;
		reset_n:in std_logic; 
		frequency_register:in unsigned(FREQ_REG_SIZE-1 downto 0); 
		digital_phase:out unsigned(FREQ_REG_SIZE-1 downto 0)
	);
end numeric_oscillator;

architecture behav of numeric_oscillator is

signal phase_accumulator_register:unsigned (FREQ_REG_SIZE-1 downto 0); --this is the phase accumulator

begin

	process (clk,reset_n) is
		begin
		if (reset_n='0') then 
			phase_accumulator_register<=to_unsigned(0,FREQ_REG_SIZE);
			digital_phase<=to_unsigned(0,FREQ_REG_SIZE);
		else
			if(clk'event and clk='1') then 
				phase_accumulator_register<=phase_accumulator_register+frequency_register;
				digital_phase<=phase_accumulator_register(FREQ_REG_SIZE-1 downto 0);
			end if;
		end if;
	end process;
end architecture behav;

