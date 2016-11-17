library std;
library ieee;
use ieee.std_logic_1164.all;
package MemoryComponent is

type MemArray is array(0 to 127) of std_logic_vector(7 downto 0);

constant INIT_MEMORY : MemArray := (
  0 => "00011110",
  1 => "00010010",
  2 => "00111110",
  3 => "01100000",
  4 => "11101000",
  5 => "00001000",
  6 => "01000010",
  7 => "00000010",
  8 => "10100000",
  9 => "00000110",
  10 => "01011000",
  11 => "00000100",
  12 => "00111110",
  13 => "01110000",
  14 => "10011101",
  15 => "01000001",
  16 => "00001000",
  17 => "00000000",
  18 => "01001010",
  19 => "00001011",
  20 => "10101000",
  21 => "00000011",
  22 => "11001011",
  23 => "00011101",
  24 => "10101000",
  25 => "00001101",
  26 => "10000000",
  27 => "11001101",
  28 => "00000000",
  29 => "00000000",
  30 => "00000000",
  31 => "00000000",
  32 => "00000000",
  33 => "00000000",
  34 => "00000000",
  35 => "00000000",
  36 => "00000000",
  37 => "00000000",
  38 => "00000000",
  39 => "00000000",
  40 => "00000000",
  41 => "00000000",
  42 => "00000000",
  43 => "00000000",
  44 => "00000000",
  45 => "00000000",
  46 => "00000000",
  47 => "00000000",
  48 => "00000000",
  49 => "00000000",
  50 => "00000000",
  51 => "00000000",
  52 => "00000000",
  53 => "00000000",
  54 => "00000000",
  55 => "00000000",
  56 => "00000000",
  57 => "00000000",
  58 => "11111111",
  59 => "01111111",
  60 => "00001011",
  61 => "00000000",
  62 => "00001100",
  63 => "00000000",
  64 => "00001101",
  65 => "00000000",
  66 => "00001110",
  67 => "00000000",
  68 => "00001111",
  69 => "00000000",
  70 => "00000000",
  71 => "00000000",
  72 => "00000000",
  73 => "00000000",
  74 => "00000000",
  75 => "00000000",
  76 => "00000000",
  77 => "00000000",
  78 => "00000000",
  79 => "00000000",
  80 => "00000000",
  81 => "00000000",
  82 => "00000000",
  83 => "00000000",
  84 => "00000000",
  85 => "00000000",
  86 => "00000000",
  87 => "00000000",
  88 => "00000000",
  89 => "00000000",
  90 => "00000000",
  91 => "00000000",
  92 => "00000000",
  93 => "00000000",
  94 => "00000000",
  95 => "00000000",
  96 => "00000000",
  97 => "00000000",
  98 => "00000000",
  99 => "00000000",
  100 => "00000000",
  101 => "00000000",
  102 => "00000000",
  103 => "00000000",
  104 => "00000000",
  105 => "00000000",
  106 => "00000000",
  107 => "00000000",
  108 => "00000000",
  109 => "00000000",
  110 => "00000000",
  111 => "00000000",
  112 => "00000000",
  113 => "00000000",
  114 => "00000000",
  115 => "00000000",
  116 => "00000000",
  117 => "00000000",
  118 => "00000000",
  119 => "00000000",
  120 => "00000000",
  121 => "00000000",
  122 => "00000000",
  123 => "00000000",
  124 => "00000000",
  125 => "00000000",
  126 => "00000000",
  127 => "00000000"
);

end MemoryComponent;
