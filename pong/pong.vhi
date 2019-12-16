
-- VHDL Instantiation Created from source file pong.vhd -- 07:51:35 11/28/2017
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT pong
	PORT(
		clk : IN std_logic;
		SW0 : IN std_logic;
		SW1 : IN std_logic;
		SW2 : IN std_logic;
		SW3 : IN std_logic;          
		DAC_CLK : OUT std_logic;
		H : OUT std_logic;
		V : OUT std_logic;
		Rout : OUT std_logic_vector(7 downto 0);
		Gout : OUT std_logic_vector(7 downto 0);
		Bout : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	Inst_pong: pong PORT MAP(
		clk => ,
		SW0 => ,
		SW1 => ,
		SW2 => ,
		SW3 => ,
		DAC_CLK => ,
		H => ,
		V => ,
		Rout => ,
		Gout => ,
		Bout => 
	);


