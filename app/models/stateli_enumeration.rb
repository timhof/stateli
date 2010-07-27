class StateliEnumeration
	
  def StateliEnumeration.add_item(key,value)
	@hash ||= {}
    enumValue = EnumValue.new(key.to_s, value)
    @hash[key] = enumValue
  end
  
  def StateliEnumeration.const_missing(key)
    @hash[key]
  end   
  
  def StateliEnumeration.each
    @hash.each {|key,value| yield(key,value)}
  end
  
  def StateliEnumeration.values
  	p @hash
    values = @hash.values || []
    values.sort
  end
  
  def StateliEnumeration.keys
    @hash.keys || []
  end
  
  def StateliEnumeration.[](key)
    @hash[key]
  end
  
  def self.findById(id)
	self.keys.find {|key| self[key].key == id}
  end
	
  def StateliEnumeration.label(key)
	@hash[self.findById(key)].label
  end
end
