library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
--LIBRARY altera_mf;
--USE altera_mf.altera_mf_components.all;
--LIBRARY lpm;
--USE lpm.all;


entity outadapter is
	generic(
				DA_OUT_SIZE:integer:=8;     --output toward the DA converter
				ACTUAL_DA_BITS:integer:=4  --actual bits for unipolar DA at output
			  );
	port (
			ck:in std_logic;
			reset:in std_logic; 
			sound_enable: in std_logic;
			from_dds:in std_logic_vector(DA_OUT_SIZE-1 downto 0); --from DDS ouput
			unip_out:out std_logic_vector (ACTUAL_DA_BITS-1 downto 0); --unipolar out obtained bu reducing resolution and adding a constant
			bip_out_p:out std_logic_vector (ACTUAL_DA_BITS-1 downto 0);--bipolar output (positive semiperiod)
			bip_out_m:out std_logic_vector (ACTUAL_DA_BITS-1 downto 0)--bipolar output (negative semiperiod multiplied by -1)
																					--please note: bip_out_p and bip_out_m musto be send to the inputs of a differential amplifier in 
																					-- order to reconstruct the full wave 	
			);
end entity outadapter;


architecture behav of outadapter is

begin

adapter: process (ck,reset) is
		variable v_bip_out_m:signed(DA_OUT_SIZE-1 downto 0);
		variable v_temp:signed(DA_OUT_SIZE-1 downto 0);
		constant unioff:signed(DA_OUT_SIZE-1 downto 0):=((DA_OUT_SIZE-2)=>'1',others=>'0'); 
		
		begin
		 if (reset='0') then 
				unip_out(ACTUAL_DA_BITS-1)<='1';  --this sets the unipolar out to half VDA max
				unip_out(ACTUAL_DA_BITS-2 downto 0)<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS-1));
				bip_out_p(ACTUAL_DA_BITS-1 downto 0)<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS));
				bip_out_m(ACTUAL_DA_BITS-1 downto 0)<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS));
		 else
		 if (sound_enable='0') then 
				unip_out(ACTUAL_DA_BITS-1)<='1';  --this sets the unipolar out to half VDA max
				unip_out(ACTUAL_DA_BITS-2 downto 0)<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS-1));
				bip_out_p(ACTUAL_DA_BITS-1 downto 0)<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS));
				bip_out_m(ACTUAL_DA_BITS-1 downto 0)<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS));
		else
		  	if (ck'event and ck='1') then 
				--first deal with bipolar output
				if (signed(from_dds)>=to_signed(0,DA_OUT_SIZE)) then
					bip_out_p<=from_dds(DA_OUT_SIZE-2 downto DA_OUT_SIZE-ACTUAL_DA_BITS-1);
					bip_out_m<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS));
				else
					bip_out_p<=std_logic_vector(to_unsigned(0,ACTUAL_DA_BITS));
					v_bip_out_m:=-signed(from_dds);
					bip_out_m<=std_logic_vector(v_bip_out_m(DA_OUT_SIZE-2 downto DA_OUT_SIZE-ACTUAL_DA_BITS-1));
				end if;
				--now deal with unipolar output. 
				--please note the use of variables and constants
				
				--the next two line ar for having from_dds/2 into v_temp;
				v_temp(DA_OUT_SIZE-1):=from_dds(DA_OUT_SIZE-1);
				v_temp(DA_OUT_SIZE-2 downto 0):=signed(from_dds(DA_OUT_SIZE-1 downto 1));
				--now we add offset
				v_temp:=v_temp+unioff;
				--now we produce output
				unip_out<=std_logic_vector(v_temp(DA_OUT_SIZE-2 downto DA_OUT_SIZE-ACTUAL_DA_BITS-1)); 
				
				end if;
			end if;
		  end if;
end process adapter;
	
end architecture behav;

			
