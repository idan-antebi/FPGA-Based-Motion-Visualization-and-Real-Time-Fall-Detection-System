
  library    IEEE;
use IEEE.std_logic_1164.all  ;
--USE ieee.std_logic_arith.all ;
--USE ieee.std_logic_unsigned.all ;
use IEEE.NUMERIC_STD.ALL;


entity  uart_adxl   is
     PORT (
           
            resetn           : IN  STD_LOGIC;
            sysclk           : IN  STD_LOGIC; --  50Mhz     	
            sim_start_strobe : IN  STD_LOGIC;
		      tx_data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            dpr_rden         : OUT STD_LOGIC;
            system_loop_cmnd : OUT STD_LOGIC;		  		 
		      tx_bit           : OUT STD_LOGIC;
			   rdaddress        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)



				);
            
      END  uart_adxl ;
        
         
   
   
		
         ARCHITECTURE  ab of uart_adxl   is
			

				
				
				
				
      	
			
	      TYPE STATE_TYPE_TX is (s0_tx,s1_tx,s2_tx,s3_tx,s4_tx,s5_tx,s6_tx,
		                           s7_tx,s8_tx,s9_tx,s10_tx,s0_tx_a);
			SIGNAL state_tx:STATE_TYPE_tx;      
         SIGNAL   sig_counter          : std_logic_vector(12 DOWNTO 0); 
		   SIGNAL   sig_CLK_C_q          : STD_LOGIC ;
         SIGNAL   sig_CLK_C_q_not      : STD_LOGIC ;
         SIGNAL   sig_CLK_C_r          : STD_LOGIC ;
 
	      SIGNAL   sig_CLK_A_q          : STD_LOGIC ;
         SIGNAL   sig_CLK_A_q_not      : STD_LOGIC ;
         SIGNAL   sig_CLK_A_r          : STD_LOGIC ;

	      SIGNAL   sig_serial_tx_reg    : STD_LOGIC_VECTOR(10 DOWNTO 0);
         SIGNAL   sig_tx_bit           : STD_LOGIC ;      
         SIGNAL   sig_tx_byte          : STD_LOGIC_VECTOR(7 DOWNTO 0);
		   SIGNAL   sig_data_tx          : STD_LOGIC_VECTOR(7 DOWNTO 0);
		   SIGNAL   sig_byte_cntr        : STD_LOGIC_VECTOR(4 DOWNTO 0);
		   SIGNAL   sig_dpr_tx_addr      : STD_LOGIC_VECTOR(3 DOWNTO 0);		
			SIGNAL   sig_tx_start_reg     : STD_LOGIC_VECTOR(15 DOWNTO 0);
			SIGNAL   sig_f38400           : STD_LOGIC;
         SIGNAL   sig_tx_rden          : STD_LOGIC;
  		   SIGNAL   sig_q                : STD_LOGIC_VECTOR(7 DOWNTO 0);
			SIGNAL   sig_sim_start_pulse  : STD_LOGIC;
			SIGNAL   sig_dpr_rden         : STD_LOGIC;
			SIGNAL   sig_rdaddress        : STD_LOGIC_VECTOR(3 DOWNTO 0);
			SIGNAL   sig_check_sum        : STD_LOGIC_VECTOR(11 DOWNTO 0);
			CONSTANT sig_size_reg         : STD_LOGIC_VECTOR(3 DOWNTO 0 ) := X"D" ;
			
			
   BEGIN

 

   
  
   
  	
	PROCESS(sysclk,RESETN)
-- strobes of   38400 clock.
    BEGIN
      IF RESETN = '0' THEN      
         sig_CLK_C_q        <= '0' ;
         sig_CLK_C_q_not    <= '1' ;
			
       ELSIF  RISING_EDGE(sysclk) THEN
			     sig_CLK_C_q <=  sig_f38400 ;
              sig_CLK_C_q_not <= not  sig_CLK_C_q ;
       END IF ;
     END PROCESS ;
	  
     sig_CLK_C_r <= sig_CLK_C_q AND sig_CLK_C_q_not ;
  



	
	PROCESS(sysclk,RESETN)
-- strobes of   dpr_rden.
    BEGIN
      IF RESETN = '0' THEN      
          sig_CLK_A_q        <= '0' ;
          sig_CLK_A_q_not    <= '1' ;
			 
       ELSIF falling_EDGE(sysclk) THEN
		       sig_CLK_A_q <=  sig_tx_rden ;
             sig_CLK_A_q_not <= not  sig_CLK_A_q ;
       END IF ;
     END PROCESS ;
	  
     sig_CLK_A_r <= sig_CLK_A_q AND sig_CLK_A_q_not ;
     sig_dpr_rden  <= sig_CLK_A_r;








  
--------------------------------    
 -- 50000000 / 38400 = 1302.08                
 -- 1302.08 / 2 = 651.04
 -- 50000000 / (651 x2) = 38402.4
 -- (2.4 / 38400) x 100 = 0.00625 %
 -- legal deviation up tp 5%    
-----------------------------------
 process(sysclk,resetn)
   -- creating the 38400 clock.
    begin
    IF (resetn = '0') THEN       
      sig_f38400  <= '0' ; 
		sig_counter <=  (others => '0') ;
    elsif  rising_edge(sysclk) then
       sig_counter <= std_logic_vector(unsigned(sig_counter) + 1);
        if  to_integer(unsigned(sig_counter)) = 651  then   -- for xtal 50Mhz
            sig_counter <= (others => '0') ;
            sig_f38400  <= not sig_f38400  ;
        end if ;
       end if ;
      end process ;
  
   
 
    
--     
     	  
-- main state machine. 
 --###
process(sysclk,resetn)

 variable tx_cntr :integer range 0 to 150 ;
 begin
 
 IF (resetn = '0') then
    state_tx <= s0_tx ;  
    tx_cntr := 0 ;	  
	 sig_tx_bit <= '1' ;
    sig_rdaddress <= (others => '0');
	 sig_data_tx  <= (others => '0');
    sig_tx_rden <= '0';
    system_loop_cmnd  <= '0';
 
 elsif rising_edge(sysclk) then
    if sig_CLK_C_r = '1'  then
      CASE state_tx is 

		
         WHEN s0_tx => 
			  
					     if sim_start_strobe = '1'   then
						     sig_check_sum <= (others => '0');
                       state_tx <= s0_tx_a ;
						  
                    else
                       state_tx <= s0_tx ;
							
                    end if;
						  
						  
			WHEN s0_tx_a =>	
            	
					       if sim_start_strobe = '0'     then
						       state_tx <= s1_tx ;
					 
                      else
                         state_tx <= s0_tx_a ;
							
                      end if;
						  
						  
         WHEN s1_tx => 
			  
               -- read data from dpr 
					
                    sig_tx_rden <= '1';
                    state_tx <= s2_tx ; 
					
					
         WHEN s2_tx =>
     			
                    sig_tx_rden <= '0';
                    state_tx <= s3_tx ;  

					 
         WHEN s3_tx => 
    
	                 if sig_rdaddress < sig_size_reg  then				
                       sig_data_tx <= tx_data;
						
					     else
					        sig_data_tx <= sig_check_sum(7 downto 0);
							  
					     end if;
                       state_tx <= s4_tx ; 
					
					
         WHEN s4_tx => 
       			 
				         sig_tx_byte(0) <= sig_data_tx(7) ;
		               sig_tx_byte(1) <= sig_data_tx(6) ;
		               sig_tx_byte(2) <= sig_data_tx(5) ;
		               sig_tx_byte(3) <= sig_data_tx(4) ;
		               sig_tx_byte(4) <= sig_data_tx(3) ;
		               sig_tx_byte(5) <= sig_data_tx(2) ;
		               sig_tx_byte(6) <= sig_data_tx(1) ;
		               sig_tx_byte(7) <= sig_data_tx(0) ;
					      sig_check_sum <= std_logic_vector(unsigned(sig_check_sum) + unsigned(sig_data_tx));
					      state_tx <= s5_tx ; 

						 
         WHEN s5_tx =>
		     
                     sig_serial_tx_reg <=  "0" & sig_tx_byte  & "11"; 
                     state_tx <= s6_tx ;	
	
	
         WHEN s6_tx =>
			   
                     sig_serial_tx_reg <= sig_serial_tx_reg(9 downto 0) & '1' ;
                     sig_tx_bit <= sig_serial_tx_reg(10) ; 
			            tx_cntr := tx_cntr + 1 ;
					  
                    if tx_cntr = 11 then
                       state_tx <= s7_tx ;
                       tx_cntr := 0 ;
						  
			      	  else  
					        state_tx <= s6_tx ;
                    end if ;  

					  
         WHEN s7_tx => 
			      
                      sig_rdaddress <= std_logic_vector(unsigned(sig_rdaddress) + 1); 
                      state_tx <= s8_tx ;
						 
						 
         WHEN s8_tx => 
             			 
                     if sig_rdaddress > sig_size_reg  then
                        state_tx <= s9_tx ;
								  
                     else
                        state_tx <= s1_tx ;
                     end if;
						
						
         WHEN s9_tx =>  
			      
                      sig_rdaddress <= (others => '0');
                      system_loop_cmnd  <= '1';
						    tx_cntr := tx_cntr + 1 ;
							 
						    if tx_cntr = 10 then
						       tx_cntr := 0 ;
                         state_tx <= s10_tx ;
							  
							 else
							    state_tx <= s9_tx ;
							 end if;
							
							
         WHEN s10_tx =>
			      
                      system_loop_cmnd  <= '0';
                      state_tx <= s0_tx ; 

					  
         WHEN OTHERS  => 
				 
                       state_tx<= s0_tx;
           END CASE ;                 
    
         end if;
       end if ;
     end process ;
	 
       
	   
	   rdaddress   <= sig_rdaddress;
      dpr_rden    <= sig_dpr_rden;

	   
	   
	   
	   
	  
	 process(sysclk,resetn) 
	 begin
	 
    if (resetn = '0') then 
	    tx_bit <= '1';
	  
	 elsif rising_edge(sysclk) then 
	       tx_bit <= sig_tx_bit;
    
	  end if ;
     end process ;
	 
    
	 
	 end ab ;  