module RippleRest
  class ProtocolError < RuntimeError
    attr_accessor :response
    def initialize message, response
      super message
      @response = response
    end
  end
  
  class RippleRestError < RuntimeError
  end
end