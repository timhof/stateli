class TransactionDebit < Transaction
	
	def validate
		errors.add(:account_id_dest, " must be assigned." ) if @autopay || @completed
	end
end
