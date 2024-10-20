 library    IEEE;
use IEEE.std_logic_1164.all  ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;
use IEEE.NUMERIC_STD.ALL;
 

 
 
 	   -- ===========================================================================================  
      -- this module get v_min from size_change and print rectangle that change with v_min .
		-- ===========================================================================================
 
 
 
     entity  lines is
     PORT ( 
            resetn        : IN   STD_LOGIC;-- key0  -- pin B8
            sysclk        : IN   STD_LOGIC;-- 50Mhz -- pin N14
            pixel_clock   : IN   STD_LOGIC;-- 25MHz
            BLANK_n       : IN   STD_LOGIC;
		    	v_cnt         : IN   STD_LOGIC_VECTOR(11 DOWNTO 0); -- vertical position
			   v_min_x       : IN   INTEGER;
			   v_max_x       : IN   INTEGER;
		      v_min_y       : IN   INTEGER;
			   v_max_y       : IN   INTEGER;
		      v_min_z       : IN   INTEGER;
			   v_max_z       : IN   INTEGER;
            VGA_B         : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
            VGA_G         : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
            VGA_R         : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
            );         
        END lines ;      
      
        
     ARCHITECTURE  ab of lines  is  
     
       
	  

       
       
      
      
	    signal    sig_ADDR        : INTEGER := 0;
		 signal    sig_bgr_data    : STD_LOGIC_VECTOR(23 DOWNTO 0);
       signal    blue_power      : std_logic_vector(7 downto 0);
		 signal    green_power     : std_logic_vector(7 downto 0);
		 signal    red_power       : std_logic_vector(7 downto 0);
		   

       constant  h_axis_max      : INTEGER := 500;
		 constant  h_axis_min      : INTEGER := 5;
		 constant  v_axis_min      : INTEGER := 256;
		 constant  v_axis_max      : INTEGER := 259;
		 
	    constant  h_min_x         : INTEGER := 250;
       constant  h_max_x         : INTEGER := 260;
		 constant  h_min_y         : INTEGER := 300;
       constant  h_max_y         : INTEGER := 310;
		 constant  h_min_z         : INTEGER := 350;
       constant  h_max_z         : INTEGER := 360;


       
	   
	begin
	
	green_power <= std_logic_vector(to_unsigned(v_min_x, green_power'length));
	blue_power  <= std_logic_vector(to_unsigned(v_min_z, blue_power'length));
	red_power   <= std_logic_vector(to_unsigned(v_min_y, red_power'length));
	
	
	
	
process(sysclk,pixel_clock,resetn,BLANK_n)
	begin
	
	    if resetn = '0' then 
		    sig_ADDR <= 0;
		elsif rising_edge(sysclk) and (pixel_clock = '1') then 
		    if BLANK_n = '1' then 
			   sig_ADDR <= sig_ADDR + 1;
			else 
				sig_ADDR <= 0;
		    end if;
		end if;
	end process;	
	
	
axis:	process(sysclk,pixel_clock,resetn,BLANK_n,v_cnt)
	begin
	
	    if resetn = '0' then 
		    sig_bgr_data <= (others => '0');
		elsif rising_edge(sysclk) and (pixel_clock = '1') then
		
		      if BLANK_n = '1' then
				
		         sig_bgr_data <= X"000000";
					
					
				if (v_cnt > 50) and (v_cnt <= 450) then  
				    
					 if (sig_ADDR > 50) and (sig_ADDR <= 53) then

			           sig_bgr_data <= X"FFFFFF"; 			 
				 
				    end if;
				end if;	

				
					
				if (v_cnt > v_axis_min) and (v_cnt <= v_axis_max) then   
				    
					 if (sig_ADDR > h_axis_min) and (sig_ADDR <= h_axis_max) then

			           sig_bgr_data <= X"FFFFFF"; 			 
				 
				    end if;
				end if;
			


		      	if (v_cnt > v_min_x) and (v_cnt <= v_max_x) then 
            
			         if (sig_ADDR > h_min_x) and (sig_ADDR <= h_max_x) then 
				 
			             sig_bgr_data(15 downto 12) <= X"F";  -- green

			       	end if;
						
						
		      	end if;	
					
			 
			    if (v_cnt > v_min_y) and (v_cnt <= v_max_y) then 
            
			        if (sig_ADDR > h_min_y) and (sig_ADDR <= h_max_y) then 
				   
			            sig_bgr_data(7 downto 4) <= X"F"; --red

				     end if;
              end if;

				
			    if (v_cnt > v_min_z) and (v_cnt <= v_max_z) then 
            
			        if (sig_ADDR > h_min_z) and (sig_ADDR <= h_max_z) then 
				 
			           sig_bgr_data(23 downto 20) <= X"F"; --blue
					  
				     end if;
			    end if;
				 
				 
				 
				 if (v_cnt > 50) and (v_cnt <= 100) then 
            
			        if (sig_ADDR > 450) and (sig_ADDR <= 600) then 
				 
			           
						 sig_bgr_data(23 downto 16) <= blue_power;
						 sig_bgr_data(16 downto 9)  <= red_power;
						 sig_bgr_data(9 downto 2)   <= green_power; 
					  
				     end if;
			    end if;
				 
			    
            

			 
				 
			
       end if;
			
		end if;
	end process;
	
	

	 
	  
	 	  VGA_B <= sig_bgr_data(23 downto 20);
        VGA_G <= sig_bgr_data(15 downto 12);
        VGA_R <= sig_bgr_data(7 downto 4);
        
	 
	 
	 end ab;