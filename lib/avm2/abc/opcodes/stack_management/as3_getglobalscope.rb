module AVM2::ABC
  class AS3GetGlobalScope < StackManagementOpcode
    instruction 0x64

    consume 0
    produce 1
  end
end