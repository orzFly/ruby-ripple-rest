module RippleRest
  generate_schema :Amount

  class Amount
    def to_s
      "#{value}+#{currency}#{issuer.to_s.size > 0 ? ("+" + issuer) : ""}"
    end
    
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