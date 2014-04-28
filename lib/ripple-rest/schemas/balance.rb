module RippleRest
  class Balance
    # @return [String]
    def inspect
      "#{value.to_s} #{currency}#{counterparty.to_s.size > 0 ? " (#{counterparty})" : ""}"
    end
  end
end