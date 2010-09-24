class ContractBimonthly < Contract
	
	
	def addTransactions
		addTransactionsMode(self.date_start, self.date_end, self.day_of_month, 'monthly')
		addTransactionsMode(self.date_start, self.date_end, self.day_of_month_alt, 'monthly')
	end
end
