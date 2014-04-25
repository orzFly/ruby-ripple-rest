module RippleRest
  generate_schema :Balance

  class Balance
    def inspect
      "#{value.to_s} #{currency}#{counterparty.to_s.size > 0 ? " (#{counterparty})" : ""}"
    end
  end
end