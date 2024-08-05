
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity input_adapter is

Port
(
clk:in std_logic;
reset_n:in std_logic;
carrier_frequency:in std_logic_vector(6 downto 0);
modulation_ratio:in std_logic_vector(3 downto 0);
sound_enable:in std_logic;
modulation_index:in std_logic_vector(10 downto 0);


fc_word:out std_logic_vector(31 downto 0);
fm_word:out std_logic_vector(31 downto 0);
flush_registers:out std_logic
);

end input_adapter;

architecture Behavioral of input_adapter is


component word_rom IS -- Contiene un map tra il numero della nota MIDI e la word che deve essere mandata al DDS per generare il tono
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
  );
END component word_rom;

component fm_word_calculator IS -- Moltiplicatore che, a partire dalla word del tono e il rapporto di modulazione, consente di determinare la word per generare il segnale modulante
  PORT (
    CLK : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    P : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;

signal fc:std_logic_vector(31 downto 0);  
signal fm:std_logic_vector(31 downto 0);  
signal delayed_fc:std_logic_vector(31 downto 0);  -- Registro che consente di sincronizzare fc_word e fm_word

signal past_carrier_frequency:std_logic_vector(6 downto 0);
signal past_modulation_ratio:std_logic_vector(3 downto 0);
signal past_modulation_index:std_logic_vector(10 downto 0);





begin

fc(31 downto 18) <= (others=>'0'); -- La word in uscita alla ROM è di soli 18 bit, così da risparmiare spazio. Qui la word viene estesa 

the_frequency_rom: word_rom
port map
(
    clka => clk,
    addra => carrier_frequency(6 downto 0),
    douta => fc(17 downto 0)
);

the_fm_calculator: component fm_word_calculator
port map
(
CLK => clk,
A => fc(17 downto 0),
B => modulation_ratio,
P => fm
);

process(clk, reset_n)
	begin
        
        if(reset_n = '0') then
		fc_word<=(others=>'0'); 
		fm_word<=(others=>'0');
		delayed_fc <= (others=>'0');
		else
			if(clk'event and clk='1') then 
			    delayed_fc <= fc;
				if sound_enable = '1' then
				    fc_word <= delayed_fc; -- ritardo di un colpo di clock l'assegnazione di fc_word per compensare il ritardo dovuto al moltiplicatore
				    fm_word <= fm;
			    else
			       fc_word <=(others=>'0');
			       fm_word <=(others=>'0');
			    end if;
			end if;
		end if;
end process;

the_flusher: process(clk, reset_n)
    begin
    if(reset_n = '0') then
        flush_registers <= '0';  
        past_carrier_frequency <= (others=>'0');
        past_modulation_ratio <= (others=>'0');
        past_modulation_index <= (others=>'0');
		else
			if(clk'event and clk='1') then 
			 past_carrier_frequency <= carrier_frequency;
             past_modulation_ratio <= modulation_ratio;
             past_modulation_index <= modulation_index;
			   if (past_carrier_frequency /= carrier_frequency or past_modulation_ratio /= modulation_ratio or past_modulation_index /= modulation_index) then
			   flush_registers <= '1';
			   else
			   flush_registers <= '0';
			end if;
			end if;
			end if;
end process;



end Behavioral;

