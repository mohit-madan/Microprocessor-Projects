library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity Datapath is
  port (
    clk, reset: in std_logic;

    -- Data coming from outside
    external_r0: out std_logic_vector(15 downto 0);
    external_r1: out std_logic_vector(15 downto 0);
    external_r2: out std_logic_vector(15 downto 0);
    external_r3: out std_logic_vector(15 downto 0);
    external_r4: out std_logic_vector(15 downto 0);
    external_r5: out std_logic_vector(15 downto 0);
    external_r6: out std_logic_vector(15 downto 0)
  );
end entity;

architecture Mixed of Datapath is
  -- Constants
  signal CONST_0: std_logic_vector(15 downto 0) := (others => '0');
  signal CONST_1: std_logic_vector(15 downto 0) := (0 => '1', others => '0');
  signal CONST_32: std_logic_vector(15 downto 0) := (5 => '1', others => '0');

---------------------------------------------------
---------STAGE 1 - INSTRUCTION FETCH---------------
  signal PC_IN: std_logic_vector(15 downto 0);
  signal LSHIFT_PC_OUT: std_logic_vector(15 downto 0);
  signal PC_OUT: std_logic_vector(15 downto 0);
  signal PC_INCREMENT: std_logic_vector(15 downto 0);
  signal INST_MEMORY: std_logic_vector(15 downto 0);
---------------------------------------------------
  signal P1_IN: std_logic_vector(31 downto 0);
  signal P1_OUT: std_logic_vector(31 downto 0);

---------------------------------------------------
---------STAGE 2 - INSTRUCTION DECODE--------------
  signal INST_DECODE: std_logic_vector(DecodeSize-1 downto 0) := (others => '0');
---------------------------------------------------
  signal P2_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P2_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P2_DATA_IN: std_logic_vector(15 downto 0);
  signal P2_DATA_OUT: std_logic_vector(15 downto 0);

---------------------------------------------------
---------STAGE 3 - REGISTER READ-------------------
  signal DATA1: std_logic_vector(15 downto 0);
  signal DATA2: std_logic_vector(15 downto 0);
---------------------------------------------------
  signal P3_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P3_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P3_DATA_IN: std_logic_vector(47 downto 0);
  signal P3_DATA_OUT: std_logic_vector(47 downto 0);

---------------------------------------------------
---------STAGE 4 - EXECUTE STAGE-------------------
  signal ALU1_IN: std_logic_vector(15 downto 0);
  signal ALU2_IN: std_logic_vector(15 downto 0);
  signal ALU_OUT: std_logic_vector(15 downto 0);
  signal ALU_carry: std_logic;
  signal ALU_zero: std_logic;
---------------------------------------------------
  signal P4_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P4_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P4_DATA_IN: std_logic_vector(31 downto 0);
  signal P4_DATA_OUT: std_logic_vector(31 downto 0);
  signal P4_FLAG_IN: std_logic_vector(1 downto 0);
  signal P4_FLAG_OUT: std_logic_vector(1 downto 0);

---------------------------------------------------
---------STAGE 5 - MEMORY STAGE--------------------
  signal ADDRESS_IN: std_logic_vector(15 downto 0);
  signal LSHIFT_ADDRESS_IN: std_logic_vector(15 downto 0);
  signal MEMDATA_IN: std_logic_vector(15 downto 0);
  signal MEM_OUT: std_logic_vector(15 downto 0);
---------------------------------------------------
  signal P5_IN: std_logic_vector(DecodeSize-1 downto 0);
  signal P5_OUT: std_logic_vector(DecodeSize-1 downto 0);
  signal P5_DATA_IN: std_logic_vector(47 downto 0);
  signal P5_DATA_OUT: std_logic_vector(47 downto 0);
  signal P5_FLAG_IN: std_logic_vector(1 downto 0);
  signal P5_FLAG_OUT: std_logic_vector(1 downto 0);

---------------------------------------------------
---------STAGE 6 - WRITE STAGE---------------------
  signal R7_IN: std_logic_vector(15 downto 0);
  signal R7_OUT: std_logic_vector(15 downto 0);
  signal R7_WRITE: std_logic;
  signal WRITE3: std_logic_vector(2 downto 0);
  signal REGDATA_IN: std_logic_vector(15 downto 0);
  signal REGLOAD_zero: std_logic;
  signal reg_write: std_logic;

  signal CARRY_IN: std_logic_vector(0 downto 0);
  signal ZERO_IN: std_logic_vector(0 downto 0);
  signal CARRY: std_logic_vector(0 downto 0);
  signal ZERO: std_logic_vector(0 downto 0);

begin
---------------------------------------------------
---------STAGE 1 - INSTRUCTION FETCH---------------
  PC: DataRegister
      generic map (data_width => 16)
      port map (
        Din => PC_IN,
        Dout => PC_OUT,
        Enable => '1',
        clk => clk
      );
  INC: Increment
       port map (
         input => PC_OUT,
         output => PC_INCREMENT
       );
  IM: Memory
      port map (
        clk => clk,
        mem_write => '0',
        addr => LSHIFT_PC_OUT,
        data => CONST_0,
        mem_out => INST_MEMORY
      );
  LS: LeftShift
      port map (
        input => PC_OUT,
        output => LSHIFT_PC_OUT
      );

  PC_IN <= PC_INCREMENT when reset = '0' else (others => '0');

  P1_IN(15 downto 0) <= INST_MEMORY;
  P1_IN(31 downto 16) <= PC_IN;
----------------------------------------------------
  P1: DataRegister
      generic map (data_width => 32)
      port map (
        Din => P1_IN,
        Dout => P1_OUT,
        Enable => '1',
        clk => clk
      );

---------------------------------------------------
---------STAGE 2 - INSTRUCTION DECODE--------------
  ID: InstructionDecoder
      port map (
        instruction => P1_OUT(15 downto 0),
        output => INST_DECODE
      );
  P2_IN <= INST_DECODE;
  P2_DATA_IN <= P1_OUT(31 downto 16);
---------------------------------------------------
  P2: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P2_IN,
        Dout => P2_OUT,
        Enable => '1',
        clk => clk
      );
  P2_data: DataRegister
      generic map(data_width => 16)
      port map (
        Din => P2_DATA_IN,
        Dout => P2_DATA_OUT,
        Enable => '1',
        clk => clk
      );

---------------------------------------------------
---------STAGE 3 - REGISTER READ-------------------
  RF: RegisterFile
      port map (
        clk => clk,
        PC_in => R7_IN,
        PC_out => R7_OUT,
        PC_write => R7_WRITE,
        dout1 => DATA1,
        dout2 => DATA2,
        readA1 => P2_OUT(5 downto 3),
        readA2 => P2_OUT(2 downto 0),
        writeA3 => WRITE3,
        register_write => reg_write,
        din => REGDATA_IN,
        zero => REGLOAD_zero,
        external_r0 => external_r0,
        external_r1 => external_r1,
        external_r2 => external_r2,
        external_r3 => external_r3,
        external_r4 => external_r4,
        external_r5 => external_r5,
        external_r6 => external_r6
      );

  P3_IN <= P2_OUT;
  P3_DATA_IN(47 downto 32) <= P2_DATA_OUT(15 downto 0);
  P3_DATA_IN(31 downto 16) <= DATA1;
  P3_DATA_IN(15 downto 0) <= DATA2;
----------------------------------------------------
  P3: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P3_IN,
        Dout => P3_OUT,
        Enable => '1',
        clk => clk
      );
  P3_data: DataRegister
      generic map(data_width => 48)
      port map (
        Din => P3_DATA_IN,
        Dout => P3_DATA_OUT,
        Enable => '1',
        clk => clk
      );

---------------------------------------------------
---------STAGE 4 - EXECUTE STAGE-------------------
  ALU1_IN <= P3_DATA_OUT(31 downto 16);
  ALU2_IN <= P3_DATA_OUT(15 downto 0);
  AL: ALU
      port map (
        alu_in_1 => ALU1_IN,
        alu_in_2 => ALU2_IN,
        op_in => P3_OUT(6),
        alu_out => ALU_OUT,
        carry => ALU_carry,
        zero => ALU_zero
      );

  P4_IN <= P3_OUT;
  P4_DATA_IN(31 downto 16) <= P3_DATA_OUT(47 downto 32);
  P4_DATA_IN(15 downto 0) <= ALU_OUT;
  P4_FLAG_IN(1) <= ALU_carry;
  P4_FLAG_IN(0) <= ALU_zero;
----------------------------------------------------
  P4: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P4_IN,
        Dout => P4_OUT,
        Enable => '1',
        clk => clk
      );
  P4_data: DataRegister
      generic map(data_width => 32)
      port map (
        Din => P4_DATA_IN,
        Dout => P4_DATA_OUT,
        Enable => '1',
        clk => clk
      );
  P4_flag: DataRegister
      generic map(data_width => 2)
      port map (
        Din => P4_FLAG_IN,
        Dout => P4_FLAG_OUT,
        Enable => '1',
        clk => clk
      );

---------------------------------------------------
---------STAGE 5 - MEMORY STAGE--------------------
  ME: Memory
      port map (
        clk => clk,
        mem_write => P4_OUT(7),
        addr => LSHIFT_ADDRESS_IN,
        data => MEMDATA_IN,
        mem_out => MEM_OUT
      );
  LS2: LeftShift
      port map (
        input => ADDRESS_IN,
        output => LSHIFT_ADDRESS_IN
      );

  P5_IN <= P4_OUT;
  P5_DATA_IN(47 downto 32) <= P4_DATA_OUT(31 downto 16);
  P5_DATA_IN(31 downto 16) <= MEM_OUT;
  P5_DATA_IN(15 downto 0) <= P4_DATA_OUT(15 downto 0);
  P5_FLAG_IN(1) <= P4_FLAG_OUT(1);
  P5_FLAG_IN(0) <= P4_FLAG_OUT(0);
---------------------------------------------------
  P5: DataRegister
      generic map (data_width => DecodeSize)
      port map (
        Din => P5_IN,
        Dout => P5_OUT,
        Enable => '1',
        clk => clk
      );
  P5_data: DataRegister
      generic map(data_width => 48)
      port map (
        Din => P5_DATA_IN,
        Dout => P5_DATA_OUT,
        Enable => '1',
        clk => clk
      );
  P5_flag: DataRegister
      generic map(data_width => 2)
      port map (
        Din => P5_FLAG_IN,
        Dout => P5_FLAG_OUT,
        Enable => '1',
        clk => clk
      );

---------------------------------------------------
---------STAGE 6 - WRITE STAGE---------------------
-- Refer to Register File defined in stage 3
  R7_IN <= P5_DATA_OUT(47 downto 32);
  R7_WRITE <= '1' when P5_OUT(14) = '0' else '0';
  REGDATA_IN <= P5_DATA_OUT(15 downto 0);
  reg_write <= P5_OUT(8);
  WRITE3 <= P5_OUT(13 downto 11);

  CARRY_IN <= P5_FLAG_OUT(1 downto 1);
  ZERO_IN <= P5_FLAG_OUT(0 downto 0);

  CR: DataRegister
      generic map (data_width => 1)
      port map (
        Din => CARRY_IN,
        Dout => CARRY,
        Enable => P5_OUT(9),
        clk => clk
      );
  ZR: DataRegister
      generic map (data_width => 1)
      port map (
        Din => ZERO_IN,
        Dout => ZERO,
        Enable => P5_OUT(10),
        clk => clk
      );


end Mixed;