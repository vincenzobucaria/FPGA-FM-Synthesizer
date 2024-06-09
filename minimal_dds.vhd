----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.06.2024 10:37:06
-- Design Name: 
-- Module Name: minimal_dds - Behavioral
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

entity minimal_dds is

    Generic
    (
    
        FREQ_REG_SIZE:integer:=32;  --size fo teh frequency register and ph accumulator
        PH_REG_SIZE:integer:=16;   --size of the phase register (also size of phase out from nco)
        ARG_SIZE:integer:=8;       --size of the phase sent to the sin table
        SINVAL_SIZE:integer:=8;    --size of sin values
        IQ_SIZE:integer:=8;			--input In phase and Quadtrature values 
        DA_OUT_SIZE:integer:=8     --output toward the DA converter
        
    );
    Port 
    (
    
    clk:in std_logic;
    reset:in std_logic;
    frequency_register:in std_logic_vector(FREQ_REG_SIZE-1 downto 0);
    da_out: out std_logic_vector(DA_OUT_SIZE-1 downto 0)
    
    );
    
end minimal_dds;




architecture Behavioral of minimal_dds is

component numeric_oscillator is
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
end component numeric_oscillator;

component sintable is
  Port 
  (
    clka: IN STD_LOGIC;
    addra: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 
  );
end component sintable;

signal reset_n:std_logic;
signal digital_phase: unsigned(FREQ_REG_SIZE-1 downto 0);

begin

reset_n <= not(reset);


the_numeric_oscillator: component numeric_oscillator
    port map
    (
        clk=>clk,
        reset_n=>reset_n,
        frequency_register=>unsigned(frequency_register),
        digital_phase=>digital_phase
    );
    
the_lookup_table: component sintable
    port map
    (
        clka=>clk,
        addra=>std_logic_vector(digital_phase(31 downto 24)),
        douta=>da_out
     );
        

end Behavioral;
