class ContractMonthly < Contract
	
	
	def addTransactions
		addTransactionsMode(self.date_start, self.date_end, self.day_of_month, 'monthly')
	end
	
end
