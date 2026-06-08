library ieee;
use ieee.std_logic_1164.all;

entity Debouncer is
	port (
			Clock_in: in std_logic;
			reset_in: in std_logic;
			Load_in: in std_logic;
			Clean_Load: out std_logic
			);
	end entity Debouncer;
	
architecture BHV of Debouncer is
	type state is (Released, Press);
	signal current_state :state := Released;
	signal count: integer range 0 to 999999 := 0;
	
	begin
		process(Clock_in, reset_in)
			begin
				if reset_in = '1' then
					current_state <= Released;
					count <= 0;
				elsif rising_edge(Clock_in) then	
					
					case current_state is
						when Released =>
							
							if Load_in = '1' then
								if count < 999999 then
									count <= count + 1;									
								else
									count <= 0;
									current_state <= Press;
								end if;
							else 
								count <= 0;
							end if;
						
						when Press =>
							
							if Load_in = '0' then
								if count < 999999 then
									count <= count + 1;
								else
									count <= 0;
									current_state <= Released;
								end if;
							else 
								count <= 0;
							end if;
						
						when others =>
							current_state <= Released;
						end case;
						end if;
				end process;
				
				Clean_Load <= '1' when current_state = Press else '0';
				
			end architecture BHV;