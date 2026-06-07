library ieee;
use ieee.std_logic_1164.all;

entity UC is
	port ( --entradas da entitade
			clock_UC, reset_UC, Saved_IR : in  std_logic;

			instruction: in std_logic_vector (7 downto 0);
			
			bus_select: out std_logic_vector (2 downto 0); -- "001" para R0, "010" para R1, "011" para A, "100" para G, e "101" para Data 
			
			R0_Load, R1_Load, A_Load, G_Load: out std_logic;
			
			ALU_op_code: out std_logic_vector (2 downto 0)
			);
	end entity UC;
	
architecture bhv of UC is
	
	type t_State is (Fetch, Decode, Movdata, Movreg1, Movreg2, Movreg3, AddData1, AddData2, AddData3, AddReg1, AddReg2, AddReg3, SubData1, SubData2, SubData3, SubReg1, SubReg2, SubReg3, MulData1, MulData2, MulData3, MulReg1, MulReg2, MulReg3, CMPData1, CMPData2, CMPReg1, CMPReg2, AndData1, AndData2, AndData3, AndReg1, AndReg2, AndReg3, OrData1, OrData2, OrData3, OrReg1, OrReg2, OrReg3, NotReg1, NotReg2);
	
	signal current_state, next_state : t_State; --estado atual e proximo estado

	signal OP_CODE: std_logic_vector(3 downto 0); --OP_CODE da operação
	signal reg1, reg2: std_logic_vector (1 downto 0); --registradores da operação
	
	begin
		OP_CODE <= instruction (7 downto 4); 
		reg1 <= instruction (3 downto 2);
		reg2 <= instruction (1 downto 0);
		
		process (clock_UC, reset_UC) --muda o estado atual para o proximo
			begin
				if reset_UC = '1' then
				
					current_State <= Fetch;
				
				elsif rising_edge(clock_UC) then
					
					current_State <= next_state;
					
				end if;
			end process;
			
		process (all) -- define qual eh o próximo estado
			begin
				--zero todas as saídas (saídas deafult)
				next_state <= current_state;
			
				bus_select <= (others => '0');
				R0_Load <= '0';
				R1_Load <= '0';
				A_Load <= '0';
				G_Load <= '0';
				ALU_op_code <= (others => '0');
				
				case current_state is
					
					when Fetch => --no estado Fetch, só sai dele quando Execute_pulse = '1'
						if Saved_IR = '1' then
							
							next_state <= Decode;
							
						else 
							
							next_state <= Fetch;
							
						end if;
					
					when Decode => -- a partir do OP_CODE da instruição define qual eh o próximo estado
						
						if Op_CODE = "0001" then
						
							next_state <= MovData;
						
						elsif OP_CODE = "0010" then
						
							next_state <= MovReg1;
						
						elsif OP_CODE = "0011" then
						
							next_state <= AddData1;
						
						elsif OP_CODE = "0100" then
						
							next_state <= AddReg1;
						
						elsif OP_CODE = "0101" then
						
							next_state <= SubData1;
						
						elsif OP_CODE = "0110" then
							
							next_state <= SubReg1;
						
						elsif OP_CODE = "0111" then
						
							next_state <= MulData1;
						
						elsif OP_CODE = "1000" then
						
							next_state <= MulReg1;
						
						elsif OP_CODE = "1001" then
						
							next_state <= CMPData1;
						
						elsif OP_CODE = "1010" then
						
							next_state <= CMPReg1;
						
						elsif OP_CODE = "1011" then
							
							next_state <= AndData1;
						
						elsif OP_CODE = "1100" then
							
							next_state <= AndReg1;
						
						elsif OP_CODE = "1101" then
							
							next_state <= OrData1;
						
						elsif OP_CODE = "1110" then
							
							next_state <= OrReg1;
						
						elsif OP_Code = "1111" then
							
							next_state <= NotReg1;
							
						else 
						
							next_state <= Fetch;
						
						end if;
						
					when MovData =>
						
						bus_select <= "101"; --DATA
						
						if Reg1 = "00" then
							
							R0_Load <= '1';
						
						elsif Reg1 = "01" then
							
							R1_Load <= '1';
						
						end if;
						
						next_state <= Fetch;
						
					when MovReg1 =>
					
						bus_select <= "010"; --R1
						
						A_Load <= '1';
						
						next_state <= MovReg2;
						
					when MovReg2 =>
					
						bus_select <= "001"; --R0
						
						R1_Load <= '1';
						
						next_state <= MovReg3;
						
					when MovReg3 =>
					
						bus_select <= "011"; --A
						
						R0_Load <= '1';
						
						next_state <= Fetch;
						
					when	AddData1 =>
					
						bus_select <= "101"; --DATA
						
						A_Load <= '1';
						
						next_state <= AddData2;
						
					when AddData2 =>
					
						if reg1 = "00" then 
							
							bus_select <= "001"; --R0
						
						elsif reg1 = "01" then
							
							bus_select <= "010"; --R1
						
						end if;
						
						ALU_op_code <= "100";
						
						G_Load <= '1';
						
						next_state <= AddData3;
						
					when AddData3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when	AddReg1 =>
					
						if reg2 = "00" then 
							
							bus_select <= "001"; --R0
						
						elsif reg2 = "01" then
							
							bus_select <= "010"; --R1
						
						end if;
						
						A_Load <= '1';
						
						next_state <= AddReg2;
						
					when AddReg2 =>
					
						if reg1 = "00" then 
							
							bus_select <= "001"; --R0
						
						elsif reg1 = "01" then
							
							bus_select <= "010"; --R1
						
						end if;
						
						ALU_op_code <= "100";
						
						G_Load <= '1';
						
						next_state <= AddReg3;
						
					when AddReg3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							
							R0_Load <= '1';
						
						elsif reg1 = "01" then
							
							R1_Load <= '1';
						
						end if;
						
						next_state <= Fetch;
						
					when SubData1 =>
					
						bus_select <= "101"; --DATA
						
						A_Load <= '1';
						
						next_state <= SubData2;
						
					when SubData2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0
						elsif reg1 = "01" then
							bus_select <= "010"; --R1
						end if;
						
						ALU_op_code <= "101";
						
						G_Load <= '1';
						
						next_state <= SubData3;
						
					when SubData3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when SubReg1 => 
					
						if reg2 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg2 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						A_Load <= '1';
						
						next_state <= SubReg2;
						
					when SubReg2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "101";
						
						G_Load <= '1';
						
						next_state <= SubReg3;
						
					when SubReg3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when MulData1 =>
					
						bus_select <= "101"; --DATA
						
						A_Load <= '1';
						
						next_state <= MulData2;
						
					when MulData2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "110";
						
						G_Load <= '1';
						
						next_state <= MulData3;
						
					when MulData3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when MulReg1 => 
					
						if reg2 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg2 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						A_Load <= '1';
						
						next_state <= MulReg2;
						
					when MulReg2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "110";
						
						G_Load <= '1';
						
						next_state <= MulReg3;
						
					when MulReg3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when CMPData1 =>
					
						bus_select <= "101"; --DATA
						
						A_Load <= '1';
						
						next_state <= CMPData2;
						
					when CMPData2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "111";
						
						next_state <= Fetch;
						
					when CMPReg1 => 
					
						if reg2 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg2 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						A_Load <= '1';
						
						next_state <= CMPReg2;
						
					when CMPReg2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "111";

						
						next_state <=  Fetch;
						
					when AndData1 =>
					
						bus_select <= "101"; --DATA
						
						A_Load <= '1';
						
						next_state <= AndData2;
						
					when AndData2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "001";
						
						G_Load <= '1';
						
						next_state <= AndData3;
						
					when AndData3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when AndReg1 => 
					
						if reg2 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg2 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						A_Load <= '1';
						
						next_state <= AndReg2;
						
					when AndReg2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "001";
						
						G_Load <= '1';
						
						next_state <= AndReg3;
						
					when AndReg3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when OrData1 =>
					
						bus_select <= "101"; --DATA
						
						A_Load <= '1';
						
						next_state <= OrData2;
						
					when OrData2 =>
					
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "010";
						
						G_Load <= '1';
						
						next_state <= OrData3;
						
					when OrData3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when OrReg1 => 
					
						if reg2 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg2 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						A_Load <= '1';
						
						next_state <= OrReg2;
						
					when OrReg2 =>
					
						if reg1 = "00" then 
							bus_select <= "001";--R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "010";
						
						G_Load <= '1';
						
						next_state <= OrReg3;
						
					when OrReg3 =>
					
						bus_select <= "100"; -- G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when NotReg1 =>
						
						if reg1 = "00" then 
							bus_select <= "001"; --R0;
						elsif reg1 = "01" then
							bus_select <= "010"; --R1;
						end if;
						
						ALU_op_code <= "011";
						
						G_Load <= '1';
						
						next_state <= NotReg2;
						
					when NotReg2 =>
					
						bus_select <= "100"; --G
					
						if reg1 = "00" then 
							R0_Load <= '1';
						elsif reg1 = "01" then
							R1_Load <= '1';
						end if;
						
						next_state <= Fetch;
						
					when others =>
					
						next_state <= Fetch;
						
				end case;
			end process;
		end architecture bhv;
		