library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;




entity frequency_modulator is

    Port 
    (
    clk:in std_logic;
    reset_n:in std_logic;
    fc_word:in std_logic_vector(31 downto 0);
    fm_word:in std_logic_vector(31 downto 0);
    modulating_signal_in:in std_logic_vector(7 downto 0);
    flush_register:in std_logic;
    
    modulation_index:in std_logic_vector(10 downto 0);
    modulator_out: out std_logic_vector(7 downto 0)
    
    );
end entity;


architecture Behavioral of frequency_modulator is

-- Unsigned signals


-- signal u_dds_frequency_register:unsigned(31 downto 0);
signal s_dds_frequency_register:signed(31 downto 0);
signal dds_frequency_register:std_logic_vector(31 downto 0);


signal modulating_signal_amplitude: std_logic_vector(31 downto 0);


signal x_to_divide:std_logic_vector(42 downto 0);
signal x:unsigned(42 downto 0);



component minimal_dds is


    Port 
    (
    
    clk:in std_logic;
    reset_n:in std_logic;
    frequency_register:in std_logic_vector(31 downto 0);
    flush_register:in std_logic;
    dds_signal_out: out std_logic_vector(7 downto 0)
    );
    
    
end component;




component coefficient_calculator IS
  PORT (
    CLK : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    P : OUT STD_LOGIC_VECTOR(42 DOWNTO 0)
  );
end component;

component modulating_word_calculator IS
  PORT (
    CLK : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
    P : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;



begin




the_coefficient_calculator: component coefficient_calculator
port map
(
CLK=>clk,
A=>fm_word,
B => modulation_index,
P => x_to_divide
);


x<=unsigned(x_to_divide) srl 11;




the_modulating_word_calculator: component modulating_word_calculator
  port map (
    CLK => clk,
    A => modulating_signal_in,
    B => std_logic_vector(x(20 downto 0)),
    P => modulating_signal_amplitude
  );


process(clk, reset_n)
    
   
    begin
        if (reset_n='0') then 
            s_dds_frequency_register<=(others=>'0');
        else
           
            if (clk'event and clk='1') then 

                    s_dds_frequency_register<= signed(fc_word) + signed(modulating_signal_amplitude);
           
               
            end if;
         end if;    
 end process;      


dds_frequency_register <= std_logic_vector(s_dds_frequency_register);

the_dds: component minimal_dds

port map
(
clk=>clk,
reset_n=>reset_n,
flush_register=>flush_register,
frequency_register=>dds_frequency_register,
dds_signal_out=>modulator_out
);  
            
            
end Behavioral;

