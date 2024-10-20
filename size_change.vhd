library    IEEE;
use IEEE.std_logic_1164.all  ;
use IEEE.NUMERIC_STD.ALL; 



	   -- ================================================================================================================  
      -- this module get MISO vector Y axis, check if it posetive or negative and Tx out_size depend on trash hold value.
		-- ================================================================================================================





entity size_change is
 
port (   resetn        : IN  STD_LOGIC;-- key0  -- pin B8
         sysclk        : IN  STD_LOGIC;-- 50Mhz -- pin N14
			pixel_clock   : in  STD_LOGIC;-- 25MHz
			X_in          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			Y_in          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			Z_in          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			v_min_x       : OUT INTEGER;
			v_max_x       : OUT INTEGER;
		   v_min_y       : OUT INTEGER;
			v_max_y       : OUT INTEGER;
		   v_min_z       : OUT INTEGER;
			v_max_z       : OUT INTEGER

	);
end size_change;


architecture arc of size_change is 




	  signal sig_v_min_x     : INTEGER;
     signal sig_v_max_x     : INTEGER;
	
	  signal sig_v_min_y     : INTEGER;
     signal sig_v_max_y     : INTEGER;
	 
 	  signal sig_v_min_z     : INTEGER;
     signal sig_v_max_z     : INTEGER;
     
	  constant v_0     : INTEGER := 255;
     constant v_max   : INTEGER := 510;
	  
	  begin 


    PROCESS(sysclk,resetn,pixel_clock)
 
	 begin 
	 
   	    if resetn = '0' then 
		
		   sig_v_min_x <= 0;
		   sig_v_max_x <= 0;
		   sig_v_min_y <= 0;
		   sig_v_max_y <= 0;		   
		   sig_v_min_z <= 0;
		   sig_v_max_z <= 0;		   
		   
		   
	       elsif rising_edge(sysclk) and (pixel_clock = '1') then
			       				 
					 
					 if X_in(15) = '1' then 
					 
					    sig_v_min_x <= v_0 + 5;
						 sig_v_max_x <= v_max - to_integer(unsigned(X_in(7 downto 0)));
						 
					 elsif X_in(15) = '0' then 
					       
						    sig_v_max_x <= v_0 ; 
						    sig_v_min_x <= v_0 - to_integer(unsigned(X_in(7 downto 0)));
							  
					 end if;
					 
					 
					 
					 if Y_in(15) = '1' then 
					 
					    sig_v_min_y <= v_0 + 5;
						 sig_v_max_y <= v_max - to_integer(unsigned(Y_in(7 downto 0)));
						 
					 elsif Y_in(15) = '0' then 
					       
						    sig_v_max_y <= v_0 ; 
						    sig_v_min_y <= v_0 - to_integer(unsigned(Y_in(7 downto 0)));
							 
					 else 
					 
							 
					 end if;					 
					 
					 
					 
					 if Z_in(15) = '1' then 
					 
					    sig_v_min_z <= v_0 + 5;
						 sig_v_max_z <= v_max - to_integer(unsigned(Z_in(7 downto 0)));
						 
					 elsif Z_in(15) = '0' then 
					       
						    sig_v_max_z <= v_0 ; 
						    sig_v_min_z <= v_0 - to_integer(unsigned(Z_in(7 downto 0)));
							 
					 end if;
					 
					 
          end if;
    END PROCESS;
	 
	 
	 
	  v_min_x  <=  sig_v_min_x;
	  v_max_x  <=  sig_v_max_x;
	  
	  v_min_y  <=  sig_v_min_y;
	  v_max_y  <=  sig_v_max_y;
	  
	  v_min_z  <=  sig_v_min_z;
	  v_max_z  <=  sig_v_max_z;
	 
	

	
	
end arc;	