 library    IEEE;
 use IEEE.std_logic_1164.all  ;
 USE ieee.std_logic_arith.all ;
 USE ieee.std_logic_unsigned.all ;		

  entity  top_final_project	
   is
          PORT ( 
			 
                 resetn               : IN  STD_LOGIC;  -- PIN B8 
                 sysclk               : IN  STD_LOGIC;  -- 50MHz  -- PIN N14
					  
			   --- ADXL345 I/O ----------------------------------------------------------------------------		  
					  
                 miso                 : IN  STD_LOGIC;  -- PIN V12        
                 cs_out               : OUT STD_LOGIC;  -- PIN AB16     
                 mosi_out             : OUT STD_LOGIC;  -- PIN V11 
         	     spi_clock_out        : OUT STD_LOGIC;  -- PIN AB15
					 -- INT1                 : IN  STD_LOGIC;  -- PIN Y14 
                 --interrupt_detected   : OUT STD_LOGIC;  -- PIN AA9
					 
				---  UART -------------------------------------------------------------------------------
				
                 uart_out       : OUT STD_LOGIC;  -- PIN AB11 
					  
				---  VGA -------------------------------------------------------------------------------	
				
					  HS	 	        : OUT STD_LOGIC;
		           VS		        : OUT STD_LOGIC;
					  VGA_R	        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		           VGA_G		     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		           VGA_B		     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
				
	
			   ---  7-segmet display ---------------------------------------------------------------
			  
			        seg_out0      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);	-- HEX0				
                 seg_out1      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);	-- HEX1
                 seg_out2      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);	-- HEX2
                 seg_out3      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);	-- HEX3
					  out_switch1   : IN  STD_LOGIC; -- SW0 -- PIN C10
					  out_switch2   : IN  STD_LOGIC;  -- SW1 -- PIN C11

				--- logic analyzer ---------------------------------------------------------------------
				
			        L_sclk        : OUT STD_LOGIC; -- PIN V7
			        L_mosi        : OUT STD_LOGIC; -- PIN W12
			        L_miso        : OUT STD_LOGIC; -- PIN V10
			        L_cs          : OUT STD_LOGIC  -- PIN W5
             
				 
					

					  
                  );
        END top_final_project	
; 
		
		
		
		
		architecture ab of top_final_project	
 is 
		
		
COMPONENT spi_adxl
	PORT
	(
		resetn		         :	 IN  STD_LOGIC;
		sysclk	            :	 IN  STD_LOGIC;
		start_state_machine  :	 IN  STD_LOGIC;
		ROM_data_in          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		cs		               :	 OUT STD_LOGIC;
		mosi		            :	 OUT STD_LOGIC;
		spi_clock	         :	 OUT STD_LOGIC;
		write_flag           :   OUT STD_LOGIC;
	   ROM_addr             :   OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
--		INT1                 :   IN  STD_LOGIC;         
--      interrupt_detected   :   OUT STD_LOGIC 
		

	);
END COMPONENT;
		

		
		
		
COMPONENT ROM_SPI
	PORT
	( 
		address		: IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
		clock		   : IN  STD_LOGIC;
		q		      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;
		
	
		
		
cOMPONENT starter_module_n
   PORT
	( 
      resetn              : IN  STD_LOGIC; -- 
      sysclk              : IN  STD_LOGIC; --  50Mhz
      system_loop_cmnd    : IN  STD_LOGIC; 
      start_tx_system	  : OUT STD_LOGIC  
	 );
END COMPONENT;



COMPONENT miso2vectors
	PORT
	(
      resetn            : IN  STD_LOGIC;
      sysclk            : IN  STD_LOGIC;
      cs                : IN  STD_LOGIC;
      sclk              : IN  STD_LOGIC;
      miso_in           : IN  STD_LOGIC;
      start_read        : IN  STD_LOGIC;
		start_ram         : OUT STD_LOGIC;
      X_vector_out      : OUT STD_LOGIC_VECTOR(15 downto 0);
      Y_vector_out      : OUT STD_LOGIC_VECTOR(15 downto 0);
		Z_vector_out      : OUT STD_LOGIC_VECTOR(15 downto 0);
		interrupt_vector  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;




COMPONENT vectors2ram
	PORT
	(
		resetn		      :	 IN  STD_LOGIC;
		sysclk		      :	 IN  STD_LOGIC;
		start_ram		   :	 IN  STD_LOGIC;
		X_vector		      :	 IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		Y_vector		      :	 IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		Z_vector		      :	 IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		interrupt_vector  :   IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		ram_address		   :	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		vector_to_ram		:	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		start_uart        :   OUT STD_LOGIC;
		write_enable      :   OUT STD_LOGIC
	);
END COMPONENT;






COMPONENT dpr_adxl
	PORT
	(
		clock		    : IN STD_LOGIC  := '1';
		data		    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		rden		    : IN STD_LOGIC  := '1';
		wraddress	 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		wren		    : IN STD_LOGIC  := '0';
		q		       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;







COMPONENT uart_adxl
   PORT 
	(  
      resetn            : IN   STD_LOGIC;
      sysclk            : IN   STD_LOGIC; --  50Mhz     	
      sim_start_strobe  : IN   STD_LOGIC;
	   tx_data           : IN   STD_LOGIC_VECTOR(7 downto 0);
      system_loop_cmnd  : OUT  STD_LOGIC;		  		 
		tx_bit            : OUT  STD_LOGIC;
	   rdaddress         : OUT  STD_LOGIC_VECTOR(3 downto 0);
      dpr_rden          : OUT  STD_LOGIC
	);
END COMPONENT;



COMPONENT pixel_clk
	PORT
	(
		resetn		    :	 IN STD_LOGIC;
		sysclk		    :	 IN STD_LOGIC;
		pixel_clock		 :	 OUT STD_LOGIC
	);
END COMPONENT;
	
	
	
COMPONENT video_sync_generator
	PORT
	(
		resetn		   :	 IN STD_LOGIC;
		sysclk		   :	 IN STD_LOGIC;
		pixel_clock		:	 IN STD_LOGIC;
		blank_n		   :	 OUT STD_LOGIC;
		HS		         :	 OUT STD_LOGIC;
		VS		         :	 OUT STD_LOGIC;
		v_cnt          :   OUT  STD_LOGIC_VECTOR(11 DOWNTO 0)
		
	);
END COMPONENT;


	
COMPONENT size_change
  PORT
   (   
	   resetn        : IN  STD_LOGIC;-- key0  -- pin B8
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
END COMPONENT;


COMPONENT lines
  PORT 
	( 
      resetn        : IN   STD_LOGIC;-- key0  -- pin B8
      sysclk        : IN   STD_LOGIC;-- 50Mhz -- pin N14
      pixel_clock   : IN   STD_LOGIC;-- 25MHz
      BLANK_n       : IN   STD_LOGIC;
		v_cnt         : IN   STD_LOGIC_VECTOR(11 DOWNTO 0); -- vertical position
	   v_min_x       : IN   INTEGER;
	   v_max_x       : IN   INTEGER;
	   v_min_y       : IN   INTEGER;
	   v_max_y       : IN   INTEGER;
		v_min_z       : IN   INTEGER;
		v_max_z       : IN   INTEGER;
      VGA_B         : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
      VGA_G         : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
      VGA_R         : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
   );   
END COMPONENT;




COMPONENT segmet_display
  PORT
	(
		sysclk		   :	 IN  STD_LOGIC;
		resetn		   :	 IN  STD_LOGIC;
		X_in		      :	 IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      Y_in           :   IN  STD_LOGIC_VECTOR(15 downto 0);
		Z_in           :   IN  STD_LOGIC_VECTOR(15 downto 0);
		out_switch1    :   IN  STD_LOGIC;
		out_switch2    :   IN  STD_LOGIC;
		
		seg_0		      :	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		seg_1		      :	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		seg_2		      :	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		seg_3		      :	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;


        --- UART signals ----------------------------------------
  
         signal sig_ram_address_r     :  STD_LOGIC_VECTOR(3 DOWNTO 0);
			signal sig_ram_address_w     :  STD_LOGIC_VECTOR(3 DOWNTO 0);
			signal sig_write_enable      :  STD_LOGIC;
			signal sig_vector_to_ram     :  STD_LOGIC_VECTOR(7 DOWNTO 0);
			signal sig_start_uart        :  STD_LOGIC;
			signal sig_start_ram         :  STD_LOGIC;
			signal sig_start_machine     :  STD_LOGIC;
			signal sig_read_enable       :  STD_LOGIC;
			signal sig_ram_out           :  STD_LOGIC_VECTOR(7 DOWNTO 0);
			signal sig_system_loop_cmnd  :  STD_LOGIC;
			signal sig_uart_out          :  STD_LOGIC;
			
        --- SPI signals ----------------------------------------
			
			signal sig_strob_spi         :  STD_LOGIC;
			signal sig_mosi              :  STD_LOGIC;
			signal sig_miso              :  STD_LOGIC;
			signal sig_spi_clock         :  STD_LOGIC;
			signal sig_cs                :  STD_LOGIC;
			signal sig_write_flag        :  STD_LOGIC;
			signal sig_ROM_addr          :  STD_LOGIC_VECTOR(5 DOWNTO 0);
         signal sig_ROM_data_out      :  STD_LOGIC_VECTOR(7 DOWNTO 0);
			signal sig_X                 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
			signal sig_Y                 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
		   signal sig_Z                 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
		   signal sig_interrupt         :  STD_LOGIC_VECTOR(15 DOWNTO 0);	
        
        --- VGA signals ----------------------------------------
		  
         signal  sig_blank_n        :  STD_LOGIC;
         signal  sig_pixel_clock    :  STD_LOGIC;
         signal  sig_v_cnt          :  STD_LOGIC_VECTOR( 11 DOWNTO 0 );
         signal  sig_v_min_x        :  INTEGER;
		   signal  sig_v_min_y        :  INTEGER;
	      signal  sig_v_min_z        :  INTEGER;
		   signal  sig_v_max_x        :  INTEGER;
		   signal  sig_v_max_y        :  INTEGER;
	      signal  sig_v_max_z        :  INTEGER;	
       
		 --- 7-segmet signals ----------------------------------------

			signal sig_seg_out0       :  STD_LOGIC_VECTOR(7 DOWNTO 0);
			signal sig_seg_out1       :  STD_LOGIC_VECTOR(7 DOWNTO 0);
			signal sig_seg_out2       :  STD_LOGIC_VECTOR(7 DOWNTO 0);
			signal sig_seg_out3       :  STD_LOGIC_VECTOR(7 DOWNTO 0);
         signal sig_out_switch1    :  STD_LOGIC;
			signal sig_out_switch2    :  STD_LOGIC; 			

    BEGIN 
	
	
 starter: starter_module_n  
	PORT  MAP
	 (
      resetn              => resetn,
      sysclk              => sysclk,
      system_loop_cmnd    => sig_system_loop_cmnd,
      start_tx_system		 => sig_strob_spi
	 );
	
	
	
 spi: spi_adxl
	PORT  MAP
	 (
		resetn		           => resetn,
		sysclk		           => sysclk,
		start_state_machine    => sig_strob_spi,
		ROM_data_in            => sig_ROM_data_out,
		ROM_addr               => sig_ROM_addr,
	   spi_clock              => sig_spi_clock,
	   mosi                   => sig_mosi,
      cs                     => sig_cs,
		write_flag             => sig_write_flag
--	   INT1                   => INT1,
--      interrupt_detected     => interrupt_detected
	 ); 
	
	
 ROM: ROM_SPI   
	PORT  MAP
	 (
		clock		              => sysclk,
      address                => sig_ROM_addr,
      q                      => sig_ROM_data_out
	 );
	
	
	
 miso_data_vectors : miso2vectors
	PORT  MAP
	 (
		resetn		           => resetn,
		sysclk		           => sysclk,
	   sclk                   => sig_spi_clock,
		miso_in                => sig_miso,
      cs                     => sig_cs,
		start_read             => sig_write_flag,
		X_vector_out           => sig_X,
      Y_vector_out           => sig_Y,
		Z_vector_out           => sig_Z,
		interrupt_vector       => sig_interrupt,
		start_ram              => sig_start_ram	
	 );

	
 ram_axis : vectors2ram
	PORT  MAP
	 (
		resetn		           => resetn,
		sysclk		           => sysclk,
		start_ram		        => sig_start_ram,
		X_vector		           => sig_X,
		Y_vector		           => sig_Y,
		Z_vector		           => sig_Z,
		interrupt_vector       => sig_interrupt,
		ram_address		        => sig_ram_address_w,
		vector_to_ram		     => sig_vector_to_ram,
		write_enable		     => sig_write_enable,
      start_uart             => sig_start_uart
	 );


	
	
RAM : dpr_adxl
	PORT  MAP
	 (
		wraddress		  =>  sig_ram_address_w, 
      rdaddress	     =>	sig_ram_address_r,	
		clock		        =>  sysclk,
		data		        =>  sig_vector_to_ram,
		rden		        =>  sig_read_enable,
		wren		        =>  sig_write_enable,
		q		           =>  sig_ram_out
	 );
	
	
	
	
UART : uart_adxl
   PORT MAP 
    (
	   resetn                => resetn,
      sysclk                => sysclk,
      sim_start_strobe      => sig_start_uart,          
		tx_data               => sig_ram_out,       
      system_loop_cmnd  	 => sig_system_loop_cmnd, 		 
		tx_bit                => sig_uart_out,
	   rdaddress             => sig_ram_address_r,
      dpr_rden              => sig_read_enable
	);
	
	
	
 pixel : pixel_clk
	PORT  MAP
    (
	   resetn		 => resetn,
		sysclk		 => sysclk,
		pixel_clock	 => sig_pixel_clock
	 );
	
	


 vid : video_sync_generator
	PORT  MAP
    (
		resetn		 => resetn,
		sysclk		 => sysclk,
		pixel_clock	 => sig_pixel_clock,
		blank_n		 => sig_blank_n,
		v_cnt        => sig_v_cnt,
		HS		       => HS,
		VS		       => VS
	 );
	


 lines_length : size_change
	PORT  MAP
	 (
		resetn		   => resetn,
		sysclk		   => sysclk,
		pixel_clock	   => sig_pixel_clock,
      X_in           => sig_X,
		Y_in           => sig_Y,
		Z_in           => sig_Z,
		v_min_X        => sig_v_min_x,
		v_max_x        => sig_v_max_x,
		v_min_y        => sig_v_min_y,
		v_max_y        => sig_v_max_y,
		v_min_z        => sig_v_min_z,
		v_max_z        => sig_v_max_z
	 );
	


 cnrl : lines
	PORT  MAP
	 (
		resetn		 => resetn,
		sysclk		 => sysclk,
		pixel_clock	 => sig_pixel_clock,
		BLANK_n		 => sig_blank_n,
      v_cnt        => sig_v_cnt,
		v_min_X      => sig_v_min_x,
		v_max_x      => sig_v_max_x,
		v_min_y      => sig_v_min_y,
		v_max_y      => sig_v_max_y,
		v_min_z      => sig_v_min_z,
		v_max_z      => sig_v_max_z,
		VGA_B		    => VGA_B,
		VGA_G		    => VGA_G,
		VGA_R		    => VGA_R
	 );	
	 
	 
	 

	 
 segmaet: segmet_display
	PORT  MAP
	(
	
	   sysclk		   =>   sysclk, 
		resetn		   =>   resetn,
		X_in		      =>   sig_X,
		Y_in           =>   sig_Y,
		z_in           =>   sig_Z,
		out_switch1    =>   sig_out_switch1,
		out_switch2    =>   sig_out_switch2,
		seg_0		      =>   sig_seg_out0,
		seg_1		      =>   sig_seg_out1,
		seg_2		      =>   sig_seg_out2,
		seg_3		      =>   sig_seg_out3
	);
	
	
	--- for logic analyzer --------------
	
   L_sclk           <= sig_spi_clock;
   L_mosi           <= sig_mosi;
   L_miso           <= miso;
   L_cs             <= sig_cs;
	
	
	
	--- for ADXL345 ---------------
	
   cs_out           <=  sig_cs;              
   mosi_out         <=  sig_mosi;        
   spi_clock_out    <=  sig_spi_clock;      
		
	--- from ADXL345 -------------------	
	
	sig_miso         <= miso;
	
   --- for UART -------------------
	
	uart_out         <= sig_uart_out;
	
	
---- for 7-SEGMET ------------------------
 
	seg_out0          <= sig_seg_out0;
	seg_out1          <= sig_seg_out1;
	seg_out2          <= sig_seg_out2;
	seg_out3          <= sig_seg_out3;
	sig_out_switch1   <= out_switch1;
	sig_out_switch2   <= out_switch2;
	
	
	
	
	
	
	
	
	
	
	end ab;