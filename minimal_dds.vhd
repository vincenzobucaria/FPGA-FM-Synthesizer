


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity minimal_dds is

   
    Port 
    (
    
    clk:in std_logic;
    reset_n:in std_logic;
    flush_register:in std_logic;
    
    frequency_register:in std_logic_vector(31 downto 0);
    dds_signal_out: out std_logic_vector(7 downto 0)
    
    );
    
end minimal_dds;



architecture Behavioral of minimal_dds is

component numeric_oscillator is
    

    
    
	Port
	(
		clk:in std_logic;
		reset_n:in std_logic; 
		flush_register:in std_logic;
		frequency_register:in unsigned(31 downto 0); 
		digital_phase:out unsigned(7 downto 0)
	);
	
	
end component numeric_oscillator;

component sine_rom is
  Port 
  (
    clka: IN STD_LOGIC;
    addra: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 
  );
end component sine_rom;


signal digital_phase: unsigned(7 downto 0);

begin


the_numeric_oscillator: component numeric_oscillator
    
  
    port map
    (
        clk=>clk,
        reset_n=>reset_n,
        flush_register=>flush_register,
        frequency_register=>unsigned(frequency_register),
        digital_phase=>digital_phase
    );
    
the_lookup_table: component sine_rom
    port map
    (
        clka=>clk,
        addra=>std_logic_vector(digital_phase),
        douta=>dds_signal_out
     );
        

end Behavioral;
