class RuleAmount < Rule
	
	def qualifies?(transaction)
		return false
	end
	
	def self.model_name
  		name = "rule"
  		name.instance_eval do
    		def plural;   pluralize;   end
    		def singular; singularize; end
    		def human;    singularize; end # only for Rails 3
  		end
  		return name
	end


end
