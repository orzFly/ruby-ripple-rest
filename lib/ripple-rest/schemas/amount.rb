module RippleRest
  class Amount
    # @return [String]
    def to_s
      "#{value}+#{currency}#{issuer.to_s.size > 0 ? ("+" + issuer) : ""}"
    end
    
    # @param s [String, Amount] an Amount object or a String like "1+XRP" or "1+USD+r..."
    # @return [Amount]
    def self.from_string s
      return s if s.is_a?(Amount)
      
      arr = s.split("+")
      Amount.new({
        "value" => arr[0],
        "currency" => arr[1],
        "issuer" => arr[2]
      })
    end
  end
end