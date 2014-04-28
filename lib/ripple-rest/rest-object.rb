require 'uri'
require 'time'

module RippleRest
  # @api private
  module RestTypeHelper
    # @!visibility private
    # @api private
    def self.exist? key
      @converter ||= {}
      @converter.keys.include? key
    end
    
    # @!visibility private
    # @api private
    def self.register key, to, from, check, name = nil
      return key if exist? key
      
      @converter ||= {}
      @converter[key] = [to, from, check, name ? name : key.to_s]
      
      key
    end
    
    # @!visibility private
    # @api private
    def self.register_string key, regexp
      reg = Regexp.new regexp
      
      register key,
        RETURN_SELF, 
        RETURN_SELF, 
        lambda { |x| (x.is_a?(String) && x.match(reg)) },
        "String<#{key}>: #{reg.inspect}"
    end
    
    # @!visibility private
    # @api private
    def self.register_array type
      register :"Array<#{type}>",
        lambda { |x| x.map { |i| self.convert_to(type, i) } }, 
        lambda { |x| x.map { |i| self.convert_from(type, i) } }, 
        lambda { |x| (x.is_a?(Array) && x.all? {|i| self.convert_check(type, i) }) },
        "Array<#{type}>"
    end
    
    # @!visibility private
    # @api private
    def self.register_string_otg regexp
      register_string :"String<#{regexp.inspect}>", regexp
    end
    
    # @!visibility private
    # @api private
    def self.register_object key, klass
      register key, 
        lambda { |x| x.to_hash },
        lambda { |x| x.is_a?(klass) ? x : klass.new(x) },
        lambda { |x| x.is_a? klass },
        "#{key}"
    end
    
    # @!visibility private
    # @api private
    def self.convert_to type, obj
      return nil if obj.nil?
      @converter[type][0].call obj
    end
    
    # @!visibility private
    # @api private
    def self.convert_from type, obj
      return nil if obj.nil?
      @converter[type][1].call obj
    end
    
    # @!visibility private
    # @api private
    def self.convert_check type, obj
      return true if obj.nil?
      @converter[type][2].call obj
    end
    
    # @!visibility private
    # @api private
    def self.convert_raise type, obj
      raise ArgumentError.new "#{obj.inspect} cannot be casted to #{@converter[type][3]}"
    end
    
    # @api private
    RETURN_SELF = lambda { |x| x }
    
    register :String, 
        RETURN_SELF, 
        RETURN_SELF, 
        lambda { |x| x.is_a?(String) }
    
    register :Boolean,
        RETURN_SELF, 
        RETURN_SELF, 
        lambda { |x| [true, false].include? x }
    
    register :FloatString,
        lambda { |x| x.is_a?(BigDecimal) ? x.to_s("F") : BigDecimal.new(x.to_s).to_s("F") },
        lambda { |x| x.is_a?(BigDecimal) ? x : BigDecimal.new(x) },
        lambda { |x| x.is_a?(BigDecimal) || x.respond_to?(:to_f)}
    
    register :UINT32,
        lambda { |x| x.to_i.to_s },
        lambda { |x| x.to_i },
        lambda { |x| x.is_a?(Numeric) && x >= 0 && x <= 4294967295 }
    
    register :Timestamp,
        lambda { |x| x.iso8601 },
        lambda { |x| x.is_a?(Time) ? x : Time.iso8601(x) },
        lambda { |x| x.is_a?(Time) || x.is_a?(String) }
    
    register :URL,
        lambda { |x| x.to_s },
        lambda { |x| URI(x.to_s) },
        lambda { |x| x.is_a?(URI) || x.respond_to?(:to_s) }
  end
  
  class RestObject
    # @param data [Hash]
    def initialize data = nil
      data.each do |key, value|
        if @@properties[self.class][key.to_sym]
          self.instance_variable_set :"@#{key}", RestTypeHelper.convert_from(@@properties[self.class][key.to_sym], value)
        else
          warn "Cannot found field `#{key}' in RippleRestObject #{self.class}. The value will leave as-is. However, this will not be serialized to JSON."
          self.instance_variable_set :"@#{key}",  value
        end
      end if data
    end
    
    # Convert to a hash
    # @return [Hash]
    def to_hash
      result = {}
      @@properties[self.class].each do |key, type|
        value = self.instance_variable_get(:"@#{key}")
        if @@required[self.class][key] && value == nil
          raise ArgumentError.new("Field `#{key}' is required in RippleRestObject #{self.class}.")
        end
        result[key] = RestTypeHelper.convert_to(type, value) if value != nil
      end
      
      result
    end
    
    # @!visibility protected
    # @api private
    def self.required symbol
      @@required[self][symbol] = true
    end
    
    # @!visibility protected
    # @api private
    def self.property symbol, typeobj
      if typeobj.is_a? Symbol
        type = typeobj
      elsif typeobj.is_a?(Array) && typeobj[0] == :String
        type = RestTypeHelper.register_string_otg typeobj[1]
      elsif typeobj.is_a?(Array) && typeobj[0] == :Array
        type = RestTypeHelper.register_array typeobj[1]
      end
      
      define_method :"#{symbol}", &lambda { self.instance_variable_get :"@#{symbol}" }
      define_method :"#{symbol}=", &lambda { |value|
        begin
          raise "" unless RestTypeHelper.convert_check(type, value)
          self.instance_variable_set :"@#{symbol}", RestTypeHelper.convert_from(type, value)
        rescue
          RestTypeHelper.convert_raise type, value
        end
      }
      
      @@properties[self][symbol] = type
    end
    
    @@required ||= Hash.new { |h, k| h[k] = Hash.new }
    @@properties ||= Hash.new { |h, k| h[k] = Hash.new }
  end
  
  
  class << RestObject
    protected :property
    protected :required
  end
end