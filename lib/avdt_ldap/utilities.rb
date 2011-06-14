class Utilities

  class Hash
    
    # Transforms all the hash keys from strings to symbols.
    # Example:
    # {"one" => "two", "three" => "four"}.symbolize_keys
    # => {:one=>"two", :three=>"four"}
    def symbolize_keys
      t = self.dup
      self.clear
      t.each_pair do |k,v|
        self[k.to_sym] = v
        if v.kind_of?(Hash)
          v.symbolize_keys
        end
        self
      end
    end
  end

end