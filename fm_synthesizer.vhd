----------------------------------------------------------------------------------
-- Company: UniMe
-- Engineer: Vincenzo Bucaria
-- 

-- Description: Sintetizzatore FM come progetto per SEP
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


entity the_synthesizer is

Generic
(
DA_OUT_SIZE:integer:=8; 
dac_size:integer:=4
);

Port
(
clk: in std_logic;
btnC: in std_logic;

-- registers

carrier_frequency_reg:in std_logic_vector(31 downto 0);
modulation_ratio_reg:in std_logic_vector(31 downto 0);
modulation_index_reg:in std_logic_vector(31 downto 0);
sound_enable_reg: in std_logic_vector(31 downto 0);

--

vgaRed:out std_logic_vector (3 downto 0);
vgaBlue:out std_logic_vector (3 downto 0);
vgaGreen:out std_logic_vector (3 downto 0);

-- debug outputs

led_enable:out std_logic;
led_frequency:out std_logic;
led_freq_440:out std_logic

);


end the_synthesizer;

architecture Behavioral of the_synthesizer is

-- _________ FRONT END _________________ --


component input_adapter is


Port
(
clk:in std_logic;
reset_n:in std_logic;
carrier_frequency:in std_logic_vector(6 downto 0);
modulation_ratio:in std_logic_vector(3 downto 0);
sound_enable:in std_logic;
fc_word:out std_logic_vector(31 downto 0);
fm_word:out std_logic_vector(31 downto 0);
modulation_index:in std_logic_vector(10 downto 0);
flush_registers:out std_logic
);
end component;


-- ____________ DEBUG ELEMENTS ____________________ --


component debug_box is
port
(
clk:in std_logic;
reset_n:in std_logic;
fc_word:in std_logic_vector(31 downto 0);
sound_enable:in std_logic;
led_enable:out std_logic;
led_frequency:out std_logic;
led_freq_440:out std_logic;
fm_word:in std_logic_vector(31 downto 0)
);
end component;


-- __________ CORE ELEMENTS _______________________ --


component minimal_dds is
    
 
    
    Port 
    (
    
    clk:in std_logic;
    reset_n:in std_logic;
    frequency_register:in std_logic_vector(31 downto 0);
    flush_register:std_logic;
    
    dds_signal_out: out std_logic_vector(7 downto 0)
    );
    
    
end component;

component frequency_modulator is

    Port 
    (
    clk:in std_logic;
    reset_n:in std_logic;
    fc_word:in std_logic_vector(31 downto 0);
    fm_word:in std_logic_vector(31 downto 0);
    modulating_signal_in:in std_logic_vector(7 downto 0);
    flush_register:std_logic;
    
    
    modulation_index:in std_logic_vector(10 downto 0);
    modulator_out: out std_logic_vector(7 downto 0)
    );

end component;



-- ____________ OUTPUT _________________ --


component outadapter is
	generic
	(
		DA_OUT_SIZE:integer:=DA_OUT_SIZE;     --output toward the DA converter
		ACTUAL_DA_BITS:integer:=4  --actual bits for unipolar DA at output
	);
	port 
	(
		ck:in std_logic;
		reset:in std_logic; 
		from_dds:in std_logic_vector(DA_OUT_SIZE-1 downto 0); --from DDS ouput
		sound_enable:in std_logic;
		unip_out:out std_logic_vector (ACTUAL_DA_BITS-1 downto 0); --unipolar out obtained bu reducing resolution and adding a constant
		bip_out_p:out std_logic_vector (ACTUAL_DA_BITS-1 downto 0);--bipolar output (positive semiperiod)
		bip_out_m:out std_logic_vector (ACTUAL_DA_BITS-1 downto 0)--bipolar output (negative semiperiod multiplied by -1																	--please note: bip_out_p and bip_out_m musto be send to the inputs of a differential amplifier in 																	-- order to reconstruct the full wave 	
	);
end component outadapter;


signal reset_n:std_logic;
signal fc_word:std_logic_vector(31 downto 0);
signal fm_word:std_logic_vector(31 downto 0);
signal modulating_signal:std_logic_vector(7 downto 0);
signal modulated_signal:std_logic_vector(7 downto 0);
signal flush_registers:std_logic;
begin

reset_n <= not(btnC);

the_input_adapter: component input_adapter
    port map
    (
    clk=>clk,
    reset_n=>reset_n,
    carrier_frequency=>carrier_frequency_reg(6 downto 0),
    modulation_ratio=>modulation_ratio_reg(3 downto 0),
    sound_enable=>sound_enable_reg(0),
    modulation_index=>modulation_index_reg(10 downto 0),
    
    fc_word=>fc_word,
    fm_word=>fm_word,
    flush_registers=>flush_registers
    );


the_first_dds: component minimal_dds

   
    
    port map
    (
    clk=>clk,
    reset_n=>reset_n,
    flush_register=>flush_registers,
    frequency_register=>fm_word,
    dds_signal_out=>modulating_signal
    );


the_frequency_modulator: component frequency_modulator
    port map
    (
    clk=>clk,
    reset_n=>reset_n,
    fc_word=>fc_word,
    fm_word=>fm_word,
    flush_register=>flush_registers,
    modulating_signal_in => modulating_signal,
    modulation_index=>modulation_index_reg(10 downto 0),
    modulator_out=>modulated_signal
    );




the_adapter: component outadapter 
	generic map (
				DA_OUT_SIZE=>DA_OUT_SIZE,
				ACTUAL_DA_BITS=>dac_size
			  )
	port map (
			ck=>clk, 
			reset=>reset_n, 
			from_dds=>modulated_signal, 
			unip_out=>vgaRed, 
			sound_enable=>sound_enable_reg(0),
			bip_out_p=>vgaBlue, 
			bip_out_m=>vgaGreen
			);
			
the_debug_box:component debug_box
port map
(
clk=>clk, 
reset_n=>reset_n, 
led_enable=>led_enable, 
led_frequency=>led_frequency, 
led_freq_440=>led_freq_440,
fc_word => fc_word,
sound_enable => sound_enable_reg(0),
fm_word => fm_word
);

end Behavioral;
