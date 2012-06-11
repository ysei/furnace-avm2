module Furnace::AVM2::ABC
  class AS3CoerceA < TypeConversionOpcode
    instruction 0x82

    consume 1
    produce 1

    ast_type :coerce
    type     :any
  end
end