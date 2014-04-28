module RippleRest
  class ProtocolError < RuntimeError
    # @return [RestClient::Response]
    attr_accessor :response
    def initialize message, response
      super message
      @response = response
    end
  end
  
  class RippleRestError < RuntimeError
    # @return [String, Hash]
    attr_accessor :response
    def initialize message, response
      super message
      @response = response
    end
  end
end