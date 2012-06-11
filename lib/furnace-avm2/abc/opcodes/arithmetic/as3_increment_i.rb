module Furnace::AVM2::ABC
  class AS3IncrementI < ArithmeticOpcode
    instruction 0xc0

    consume 1
    produce 1

    type :integer
    ast_type :increment
  end
end