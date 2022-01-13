library IEEE;
use IEEE.std_logic_1164.ALL;

entity calculation is
    port(screen_x     : in  std_logic_vector(8 downto 0); -- 0 -> 511
         screen_y     : in  std_logic_vector(7 downto 0); -- 0 -> 255, van 128 tot 256 is de track zichtbaar
         orientations : in  std_logic_vector(8 downto 0);
         player_x     : in  std_logic_vector(9 downto 0);
         player_y     : in  std_logic_vector(9 downto 0);
         sample_x     : out std_logic_vector(9 downto 0);
         sample_y     : out std_logic_vector(9 downto 0));
end calculation;

