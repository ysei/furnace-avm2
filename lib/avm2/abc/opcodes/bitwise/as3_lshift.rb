module AVM2::ABC
  class AS3LShift < BitwiseOpcode
    instruction 0xa5

    consume 2
    produce 1
  end
end