class ContractBimonthly < Contract
	
	
	def addTransactions
		addTransactionsMode(self.date_start, self.date_end, self.day_of_month, 'monthly', self.transaction_type)
		addTransactionsMode(self.date_start, self.date_end, self.day_of_month_alt, 'monthly', self.transaction_type)
	end
end
