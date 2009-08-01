class TransactionCredit < Transaction
	
	def validate
		errors.add(:account_id_source, " must be assigned." ) if @autopay || @completed
	end
	
end
