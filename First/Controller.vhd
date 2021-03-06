library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity Controller is
  port (
    -- Instruction Register write
    inst_write: out std_logic;

    -- Program counter write / select
    pc_write: out std_logic;
    pc_in_select: out std_logic_vector(2 downto 0);

    -- Select the two ALU inputs / op_code
    alu_op: out std_logic;
    alu_op_select: out std_logic;
    alu1_select: out std_logic_vector(2 downto 0);
    alu2_select: out std_logic_vector(2 downto 0);
    alureg_write: out std_logic;

    -- Select the correct inputs to memory
    addr_select: out std_logic_vector(1 downto 0);
    mem_write: out std_logic;
    memreg_write: out std_logic;

    -- Choices for Register file
    regread2_select: out std_logic;
    regdata_select: out std_logic_vector(1 downto 0);
    regwrite_select: out std_logic_vector(1 downto 0);
    reg_write: out std_logic;
    t1_write, t2_write: out std_logic;

    -- Control signals which decide whether or not to set carry flag
    set_carry, set_zero: out std_logic;
    -- Decide where to take carry_enable input from. If zero, set_carry
    -- is taken. Otherwise, IR gives these signals.
    carry_enable_select, zero_enable_select: out std_logic;

    -- Choice between input register and feedback
    pl_select: out std_logic;

    -- Active signal, if high ADC / ADZ / NDC / NDZ executed
    active: in std_logic;

    -- Returns whether priority loop input is zero or not
    plinput_zero: in std_logic;

    -- Used to transition from S2
    inst_type: in OperationCode;

    -- choice for input into zero flag
    zero_select: out std_logic;

    -- zero flag which is useful for BEQ control
    zero_flag: in std_logic;

    -- Tells you whether PC will be updated in this instruction
    pc_updated: in std_logic;

    -- clock and reset pins, if reset is high, external memory signals
    -- active.
    clk, reset: in std_logic
  );
end entity;
architecture Struct of Controller is
  type FsmState is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11,
                    S12, S13, S14, S15, S16, S17, S18, S19, end_state);
  signal state: FsmState;
begin

  -- Next state process
  process(clk, state, reset, active, inst_type, plinput_zero, zero_flag, pc_updated)
    variable nstate: FsmState;
  begin
    nstate := S0;
    case state is
      when S0 =>  -- First state whenever the code is loaded
        nstate := S1;
      when S1 =>  -- Always the first state of every instruction.
        nstate := S2;
      when S2 =>  -- Common Second state of all instructions
        if inst_type = R_TYPE and active = '1' then
          nstate := S3;
        elsif inst_type = LW or inst_type = SW then
          nstate := S5;
        elsif inst_type = ADI then
          nstate := S9;
        elsif inst_type = LHI then
          nstate := S11;
        elsif inst_type = BEQ then
          nstate := S12;
        elsif inst_type = JLR or inst_type = JAL then
          nstate := S13;
        elsif inst_type = LM then
          nstate := S16;
        elsif inst_type = SM then
          nstate := S18;
        else
          nstate := end_state;
        end if;
      when S3 =>  -- For ALU operations: ADD,ADC,ADZ,NDU,NDZ,NDC
        nstate := S4;
      when S4 =>  -- For ADZ,ADC,NDC,NDZ
        if pc_updated = '1' then    --pc already updated hence go to S1.
          nstate := S1;
        else                        --pc has to be updated in end state
          nstate := end_state;
        end if;
      when S5 =>  -- For LW,SW
        if inst_type = LW then
          nstate := S6;
        elsif inst_type = SW then
          nstate := S8;
        else
          nstate := end_state;
        end if;
      when S6 =>  -- For LW
          nstate := S7;
      when S7 =>  -- For LW
        if pc_updated = '1' then
          nstate := S1;
        else
          nstate := end_state;
        end if;
      when S8 =>  -- For SW
        if pc_updated = '1' then
          nstate := S1;
        else
          nstate := end_state;
        end if;
      when S9 =>  -- For ADI
          nstate := S10;
      when S10 => --For ADI
        if pc_updated = '1' then
          nstate := S1;
        else
          nstate := end_state;
        end if;
      when S11 => -- For LHI
        if pc_updated = '1' then
          nstate := S1;
        else
          nstate := end_state;
        end if;
      when S12 => -- For BEQ
        if zero_flag = '1' then
          nstate := S1;             -- pc already updated hence go to S1
        else
          nstate := end_state;      -- pc not updated hence go to end state
        end if;
      when S13 => -- For JAL and JLR
        if inst_type = JLR then
          nstate := S14;
        elsif inst_type = JAL then
          nstate := S15;
        else
          nstate := end_state;
        end if;
      when S14 =>-- For JLR
        if pc_updated = '1' then
          nstate := S1;
        else
          nstate := end_state;
        end if;
      when S15 => -- For JAL
        if pc_updated = '1' then
          nstate := S1;
        else
          nstate := end_state;
        end if;
      when S16 => -- For LM
        -- In this case, all 8 bits are zero
        if plinput_zero = '1' then          -- no bit is set for any reg
          nstate := end_state;
        else                                -- at least one bit is set
          nstate := S17;
        end if;
      when S17 => -- For LM
        if plinput_zero = '1' and pc_updated = '1' then -- no bit is set for any reg and pc updated
          nstate := S1;
        elsif plinput_zero = '1' and pc_updated = '0' then -- no bit is set for any reg and pc not updated
          nstate := end_state;
        else                                -- at least one bit is still set
          nstate := S17;
        end if;
      when S18 => -- For SM
        -- In this case, all 8 bits are zero
        if plinput_zero = '1' then          -- no bit is set for any reg
          nstate := end_state;
        else                                -- at least one bit is set
          nstate := S19;
        end if;
      when S19 => -- For SM
        -- In this case, all 8 bits are zero
        if plinput_zero = '1' and pc_updated = '1' then -- no bit is set for any reg and pc updated
          nstate := S1;
        elsif plinput_zero = '1' and pc_updated = '0' then -- no bit is set for any reg and pc not updated
          nstate := end_state;
        else                                -- at least one bit is still set
          nstate := S19;
        end if;
      when end_state =>
        nstate := S1;
    end case;

    if(clk'event and clk = '1') then
      if(reset = '1') then
        state <= S0;
      else
        state <= nstate;
      end if;
    end if;
  end process;

  -- Control Signal process
  process(state, zero_flag, plinput_zero, reset)
    variable n_inst_write: std_logic;
    variable n_pc_write: std_logic;
    variable n_pc_in_select: std_logic_vector(2 downto 0);
    variable n_alu_op: std_logic;
    variable n_alu_op_select: std_logic;
    variable n_alu1_select: std_logic_vector(2 downto 0);
    variable n_alu2_select: std_logic_vector(2 downto 0);
    variable n_alureg_write: std_logic;
    variable n_addr_select: std_logic_vector(1 downto 0);
    variable n_mem_write: std_logic;
    variable n_memreg_write: std_logic;
    variable n_regread2_select: std_logic;
    variable n_regdata_select: std_logic_vector(1 downto 0);
    variable n_regwrite_select: std_logic_vector(1 downto 0);
    variable n_reg_write: std_logic;
    variable n_t1_write: std_logic;
    variable n_t2_write: std_logic;
    variable n_set_carry: std_logic;
    variable n_set_zero: std_logic;
    variable n_carry_enable_select: std_logic;
    variable n_zero_enable_select: std_logic;
    variable n_pl_select: std_logic;
    variable n_zero_select: std_logic;
  begin
    n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "000";
    n_alu_op := '0';
    n_alu_op_select := '0';
    n_alu1_select := "000";
    n_alu2_select := "000";
    n_alureg_write := '0';
    n_addr_select := "00";
    n_mem_write := '0';
    n_memreg_write := '0';
    n_regread2_select := '0';
    n_regdata_select := "00";
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
    n_t2_write := '0';
    n_set_carry := '0';
    n_set_zero := '0';
    n_carry_enable_select := '0';
    n_zero_enable_select := '0';
    n_pl_select := '0';
    n_zero_select := '0';

    case state is
      when S0 =>
      -- First state whenever the code is loaded
      -- Sets PC to 0
        n_pc_write := '1';
      -- default
        n_inst_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S1 =>
      -- Always the first state of every instruction.
      -- Fetches the instruction
        n_addr_select := "00";
        n_inst_write := '1';
      -- default
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S2 =>
      -- Common Second state of all instructions
      -- For S2:
        n_t1_write := '1';
        n_t2_write := '1';
        n_alu1_select := "000";
        n_alu2_select := "010";
        n_alureg_write := '1';
        n_pl_select := '1';
        n_regread2_select := '0';
      --default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_zero_select := '0';
      when S3 =>
      -- For ALU operations: ADD,ADC,ADZ,NDU,NDZ,NDC
        n_alu_op_select := '1';
        n_alu1_select := "001";
        n_alu2_select := "001";
        n_alureg_write := '1';
        n_carry_enable_select := '1';
        n_zero_enable_select := '1';
      -- default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S4 =>
      -- For ADZ,ADC,NDC,NDZ
        n_reg_write := '1';
        n_regwrite_select := "00";
      -- default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S5 =>
      -- For LW,SW
        n_alu1_select := "001";
        n_alu2_select := "010";
        n_alureg_write := '1';
        n_carry_enable_select := '1';
        n_zero_enable_select := '1';
      -- default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S6 =>
      -- For LW
        n_addr_select := "01";
        n_memreg_write := '1';
      -- default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_mem_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S7 =>
      -- For LW
        n_regdata_select := "01";
        n_regwrite_select := "01";
        n_reg_write := '1';
        n_zero_select := '1';
      --default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '1';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
      when S8 =>
      -- For SW
        n_addr_select := "01";
        n_mem_write := '1';
      --default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S9 =>
      -- For ADI
        n_alu1_select := "011";
        n_alu2_select := "001";
        n_alureg_write := '1';
        n_carry_enable_select := '1';
        n_zero_enable_select := '1';
      -- default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S10 =>
      --For ADI
        n_regdata_select := "00";
        n_regwrite_select := "10";
        n_reg_write := '1';
      -- default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S11 =>
      -- For LHI
        n_regdata_select := "10";
        n_regwrite_select := "01";
        n_reg_write := '1';
      --Default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S12 =>
      -- For BEQ
        n_alu1_select := "001";
        n_alu2_select := "101";
        n_alureg_write := '1';
        if(zero_flag = '1') then
          n_pc_in_select := "100";
          n_pc_write := '1';
        else
          n_pc_in_select := "000";
          n_pc_write := '0';
        end if;
      --default
        n_inst_write := '0';
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S13 =>
      --For JLR and JAL
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '1';
      --Default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S14 =>
      --For JLR
        n_pc_write := '1';
        n_pc_in_select := "010";
        n_regdata_select := "00";
        n_regwrite_select := "01";
        n_reg_write := '1';
      -- default
        n_inst_write := '0';
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alu1_select := "000";
        n_alu2_select := "000";
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S15 =>
      --For JAL
        n_pc_write := '1';
        n_pc_in_select := "001";
        n_alu1_select := "000";
        n_alu2_select := "011";
        n_regdata_select := "00";
        n_regwrite_select := "01";
        n_reg_write := '1';
      --Default
        n_inst_write := '0';
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S16 =>
      --For LM
        n_alu1_select := "101";
        n_alu2_select := "001";
        n_alureg_write := '1';
        n_addr_select := "11";
        n_memreg_write := '1';
        n_pl_select := '1';
      --default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_mem_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_zero_select := '0';
      when S17 =>
      --For LM:
        n_alu1_select := "010";
        n_alu2_select := "000";
        n_alureg_write := '1';
        n_addr_select := "01";
        n_memreg_write := '1';
        n_regdata_select := "01";
        n_regwrite_select := "11";
        if plinput_zero = '1' then
          n_reg_write := '0';
        else
          n_reg_write := '1';
        end if;
      --default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_mem_write := '0';
        n_regread2_select := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
      when S18 =>
      --For SM
        n_alu1_select := "100";
        n_alu2_select := "001";
        n_alureg_write := '1';
        n_regread2_select := '1';
        n_t2_write := '1';
        n_pl_select := '0';
      --Default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_zero_select := '0';
      when S19 =>
      -- For SM
        n_alu1_select := "010";
        n_alu2_select := "000";
        n_alureg_write := '1';
        n_addr_select := "01";
        n_mem_write := '1';
        n_regread2_select := '1';
        n_regdata_select := "01";
        n_regwrite_select := "11";
        n_t2_write := '1';
        n_pl_select := '0';
      --default
        n_inst_write := '0';
        n_pc_write := '0';
        n_pc_in_select := "000";
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_memreg_write := '0';
        n_reg_write := '0';
        n_t1_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_zero_select := '0';
      when end_state =>
      -- Common end_state for all in which pc not updated
        n_pc_write := '1';
        n_pc_in_select := "001";
        n_alu1_select := "000";
        n_alu2_select := "000";
      --default
        n_inst_write := '0';
        n_alu_op := '0';
        n_alu_op_select := '0';
        n_alureg_write := '0';
        n_addr_select := "00";
        n_mem_write := '0';
        n_memreg_write := '0';
        n_regread2_select := '0';
        n_regdata_select := "00";
        n_regwrite_select := "00";
        n_reg_write := '0';
        n_t1_write := '0';
        n_t2_write := '0';
        n_set_carry := '0';
        n_set_zero := '0';
        n_carry_enable_select := '0';
        n_zero_enable_select := '0';
        n_pl_select := '0';
        n_zero_select := '0';
    end case;

    if reset = '1' then
      inst_write <= '0';
      pc_write <= '0';
      pc_in_select <= "000";
      alu_op <= '0';
      alu_op_select <= '0';
      alu1_select <= "000";
      alu2_select <= "000";
      alureg_write <= '0';
      addr_select <= "00";
      mem_write <= '0';
      memreg_write <= '0';
      regread2_select <= '0';
      regdata_select <= "00";
      regwrite_select <= "00";
      reg_write <= '0';
      t1_write <= '0';
      t2_write <= '0';
      set_carry <= '1';
      set_zero <= '1';
      carry_enable_select <= '0';
      zero_enable_select <= '0';
      pl_select <= '0';
      zero_select <= '0';
    else
      inst_write <= n_inst_write;
      pc_write <= n_pc_write;
      pc_in_select <= n_pc_in_select;
      alu_op <= n_alu_op;
      alu_op_select <= n_alu_op_select;
      alu1_select <= n_alu1_select;
      alu2_select <= n_alu2_select;
      alureg_write <= n_alureg_write;
      addr_select <= n_addr_select;
      mem_write <= n_mem_write;
      memreg_write <= n_memreg_write;
      regread2_select <= n_regread2_select;
      regdata_select <= n_regdata_select;
      regwrite_select <= n_regwrite_select;
      reg_write <= n_reg_write;
      t1_write <= n_t1_write;
      t2_write <= n_t2_write;
      set_carry <= n_set_carry;
      set_zero <= n_set_zero;
      carry_enable_select <= n_carry_enable_select;
      zero_enable_select <= n_zero_enable_select;
      pl_select <= n_pl_select;
      zero_select <= n_zero_select;
    end if;
  end process;

end Struct;