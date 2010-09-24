class Contract < ActiveRecord::Base
	
	require 'bigdecimal'
  	require 'bigdecimal/util'
  	
	before_save :set_date_fields
	after_create :addTransactions
	
	belongs_to :user
	belongs_to :account	
	has_many :transactions, :dependent => :destroy
	
	named_scope :user_only, lambda { |user_id| { :conditions => { :user_id => user_id } }}

	def update_contract_attributes(params)
		p params
 		unless(params[:name].nil?)
 			self.name = params[:name]
 		end
 		unless(params[:description].nil?)
 			self.description = params[:description]
 		end
 		unless(params[:date_start].nil?)
 			self.date_start = Date.parse(params[:date_start])
 		end
 		unless(params[:date_end].nil?)
 			self.date_end = Date.parse(params[:date_end])
 		end
 		unless(params[:autopay].nil?)
 			self.autopay = params[:autopay]
 		end
 		unless(params[:autopay_account_id].nil?)
 			self.autopay_account_id = params[:autopay_account_id]
 		end
 		unless(params[:full_date].nil?)
 			self.full_date = Date.parse(params[:full_date])
 		end
 		unless(params[:day_of_month].nil?)
 			self.day_of_month = params[:day_of_month]
 		end
 		unless(params[:day_of_month_alt].nil?)
 			self.day_of_month_alt = params[:day_of_month_alt]
 		end
 		unless(params[:weekday].nil?)
 			self.weekday = params[:weekday]
 		end
 		unless(params[:amount].nil?)
 			self.amount = params[:amount].to_d
 		end
 	end
 	
	def self.activeCreditContracts(userId)
		contracts = user_only(userId).credit_only.find(:all)
	end
	
	def self.activeDebitContracts(userId)
		contracts = user_only(userId).debit_only.find(:all)
	end
	
	def self.activeContracts(userId)
		contracts = user_only(userId).find(:all)
	end
	
	def addTransactions
		
		#Add all Transactions from start_date to end_date
		
	end
	
	def addTransaction(params)
		
		transaction = Transaction.new()
		
		params[:contract_id]  = self.id
		params[:autopay] = false
		params[:user_id] = self.user_id
		transaction.update_transaction_attributes(params)
		logger.info "Transaction completed: #{transaction.completed}"
		if transaction.new_record?
			logger.info "Transaction not saved."
		else
			logger.info "Transaction saved."
		end
		
		if transaction.completed
			transaction.complete
		end
	end
		
	def type_display
		
		if(self.type == 'ContractOnce')
			td = "Flexible"
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
	
	
  	def has_pending_transactions
		Transaction.contract_has_incomplete(self.id)
	end
	
	
	def self.build_new_contract(params, userid)
	  	contractType =  params[:type]
	    if contractType == 'ContractYearly'
			contract = ContractYearly.new()
		elsif contractType == 'ContractMonthly'
			contract = ContractMonthly.new()
		elsif contractType == 'ContractBimonthly'
			contract = ContractBimonthly.new()
		elsif contractType == 'ContractWeekly'
			contract = ContractWeekly.new()
		elsif contractType == 'ContractOnce'
			contract = ContractOnce.new()
		end
		
		contract.user_id = userid
		contract.update_contract_attributes(params)
		
		logger.info "CONTRACT TYPE: #{contract.type}"
		return contract
  	end
  	
	def completed_transactions_by_date(start_date, end_date)
		transactions = Transaction.completed_by_contract_date(self.id, start_date, end_date)
	end
	
	def uncompleted_transactions_by_date(start_date, end_date)
		transactions = Transaction.uncompleted_by_contract_date(self.id, start_date, end_date)
	end
	
	protected
		def addTransactionsMode(date_start, date_end, day_of_month, mode)
			
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
				create_transaction(this_date)
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
		
		def create_transaction(date)
			transaction = Transaction.new
			set_transaction_fields(transaction, date)
		end
		
		def set_transaction_fields(transaction, date)
			
			params = {:name => self.name + " Contract Transaction", :description => self.description + " Contract Transaction", :trans_date => date, :amount => self.amount, :contract_id => self.id, :user_id => self.user_id, :account_id => self.account_id, :pocket_id => Pocket.unclassified.id}
	    	
			transaction.update_transaction_attributes(params)
		end

end
