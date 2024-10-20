
library    IEEE;
use IEEE.std_logic_1164.all  ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;

-- 04.07.2024 This is master module that read data from cc1101 tranceiver.

entity  video_sync_generator  is
     PORT (        
            resetn           :  IN   STD_LOGIC;
            sysclk           :  IN   STD_LOGIC;-- 50mHz
            pixel_clock      :  IN   STD_LOGIC;-- 25mHz
            blank_n          :  OUT  STD_LOGIC; 
            HS               :  OUT  STD_LOGIC; 
            VS               :  OUT  STD_LOGIC;
            v_cnt            :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0)

				
            );

  END video_sync_generator;      
      
        
     ARCHITECTURE  ab of video_sync_generator  is
     
       -- components declaration.


        -- parameters
        constant   sig_hori_line     : STD_LOGIC_VECTOR(11 DOWNTO 0) := X"320" ; -- 800 decimal
        constant   sig_hori_back     : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"90" ; -- 144 decimal
        constant   sig_hori_front    : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"10" ; -- 16 decimal
        constant   sig_vert_line     : STD_LOGIC_VECTOR(11 DOWNTO 0) := X"20D" ;  -- 525 decimal
        constant   sig_vert_back     : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"22" ;  -- 34 decimal
        constant   sig_vert_front    : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"B" ;   -- 11 decimal
        constant   sig_H_sync_cycle  : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"60" ;  -- 96 decimal
        constant   sig_V_sync_cycle  : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"2" ;   -- 2 decimal
        signal     sig_H_BLANK       : STD_LOGIC;
        signal     sig_h_cnt         : STD_LOGIC_VECTOR( 11 DOWNTO 0 );
        signal     sig_v_cnt         : STD_LOGIC_VECTOR( 11 DOWNTO 0 );
        signal     sig_cHD           : STD_LOGIC;
        signal     sig_cVD           : STD_LOGIC;
        signal     sig_cDEN          : STD_LOGIC;
        signal     sig_hori_valid    : STD_LOGIC;
        signal     sig_vert_valid    : STD_LOGIC;

    begin
			  
        -- components ports.  
        
        
       process (sysclk, resetn, pixel_clock) 
      begin	
	  if resetn = '0' then
	  
       sig_h_cnt   <= (others => '0');
       sig_v_cnt   <= (others => '0');
		 
       elsif rising_edge(sysclk) and (pixel_clock ='1') then 
		 
        if (sig_h_cnt = sig_hori_line-1) then
		  
           sig_h_cnt   <= (others => '0');
			  
           if (sig_v_cnt  = sig_vert_line-1)  then
			  
              sig_v_cnt   <= (others => '0');
				  
           else
			  
              sig_v_cnt <= sig_v_cnt + 1;
				  
           end if;
        else
         sig_h_cnt <=  sig_h_cnt+1;
      end if;
		end if;
      end process;
      

  
      sig_CHD <= '0'  when (sig_h_cnt < sig_H_sync_cycle) else '1'; -- h_cnt less then 96 CHD = '0'
      sig_cVD <= '0'   when (sig_v_cnt < sig_V_sync_cycle) else '1'; -- sig_v_cnt less then 2 cVD = '0' 
      sig_hori_valid  <= '1'  when (sig_h_cnt < (sig_hori_line - sig_hori_front)) and (sig_h_cnt  >= sig_hori_back) else '0';
                             -- when h_cnt is less 800 - 16 and h_cnt greater equal the 144
      sig_vert_valid  <= '1'  when (sig_v_cnt < (sig_vert_line - sig_vert_front))   and (sig_v_cnt >= sig_vert_back)  else '0';
                              -- when v_cnt less then 525 - 16 and v_cnt greater or equal then 34 
       sig_cDEN <= sig_hori_valid and sig_vert_valid;
      
         
        
  process (sysclk, resetn, pixel_clock) 
      begin	
	  if resetn = '0' then
          HS <= '0';
          VS <= '0';
          blank_n <= '0';
			 
     elsif rising_edge(sysclk) and (pixel_clock ='1') then 
          HS <= sig_CHD;
          VS <= sig_cVD;
          blank_n <= sig_cDEN;
     end if;
    end process;
	 

	 v_cnt  <=  sig_v_cnt;

	 
	 
     
 end ab;