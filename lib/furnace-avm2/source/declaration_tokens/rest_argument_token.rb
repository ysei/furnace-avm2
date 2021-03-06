module Furnace::AVM2::Tokens
  class RestArgumentToken < Furnace::Code::TerminalToken
    def initialize(origin, name, options={})
      super(origin, options)
      @name = name
    end

    def to_text
      "...#{@name}"
    end
  end
end