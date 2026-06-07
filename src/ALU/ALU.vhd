Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.comparator.all;
use work.multiplier.all;
use work.four_adder.all;
use work.general_adder.all;

entity ALU is
		port (
				OP_CODE: in std_logic_vector (2 downto 0);
				Reg, Reg_A: in std_logic_vector (3 downto 0);
				
				Result: out std_logic_vector (3 downto 0);
				Flags: out std_logic_vector (5 downto 0)
				);
		end entity ALU;
		
architecture BHV_ALU of ALU is
	
	signal Num_A, Num_B, Inner_Result: std_logic_vector (3 downto 0);
	signal Greater, Lesser, Equal, OFW, CF, ZF: std_logic;
	
	signal SOMA_RES, SUB_RES, MUL_RES, AND_RES, OR_RES, NOT_RES: std_logic_vector (3 downto 0);
	signal SOMA_OF, SUB_OF, SOMA_CF, SUB_CF: std_logic;
	
	signal Not_num_b: std_logic_vector (3 downto 0);
	
		begin
			
			Num_A <= "0000" when OP_CODE = "000" else 
						"00" & Reg(1 downto 0) when OP_CODE = "110" else 
						Reg;
			Num_B <= "0000" when OP_CODE = "000" else 
						"00" & Reg_A(1 downto 0) when OP_CODE = "110" else
						Reg_A;
						
			not_num_b <= not Num_B;
			
			SOMADOR: adder_4_bits port map (a => Num_A, b => Num_B, cin => '0', soma => SOMA_RES, cout => SOMA_CF, overflow => SOMA_OF);
			
			SUBTRATOR: adder_4_bits port map (a => Num_A, b => not_num_b, cin => '1', soma => SUB_RES, cout => SUB_CF, overflow => SUB_OF);
			
			MULTIPLICADOR: multiplier_2_bits port map (a => Num_A (1 downto 0), b => Num_B (1 downto 0), Res => MUL_RES);
		
			COMPARADOR: comparator_4_bits port map (Comp => SUB_RES, Overflow => SUB_OF, EQU => Equal, GRT => Greater, LST => Lesser);
			
			AND_RES <= Num_A AND Num_B;
			
			OR_RES <= Num_A OR Num_B;
			
			NOT_RES <= NOT Num_A;
			
			with OP_CODE select  --seleção do resultado de acordo com o códigos operacional da ULA
				Inner_Result <=
					"0000" when "000",
					AND_RES when "001",
					OR_RES when "010",
					NOT_RES when "011",
					SOMA_RES when "100",
					SUB_RES when "101",
					MUL_RES when "110",
					"0000" when others;
			
			with OP_CODE select	--seleção da utilização do carry flag de acordo com o códigos operacional da ULA
				CF <= 
					SOMA_CF when "100",
					SUB_CF when "101",
					'0' when others;
					
			with OP_CODE select 	--seleção da utilização do overflow de acordo com o códigos operacional da ULA
				OFW <= 
					SOMA_OF when "100",
					SUB_OF when "101",
					'0' when others;	
			
			with Inner_Result select	--seleção da utilização do zero flag de acordo com o códigos operacional da ULA
				ZF <= 
					'1' when "0000",
					'0' when others;
						
			with OP_CODE select	--seleção de qual led utilizar de acordo com o resultado vindo da função de comparar presente na ULA
				Flags(5) <= 
						  Lesser when "111",
						  '0' when others;
							  
			with OP_CODE select
				Flags(4) <= 
						  Greater when "111",
						  '0' when others;
			
			with OP_CODE select
				Flags(3) <= 
						  Equal when "111",
						  '0' when others;
							  
			Flags(2) <= OFW;	-- direcionamento do sinal da overflow flag para seu respectivo led
			Flags(1) <= CF;		-- direcionamento do sinal da carry flag para seu respectivo led	
			Flags(0) <= '0' when OP_CODE = "000" OR OP_CODE = "111" else ZF;  -- direcionamento do sinal da zero flag para seu respectivo led e seleção da representação do zaero flag no led de acordo com a escolha de código operacional		
			
			Result <= Inner_Result;
			
		end architecture BHV_ALU;
							