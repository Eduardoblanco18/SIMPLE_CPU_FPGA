library ieee;
use ieee.std_logic_1164.all;

entity N_Register is
	generic (n: integer :=4);
	port (
			clock_reg, reset_reg, load_reg: in std_logic;
			Data_in: in std_logic_vector (n-1 downto 0);
			Data_out: out std_logic_vector (n-1 downto 0)
			);
	end entity N_Register;
	
architecture bhv of N_Register is
	signal Reg : std_logic_vector (n-1 downto 0) := (others => '0');
	begin 
		process(clock_reg)
			begin 
				if rising_edge(clock_reg) then
					if reset_reg = '1' then
						Reg <= (others => '0');
					elsif load_reg = '1' then
						Reg <= Data_in;
					end if;
				end if;
			end process;
			
			Data_out <= Reg;
			
		end architecture bhv;
						
			