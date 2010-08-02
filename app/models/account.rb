class Account < ActiveRecord::Base
	
	require 'bigdecimal'
  	require 'bigdecimal/util'

	include StateliHelper
	
	has_many :transactions, :order => "trans_date desc", :conditions => {:active => true}
	has_many :rules, :order => "rank asc"
	before_create :initializate_previous_balance
	after_save :reconcile_balance
	
	named_scope :active_only, :conditions => { :active => true } 
	named_scope :user_only, lambda { |user_id| { :conditions => { :user_id => user_id } }}
	
	attr_accessor :previous_balance, :has_overdue_transactions, :has_pending_transactions
	
	validates_presence_of :name, :balance
	validates_numericality_of :balance
	
	def deleted_transactions
		return Transaction.deleted_transactions(id)
	end
	
	def update_account_attributes(params)

		self.previous_balance = self.balance
		
 		unless(params[:name].nil?)
 			self.name = params[:name]
 		end
 		unless(params[:description].nil?)
 			self.description = params[:description]
 		end
 		unless(params[:balance].nil?)
 			self.balance = params[:balance].to_d
 		end
 		unless(params[:active].nil?)
 			self.active = params[:active]
 		end
 		
 		return self.save
 	end
 	

	def has_overdue_transactions
		has_overdue = false
		transactions.each do |trans|
			if trans.trans_date < Date.today && !trans.completed
				has_overdue = true
			end
		end
		return has_overdue
	end
	
	def has_pending_transactions
		has_pending = false
		transactions.each do |trans|
			if !trans.completed	
				has_pending = true
			end
		end
		return has_pending
	end
	
	def add_upload_transactions(filename, uploadType=nil)
		transactionUploader = TransactionUploader.new
		transactionUploader.type = uploadType
		new_transactions = transactionUploader.parseTransactions(filename)
   		new_transactions.each do |trans|
   			unless has_transaction(trans)
   				p "Adding: "#{trans.trans_date}, #{trans.name}, #{trans.amount}"
   				trans.user_id = user_id
   				trans.account_id = id
   				trans.save!
   			end
   		end
   	end
   	
	def has_transaction(transaction)
		
		return transactions.to_a.any? do |trans|
			trans.trans_date == transaction.trans_date && trans.name == transaction.name && trans.amount == transaction.amount
		end
	end
		
			
	def reload_transactions
		
		puts "RELOADING TRANSACTIONS"
		self.reload
		
		account_balance = 0.0.to_d
		
		#get list of completed transactions
		completed_transactions = self.completed_transactions
		
		completed_transactions.reverse_each do |trans|
			next if trans.amount.nil?
			account_balance = account_balance + trans.amount.to_d
			trans.account_balance = account_balance
			trans.save
		end
		
		self.update_balance(account_balance)
		self.save
	end
	
	def self.activeAccounts(userId)
		accounts = user_only(userId).active_only.find(:all)
	end

	def completed_transactions_by_date(start_date, end_date)
		return completed_transactions
	end
	
	def uncompleted_transactions_by_date(start_date, end_date)
		return uncompleted_transactions
	end
	
	def completed_transactions
		
		completed_transactions = []
		transactions.each do |trans|
			if trans.completed
				completed_transactions << trans
			end
		end
		return completed_transactions
	end
	
	def uncompleted_transactions
		
		uncompleted_transactions = []
		transactions.each do |trans|
			if !trans.completed
				uncompleted_transactions << trans
			end
		end
		return uncompleted_transactions
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
	
	def execute_deposit(params)
  		transaction = Transaction.new(params)
  		transaction.amount = transaction.amount.to_d
  		transaction.trans_date = Date.today
    	
    	self.execute_transaction(transaction)
    	
  		 logger.info "Executing #{transaction.type} transactionddfd"
  		return transaction
  	end
  	
  	def execute_withdrawal(params)
  		transaction = Transaction.new(params)
  		transaction.amount = 0 - transaction.amount.to_d
  		transaction.trans_date = Date.today
    
      	self.execute_transaction(transaction)
      	
  		return transaction
  	end
  	
  	def execute_transaction(transaction)
  		transaction.completed = true
    	transaction.user_id = self.user_id
    	transaction.account = self
    	puts "Saving Transaction"
    	if transaction.save!
      		self.reload_transactions
  		end
 	end
 		
 	def removeAllTransactions()
    	transactions.each do |trans|
    		trans.destroy
  		end
  		self.reload_transactions
 	end
 	
 	def apply_rules
		transactions.each do |trans|
			rules.each do |rule|
				if rule.condition_match?(trans)
					rule.apply_action(trans)
					break
				end
			end
		end
		self.reload
	end
	
	def pocket_map(filtered_transactions)
	
		pocket_map = {}
		filtered_transactions.each do |trans|
			pocket_id = trans.pocket_id
			pocket_map[pocket_id] ||= 0
			pocket_map[pocket_id] = pocket_map[pocket_id] + trans.amount
		end
		return pocket_map
	end
	
	def month_pocket_map(filtered_transactions)
		
		month_pocket_map = {}
		filtered_transactions.each do |trans|
			pocket_id = trans.pocket_id
			if pocket_id.nil?
				p "NIL POCKET"
			end
			date = Date.new(trans.trans_date.year, trans.trans_date.month, 1)
			month_pocket_key = "#{(trans.trans_date.year*100) + trans.trans_date.month}_#{pocket_id}"
			month_total_key = "#{(trans.trans_date.year*100) + trans.trans_date.month}_-2"
			month_pocket_map[month_pocket_key] ||= 0
			month_pocket_map[month_pocket_key] = month_pocket_map[month_pocket_key] + trans.amount
		end
		return month_pocket_map
	end
	
 	protected
 	
 		#Called to prevent additional transaction from being created in set_previous_balance.
 		#self.previous_balance is set to new_balance.
 		#this method should only be called after from execute_transaction.
 		#Other updates require a new "reconcile" transaction to be created in set_previous_balance.
		def update_balance(new_balance)
			logger.info "UPDATING BALANCE. OLD BALANCE: #{self.balance}, NEW BALANCE: #{new_balance}"
	  		self.previous_balance = new_balance
	  		self.balance = new_balance
	  		self.save
	  		
	  	end
	  	
	  
	private
		#before_create
	    def initializate_previous_balance
			self.previous_balance = 0.0.to_d
	    end
	    
		#after_save
		def reconcile_balance
			
			if self.previous_balance != balance
			
				puts "OLD BALANCE: #{previous_balance} NEW BALANCE: #{balance}"
				balanceDiff = self.balance - self.previous_balance
			
				transaction = TransactionReconcile.new
				transaction.name = 'Account Reconciliation'
			    transaction.description = 'Account Reconciliation'
			    transaction.trans_date = Date.today
			    transaction.amount = balanceDiff.to_d
			    transaction.completed = true
			    transaction.account_id = id
			    transaction.user_id = user_id
		    
			    transaction.save
			    
			    self.reload_transactions
	    	end
		end
  	
end
