library ieee;
use ieee.std_logic_1164.all;

package Computer_components is  --Package geral com todos os components
	
	component N_Register is --Component dos Registradores
		generic (n: integer :=4);
		port (
				clock_reg, reset_reg, load_reg: in std_logic;
				Data_in: in std_logic_vector (n-1 downto 0);
				Data_out: out std_logic_vector (n-1 downto 0)
				);
		end component N_Register;
	
	component UC is -- Component da Unidade de Controle
		port (
			clock_UC, reset_UC, Saved_IR : in  std_logic;

			instruction: in std_logic_vector (7 downto 0);
			
			bus_select: out std_logic_vector (2 downto 0); -- "001" para R0, "010" para R1, "011" para A, "100" para G, e "101" para Data 
			
			R0_Load, R1_Load, A_Load, G_Load: out std_logic;
			
			ALU_op_code: out std_logic_vector (2 downto 0)
			);
		end component UC;

	component ALU is -- Component da ULA
		port (
				OP_CODE: in std_logic_vector (2 downto 0);
				Reg, Reg_A: in std_logic_vector (3 downto 0);
				
				Result: out std_logic_vector (3 downto 0);
				Flags: out std_logic_vector (5 downto 0)
				);
		end component ALU;
		
	end package;