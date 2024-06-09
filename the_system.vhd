----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.06.2024 11:18:29
-- Design Name: 
-- Module Name: simulation_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity the_system is
Port (
clk: in std_logic;
reset:in std_logic;
sw: in std_logic_vector(15 downto 0)

 );
end the_system;

architecture Behavioral of the_system is

component minimal_dds is

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
end component;

component the_modulator is
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
    input_frequency_register:in std_logic_vector(FREQ_REG_SIZE-1 downto 0);
    modulating_vector:in std_logic_vector(7 downto 0);
    modulator_out: out std_logic_vector(DA_OUT_SIZE-1 downto 0)
    
    );

end component;

signal frequency: std_logic_vector(31 downto 0);

signal first_dds_output:std_logic_vector(7 downto 0);
signal output:std_logic_vector(7 downto 0);

begin

frequency<="00000000000000001010011111000110";



the_first_dds: component minimal_dds
port map
(
clk=>clk,
reset=>reset,
frequency_register=>frequency,
da_out=>first_dds_output
);

the_modulator_instance: component test
port map
(
clk=>clk,
reset=>reset,
input_frequency_register=>"00000000000000000001010011111000",
modulating_vector(7 downto 0) => first_dds_output,
modulator_out=>output
);


end Behavioral;
