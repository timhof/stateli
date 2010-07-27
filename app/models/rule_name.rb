class RuleName < Rule
	
	def match_value(transaction)
		compareto = -1
		trans_name = transaction.description.nil? ? "" : transaction.description.upcase
		comp_name = comp_string.upcase
		includes = trans_name.include? comp_name
		if includes 
			compareto = 1
			if trans_name.starts_with? comp_name
				compareto = 0
			end
		end
		return compareto
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
