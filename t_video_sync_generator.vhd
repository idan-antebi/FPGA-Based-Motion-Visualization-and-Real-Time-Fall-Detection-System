 library    IEEE;
use IEEE.std_logic_1164.all  ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;




entity t_video_sync_generator is
PORT (
 		blank_n		:	 OUT STD_LOGIC;
		HS		:	 OUT STD_LOGIC;
		VS		:	 OUT STD_LOGIC
	                 );
end t_video_sync_generator;

 architecture only of t_video_sync_generator is
 
COMPONENT video_sync_generator
	PORT
	(
		resetn		:	 IN STD_LOGIC;
		sysclk		:	 IN STD_LOGIC;
		pixel_clock		:	 IN STD_LOGIC;
		blank_n		:	 OUT STD_LOGIC;
		HS		:	 OUT STD_LOGIC;
		VS		:	 OUT STD_LOGIC
	);
END COMPONENT;

   
   signal sig_sysclk   :  STD_LOGIC   := '0';
   signal sig_resetn   :  STD_LOGIC   := '0';
   signal sig_pixel_clock : STD_LOGIC := '0';
      

  
begin
 
  
   
  
  
  
   dut: video_sync_generator
	PORT    MAP
	(
		resetn		            => sig_resetn,
	 	sysclk		            => sig_sysclk,
		pixel_clock             => sig_pixel_clock,
        blank_n                 => blank_n,
		HS                      => HS, 
		VS                      => VS
        
 	);
   
    
 
 
 	  PROCESS
   begin
    wait for 10.0 ns; sig_sysclk       <= not sig_sysclk; -- 50.000mhz
end PROCESS ;



 	  PROCESS
   begin
    wait for 20.0 ns; sig_pixel_clock       <= not sig_pixel_clock; 
end PROCESS ;


 
 
stimulus : PROCESS
   begin
   wait for 50 ns; sig_resetn  <= '0';
   wait for 40 ns; sig_resetn  <= '1';
   wait;
end PROCESS stimulus;
 
  
end only;