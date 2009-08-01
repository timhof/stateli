class Account < ActiveRecord::Base
	
	before_create :setPreviousBalance
	after_create :addTransaction
	
	belongs_to :user
	
	named_scope :active_only, :conditions => { :active => true } 
	named_scope :user_only, lambda { |user_id| { :conditions => { :user_id => user_id } }}
	
	attr_accessor :previous_balance, :has_overdue_transactions
	
	validates_presence_of :name, :balance
	validates_numericality_of :balance
	
	def self.activeAccounts(userId)
		accounts = user_only(userId).active_only.find(:all)
		accounts.each do |acc|
			acc.set_overdue_transactions(Date.today, Date.today)
		end
	end
	
	def set_overdue_transactions(start_date, end_date)
		@has_overdue_transactions = Transaction.account_has_overdue(self.id)
	end

	def completed_transactions_by_date(start_date, end_date)
		
		@transactions = Transaction.completed_by_date(self.id, self.user_id, start_date, end_date)
		balance = 0
		@transactions.each do |trans|
			logger.info "amount: #{trans.amount}"
			next if trans.amount.nil?
			if trans.type == 'TransactionCredit'
				balance = balance - trans.amount
			elsif trans.type == 'TransactionDebit'
				balance = balance + trans.amount
			else
				balance = trans.amount
			end
			trans.account_balance = balance
		end
	end
	
	def completed_transactions(start_date, end_date)
		
		credit_transactions = Transaction.account_credit_completed(self.id)
		debit_transactions = Transaction.account_debit_completed(self.id)
		reconcile_transactions = Transaction.account_reconcile_completed(self.id)
		logger.info "#{credit_transactions.size} Completed CREDIT Transactions"
		logger.info "#{debit_transactions.size} Completed DEBIT Transactions"
		logger.info "#{reconcile_transactions.size} Completed RECONCILE Transactions"
		transactions = {:credit => credit_transactions, :debit => debit_transactions, :reconcile => reconcile_transactions}	
		
	end
	
	def uncompleted_transactions(start_date, end_date)
		
		credit_transactions = Transaction.account_credit_uncompleted(self.id)
		debit_transactions = Transaction.account_debit_uncompleted(self.id)
		reconcile_transactions = Transaction.account_reconcile_uncompleted(self.id)
		logger.info "#{credit_transactions.size} Uncompleted CREDIT Transactions"
		logger.info "#{debit_transactions.size} Uncompleted DEBIT Transactions"
		logger.info "#{reconcile_transactions.size} Uncompleted RECONCILE Transactions"
		transactions = {:credit => credit_transactions, :debit => debit_transactions, :reconcile => reconcile_transactions}	
		
	end
	
	def self.uncompleted_transactions_all_accounts(userId, start_date, end_date)
		
		credit_transactions = Transaction.credit_uncompleted_by_date(userId, start_date, end_date)
		debit_transactions = Transaction.debit_uncompleted_by_date(userId, start_date, end_date)

		logger.info "#{credit_transactions.size} Uncompleted CREDIT Transactions"
		logger.info "#{debit_transactions.size} Uncompleted DEBIT Transactions"
		transactions = {:credit => credit_transactions, :debit => debit_transactions}	
		
	end
	
	def overdue_transactions(start_date, end_date)
		
		credit_transactions = Transaction.account_credit_uncompleted(self.id)
		debit_transactions = Transaction.account_debit_uncompleted(self.id)
		reconcile_transactions = Transaction.account_reconcile_uncompleted(self.id)
		logger.info "#{credit_transactions.size} Uncompleted CREDIT Transactions"
		logger.info "#{debit_transactions.size} Uncompleted DEBIT Transactions"
		logger.info "#{reconcile_transactions.size} Uncompleted RECONCILE Transactions"
		transactions = {:credit => credit_transactions, :debit => debit_transactions, :reconcile => reconcile_transactions}	
		
	end
	
	def deactivate
		# Set ACTIVE to false
		# Save Account
	end
	
    def setPreviousBalance
    	
		logger.info "OLD BALANCE: #{balance}"
		if self.id.nil?
			@previous_balance = 0
		else
			orig = Account.find(self.id)
    		@previous_balance = orig.balance
    	end
    end
    
	def addTransaction
		
		logger.info "OLD BALANCE: #{previous_balance} NEW BALANCE: #{balance}"
		if @previous_balance != balance
		
			balanceDiff = self.balance - @previous_balance
		
			transaction = TransactionReconcile.new
			transaction.name = 'Account Reconciliation'
		    transaction.description = 'Account Reconciliation'
		    transaction.scheduled_date = Date.today
		    transaction.executed_date = Date.today
		    transaction.amount = balanceDiff
		    transaction.completed = true
		    transaction.account_id_source = id
		    transaction.account_id_dest = id
		    transaction.user_id = user_id
	    
		    transaction.save
    	end
	end
	
	def updateBalance(transaction)
		amount = transaction.amount
		if transaction.type == 'TransactionCredit'
			amount = 0 - transaction.amount
		end
		logger.info "AMOUNT: #{amount}"
		old_balance = self.balance
  		new_balance = old_balance + amount
  		self.balance = new_balance
  		self.save
  	end
  	
end
