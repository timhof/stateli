class EnumValue
	
	include Comparable
	
	attr_accessor :key, :label
	
	def initialize(key, label)
		@key = key
		@label = label
	end
	
	def <=>(other)
		@key <=> other.key
	end
end