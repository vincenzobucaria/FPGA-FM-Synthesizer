----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.06.2024 17:22:53
-- Design Name: 
-- Module Name: fm_modulator - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fm_modulator is
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
end entity;


architecture Behavioral of fm_modulator is

-- Unsigned signals

signal s_modulating_vector:signed(7 downto 0);
signal u_input_frequency_register:unsigned(31 downto 0);
signal u_dds_frequency_register:unsigned(31 downto 0);
signal dds_frequency_register:std_logic_vector(31 downto 0);
signal reset_n: std_logic;
signal check: signed(23 downto 0);
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




begin

reset_n<=not(reset);
dds_frequency_register <= std_logic_vector(u_dds_frequency_register);
s_modulating_vector<=signed(modulating_vector);
u_input_frequency_register<=unsigned(input_frequency_register);

process(clk, reset_n)
    
    variable multiplication_var:signed(23 downto 0):=(others=>'0');
    
    begin
        if (reset_n='0') then 
            u_dds_frequency_register<=(others=>'0');
        else
            if (clk'event and clk='1') then 
            multiplication_var:=s_modulating_vector*to_signed(1000, 16);
            check<=multiplication_var;
                if (signed(s_modulating_vector)>=to_signed(0,DA_OUT_SIZE)) then
                    u_dds_frequency_register<=u_input_frequency_register + unsigned(abs(multiplication_var));
                else
                    u_dds_frequency_register<=u_input_frequency_register - unsigned(abs(multiplication_var));
                end if;
            end if;
         end if;       
    end process;
    
the_dds: component minimal_dds
port map
(
clk=>clk,
reset=>reset,
frequency_register=>dds_frequency_register,
da_out=>modulator_out
);  
            
            
    






end Behavioral;
