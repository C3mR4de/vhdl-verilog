library IEEE;
use IEEE.std_logic_1164.all;

package my_types is
  type int_array is array (natural range <>) of integer;
end;

library IEEE;
use IEEE.std_logic_1164.all;
use work.my_types.all;

entity quick_sort is
  generic
  (
    ARRAY_SIZE : integer := 8
  );
  port
  (
    clk      : in  std_logic;
    rst      : in  std_logic;
    start    : in  std_logic;
    done     : out std_logic;
    data_in  : in  int_array(0 to ARRAY_SIZE - 1);
    data_out : out int_array(0 to ARRAY_SIZE - 1)
  );
end quick_sort;

architecture Behavioral of quick_sort is
  signal mem         : int_array(0 to ARRAY_SIZE - 1);
  signal pIndex      : integer range 0 to ARRAY_SIZE;
  signal pivot       : integer range 0 to ARRAY_SIZE;
  signal arr_begin   : integer range 0 to ARRAY_SIZE;
  signal arr_end     : integer range 0 to ARRAY_SIZE;
  signal arr_iter    : integer range 0 to ARRAY_SIZE;
  signal stack       : int_array(0 to 10 * ARRAY_SIZE - 1);
  signal stack_ptr   : integer range 0 to 10 * ARRAY_SIZE;
  type   state_type  is (IDLE, INIT, SORT_BEGIN, PARTITION_BEGIN, SWAP_CYCLE, PARTITION_END, SORT_END, FINISH);
  signal state       : state_type;
begin
  process (clk, rst)
    variable mem_v       : int_array(0 to ARRAY_SIZE - 1);
    variable pivot_v   : integer range 0 to ARRAY_SIZE;
    variable pIndex_v    : integer range 0 to ARRAY_SIZE;
    variable arr_iter_v  : integer range 0 to ARRAY_SIZE;
    variable arr_end_v   : integer range 0 to ARRAY_SIZE;
    variable stack_v     : int_array(0 to 10 * ARRAY_SIZE - 1);
    variable stack_ptr_v : integer range 0 to 10 * ARRAY_SIZE;
    variable state_v   : state_type;
    variable temp        : integer;
  begin
    if rst = '1' then
      state <= IDLE;
      done  <= '0';
    elsif clk'event and clk = '1' then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= INIT;
          end if;

        when INIT =>
          mem       <= data_in;
          stack(0)  <= 0;
          stack(1)  <= ARRAY_SIZE - 1;
          stack_ptr <= 2;
          state     <= SORT_BEGIN;

        when SORT_BEGIN =>
          if stack_ptr = 0 then
            state <= FINISH;
          else
            arr_begin <= stack(stack_ptr - 2);
            arr_end   <= stack(stack_ptr - 1);
            stack_ptr <= stack_ptr - 2;
            state     <= PARTITION_BEGIN;
          end if;

        when PARTITION_BEGIN =>
          pivot    <= mem(arr_end);
          pIndex   <= arr_begin;
          arr_iter <= arr_begin;
          state    <= SWAP_CYCLE;

        when SWAP_CYCLE =>
          mem_v      := mem;
          pIndex_v   := pIndex;
          pivot_v    := pivot;
          arr_iter_v := arr_iter;
          arr_end_v  := arr_end;
          state_v    := state;
          if arr_iter_v >= arr_end_v then
            state_v := PARTITION_END;
          else
            if mem_v(arr_iter_v) <= pivot_v then
              temp            := mem_v(arr_iter_v);
              mem_v(arr_iter_v) := mem_v(pIndex_v);
              mem_v(pIndex_v)   := temp;
              pIndex_v       := pIndex_v + 1;
            end if;
            arr_iter_v := arr_iter_v + 1;
          end if;
          mem      <= mem_v;
          pIndex   <= pIndex_v;
          arr_iter <= arr_iter_v;
          state    <= state_v;

        when PARTITION_END =>
          mem_v          := mem;
          temp           := mem_v(pIndex);
          mem_v(pIndex)  := mem_v(arr_end);
          mem_v(arr_end) := temp;
          mem            <= mem_v;
          pivot          <= pIndex;
          state          <= SORT_END;

        when SORT_END =>
          stack_v     := stack;
          stack_ptr_v := stack_ptr;
          if pivot - 1 > arr_begin then
            stack_v(stack_ptr_v)     := arr_begin;
            stack_v(stack_ptr_v + 1) := pivot - 1;
            stack_ptr_v              := stack_ptr_v + 2;
          end if;
          if pivot + 1 < arr_end then
            stack_v(stack_ptr_v)     := pivot + 1;
            stack_v(stack_ptr_v + 1) := arr_end;
            stack_ptr_v              := stack_ptr_v + 2;
          end if;
          stack     <= stack_v;
          stack_ptr <= stack_ptr_v;
          state     <= SORT_BEGIN;

        when FINISH =>
          done <= '1';

        when others =>
          state <= IDLE;

      end case;
    end if;
  end process;

  data_out <= mem;

end Behavioral;

