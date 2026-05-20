library ieee;
use ieee.std_logic_1164.all;

entity UC is
	port (
			clock_UC, reset_UC : in  std_logic;

			instruction: in std_logic_vector (7 downto 0);
			
			bus_select: out std_logic_vector (2 downto 0);
			
			R0in, R1in, Ain : out std_logic;
			
			ALU_op_code: out std_logic_vector (1 downto 0)
			);
	end entity UC;
	
architecture bhv of UC is
	
	type t_State is (Fetch, Decode, Execution1, Execution2, Execution3);
	
	signal current_state : t_State;

	signal OP_CODE: std_logic_vector(3 downto 0);
	signal reg1, reg2: std_logic_vector (1 downto 0);
	signal exec: std_logic_vector (1 downto 0);
	
	begin
		
		process (clock_UC)
			begin
				if rising_edge(clock_UC) then
					if reset_UC = '1' then
						
						current_state <= Fetch;
						
						bus_select <= (others => '0');
						R0in <= '0';
						R1in <= '0';
						Ain <= '0';
						ALU_op_code <= (others => '0');
						
						
					
					else
						
						bus_select <= (others => '0');
						R0in <= '0';
						R1in <= '0';
						Ain <= '0';
						ALU_op_code <= (others => '0');
						
						case current_state is
							
							when Fetch => 
								
								OP_CODE <= instruction (7 downto 4);
								
								reg1 <= instruction (3 downto 2);
								
								reg2 <= instruction (1 downto 0);
								
								current_state <= Decode;
							
							when Decode =>

								case OP_CODE is
									when "0000" =>
										exec <= "00";
									when "0001" => 
										exec <= "01";
									when "0010" =>
										exec <= "10";
									when "0011" =>
										exec <= "11";
									when others =>
										exec <= "00";
								end case;
							
								current_state <= execution1;		
							
							when Execution1 =>
								
								case exec is
									when "01" =>
										bus_select <= "101";
										
										case reg1 is
											when "00" =>
												R0in <= '1';
											when "01" =>
												R1in <= '1';
											when others =>
												null;
										end case;
										
										current_state <= Fetch;
									
									when "10" =>
										
										case reg2 is
											when "00" =>
												bus_select <= "001";
											when "01" =>
												bus_select <= "010";
											when others =>
												null;
										end case;
											
										Ain <= '1';
										
										current_state <= Execution2;
									
									when "11" =>
										
										case reg2 is
											when "00" =>
												bus_select <= "001";
											when "01" =>
												bus_select <= "010";
											when others =>
												null;
										end case;
										
										Ain <= '1';
										
										current_state <= Execution2;
										
									when others =>
										current_state <= Fetch;
								end case;
							
							when Execution2 =>
								
								case exec is
									when "10" =>
										
										case reg1 is
											when "00" =>
												bus_select <= "001";
											when "01" =>
												bus_select <= "010";
											when others =>
												null;
										end case;
										
										ALU_op_code <= "01";
										
										current_state <= Execution3;
									
									when "11" =>
										
										case reg1 is
											when "00" =>
												bus_select <= "001";
											when "01" =>
												bus_select <= "010";
											when others =>
												null;
										end case;
										
										ALU_op_code <= "10";
										
										current_state <= Execution3;
									
									when others =>
										current_state <= Fetch;
								end case;
							
							when Execution3 =>
								bus_select <= "100";
								
								case reg1 is
											when "00" =>
												R0in <= '1';
											when "01" =>
												R1in <= '1';
											when others =>
												null;
										end case;
								
								current_state <= Fetch;
						end case;
					end if;
				end if;
			end process;
		end architecture bhv;
		