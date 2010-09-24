class ContractYearly < Contract
	
	
	def addTransactions
		addTransactionsMode(self.date_start, self.date_end, self.full_date.mday, 'yearly')
	end
	
end
