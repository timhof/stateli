class ContractOnce < Contract
	
	def addTransactions
		addTransactionsMode(self.date_start, self.date_start, self.full_date.mday, 'once')
	end
end
