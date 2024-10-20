library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;




	     -- ===========================================================================================  
        -- this module write the vectors of the axiss to RAM module.
		  -- x_msb_vector to address : 5 
		  -- x_lsb_vector to address : 6
		  -- y_msb_vector to address : 7
		  -- y_lsb_vector to address : 8
		  -- z_msb_vector to address : 9
		  -- z_lsb_vector to address : A
		  -- interrupt_msb_vector to address : B
		  -- interrupt_lsb_vector to address : C  
		  -- ===========================================================================================





entity vectors2ram is
     PORT (
            resetn            : IN   STD_LOGIC;
            sysclk            : IN   STD_LOGIC;
			   start_ram         : IN   STD_LOGIC;
			   X_vector          : IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
			   Y_vector          : IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
			   Z_vector          : IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
				interrupt_vector  : IN   STD_LOGIC_VECTOR(15 DOWNTO 0); 
			   ram_address       : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
			   vector_to_ram     : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
				
				start_uart        : OUT  STD_LOGIC;
			   write_enable      : OUT  STD_LOGIC
			


     );
END vectors2ram;

ARCHITECTURE ab OF vectors2ram IS




    TYPE STATE_TYPE IS (idle,s0, s1, s2, s3, s4, s5,s6, s7, s8, s9, s10, s11 ,s12 ,s13, s14, s15, s16, s17, s18,
	                      s19 ,s20, s21, s22, s23, s24, s25, s26 ,s27, s28, s29, s30, s31, s32, s33 ,s34, s35);
    SIGNAL state : STATE_TYPE;
	 
	 

   -- SIGNAL sig_cntr             : INTEGER;

    SIGNAL sig_ram_addr         : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL sig_we               : STD_LOGIC;
	 SIGNAL sig_vector_to_ram    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL sig_write_clk        : STD_LOGIC;
	 SIGNAL sig_cnt_clk          : STD_LOGIC_VECTOR(10 DOWNTO 0);
	 SIGNAL sig_start_uart       : STD_LOGIC;
	 SIGNAL sig_cntr             : STD_LOGIC_VECTOR(10 DOWNTO 0);


BEGIN



	 
	 
	 	-- ==============  
      -- state machine. 
		-- ==============

    process(sysclk, resetn)
    begin
	 
        if resetn = '0' then
		  
           sig_vector_to_ram <= (others => '0');
           sig_ram_addr <= X"5";
		     sig_we <= '0';
			
            state <= idle;
				
        elsif rising_edge(sysclk) then
		  
            CASE state IS
				
				
		-- ===========================================================================  
        --   
		-- ===========================================================================
				
				WHEN idle => 
				
				            
				            sig_start_uart <= '0';
							   sig_ram_addr <= X"5";
							   sig_vector_to_ram <= (others => '0');
				
							   if start_ram <= '1' then 
							      state <= s0;
							   else 
							      state <= idle;
							   end if;

				
            WHEN s0 =>					
						      sig_vector_to_ram <= X_vector(15 DOWNTO 8); -- msb
                        state <= s1;	  
            WHEN s1 =>
							   state <= s2;				   
				WHEN s2 =>						 
						      sig_we <= '1';
							   state <= s3; 
            WHEN s3 =>				
				            sig_we <= '0';
                        state <= s4;
            WHEN s4 =>						 
							   sig_ram_addr <= std_logic_vector(unsigned(sig_ram_addr) + 1);
						      sig_vector_to_ram <= X_vector(7 DOWNTO 0); -- lsb
							   state <= s5;
            WHEN s5 =>				   
				            state <= s6;
            WHEN s6 =>				   
			               sig_we <= '1';
                        state <= s7;										
            WHEN s7 =>				
				            sig_we <= '0';
                        state <= s8;										
            WHEN s8 =>						 
							   sig_ram_addr <= std_logic_vector(unsigned(sig_ram_addr) + 1);
						      sig_vector_to_ram <= Y_vector(15 DOWNTO 8); -- msb
							   state <= s9;				
            WHEN s9 =>				   
				           state <= s10;									
            WHEN s10 =>
			              sig_we <= '1';
                       state <= s11;
            WHEN s11 =>
				            sig_we <= '0';
                        state <= s12; 
            WHEN s12 => 
						      sig_ram_addr <= std_logic_vector(unsigned(sig_ram_addr) + 1);
						      sig_vector_to_ram <= Y_vector(7 DOWNTO 0); -- lsb
							   state <= s13;					
            WHEN s13 =>				   
				           state <= s14;									
            WHEN s14 =>

			              sig_we <= '1';
                       state <= s15;						  
            WHEN s15 =>				
				            sig_we <= '0';
                        state <= s16; 
            WHEN s16 => 				        
						      sig_ram_addr <= std_logic_vector(unsigned(sig_ram_addr) + 1);
						      sig_vector_to_ram <= Z_vector(15 DOWNTO 8); -- msb
							   state <= s17;																
            WHEN s17 =>				
				           state <= s18;									
            WHEN s18 =>				
			              sig_we <= '1';
                       state <= s19;						  
            WHEN s19 =>				
				            sig_we <= '0';
                        state <= s20; 	
            WHEN s20 => 				        
						      sig_ram_addr <= std_logic_vector(unsigned(sig_ram_addr) + 1);
						      sig_vector_to_ram <= Z_vector(7 DOWNTO 0); -- lsb
							   state <= s21;
            WHEN s21 => 
				           state <= s22;

            WHEN s22 =>
			              sig_we <= '1';
                       state <= s23;						  
            WHEN s23 =>				
				            sig_we <= '0';
                        state <= s24;
            WHEN s24 => 				        
						      sig_ram_addr <= std_logic_vector(unsigned(sig_ram_addr) + 1);
						      sig_vector_to_ram <= interrupt_vector(15 DOWNTO 8); -- msb
							   state <= s25;																
            WHEN s25 =>				   
				           state <= s26;							
            WHEN s26 =>
			              sig_we <= '1';
                       state <= s27;						  
            WHEN s27 =>				
				            sig_we <= '0';
                        state <= s28; 
            WHEN s28 => 				        
						      sig_ram_addr <= std_logic_vector(unsigned(sig_ram_addr) + 1);
						      sig_vector_to_ram <= interrupt_vector(7 DOWNTO 0); -- lsb
							   state <= s29;
            WHEN s29 => 
				           state <= s30;

            WHEN s30 =>
			              sig_we <= '1';
                       state <= s31;						  
            WHEN s31 =>				
				            sig_we <= '0';
                        state <= s32;																	
            WHEN s32 =>				  
							   sig_ram_addr <= X"5"; 
								sig_start_uart <= '1';
								
							   state <= s33;																								
             WHEN s33 => 
                         if to_integer(unsigned(sig_cntr)) = 700 then  -- 700 for start_uart to be big enough.
                            sig_cntr <= (others => '0');
									 state <= idle;
									 sig_start_uart <= '0';
								
								 else 
								    sig_cntr <= std_logic_vector(unsigned(sig_cntr) + 1);
									 state <= s33;
								
								  end if;


                       				 
			

                WHEN OTHERS =>
                    state <= idle;
						  
            END CASE;
        end if;
    end process;
	 
	 
	   ram_address    <=  sig_ram_addr;
	   write_enable   <=  sig_we;
	   vector_to_ram  <=  sig_vector_to_ram;
      start_uart     <=  sig_start_uart;
   
 
	 
	 
	 
	 
	 
END ab;