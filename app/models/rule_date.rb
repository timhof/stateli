class RuleDate < Rule
	
	def match_value(transaction)
		compareto = transaction.trans_date <=> comp_date 
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
