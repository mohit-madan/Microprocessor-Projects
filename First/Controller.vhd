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
    pc_in_select: out std_logic;

    -- Select the two ALU inputs / op_code
    alu_op: out std_logic;
    alu_op_select: out std_logic;
    alu1_select: out std_logic_vector(1 downto 0);
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

    -- Choice between input register and feedback
    pl_select: out std_logic;

    -- Active signal, if high ADC / ADZ / NDC / NDZ executed
    active: in std_logic;

    -- Returns whether priority loop input is zero or not
    plinput_zero: in std_logic;

    -- Used to transition from S2
    inst_type: in OperationCode;

    -- zero flag which is useful for BEQ control
    zero_flag: in std_logic;

    -- clock and reset pins, if reset is high, external memory signals
    -- active.
    clk, reset: in std_logic
  );
end entity;
architecture Struct of Controller is
  type FsmState is (S0, S1, S2, S3);
  signal state: FsmState;
begin

  -- Next state process
  process(clk, reset, active, inst_type, plinput_zero, zero_flag)
    variable nstate: FsmState;
  begin
    nstate := S0;
    case state is
      when S0 =>
        nstate := S1;
      when S1 =>
        nstate := S2;
      when S2 =>
        if inst_type = R_TYPE then
          nstate := S3;
        else
          nstate := S1;
        end if;
      when S3 =>
        nstate := S0;
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
  process(state)
    variable n_inst_write: std_logic;
    variable n_pc_write: std_logic;
    variable n_pc_in_select: std_logic;
    variable n_alu_op: std_logic;
    variable n_alu_op_select: std_logic;
    variable n_alu1_select: std_logic_vector(1 downto 0);
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
    variable n_pl_select: std_logic;
  begin
    n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := '0';
    n_alu_op := '0';
    n_alu_op_select := '0';
    n_alu1_select := "00";
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
    n_pl_select := '0';

    case state is
      when S0 =>
      when S1 =>
      when S2 =>
      when S3 =>
    end case;

    if reset = '1' then
      inst_write <= '0';
      pc_write <= '0';
      pc_in_select <= '0';
      alu_op <= '0';
      alu_op_select <= '0';
      alu1_select <= "00";
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
      set_carry <= '0';
      set_zero <= '0';
      pl_select <= '0';
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
      pl_select <= n_pl_select;
    end if;
  end process;

end Struct;