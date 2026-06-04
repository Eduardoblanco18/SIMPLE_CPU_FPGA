library ieee;
use ieee.std_logic_1164.all;
use work.Computer_components.all;

entity CPU is
	port (
			CLOCK_50: in std_logic;
			SW: in std_logic_vector (11 downto 0);
			KEY: in std_logic_vector (1 downto 0);
			
			LEDR: out std_logic_vector (5 downto 0);
			
			HEX0: out std_logic_vector (6 downto 0);
			
			HEX2: out std_logic_vector (6 downto 0);
			--HEX3: out std_logic_vector (6 downto 0);
			
			HEX4: out std_logic_vector (6 downto 0)
			--HEX5: out std_logic_vector (6 downto 0)
			);
	end entity;
	
architecture BHV of CPU is
	signal Instruc, IR: std_logic_vector (7 downto 0);
	
	signal OP_CODE_ALU: std_logic_vector (2 downto 0);
	signal Load_R0, Load_R1, Load_A, Load_G: std_logic;
	
	signal Load_IR: std_logic;
	signal Loaded_IR, Execute_pulse : std_logic:= '0';
	
	signal DATA, Reg0, Reg1, A, G, Barramento, ALU_Res: std_logic_vector (3 downto 0);
	signal select_bus: std_logic_vector (2 downto 0);

	Signal TOTAL_RESET: std_logic;

--	Signal sinal_Reg0, Sinal_Reg1: std_logic;
--	signal valor_abs_reg0, valor_abs_reg1: std_logic_vector(3 downto 0);
	
	begin
		instruc <= SW(7 downto 0);
		DATA <= SW(11 downto 8);
		TOTAL_RESET <= NOT KEY(0);
		Load_IR <= NOT KEY(1);
		
		Instruction_Register: N_Register generic map (n => 8) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_IR, Data_in => instruc, Data_out => IR); 
		
		process(CLOCK_50)
			begin
				
				if rising_edge(CLOCK_50) then
				
					Execute_pulse <= '0';
					
					if Loaded_IR = '0'and LOad_IR = '1' then
						
						Execute_pulse <= '1';
						
					end if;
					
					Loaded_IR <= Load_IR;
					
				end if;
			end process;
		
		Control_unity: UC port map (clock_uc => CLOCK_50, Reset_UC => TOTAL_RESET, Saved_IR => Execute_pulse, instruction => IR, bus_select => select_bus, R0_Load => Load_R0, R1_Load => Load_R1, A_Load => Load_A, G_Load => Load_G, ALU_op_code => OP_CODE_ALU);
		
		with Select_bus select
			Barramento <=
						Reg0 when "001",
						Reg1 when "010",
						A when "011",
						G when "100",
						DATA when "101",
						(Others => '0') when others;
		
		Registrador_0: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_R0, Data_in => Barramento, Data_out => Reg0);
					
		Registrador_1: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_R1, Data_in => Barramento, Data_out => Reg1);				
		
		Registrador_A: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_A, Data_in => Barramento, Data_out => A);	
	
		Unidade_logica_aritimetica: ALU port map(OP_CODE => OP_CODE_ALU, Reg => Barramento, Reg_A => A, Result => ALU_Res, Flags => LEDR);
		
		Registrador_G: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_G, Data_in => ALU_Res, Data_out => G);
		
		with Instruc (7 downto 4) select
				HEX0 <= 
					"1000000" when "0000", -- '0'
					"1111001" when "0001", -- '1'
					"0100100" when "0010", -- '2'
					"0110000" when "0011", -- '3'
					"0011001" when "0100", -- '4'
					"0010010" when "0101", -- '5'
					"0000010" when "0110", -- '6'
					"1111000" when "0111", -- '7'
					"0000000" when "1000", -- '8'
					"0011000" when "1001", -- '9'
					"0001000" when "1010", -- 'A'
					"0000011" when "1011", -- 'B'
					"1000110" when "1100", -- 'C'
					"0100001" when "1101", -- 'D'
					"0000110" when "1110", -- 'E'
					"0001110" when "1111", -- 'F'
					"1111111" when others;
					
		with Reg0 select
				HEX2 <= 
					"1000000" when "0000", -- '0'
					"1111001" when "0001", -- '1'
					"0100100" when "0010", -- '2'
					"0110000" when "0011", -- '3'
					"0011001" when "0100", -- '4'
					"0010010" when "0101", -- '5'
					"0000010" when "0110", -- '6'
					"1111000" when "0111", -- '7'
					"0000000" when "1000", -- '8'
					"0011000" when "1001", -- '9'
					"0001000" when "1010", -- 'A'
					"0000011" when "1011", -- 'B'
					"1000110" when "1100", -- 'C'
					"0100001" when "1101", -- 'D'
					"0000110" when "1110", -- 'E'
					"0001110" when "1111", -- 'F'
					"1111111" when others;
					
					
			with Reg1 select
				HEX4 <= 
					"1000000" when "0000", -- '0'
					"1111001" when "0001", -- '1'
					"0100100" when "0010", -- '2'
					"0110000" when "0011", -- '3'
					"0011001" when "0100", -- '4'
					"0010010" when "0101", -- '5'
					"0000010" when "0110", -- '6'
					"1111000" when "0111", -- '7'
					"0000000" when "1000", -- '8'
					"0011000" when "1001", -- '9'
					"0001000" when "1010", -- 'A'
					"0000011" when "1011", -- 'B'
					"1000110" when "1100", -- 'C'
					"0100001" when "1101", -- 'D'
					"0000110" when "1110", -- 'E'
					"0001110" when "1111", -- 'F'
					"1111111" when others;
		
		
		
		
	end architecture BHV;