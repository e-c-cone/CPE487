LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY froggie IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC;
		up        : IN STD_LOGIC;
		down      : IN STD_LOGIC;
	    left      : IN STD_LOGIC;
	    right     : IN STD_LOGIC		
	);
END froggie;

ARCHITECTURE Behavioral OF froggie IS
 -- signals and variables for frog
	CONSTANT size  : INTEGER := 8;
	SIGNAL frog_on : STD_LOGIC; -- indicates whether frog is over current pixel position
	-- current frog position - intitialized to center of screen
	SIGNAL frog_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL frog_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(580, 11);
	-- current frog motion - initialized to +4 pixels/frame
	SIGNAL frog_hop : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	SIGNAL direction  : INTEGER := 8;
-- signals and variables for cars
    CONSTANT car_size  : INTEGER := 10;
	SIGNAL car1_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current car motion - initialized to +3 pixels/frame
	SIGNAL car1_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000011";
	-- car 2 -
	SIGNAL car2_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(340, 11);
	-- current car motion - initialized to +4 pixels/frame
	SIGNAL car2_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	-- car 2 -
	SIGNAL car3_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(260, 11);
	-- current car motion - initialized to +5 pixels/frame
	SIGNAL car3_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000101";	
		
BEGIN
	red <= car1_on OR (car2_on) OR car3_on;
	green <= frog_on;
	blue  <= NOT frog_on;

	-- process to draw frog current pixel address is covered by frog position
	fdraw : PROCESS (frog_x, frog_y, pixel_row, pixel_col) IS
	BEGIN
		IF (pixel_col >= frog_x - size) AND
		   (pixel_col <= frog_x + size) AND
		   (pixel_row >= frog_y - size) AND
	  	   (pixel_row <= frog_y + size) THEN
			frog_on <= '1';
		ELSE
			frog_on <= '0';
		END IF;
		END PROCESS;
		
	-- process to move frog once every frame (i.e. once every vsync pulse)
	mfrog : PROCESS
	BEGIN
	   WAIT UNTIL rising_edge(v_sync);
	   IF up = '1' THEN
	       direction <= 1;
	   ELSIF down = '1' THEN
	       direction <= 2;
	   ELSIF left = '1' THEN
	       direction <= 3;
	   ELSIF right = '1' THEN
	       direction <= 4;
	   ELSE
	       direction <= 0;
	   END IF;
	   
	   IF direction = 1 THEN
	       frog_y <= frog_y - frog_hop;
	   ELSIF direction = 2 THEN
	       frog_y <= frog_y + frog_hop;
	   ELSIF direction = 3 THEN
	       frog_x <= frog_x - frog_hop;
	   ELSIF direction = 4 THEN
	       frog_x <= frog_x + frog_hop;
	   ELSIF direction = 0 THEN
	       frog_x <= frog_x;  
	   END IF;  
	   --- collision detection for car1, 2 and 3
	   IF ((frog_x >= car1_x - 15 AND frog_x <= car1_x + 15) 
       AND (frog_y >= car1_y - 15 AND frog_y <= car1_y + 15)) OR 
       ((frog_x >= car2_x - 15 AND frog_x <= car2_x + 15) 
       AND (frog_y >= car2_y - 15 AND frog_y <= car2_y + 15)) OR
       ((frog_x >= car3_x - 15 AND frog_x <= car3_x + 15) 
       AND (frog_y >= car3_y - 15 AND frog_y <= car3_y + 15))
       THEN
           frog_x <= CONV_STD_LOGIC_VECTOR(400, 11);
           frog_y <= CONV_STD_LOGIC_VECTOR(580, 11); 
       END IF;
	   END PROCESS;
	
	--process to draw cars
	c1draw : PROCESS (car1_x, car1_y, pixel_row, pixel_col) IS
	BEGIN
		IF (pixel_col >= car1_x - size) AND
		 (pixel_col <= car1_x + size) AND
			 (pixel_row >= car1_y - size) AND
			 (pixel_row <= car1_y + size) THEN
				car1_on <= '1';
		ELSE
			car1_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car1 once every frame (i.e. once every vsync pulse)
		mcar1 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car1_x + size >= 800 THEN
				car1_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car1_x <= size THEN
				car1_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car1_x <= car1_x + car1_x_motion; -- compute next car1 position
		END PROCESS;
		
		c2draw : PROCESS (car2_x, car2_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car2_x - size) AND
		 (pixel_col <= car2_x + size) AND
			 (pixel_row >= car2_y - size) AND
			 (pixel_row <= car2_y + size) THEN
				car2_on <= '1';
		ELSE
			car2_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car2 once every frame (i.e. once every vsync pulse)
		mcar2 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car2_x + size >= 800 THEN
				car2_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car2_x <= size THEN
				car2_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car2_x <= car2_x + car2_x_motion; -- compute next car2 position
		END PROCESS;
		c3draw : PROCESS (car3_x, car3_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car3_x - size) AND
		 (pixel_col <= car3_x + size) AND
			 (pixel_row >= car3_y - size) AND
			 (pixel_row <= car3_y + size) THEN
				car3_on <= '1';
		ELSE
			car3_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car3 once every frame (i.e. once every vsync pulse)
		mcar3 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car3_x + size >= 800 THEN
				car3_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car3_x <= size THEN
				car3_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car3_x <= car3_x + car3_x_motion; -- compute next car3 position
		END PROCESS;
END Behavioral;

