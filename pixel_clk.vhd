library    IEEE;
use IEEE.std_logic_1164.all  ;
use IEEE.NUMERIC_STD.ALL; 


 entity  pixel_clk  is  
      PORT (   
            resetn                  : IN  STD_LOGIC;
            sysclk                  : IN  STD_LOGIC; -- 50mHz
            pixel_clock             : OUT STD_LOGIC
				
       );
		
   end pixel_clk; 
			
	    
           
     ARCHITECTURE  ab of pixel_clk  is   


    
     
            signal sig_pixel_clock  : STD_LOGIC; 
                
            begin
	 
        

    process (sysclk, resetn) 
	 
     begin
	  
	  
        if resetn = '0'      then   
           sig_pixel_clock <= '0';	 
			  
        elsif falling_edge(sysclk) then --rising_edge
             sig_pixel_clock <= not sig_pixel_clock;
				 
        end if;
     end process; 
	  
      pixel_clock  <= sig_pixel_clock;
      
      end ab;