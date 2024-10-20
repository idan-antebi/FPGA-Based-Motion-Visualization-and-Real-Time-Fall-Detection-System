library    IEEE;
use IEEE.std_logic_1164.all  ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;
use IEEE.NUMERIC_STD.ALL;

 -- 15.8.2024  module to read/write from adxl345 

 
--   |----------|                                       |-----------|
--   |    SPI   |---> cs------------------------------->|-----------|
--	  | CONTROLER|---> spi_clock------------------------>|  ADXL345  |
--	  |   MODULE |---> mosi----------------------------->|-----------|
--   |----------|<--- miso-----------------------------<|-----------|

 

 
	
entity  spi_adxl   is
     PORT (        
            resetn                : IN  STD_LOGIC; -- B8 
            sysclk                : IN  STD_LOGIC; -- 50mHz  -- N14
			   start_state_machine   : IN  STD_LOGIC; -- external triger start transmit data read from adxl        
            cs                    : OUT STD_LOGIC; -- AB16     
            mosi                  : OUT STD_LOGIC; -- V11 
	         spi_clock             : OUT STD_LOGIC; -- AB15 
			   
			   write_flag            : OUT  STD_LOGIC;
				
		 ---- ROM I/O ------------------------------------------------
			    
				 ROM_data_in          : IN  STD_LOGIC_VECTOR(7 downto 0);
				 ROM_addr             : OUT STD_LOGIC_VECTOR(5 downto 0)
				 
		 ---- interrupt ------------------------------------------------	
		 
--		       INT1                 : IN  STD_LOGIC;         
--             interrupt_detected   : OUT STD_LOGIC 

			
		 ---- for simulation -----------------------------------------------
		 
		      --raw_clock     : OUT STD_LOGIC;
            --strob_clk     : OUT STD_LOGIC;
		      --cs_stop       : OUT STD_LOGIC;				
			     
     );
	  END spi_adxl;      
      
        
     ARCHITECTURE  ab of spi_adxl  is
     
       -- signals declaration =========================================
		 
        TYPE STATE_TYPE is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19);
           SIGNAL state:STATE_TYPE;
              
              signal  sig_raw_cntr        : STD_LOGIC_VECTOR(3 downto 0);
              signal  sig_adxl_adr        : STD_LOGIC_VECTOR(15 downto 0); 
              signal  sig_spi_state_cntr  : STD_LOGIC_VECTOR(4 downto 0);
              signal  sig_CLK_A_q         : STD_LOGIC;
              signal  sig_CLK_A_q_not     : STD_LOGIC;
              signal  sig_CLK_A_r         : STD_LOGIC;
				  signal  sig_spi_raw_clock   : STD_LOGIC;
				  signal  sig_cs              : STD_LOGIC;
				  signal  sig_spi_clock       : STD_LOGIC;
				  signal  sig_spi_clock_1     : STD_LOGIC;
			     signal  sig_spi_clock_2     : STD_LOGIC;
              signal  sig_tx_reg          : STD_LOGIC_VECTOR(15 downto 0);
              signal  sig_mosi            : STD_LOGIC;
				  signal  sig_shift_reg       : STD_LOGIC_VECTOR(31 downto 0);
	           signal  sig_spi_clock_out   : STD_LOGIC;
				  signal  sig_cs_stop         : STD_LOGIC;
				  
			     signal  sig_ROM_addr        : STD_LOGIC_VECTOR(5 downto 0):= (others => '0');
				  signal  sig_ROM_data_in     : STD_LOGIC_VECTOR(7 downto 0);
              signal  sig_ROM_cntr        : STD_LOGIC_VECTOR(4 downto 0);
				  
				  signal  sig_write_cntr      : STD_LOGIC_VECTOR(6 downto 0);
				  signal  sig_write_flag      : STD_LOGIC;
				  
				  signal  sig_miso_start       : STD_LOGIC; 
              
				  signal  sig_last_INT1        : STD_LOGIC;
				  signal  sig_interrupt        : STD_LOGIC;
				 --===========================================================
           
        begin
			  
    
     --==========================================
     --  Main state machine
     --============================================	  
     process (sysclk, resetn)

     begin
       if resetn = '0' then 

         sig_adxl_adr <= (others => '0');
         state   <= s0 ;
         sig_cs  <= '1';
		   sig_cs_stop <= '1';
         sig_spi_state_cntr <= (others => '0');
			sig_ROM_cntr <= (others => '0');
			sig_write_cntr <= (others => '0');
			sig_write_flag <= '1';
			
       elsif rising_edge(sysclk) then
         if sig_CLK_A_r = '1' then -- spi_raw_clock raising edge strobe
         CASE state is
			
			         when s0 => 
					       -- =========================================== 
			             -- external signal to start the state machine.
					       -- ============================================						
						         if start_state_machine = '1' then  -- external signal 
									   sig_spi_state_cntr <= (others => '0'); 
                              state <= s1 ; 
								  
                           else
                              state <= s0 ; 
                           end if;
						
						
                  WHEN s1 => 
					       -- =========================================== 
			             -- load data from ROM to sig_adxl_adr.
							 -- this load use to be address of adxl register.
					       -- ============================================								  
								  
                          sig_spi_state_cntr <= (others => '0');													        
							     sig_adxl_adr(15 downto 8)  <= sig_ROM_data_in;
								  sig_ROM_addr  <= sig_ROM_addr + 1; 
								  
								 
								  
	                       state <= s2 ;
							 
                  WHEN s2 =>
					       -- ========================================================= 
			             -- load data from ROM to sig_adxl_adr.
							 -- this load use to be data that write to the adxl register.
							 -- we write only few times and then always read.
					       -- =========================================================
							 
								  sig_adxl_adr(7 downto 0)  <= sig_ROM_data_in;
								  sig_ROM_addr  <= sig_ROM_addr + 1;
								  state <= s3 ;
								  
								  
                  WHEN s3 =>
					       -- ============================== 
			             -- detecting end of triger pulse.
					       -- ==============================
							 
                       if start_state_machine = '0' then  -- external signal
                           state <= s4 ;
                       else
                           state <= s3 ;  
                       end if;  
                          
							 
                  WHEN s4 =>
					       -- ================================== 
			             -- copy to register for creatig mosi.
					       -- ==================================
							 
					         sig_tx_reg(15 downto 8) <=  sig_adxl_adr(15 downto 8); 
								sig_tx_reg(7 downto 0)  <=  sig_adxl_adr(7 downto 0);
                        state <= s5 ;
							 
			         WHEN s5 => 
					       -- ========================== 
			             -- start transmission enable.
					       -- ==========================						
						       sig_cs       <= '0';
					          sig_cs_stop  <= '0';
                         state <= s6 ;
								 	
								
								
			         WHEN s6 =>
						
						
								 
					       -- ================================================== 
			             -- creating the mosi,sig_tx_reg is the shift reister.
					       -- ==================================================	
							 
				            sig_mosi <= sig_tx_reg(15);
                        sig_tx_reg <= sig_tx_reg(14 downto 0) & '0';
							 
		                -- ==============================================================================
						    -- sig_cs_stop signal to stop spi clock 
						    -- to be length of 16, stop by cs only will result in two more clocks.
                      -- sig_spi_state_cntr is responsible to crate 32 clock inside a transmition slice.								 
						    -- ===============================================================================
							 
							  if sig_spi_state_cntr = 15 then
							  
                          state <= s7 ;
							     sig_cs_stop <='1';
							     sig_spi_state_cntr <= (others => '0'); 
							     
                       else
							     
                          state <= s6 ;
                       end if; 
							  
                          sig_spi_state_cntr <= sig_spi_state_cntr + 1;
								 
								 
       
								 							 
                  when s7 => 
						
		     -- ===========================================================================================
			  -- sig_ROM_cntr is responsible to create delay after all the registers of the ROM are readed.
           -- sig_write_flag is responsible to detacting that all ADXL registers are initialized 1 time.
		     -- after 1 time start to use only the other registers of the ROM.	  
			  -- ===========================================================================================	
								 
								 
								if sig_ROM_cntr = X"1F" then
							    
									 if sig_write_flag = '1' then 
									    sig_ROM_cntr <= "00111";  -- 7
										 sig_ROM_addr <= "001110"; -- E
										 state <= s10; -- break
										 sig_cs <= '1';
									 else 							
								
			 					       sig_ROM_cntr <= (others => '0');
	                            state <= s8 ;
									    sig_cs <= '1';
										 
									 end if;
								
								
								else 
																
								   sig_cs <= '1';
								   state <= s1;
									sig_ROM_cntr <= sig_ROM_cntr + 1;
									
								end if;
								
                        
								
						      
                      
                  when s8 =>
						
		            -- =====================================================================================
			         -- sig_write_cntr is responsible to count how many times ADXL registers are initialized. 
			         -- =====================================================================================						         
                           
					   	       if sig_write_cntr = 1 then 
									
							          state <= s9 ;
									 else 
									    state <= s10;
										 
									 end if; 
									 
									 sig_write_cntr <= sig_write_cntr + 1; -- count times of ADXL initialized.
									 
							  
						
			         when s9 =>		 
	                          sig_write_flag <= '1'; -- detacting when write 1 time initial byets.
									  state <= s10;

			         when s10 =>	
				                

		                      		
							      
							       state <= s0 ;									 
						 
		
							  
                  WHEN OTHERS  => 
                               state <= s0 ;
										 
                END CASE ; 
            end if; 
          end if;
      end process; 
      
      
      write_flag <= sig_write_flag;
       
      
       PROCESS(sysclk,RESETN)
		 -- strobe of spi_raw clock.
   BEGIN
      IF (RESETN = '0') THEN      
       sig_CLK_A_q        <= '0' ;
       sig_CLK_A_q_not    <= '1' ;
      ELSIF  falling_edge(sysclk) THEN
       sig_CLK_A_q <= sig_spi_raw_clock ;
       sig_CLK_A_q_not <= not  sig_CLK_A_q ;
      END IF ;
    END PROCESS ;
    sig_CLK_A_r <= sig_CLK_A_q AND sig_CLK_A_q_not ; 

      
      process (sysclk, resetn)
	 -- ========================================================
    -- creating the spi master clock.
	 -- This clock is alwayes active.
	 -- 8 bits '0' and 8 bis '1' bit time = 320nSec f= 3.125mHz.
	 -- ========================================================
    begin
	      if resetn = '0' then 
         sig_raw_cntr <= (others => '0');
         sig_spi_raw_clock  <= '0' ;
      elsif rising_edge(sysclk) then 
        sig_raw_cntr <=  sig_raw_cntr + 1;
        sig_spi_raw_clock <= sig_raw_cntr(3);     
      end if;
    end process; 
    
     process (sysclk, resetn)   
      -- ============================================
		-- loocking for the correct phase of spi clock.
	   -- is the raw clock and the sig_cs_stop.
	   -- ============================================	
     begin
       if resetn = '0' then
         sig_spi_clock     <= '0';
	      sig_spi_clock_1   <= '0';	
		   sig_spi_clock_2   <= '0';
			
       elsif rising_edge(sysclk) then

			sig_spi_clock     <= sig_spi_raw_clock and  ( not sig_cs_stop);
			sig_spi_clock_1   <= sig_spi_clock and  ( not sig_cs_stop);
		   sig_spi_clock_2   <= not sig_spi_clock_1;	
			
         end if;
      end process;
	
	  
	  process (sysclk, resetn) 
	   -- =========================================================  
      -- shift of sig_spi_clock_out by 11 sysclk.
		-- This is a delay line to adjust the clock timing according
		-- to the simulation.
		-- =========================================================
     begin
       if resetn = '0' then
         sig_spi_clock_out <= '0' ; 
       elsif rising_edge(sysclk) then 
	      sig_shift_reg <=  sig_shift_reg(30 downto 0) &  sig_spi_clock_2;
	      sig_spi_clock_out <= sig_shift_reg(11); 
	    end if;
      end process;
		
		

		
		
		
		
		
	 	
	   spi_clock    <= sig_spi_clock_out;
      cs           <= sig_cs;
      mosi         <= sig_mosi;
	
      ROM_addr         <= sig_ROM_addr;
		sig_ROM_data_in  <= ROM_data_in;
	 

      	 
	   --- for simulation ----------------
		
	   --raw_clock   <= sig_spi_raw_clock;  
      --strob_clk   <= sig_CLK_A_r;
      --cs_stop     <= sig_cs_stop;
     
     end ab;   