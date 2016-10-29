library std;
library ieee;
use ieee.std_logic_1164.all;
package MemoryComponent is

type MemArray is array(0 to 127) of std_logic_vector(7 downto 0);

constant INIT_MEMORY : MemArray := (
  0 => "01011110",
  1 => "01000000",
  2 => "01000001",
  3 => "00010100",
  4 => "10000001",
  5 => "00010110",
  6 => "11000001",
  7 => "00011010",
  8 => "00000101",
  9 => "00011011",
  10 => "10000001",
  11 => "00010100",
  12 => "11011000",
  13 => "00000100",
  14 => "10011000",
  15 => "11000000",
  16 => "00000000",
  17 => "10011011",
  18 => "00000000",
  19 => "00000000",
  20 => "00000000",
  21 => "00000000",
  22 => "00000000",
  23 => "00000000",
  24 => "00000000",
  25 => "00000000",
  26 => "00000000",
  27 => "00000000",
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
  58 => "00000000",
  59 => "00000000",
  60 => "00010100",
  61 => "00000000",
  62 => "10101000",
  63 => "00000111",
  64 => "00000000",
  65 => "10000110",
  66 => "00000000",
  67 => "00000000",
  68 => "00000000",
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