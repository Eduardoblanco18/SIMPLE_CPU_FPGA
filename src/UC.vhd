library ieee;
use ieee.std_logic_1164.all;

entity UC is
	port (
			clock_UC, reset_UC : in  std_logic;

			instruction: in std_logic_vector (7 downto 0);
			
			bus_select: out std_logic_vector (2 downto 0);
			
			R0_Load, R1_Load, A_Load, G_Load : out std_logic;
			
			ALU_op_code: out std_logic_vector (2 downto 0)
			);
	end entity UC;
	
architecture bhv of UC is
	
	type t_State is (Fetch, Movdata, Movreg1, Movreg2, Movreg3, AddData1, AddaData2, AddaData3, AddReg1, AddReg2, AddrReg3, SubData1, SubaData2, SubData3, SubReg1, SubReg2, SubReg3, MulData1, MulData2, MulData3, MulReg1, MulReg2, MulReg3, CMPData1, CMPData2, CMPData3, CMPReg1, CMPReg2, CMPReg3, AndData1, AndData2, AndData3, AndReg1, AndReg2, AndReg3, OrData1, OrData2, OrData3, OrReg1, OrReg2, OrReg3, NotReg1, NotReg2, NotReg3);
	
	signal current_state : t_State;

	signal OP_CODE: std_logic_vector(3 downto 0);
	signal reg1, reg2: std_logic_vector (1 downto 0);
	
	begin
		OP_CODE <= instruction (7 downto 4);
		reg1 <= instruction (3 downto 2);
		reg2 <= instruction (1 downto 0);
		
		process (clock_UC)
			begin
				if rising_edge(clock_UC) then
					if reset_UC = '1' then
						
						current_state <= Fetch;
						
						bus_select <= (others => '0');
						R0_Load <= '0';
						R1_Load <= '0';
						A_Load <= '0';
						G_Load <= '0';
						ALU_op_code <= (others => '0');
						
						
					
					else
						
						bus_select <= (others => '0');
						R0_Load <= '0';
						R1_Load <= '0';
						A_Load <= '0';
						G_Load <= '0';
						ALU_op_code <= (others => '0');
						
						case current_state is
							
							when Fetch => 
								
								if Op_CODE = "0001" then
								
									current_state <= MovData;
								
								elsif OP_CODE = "0010" then
								
									current_state <= MovReg1;
								
								elsif OP_CODE = "0011" then
								
									current_state <= AddData1;
								
								elsif OP_CODE = "0100" then
								
									current_state <= AddReg1;
								
								elsif OP_CODE = "0101" then
								
									current_state <= SubData1;
								
								elsif OP_CODE = "0110" then
									
									current_state <= SubReg1;
								
								elsif OP_CODE = "0111" then
								
									current_state <= MulData1;
								
								elsif OP_CODE = "1000" then
								
									current_state <= MulReg1;
								
								elsif OP_CODE = "1001" then
								
									current_state <= CMPData1;
								
								elsif OP_CODE = "1010" then
								
									current_state <= CMPReg1;
								
								elsif OP_CODE = "1011" then
									
									current_state <= AndData1;
								
								elsif OP_CODE = "1100" then
									
									current_state <= AndReg1;
								
								elsif OP_CODE = "1101" then
									
									current_state <= OrData1;
								
								elsif OP_CODE = "1110" then
									
									current_state <= OrReg1;
								
								elsif OP_Code = "1111" then
									
									current_state <= NotReg1;
								
								end if;
								
							when MovData =>
								
								bus_select <= "111";
								
								if Reg1 = "00" then
									
									R0_Load = '1';
								
								elsif Reg1 = "01" then
									
									R1_Load = '1';
								
								end if;
								
								
								
						end case;
					end if;
				end if;
			end process;
		end architecture bhv;
		