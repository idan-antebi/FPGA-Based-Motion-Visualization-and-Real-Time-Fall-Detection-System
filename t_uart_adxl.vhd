 library    IEEE;
use IEEE.std_logic_1164.all  ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;

-- Test bench for spi_cc1101_read.


entity t_uart_adxl is
PORT (
   	   f38400		:	 OUT STD_LOGIC;
		system_loop_cmnd		:	 OUT STD_LOGIC;
		tx_bit		:	 OUT STD_LOGIC;
        rdaddress		:	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		dpr_rden		:	 OUT STD_LOGIC;
		q		:	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        state_cntr        : out std_logic_vector(3 downto 0)  
	                 );
end t_uart_adxl;

 architecture only of t_uart_adxl is
 
 
COMPONENT uart_adxl
	PORT
	(
		resetn		:	 IN STD_LOGIC;
		sysclk		:	 IN STD_LOGIC;
		sim_start_strobe		:	 IN STD_LOGIC;
		tx_address		:	 IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		tx_data		:	 IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		dpr_wren		:	 IN STD_LOGIC;
		f38400		:	 OUT STD_LOGIC;
		system_loop_cmnd		:	 OUT STD_LOGIC;
		tx_bit		:	 OUT STD_LOGIC;
        rdaddress		:	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		dpr_rden		:	 OUT STD_LOGIC;
		q		:	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        state_cntr        : out std_logic_vector(3 downto 0)
	);
END COMPONENT;

   signal sig_sysclk        :  STD_LOGIC   := '0';
   signal sig_resetn        :  STD_LOGIC   := '0';
   signal sig_start_strobe  :  STD_LOGIC   := '0';
   signal sig_baud_rate     :  STD_LOGIC   := '0';
   constant sig_q_8_bits_out : std_logic_vector( 7 downto 0 ) := X"CA" ;
   constant sig_hdr_q        : std_logic_vector( 7 downto 0 ) := X"83" ;
   constant sig_tx_address        : std_logic_vector( 3 downto 0 ) := X"A" ;
   constant sig_tx_data        : std_logic_vector( 7 downto 0 ) := X"83" ;
      
      
      
     
  
begin
 
  
   
  
  
  
   dut: uart_adxl
	PORT    MAP
	(
		resetn		            => sig_resetn,
	 	sysclk		            => sig_sysclk,
        
        sim_start_strobe		=> sig_start_strobe,
        
		tx_address		        => sig_tx_address,
		tx_data		            => sig_tx_data,
		dpr_wren		        => sig_start_strobe ,
        
		f38400		        => f38400,
		system_loop_cmnd	=> system_loop_cmnd,
		tx_bit		        => tx_bit,
        rdaddress		    => rdaddress,
		dpr_rden		    => dpr_rden,
		q		            => q,
        state_cntr          => state_cntr
 	);
   
     	 
 
 
 	  PROCESS
   begin
    wait for 10.0 ns; sig_sysclk       <= not sig_sysclk; -- 50.000mhz
end PROCESS ;

  
 
stimulus : PROCESS
   begin
   wait for 50 ns; sig_resetn  <= '0';
   wait for 40 ns; sig_resetn  <= '1';
   wait;
end PROCESS stimulus;
 
 

 	  PROCESS
   begin
     wait for 13000 ns; sig_baud_rate  <= not sig_baud_rate;  -- 38400Hz
    
end PROCESS; 

 
 
    start_strobe : PROCESS
    begin
    wait for 500 ns; sig_start_strobe  <= '0';
    wait for 500 ns; sig_start_strobe  <= '1';
    wait for 50000 ns; sig_start_strobe  <= '0';
    
     wait for 5000000 ns; sig_start_strobe  <= '1';
     wait for 50000 ns; sig_start_strobe  <= '0';
    
     wait for 1000000 ns; sig_start_strobe  <= '1';
     wait for 5000 ns; sig_start_strobe  <= '0';
    
    wait;
 end PROCESS start_strobe ;
 
 
  
end only;