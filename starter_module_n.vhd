 library    IEEE;
use IEEE.std_logic_1164.all  ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;

 



entity   starter_module_n   is
     PORT (
           
        resetn              : IN  STD_LOGIC; 
        sysclk              : IN  STD_LOGIC;--  50Mhz
        system_loop_cmnd    : IN  STD_LOGIC; 
        start_tx_system		 : OUT STD_LOGIC  
		 );
            
      END    starter_module_n ;
        
        
		
         ARCHITECTURE  ab of   starter_module_n   is
			
            TYPE STATE_TYPE is (s0,s1,s2,s3,s4,s5,s6,s7,s8);     
            SIGNAL state:STATE_TYPE;
                
            SIGNAL  sig_time_flag       : STD_LOGIC;
				SIGNAL  sig_flag            : STD_LOGIC;
			   SIGNAL  sig_time_cntr       : STD_LOGIC_VECTOR(25 DOWNTO 0);
		 	   CONSTANT sig_limit_value    : STD_LOGIC_VECTOR(19 DOWNTO 0) :=  X"7A120" ; -- 10mSec
		                               
                                                     
            begin
     
             

        
    process (sysclk, resetn)
	 
       variable delay_cntr : integer range 0 to 50000;

     begin
	  
       if resetn = '0' then 
          delay_cntr := 0 ;
          state <= s0 ;
	       sig_flag  <= '0' ;
			 
       elsif rising_edge(sysclk) then
		 
         CASE state is 
		  
		  
           WHEN s0 => 
			   
				       sig_flag  <= '1' ;       
                   state <= s1 ;
						 
           WHEN s1 =>
		  
			          delay_cntr :=  delay_cntr + 1;
				   
                   if  delay_cntr = 50 then
                       delay_cntr := 0 ;
						     sig_flag  <= '0' ;  
					        state <= s2 ;
						  
						 else
						     state <= s1 ;
                   end if;
						
          WHEN s2 =>
			 
			         delay_cntr := delay_cntr + 1;
			
			 	      if system_loop_cmnd  = '1' then
				         delay_cntr := 0 ;
                       state <= s0 ;
							  
                  else
                      state <= s2 ;
                  end if;
						  
                    
            WHEN OTHERS  => 
				
                         state <= s0 ;
								 
					END CASE ;
             end if;					
            end process;
				
				start_tx_system  <= sig_flag;
      
      
      end ab;
   