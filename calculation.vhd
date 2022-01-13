library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Welcome to the behavioral description of the calculation module. 
-- This module receives a coordinate from a pixel the vga module would like to colour in plus the position and orientation of the player. 
-- This module finds a suiting position on the map and sends the coordinate of this position to the rom module, where the colours are stored. 
-- The algorithm used in this module was inspired by javidx9 on YouTube or OneLoneCoder on GitHub. His code can be found here: ¨https://github.com/OneLoneCoder/videos/blob/master/OneLoneCoder_Pseudo3DPlanesMode7.cpp¨.
-- The code found there was however (very) heavily modified and simplified to be synthesizable and fit in the allocated space.
-- This module was written by Anne Hinrichs, Robbert Bithray and Julia Overbeek.

architecture behavioral of calculation is
    signal x       : unsigned(8 downto 0);
    signal y       : unsigned(7 downto 0);
    signal playerx : unsigned(9 downto 0);
    signal playery : unsigned(9 downto 0);

    signal samplex : unsigned(9 downto 0);
    signal sampley : unsigned(9 downto 0);

    type t_divition_lut is array (0 to 2 ** 7 - 1) of unsigned(9 downto 0);
    constant C_DIV_LUT : t_divition_lut := ("1111111111", "1111111111", "0111111111", "0101010101", "0011111111", "0011001100", "0010101010", "0010010010", "0001111111", "0001110001", "0001100110", "0001011101", "0001010101", "0001001110", "0001001001", "0001000100", "0000111111", "0000111100", "0000111000", "0000110101", "0000110011", "0000110000", "0000101110", "0000101100", "0000101010", "0000101000", "0000100111", "0000100101", "0000100100", "0000100011", "0000100010", "0000100001", "0000011111", "0000011111", "0000011110", "0000011101", "0000011100", "0000011011", "0000011010", "0000011010", "0000011001", "0000011000", "0000011000", "0000010111", "0000010111", "0000010110", "0000010110", "0000010101", "0000010101", "0000010100", "0000010100", "0000010100", "0000010011", "0000010011", "0000010010", "0000010010", "0000010010", "0000010001", "0000010001", "0000010001", "0000010001", "0000010000", "0000010000", "0000010000", "0000001111", "0000001111", "0000001111", "0000001111", "0000001111", "0000001110", "0000001110", "0000001110", "0000001110", "0000001110", "0000001101", "0000001101", "0000001101", "0000001101", "0000001101", "0000001100", "0000001100", "0000001100", "0000001100", "0000001100", "0000001100", "0000001100", "0000001011", "0000001011", "0000001011", "0000001011", "0000001011", "0000001011", "0000001011", "0000001011", "0000001010", "0000001010", "0000001010", "0000001010", "0000001010", "0000001010", "0000001010", "0000001010", "0000001010", "0000001001", "0000001001", "0000001001", "0000001001", "0000001001", "0000001001", "0000001001", "0000001001", "0000001001", "0000001001", "0000001001", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000", "0000001000");
    
    type t_cossin_lut is array (0 to 2 ** 7 - 1) of unsigned(6 downto 0);
   constant COS : t_cossin_lut := ("1111111", "1111110", "1111110", "1111110", "1111110", "1111110", "1111110", "1111110", "1111101", "1111101", "1111101", "1111100", "1111100", "1111011", "1111011", "1111010", "1111010", "1111001", "1111000", "1111000", "1110111", "1110110", "1110101", "1110100", "1110100", "1110011", "1110010", "1110001", "1110000", "1101111", "1101101", "1101100", "1101011", "1101010", "1101001", "1101000", "1100110", "1100101", "1100100", "1100010", "1100001", "1011111", "1011110", "1011100", "1011011", "1011001", "1011000", "1010110", "1010100", "1010011", "1010001", "1001111", "1001110", "1001100", "1001010", "1001000", "1000111", "1000101", "1000011", "1000001", "0111111", "0111101", "0111011", "0111001", "0110111", "0110101", "0110011", "0110001", "0101111", "0101101", "0101011", "0101001", "0100111", "0100101", "0100011", "0100000", "0011110", "0011100", "0011010", "0011000", "0010110", "0010011", "0010001", "0001111", "0001101", "0001011", "0001000", "0000110", "0000100", "0000010", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000", "0000000");
    constant SIN : t_cossin_lut := ("0000000", "0000010", "0000100", "0000110", "0001000", "0001011", "0001101", "0001111", "0010001", "0010011", "0010110", "0011000", "0011010", "0011100", "0011110", "0100000", "0100011", "0100101", "0100111", "0101001", "0101011", "0101101", "0101111", "0110001", "0110011", "0110101", "0110111", "0111001", "0111011", "0111101", "0111111", "1000001", "1000011", "1000101", "1000111", "1001000", "1001010", "1001100", "1001110", "1001111", "1010001", "1010011", "1010100", "1010110", "1011000", "1011001", "1011011", "1011100", "1011110", "1011111", "1100001", "1100010", "1100100", "1100101", "1100110", "1101000", "1101001", "1101010", "1101011", "1101100", "1101101", "1101111", "1110000", "1110001", "1110010", "1110011", "1110100", "1110100", "1110101", "1110110", "1110111", "1111000", "1111000", "1111001", "1111010", "1111010", "1111011", "1111011", "1111100", "1111100", "1111101", "1111101", "1111101", "1111110", "1111110", "1111110", "1111110", "1111110", "1111110", "1111110", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111", "1111111");
    
begin
    x       <= unsigned(screen_x);
    y       <= unsigned(screen_y);
    playerx <= unsigned(player_x);
    playery <= unsigned(player_y);

    process(player_angle, playerx, playery, x, y)

        variable loxroy : signed(7 downto 0);
        variable roxloy : signed(7 downto 0);
        variable rbxlby : signed(7 downto 0);
        variable lbxrby : signed(7 downto 0);

        variable xboundleft  : signed(17 downto 0);
        variable xboundright : signed(17 downto 0);
        variable yboundlow   : signed(17 downto 0);
        variable yboundhigh  : signed(17 downto 0);

        variable sampleWidth : unsigned(8 downto 0);

        variable samplexVar : signed(26 downto 0);
        variable sampleyVar : signed(26 downto 0);

        variable divide : unsigned(9 downto 0);
        variable yvar   : unsigned(7 downto 0);
        
        variable sinplus : signed(7 downto 0);
        variable usinplus : unsigned(7 downto 0);
        variable cosplus : signed(7 downto 0);
        variable ucosplus : unsigned(7 downto 0);
        
        variable playerangle : unsigned(8 downto 0);
        variable angle : unsigned(8 downto 0);
        variable anglemod : unsigned(8 downto 0);

    begin
        if (y > to_unsigned(127, screen_y'length)) then
            -- The pixel to be coloured is in the bottom half of the screen
            -- Translate y-value to be able to use yvar from 0 -> 128
            yvar := y - 128;
            -- Remap the player angle from -180 -> 180 to 0 -> 360
            if (signed(player_angle) < 0) then
                playerangle := unsigned(signed(player_angle) + 360);
            else
                playerangle := unsigned(player_angle);
            end if;
            -- Add half the fov-angle (90 degrees) to the playerangle
            angle := playerangle + 45;
            
            -- Check if angle is bigger than 360. If it is, subtract 360. Angle has a maximum of 511, 
            -- making it overflow automatically and preventing errors with values bigger than 640.
            if (angle > "101101000") then
                anglemod := angle - "101101000";
            else
                anglemod := angle;
            end if;
            
            -- Choose different values for sine and cosine from the lookup table.
            -- It goes from 0 to 90 degrees for both functions so we have to invert the index and/or the sign depending on the region
            if (anglemod < 90) then
                usinplus := "0" & SIN(to_integer(anglemod));
                sinplus := signed(usinplus);
                ucosplus := "0" & COS(to_integer(anglemod));
                cosplus := signed(ucosplus);
            elsif (anglemod < 180) then
                usinplus := "0" & SIN(to_integer(to_unsigned(90, 9) - anglemod));
                sinplus := signed(usinplus);
                ucosplus := "0" & COS(to_integer(to_unsigned(90, 9) - anglemod));
                cosplus := -signed(ucosplus);
            elsif (anglemod < 270) then
                usinplus := "0" & SIN(to_integer(anglemod));
                sinplus := -signed(usinplus);
                ucosplus := "0" & COS(to_integer(anglemod));
                sinplus := -signed(ucosplus);
            else
                usinplus := "0" & SIN(to_integer(to_unsigned(90, 9) - anglemod));
                sinplus := -signed(usinplus);
                ucosplus := "0" & COS(to_integer(to_unsigned(90, 9) - anglemod));
                cosplus := signed(ucosplus);
            end if;

            -- Some x and y values being the same, we only need 4 instead of 8 variables to describe the field of view.
            -- The values are shifted right to correct for the sin(x)*128 content of the luts (so 7 right) but then
            -- shifted left to create a better looking field of view. The top two are shifted left by 7-1=6 to create 
            -- a multiplication by two, the bottom one is shifted left by 4 less to create a factor of 16.
            loxroy := shift_right(cosplus, 6)(7 downto 0);
            roxloy := shift_right(sinplus, 6)(7 downto 0);
            rbxlby := shift_right(cosplus, 3)(7 downto 0);
            lbxrby := shift_right(sinplus, 3)(7 downto 0);
            
            -- The divide variable is to avoid the costly computation of dividing four times. Instead it only 
            -- needs to fetch one value from the lut per pixel. Once the value exeeds the range of the lut, 
            -- the real division does barely differ from one, allowing us to let the value to 1 without problem.
            if (yvar + 1 > 127) then
                divide := "0000000001";
            else
                divide := C_DIV_LUT(to_integer(yvar + 1));
            end if;

            -- The following varables calculate the region to be sampled from and do so non-linearly.
            -- This makes sure the samples for the bottom of the screen are close together from the map, 
            -- creating a pseudo-3D effect.
            -- The same trick as before is applied, the result of the calculation inside the shift_right function is
            -- the correct value * 1024 but it also needs to be multiplied by 128 (so 10-7=3) to stay away from floating point numbers.
            -- (Just like in the three luts.) These values have to stay scaled by 128 until their use in samplexVar and sampleyVar.
            -- The divide value calculated previously depending on y only and the scale of 128 arent incidental. The original division
            -- in the bounds was based on a sampleDepth variable, being equal to scale*y/(screenheight/2). Because the screenheight was
            -- chosen to be 256, with a scale of 128 we can avoid this calculation. 
            --              7u -> 8s         8s           10u -> 11s
            xboundleft  := shift_right((lbxrby - loxroy) * signed(divide), 3) + loxroy;
            xboundright := shift_right((rbxlby - roxloy) * signed(divide), 3) + roxloy;
            yboundlow   := shift_right((-rbxlby - roxloy) * signed(divide), 3) + roxloy;
            yboundhigh  := shift_right((lbxrby + loxroy) * signed(divide), 3) - loxroy;

            -- This variable is to correct the sampling in the x-direction, the same trick as before applies, by carefully chosing the
            -- screensize a division and multiplication can be implemented as a bitshift.
            -- 128*x/512 -> 1/4
            sampleWidth := shift_right(x, 2);

            -- These values calculate the final coordinates to be sampled at. They do this by interpolating between the bounds and
            -- coming up with the best map positions to sample at.
            samplexVar := shift_right((xboundright - xboundleft) * signed(sampleWidth), 7) + xboundleft + signed(playerx);
            sampleyVar := shift_right((yboundhigh - yboundlow) * signed(sampleWidth), 7) + yboundlow + signed(playery);

            -- As samplexVar and sampleyVar can be very large and even result in values bigger than the map, only the part
            -- of the bit vector on the map has to be looked at.
            samplex <= unsigned(samplexVar(9 downto 0));
            sampley <= unsigned(sampleyVar(9 downto 0));

        else

            samplex  <= (others => '0');
            sampley  <= (others => '0');
            
        end if;
    end process;

    sample_x <= std_logic_vector(samplex);
    sample_y <= std_logic_vector(sampley);

end architecture behavioral;
