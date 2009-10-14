class Transaction < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :sourceAccount, :foreign_key => 'account_id_source', :class_name => 'Account'
	belongs_to :destinationAccount, :foreign_key => 'account_id_dest', :class_name => 'Account'
	belongs_to :contract
	
	named_scope :user_only, lambda { |user_id| { :conditions => { :user_id => user_id } }}
	named_scope :account_credit, lambda { |account_id| { :conditions => ["account_id_source = :account and type = :type", {:account => account_id, :type => 'TransactionCredit'}]  }}
	named_scope :account_debit, lambda { |account_id| { :conditions => ["account_id_dest = :account and type = :type", {:account => account_id, :type => 'TransactionDebit'}] }}
	named_scope :account_any_type, lambda { |account_id| { :conditions => ["account_id_dest = :account or account_id_source = :account", {:account => account_id}] }}
	named_scope :account_reconcile, lambda { |account_id| { :conditions => ["account_id_dest = :account and account_id_dest = :account and type = :type", {:account => account_id, :type => 'TransactionReconcile'}] }}
	
	named_scope :executed_within, lambda { |start_date, end_date| { :conditions => ["executed_date >= :start_date and executed_date <= :end_date", {:start_date => start_date, :end_date => end_date}] }}
	named_scope :scheduled_within, lambda { |start_date, end_date| { :conditions => ["scheduled_date >= :start_date and scheduled_date <= :end_date", {:start_date => start_date, :end_date => end_date}] }}
	
	named_scope :transaction_credit, {:conditions => ["type = :type", {:type => 'TransactionCredit'}]}
	named_scope :transaction_debit, {:conditions => ["type = :type", {:type => 'TransactionDebit'}]}
	named_scope :transaction_reconcile, {:conditions => ["type = :type", {:type => 'TransactionReconcile'}]}
	
	named_scope :completed, {:conditions => ['completed = :completed', {:completed => true}]}
	named_scope :uncompleted, {:conditions => ['completed = :completed', {:completed => false}]}
	named_scope :overdue, {:conditions => ['scheduled_date < :date_today', {:date_today => Date.today}]}
	
	attr_accessor :account_balance
	
	validates_presence_of :name, :amount, :scheduled_date
	validates_numericality_of :amount
	
	def self.account_has_overdue(account_id)
		count_credit = account_credit(account_id).uncompleted.overdue.count
		count_debit = account_debit(account_id).uncompleted.overdue.count
		return count_credit > 0 || count_debit > 0
	end
	
	def self.account_has_incomplete(account_id)
		count_credit = account_credit(account_id).uncompleted.count
		count_debit = account_debit(account_id).uncompleted.count
		return count_credit > 0 || count_debit > 0
	end

	
	def self.account_credit_completed(account_id)
		transactions = account_credit(account_id).completed.find(:all, :order => "executed_date")
	end
	
	def self.account_credit_uncompleted_by_account_date(account_id, start_date, end_date)
		transactions = account_credit(account_id).uncompleted.scheduled_within(start_date, end_date).find(:all, :order => "scheduled_date")
	end
	
	def self.account_debit_completed(account_id)
		transactions = account_debit(account_id).completed.find(:all, :order => "executed_date")
	end
	
	def self.account_debit_uncompleted_by_account_date(account_id, start_date, end_date)
		transactions = account_debit(account_id).uncompleted.scheduled_within(start_date, end_date).find(:all, :order => "scheduled_date")
	end
	
	def self.account_reconcile_completed(account_id)
		transactions = account_reconcile(account_id).completed.find(:all, :order => "executed_date")
	end
	
	def self.account_reconcile_uncompleted(account_id)
		transactions = account_reconcile(account_id).uncompleted.find(:all, :order => "scheduled_date")
	end
	
	def overdue?
		self.scheduled_date < Date.today && !self.completed
	end
	
	def self.completed_by_account_date(account_id, start_date, end_date)
		transactions = completed.account_any_type(account_id).executed_within(start_date, end_date).find(:all,  :order => "executed_date ASC")
	end
	
	def self.uncompleted_by_account_date(account_id, start_date, end_date)
		transactions = uncompleted.account_any_type(account_id).scheduled_within(start_date, end_date).find(:all, :order => "scheduled_date ASC")
	end
	
	def self.completed_by_account(account_id)
		transactions = completed.account_any_type(account_id).find(:all,  :order => "executed_date ASC")
	end
	
	def self.uncompleted_by_account(account_id)
		transactions = uncompleted.account_any_type(account_id).find(:all, :order => "scheduled_date ASC")
	end
	
	def self.completed_by_user(userId)
		transactions = user_only(userId).completed.find(:all, :order => "executed_date ASC")
		Account.set_account_balances(transactions);
		return transactions
	end
	
	def self.uncompleted_by_user(userId)
		transactions = user_only(userId).uncompleted.find(:all, :order => "scheduled_date ASC")
		Account.set_account_balances(transactions);
		return transactions
	end
	
	def self.uncompleted_by_date_user(userId, start_date, end_date)
		transactions = user_only(userId).uncompleted.scheduled_within(start_date, end_date).find(:all, :order => "scheduled_date ASC")
	end
	
	def self.credit_uncompleted_by_date_user(userId, start_date, end_date)
		transactions = user_only(userId).transaction_credit.uncompleted.scheduled_within(start_date, end_date).find(:all, :order => "scheduled_date ASC")
	end
	
	def self.debit_uncompleted_by_date_user(userId, start_date, end_date)
		transactions = user_only(userId).transaction_debit.uncompleted.scheduled_within(start_date, end_date).find(:all, :order => "scheduled_date ASC")
	end
	
	def to_xml(options = {})
      options[:indent] ||= 2
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.transaction do
       	xml.tag!(:name, self.name)
       	xml.tag!(:description, self.description)
       	xml.tag!(:scheduled_date, self.scheduled_date)
       	xml.tag!(:executed_date, self.executed_date)
       	xml.tag!(:amount, self.amount)
       	xml.tag!(:account_balance, self.account_balance)
       	
      end
    end

end
