class Contract < ActiveRecord::Base
	
	before_save :set_date_fields
	after_save :addTransactions
	
	belongs_to :user
	has_many :transactions
	belongs_to :autopayAccount, :foreign_key => 'autopay_account_id', :class_name => 'Account'
	
	named_scope :user_only, lambda { |user_id| { :conditions => { :user_id => user_id } }}
	named_scope :active_only, :conditions => { :active => true } 
	named_scope :credit_only, :conditions => { :transaction_type => 'TransactionCredit' } 
	named_scope :debit_only, :conditions => { :transaction_type => 'TransactionDebit' } 

	def self.activeCreditContracts(userId)
		contracts = user_only(userId).active_only.credit_only.find(:all)
		
	end
	
	def self.activeDebitContracts(userId)
		contracts = user_only(userId).active_only.debit_only.find(:all)
	end
	
	def addTransactions
		
		#Add all Transactions from start_date to end_date
		
	end
	
	def type_display
		
		if(self.type == 'ContractOnce')
			td = "One Time"
		elsif(self.type == 'ContractWeekly')
			td = "Weekly"
		elsif(self.type == 'ContractBimonthly')
			td = "Bi-monthly"
		elsif(self.type == 'ContractMonthly')
			td = "Monthly"
		elsif(self.type == 'ContractYearly')
			td = "Yearly"
		end
		return td
	end
	
	def addTransactionsMode(date_start, date_end, day_of_month, mode, transaction_type)
		
		contract_start_date = Date.new(date_start.year, date_start.mon, date_start.mday)
		logger.info "START DATE: #{contract_start_date.to_s}"
		start_month = contract_start_date.mon
		start_year = contract_start_date.year
		if mode == 'yearly' || mode == 'once'
			this_date = self.full_date
		else
			this_date = Contract.get_last_valid_date(start_year, start_month, day_of_month)
		end
		if this_date < contract_start_date
			this_date = Contract.get_next_date(mode, this_date, day_of_month)
		end
		
		while this_date > 0 && this_date <= date_end do
			logger.info "ADDING #{this_date}"
			if transaction_type == 'TransactionCredit'
				create_transactions_credit(this_date)
			elsif transaction_type == 'TransactionDebit'
				create_transactions_debit(this_date)
			end
			this_date = Contract.get_next_date(mode, this_date, day_of_month)
		end
		
	end

	
	
	private 
	def set_date_fields
		logger.info "SETTING DATE FIELDS"
		if self.type == 'ContractOnce'
			self.date_start = self.full_date
			self.date_end = self.full_date
		end
		
		unless self.autopay
			self.autopay_account_id = -1
		end
		logger.info "FINISHED SETTING DATE FIELDS"
	end
	
	def self.get_next_date(mode, this_date, day_of_month)
		if mode == 'monthly'
			this_date = Contract.get_date_next_month(this_date, day_of_month)
		elsif mode == 'weekly'
			this_date = Contract.get_date_next_week(this_date, day_of_month)
		elsif mode == 'yearly'
			this_date = Contract.get_date_next_year(this_date, day_of_month)
		elsif mode == 'once'
			this_date = -1
		end
		
		return this_date
	end
	
	def self.get_date_next_year(date, desired_day_of_month)
		
		month = date.mon
		year = date.year + 1
		
		date =  get_last_valid_date(year, month, desired_day_of_month)
	
	end
	
	def self.get_date_next_month(date, desired_day_of_month)
		
		month = date.mon
		year = date.year
		
		if month == 12
			month = 1
			year += 1
		else
			month += 1
		end
		
		date =  get_last_valid_date(year, month, desired_day_of_month)
	
	end
	
	def self.get_date_next_week(date, desired_day_of_month)
		
		date = date + 7
	
	end
	
	def self.get_last_valid_date(year, month, desired_day_of_month)
		
		until Date.valid_civil?(year, month, desired_day_of_month)
			logger.info "INVALID DATE: #{month}/#{desired_day_of_month}/#{year}"
			desired_day_of_month -= 1
			
		end
		logger.info "VALID DATE: #{month}/#{desired_day_of_month}/#{year}"
		date =  Date.new(year, month, desired_day_of_month)

	end
	
	def create_transactions_credit(date)
		
		transaction = TransactionCredit.new
		transaction.name = self.name + " Contract Transaction"
		transaction.description = self.description + " Contract Transaction"
		transaction.scheduled_date = date
  		transaction.amount = self.amount
    	transaction.contract_id = self.id
    	transaction.user_id = self.user_id
    	if self.autopay
    		transaction.account_id_source = self.autopay_account_id
    	end
    	transaction.autopay = self.autopay
    	transaction.save
	end
	
	def create_transactions_debit(date)
		
		transaction = TransactionDebit.new
		transaction.name = self.name + " Contract Transaction"
		transaction.description = self.description + " Contract Transaction"
		transaction.scheduled_date = date
  		transaction.amount = self.amount
    	transaction.contract_id = self.id
    	transaction.user_id = self.user_id
    	if self.autopay
    		transaction.account_id_dest = self.autopay_account_id
    	end
    	transaction.autopay = self.autopay
    	transaction.save
	end
	
	def has_completed_transactions
		self.transactions.each do |trans|
			if trans.completed
				return true
			end
		end
		return false
	end
	
	def delete_incomplete_transactions
		self.transactions.each do |trans|
			unless trans.completed
				trans.delete
			end
		end
		return false
	end
	
end
