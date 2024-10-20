library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;





		-- ==================================================================================================  
      -- this module disply the vector of eche axis on 7-segmet for verify the results with LOGIC ANALYZER.
		-- when vector of 16 get in, its saparate to 4 vectors of 4 bits.
		-- eche vector of 4 bits get a value to be showen of 1 segmet.
		-- ==================================================================================================	









entity segmet_display is
    Port (
        sysclk         : IN  STD_LOGIC;
        resetn         : IN  STD_LOGIC;  
        X_in           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  Y_in           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  Z_in           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  out_switch1    : IN  STD_LOGIC;
		  out_switch2    : IN  STD_LOGIC;
		  
        seg_0          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        seg_1          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        seg_2          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        seg_3          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end segmet_display;




ARCHITECTURE ab of segmet_display is 


    TYPE seg_map_type is array(0 to 15) of STD_LOGIC_VECTOR(7 DOWNTO 0); -- arry of vectors
	 
	 
	 
		-- ================================================
      -- map value for eche number of letter on 7-segmet.
		-- ================================================
		
    constant seg_map : seg_map_type := (
	 
        not "11111100", -- 0
        not "01100000", -- 1
        not "11011010", -- 2
        not "11110010", -- 3
        not "01100110", -- 4
        not "10110110", -- 5
        not "10111110", -- 6
        not "11100000", -- 7
        not "11111110", -- 8
        not "11110110", -- 9
        not "11101110", -- A
        not "00111110", -- B
        not "10011100", -- C
        not "01111010", -- D
        not "10011110", -- E
        not "10001110"  -- F
		 
		  
    );
	 
	 
	 

    signal sig_x0         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_x1         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_x2         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_x3         : STD_LOGIC_VECTOR(3 DOWNTO 0); 
	 
	 signal sig_y0         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_y1         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_y2         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_y3         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	 
	 signal sig_z0         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_z1         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_z2         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_z3         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	 
	 
	 
	 
	 
	 
		-- =================================  
      -- saparate the vector to 4 vectors.
		-- =================================		 

begin 
    process(sysclk, resetn)
    begin 
	 
        if resetn = '0' then
		  
            sig_x0 <= (others => '0');
            sig_x1 <= (others => '0');
            sig_x2 <= (others => '0');
            sig_x3 <= (others => '0');
				
				sig_y0 <= (others => '0');
            sig_y1 <= (others => '0');
            sig_y2 <= (others => '0');
            sig_y3 <= (others => '0');
				
				sig_z0 <= (others => '0');
            sig_z1 <= (others => '0');
            sig_z2 <= (others => '0');
            sig_z3 <= (others => '0');
				
        elsif rising_edge(sysclk) then
		  
            sig_x3 <= X_in(15 DOWNTO 12);
            sig_x2 <= X_in(11 DOWNTO 8);
            sig_x1 <= X_in(7 DOWNTO 4);
            sig_x0 <= X_in(3 DOWNTO 0);
				
            sig_y3 <= Y_in(15 DOWNTO 12);
            sig_y2 <= Y_in(11 DOWNTO 8);
            sig_y1 <= Y_in(7 DOWNTO 4);
            sig_y0 <= Y_in(3 DOWNTO 0);

            sig_z3 <= Z_in(15 DOWNTO 12);
            sig_z2 <= Z_in(11 DOWNTO 8);
            sig_z1 <= Z_in(7 DOWNTO 4);
            sig_z0 <= Z_in(3 DOWNTO 0);				
				
        end if;
		  
    end process;

	 

		  
		-- =====================================  
      -- match each value finder from the map.
		-- =====================================			  
		  
	 
              seg_0 <= 
				         seg_map(to_integer(unsigned(sig_x0))) when out_switch1 = '1' and out_switch2 = '1' else 
				         seg_map(to_integer(unsigned(sig_y0))) when out_switch1 = '0' and out_switch2 = '0' else
							seg_map(to_integer(unsigned(sig_z0)));
				  
				  seg_1 <= 
				         seg_map(to_integer(unsigned(sig_x1))) when out_switch1 = '1' and out_switch2 = '1' else
				         seg_map(to_integer(unsigned(sig_y1))) when out_switch1 = '0' and out_switch2 = '0' else
				         seg_map(to_integer(unsigned(sig_z1)));
							
              seg_2 <= 
				         seg_map(to_integer(unsigned(sig_x2))) when out_switch1 = '1' and out_switch2 = '1' else
				         seg_map(to_integer(unsigned(sig_y2))) when out_switch1 = '0' and out_switch2 = '0' else
				         seg_map(to_integer(unsigned(sig_z2)));
							
              seg_3 <= 
				         seg_map(to_integer(unsigned(sig_x3))) when out_switch1 = '1' and out_switch2 = '1' else
	                  seg_map(to_integer(unsigned(sig_y3))) when out_switch1 = '0' and out_switch2 = '0' else
						   seg_map(to_integer(unsigned(sig_z3)));
		  
              
              
              
              
		

 
	 


end ab;		