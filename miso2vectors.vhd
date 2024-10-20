library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;




	   -- ===========================================================================================  
      -- this module get MISO siganl, separator it to 16 bits vectors and detect the data to axiss.
		-- ===========================================================================================





entity miso2vectors is
     PORT (
            resetn              : IN  STD_LOGIC;
            sysclk              : IN  STD_LOGIC;
            cs                  : IN  STD_LOGIC;
            sclk                : IN  STD_LOGIC;
            miso_in             : IN  STD_LOGIC;
            start_read          : IN  STD_LOGIC;
				start_ram           : OUT STD_LOGIC;
            X_vector_out        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Y_vector_out        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				Z_vector_out        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				interrupt_vector    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

     );
END miso2vectors;

ARCHITECTURE ab OF miso2vectors IS




    TYPE STATE_TYPE IS (s0, s1, s2, s3, s4, s5, s6, s7);
    SIGNAL state : STATE_TYPE;
	 
	 
    SIGNAL sig_sclk_last       : STD_LOGIC;
    SIGNAL sig_cntr            : STD_LOGIC_VECTOR(8 downto 0); -- counter spi clock rising_edge
    SIGNAL sig_miso_collect    : STD_LOGIC_VECTOR(15 downto 0);
    SIGNAL sig_rom_addr        : INTEGER range 0 to 28 := 0;
    SIGNAL sig_X_out           : STD_LOGIC_VECTOR(15 downto 0);
    SIGNAL sig_Y_out           : STD_LOGIC_VECTOR(15 downto 0);
	 SIGNAL sig_Z_out           : STD_LOGIC_VECTOR(15 downto 0);
	 SIGNAL sig_interrupt       : STD_LOGIC_VECTOR(15 downto 0);
	 SIGNAL sig_start_ram       : STD_LOGIC;
    
	 
	 

BEGIN



	   -- ===========================================================  
      -- generate another SPI clock to detect the rising_edge of it.
		-- ===========================================================
    process(sysclk, resetn)
    begin
        if resetn = '0' then
            sig_sclk_last <= '0';
        elsif rising_edge(sysclk) then
            sig_sclk_last <= sclk;
        end if;
    end process;
	 
	 
	 
	 
	 
	 
	 	-- ==============  
      -- state machine. 
		-- ==============

    process(sysclk, resetn)
    begin
	 
        if resetn = '0' then
		  
            sig_cntr <= (others => '0');
            sig_rom_addr <= 0;
            sig_X_out <= (others => '0');
            sig_Y_out <= (others => '0');
				sig_Z_out <= (others => '0');
            sig_miso_collect <= (others => '0');
            state <= s0;
				
        elsif rising_edge(sysclk) then
		  
            CASE state IS
				
				
		-- ==================================================================  
      -- start state machine when the registers of ADXL345 are initialized.
		-- start_read is the flag for the initialized. 
		-- ==================================================================
				
				
                WHEN s0 =>
					          
								 sig_start_ram <= '0';
					         
					 
                    if cs = '0' and start_read = '1' then
                        sig_cntr <= (others => '0');
                        state <= s1;
                    else
                        state <= s0;
                    end if;
						  
						  
						  
		-- =========================================  
      -- collect the MISO into vectors of 16 bits.
		-- =========================================						  

                WHEN s1 =>
					 
                    if sclk = '1' and sig_sclk_last = '0' then
                        sig_cntr <= sig_cntr + 1;
                        sig_miso_collect <= sig_miso_collect(14 downto 0) & miso_in;
								
                        if sig_cntr = 15 then
                            sig_cntr <= (others => '0');
                            state <= s2;
                        else
                            state <= s1;
                        end if;
                    end if;
						  
						  
						  
		-- ===================================================================================  
      -- count the times that vectors are generate to point the correct vector of eche axis.
		-- the value of sig_rom_addr is selectd according the LOGIC ANALYZER. 
		-- ===================================================================================							  

                WHEN s2 =>
					 
                    sig_rom_addr <= sig_rom_addr + 1;

                    if sig_rom_addr = 9 then
                       sig_X_out <= sig_miso_collect;
							  

								
                    elsif sig_rom_addr = 14 then
                          sig_Y_out <= sig_miso_collect;
								  

								
					     elsif sig_rom_addr = 19 then
                          sig_Z_out <= sig_miso_collect;
								  
								  
								  
                    elsif sig_rom_addr = 24 then
                          sig_interrupt <= sig_miso_collect;
								  
								  
                    end if;

                    if sig_rom_addr = 24 then
                        sig_rom_addr <= 0;
                    end if;

                    state <= s3;
					
					
                WHEN s3 =>	

--                      X_vector_out <= sig_X_out;
--                      Y_vector_out <= sig_Y_out;
--                      Z_vector_out <= sig_Z_out;
					  
					  
					   state <= s4;
						
						
                WHEN s4 =>						
						
						       sig_start_ram <= '1';
								 
								 state <= s5;
								 
								 
                WHEN s5 =>	

                         state <= s0;					 
					

                WHEN OTHERS =>
                            state <= s0;
					
					
					
            END CASE;
        end if;
    end process;
	 
             X_vector_out <= sig_X_out;
             Y_vector_out <= sig_Y_out;
             Z_vector_out <= sig_Z_out;    
	          interrupt_vector <= sig_interrupt;
	 
	          start_ram <= sig_start_ram;
	 
END ab;