library ieee;
use ieee.std_logic_1164.all;
use work.Computer_components.all;

entity CPU is --Entidade da CPU
	port ( --Entradas e sa�das da Placa Altera DE2-115
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
	signal Instruc, IR: std_logic_vector (7 downto 0); --Sinais para a Instru��o e Registrador de Instru��o
	
	signal OP_CODE_ALU: std_logic_vector (2 downto 0); --Sinal para OP_CODE da ULA
	signal Load_R0, Load_R1, Load_A, Load_G: std_logic; --Sinais para carregar Registradores
	
	signal Load_IR: std_logic; --sinal para carregar IR
	signal Loaded_IR, Execute_pulse : std_logic:= '0'; --sinais criados para debounce do KEY(1)
	
	signal DATA, Reg0, Reg1, A, G, Barramento, ALU_Res: std_logic_vector (3 downto 0); --valores nos registradores, DATA, Barramento e resultado da ULA
	signal select_bus: std_logic_vector (2 downto 0); --sinal de escolha para a sa�da no barramento

	Signal TOTAL_RESET: std_logic; --sinal para reset total   

--	Signal sinal_Reg0, Sinal_Reg1: std_logic; --sinais criados e deixados de lado, para caso o display hexa fosse sinalizado
--	signal valor_abs_reg0, valor_abs_reg1: std_logic_vector(3 downto 0);
	
	begin
		instruc <= SW(7 downto 0); --instruc recebe os 8 primeiros switchs, DATA recebe o resto.
		DATA <= SW(11 downto 8);
		TOTAL_RESET <= NOT KEY(0); --total reset e Load_IR s�o, respectivamente KEY(0) e KEY(1) negadas para que elas funcionem quando o bot�o eh apertado
		Load_IR <= NOT KEY(1);
		
		Instruction_Register: N_Register generic map (n => 8) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_IR, Data_in => instruc, Data_out => IR); --Chamada de component para o registrador IR
		
		Debouncing: Debouncer port map (Clock_in => CLOCK_50, Reset_in => TOTAL_RESET, Load_in => Load_IR, Clean_load => Execute_pulse);
		
		Control_unity: UC port map (clock_uc => CLOCK_50, Reset_UC => TOTAL_RESET, Saved_IR => Execute_pulse, instruction => IR, bus_select => select_bus, R0_Load => Load_R0, R1_Load => Load_R1, A_Load => Load_A, G_Load => Load_G, ALU_op_code => OP_CODE_ALU); --Chamada da UC, s� executa se Execute_pulse for igual a '1'
		
		with Select_bus select --seleciono qual registrador vai para o barramento atraves do Select_bus
			Barramento <=
						Reg0 when "001",
						Reg1 when "010",
						A when "011",
						G when "100",
						DATA when "101",
						(Others => '0') when others;
		
		Registrador_0: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_R0, Data_in => Barramento, Data_out => Reg0); --chamada de component para o registrador 0
					
		Registrador_1: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_R1, Data_in => Barramento, Data_out => Reg1);	--chamada de component para o registrador 1			
		
		Registrador_A: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_A, Data_in => Barramento, Data_out => A);	--chamada de component para o registrador A
	
		Unidade_logica_aritimetica: ALU port map(OP_CODE => OP_CODE_ALU, Reg => Barramento, Reg_A => A, Result => ALU_Res, Flags => LEDR); --Chamada de component para ALU
		
		Registrador_G: N_Register generic map (n => 4) port map(clock_reg => CLOCK_50, reset_reg => TOTAL_RESET, Load_reg => Load_G, Data_in => ALU_Res, Data_out => G); --chamada de component para o registrador G
		
		--Displays HEX's
		Display_instruction: DisplayDecoder port map(hex_in => instruc(7 downto 4), display => HEX0);
					
		Display_Reg0: DisplayDecoder port map(hex_in => reg0, display => HEX2);
					
		display_reg1: DisplayDecoder port map(hex_in => reg1, display => HEX4);
		
		--Ordem dos LED's: LEDR(5) == Menor, LEDR(4) == Maior, LEDR(3) == Igual, LEDR(2) == Overflow, LEDR(1) = Carry Out, LEDR(0) = Zero
		
		
	end architecture BHV;