require 'test_helper'

class AccountTest < ActiveSupport::TestCase
 
	fixtures :accounts, :contracts, :transactions, :rules
	
	def test_create_account
		account = Account.new
		assert !account.save
	end
	
	def test_execute_transaction
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.save
		
		assert(chase_account.transactions.size == 1, "Account has #{chase_account.transactions.size} transactions")
		
		chase_account.execute_transaction(transactions(:oil_delivery))
		
		assert(chase_account.transactions.size == 2, "Account has #{chase_account.transactions.size} transactions")
	end
	
	def test_execute_deposit
		
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.save
		
		assert(chase_account.transactions.size == 1, "Account has #{chase_account.transactions.size} transactions")
		
		chase_account.execute_deposit({:name => transactions(:oil_delivery).name, :description => transactions(:oil_delivery).description, :trans_date => transactions(:oil_delivery).trans_date, :amount => transactions(:oil_delivery).amount, :account => transactions(:oil_delivery).account, :contract => transactions(:oil_delivery).contract, :user_id => transactions(:oil_delivery).user_id, :autopay => transactions(:oil_delivery).autopay})
		
		assert(chase_account.transactions.size == 2, "Account has #{chase_account.transactions.size} transactions")
		assert(chase_account.balance == (accounts(:chase).balance + transactions(:oil_delivery).amount), "Account has #{chase_account.transactions.size} transactions")
	end
	
	def test_execute_withdrawal
		
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.save
		
		assert(chase_account.transactions.size == 1, "Account has #{chase_account.transactions.size} transactions")
		
		chase_account.execute_withdrawal({:name => transactions(:oil_delivery).name, :description => transactions(:oil_delivery).description, :trans_date => transactions(:oil_delivery).trans_date, :amount => transactions(:oil_delivery).amount, :account => transactions(:oil_delivery).account, :contract => transactions(:oil_delivery).contract, :user_id => transactions(:oil_delivery).user_id, :autopay => transactions(:oil_delivery).autopay})
		
		assert(chase_account.transactions.size == 2, "Account has #{chase_account.transactions.size} transactions")
		assert(chase_account.balance == (accounts(:chase).balance - transactions(:oil_delivery).amount), "Account has #{chase_account.transactions.size} transactions")
	end
	
	
	def test_remove_transaction
	end
	
	def test_update_account_attributes
	end
	
	def test_create_chase_account
		account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, 							  :type => accounts(:chase).type,  :balance => accounts(:chase).balance, 							   :active => accounts(:chase).active)
		assert_not_nil(account.name, "Chase name is not nil")
	end
	
	def test_transaction_balances
		
		chase_account = Account.new(:name => accounts(:chase).name, 
									:description => accounts(:chase).description, 
									:type => accounts(:chase).type,  
									:balance => 0, 
									:active => accounts(:chase).active)
		chase_account.save
		
		puts "Chase Account Created: #{chase_account.id}!
		"
		assert(chase_account.transactions.size == 0, "Account has #{chase_account.transactions.size} transactions")
		
		l5m_contract = ContractBimonthly.new(:name => contracts(:l5m).name, 
								:description => contracts(:l5m).description,
  								:date_start => contracts(:l5m).date_start,
  								:date_end => contracts(:l5m).date_end,
  								:type => contracts(:l5m).type,
  								:user_id => contracts(:l5m).user_id,
  								:autopay => true,
  								:autopayAccount => chase_account,
  								:full_date => contracts(:l5m).full_date,
  								:day_of_month => contracts(:l5m).day_of_month,
  								:day_of_month_alt => contracts(:l5m).day_of_month_alt,
  								:weekday => contracts(:l5m).weekday,
  								:active => contracts(:l5m).active,
  								:amount => contracts(:l5m).amount,
  								:transaction_type => contracts(:l5m).transaction_type)
		l5m_contract.save
		
		puts "L5M Contract Created!"
		
		mortgage_contract = ContractMonthly.new(:name => contracts(:mortgage).name, 
								:description => contracts(:mortgage).description,
  								:date_start => contracts(:mortgage).date_start,
  								:date_end => contracts(:mortgage).date_end,
  								:type => contracts(:mortgage).type,
  								:user_id => contracts(:mortgage).user_id,
  								:autopay => true,
  								:autopayAccount => chase_account,
  								:full_date => contracts(:mortgage).full_date,
  								:day_of_month => contracts(:mortgage).day_of_month,
  								:day_of_month_alt => contracts(:mortgage).day_of_month_alt,
  								:weekday => contracts(:mortgage).weekday,
  								:active => contracts(:mortgage).active,
  								:amount => contracts(:mortgage).amount,
  								:transaction_type => contracts(:mortgage).transaction_type)
		mortgage_contract.save
		
		puts "Mortage Contract Created!"
		
		assert(chase_account.transactions.size == 0, "Account has #{chase_account.transactions.size} transactions")
		chase_account.reload_transactions()
		assert(chase_account.transactions.size == 36, "Account has #{chase_account.transactions.size} transactions")
		
		assert(l5m_contract.transactions.size == 24, "L5M Contract has #{l5m_contract.transactions.size} transactions")
		l5m_contract.transactions.each do |trans|
			trans.complete
		end
		puts "L5M Transactions paid!"
		
		chase_account.reload_transactions()
		assert(chase_account.balance == 65081.52.to_d, "Balance = #{chase_account.balance}")
		
		assert(mortgage_contract.transactions.size == 12, "Mortgage Contract has #{mortgage_contract.transactions.size} transactions")
		for trans in mortgage_contract.transactions do
			trans.complete
		end
		puts "Mortgage Transactions paid!"
		
		chase_account.reload_transactions()
		assert(chase_account.balance == (30536.76.to_d + 65081.52.to_d), "Balance = #{chase_account.balance}")
		
		assert(chase_account.completed_transactions[-1].account_balance == chase_account.balance, "#{chase_account.id} - Transaction balance: #{chase_account.transactions[-1].account_balance}, Account balance: #{chase_account.balance}")
	end
	
	def test_transaction_balances_unpaid
		
		chase_account = Account.new(:name => accounts(:chase).name, 
									:description => accounts(:chase).description, 
									:type => accounts(:chase).type,  
									:balance => 0, 
									:active => accounts(:chase).active)
		chase_account.save
		
		puts "Chase Account Created: #{chase_account.id}!
		"
		assert(chase_account.transactions.size == 0, "Account has #{chase_account.transactions.size} transactions")
		
		l5m_contract = ContractBimonthly.new(:name => contracts(:l5m).name, 
								:description => contracts(:l5m).description,
  								:date_start => contracts(:l5m).date_start,
  								:date_end => contracts(:l5m).date_end,
  								:type => contracts(:l5m).type,
  								:user_id => contracts(:l5m).user_id,
  								:autopay => true,
  								:autopayAccount => chase_account,
  								:full_date => contracts(:l5m).full_date,
  								:day_of_month => contracts(:l5m).day_of_month,
  								:day_of_month_alt => contracts(:l5m).day_of_month_alt,
  								:weekday => contracts(:l5m).weekday,
  								:active => contracts(:l5m).active,
  								:amount => contracts(:l5m).amount,
  								:transaction_type => contracts(:l5m).transaction_type)
		l5m_contract.save
		
		puts "L5M Contract Created!"
		
		mortgage_contract = ContractMonthly.new(:name => contracts(:mortgage).name, 
								:description => contracts(:mortgage).description,
  								:date_start => contracts(:mortgage).date_start,
  								:date_end => contracts(:mortgage).date_end,
  								:type => contracts(:mortgage).type,
  								:user_id => contracts(:mortgage).user_id,
  								:autopay => true,
  								:autopayAccount => chase_account,
  								:full_date => contracts(:mortgage).full_date,
  								:day_of_month => contracts(:mortgage).day_of_month,
  								:day_of_month_alt => contracts(:mortgage).day_of_month_alt,
  								:weekday => contracts(:mortgage).weekday,
  								:active => contracts(:mortgage).active,
  								:amount => contracts(:mortgage).amount,
  								:transaction_type => contracts(:mortgage).transaction_type)
		mortgage_contract.save
		
		chase_account.reload_transactions()
		
		puts "Chase balance: #{chase_account.balance}!"
		puts "Chase has #{chase_account.transactions.size} Transactions!"
		
		assert(chase_account.transactions.size > 0, "Account has #{chase_account.transactions.size} transactions")

		assert(chase_account.balance == 0, "#{chase_account.id} - Balance: #{chase_account.balance}")
		
	end
	
	def test_upload_file
		filename = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/transactionDataStore.xml")
		
		transactionUploader = TransactionUploader.new
		new_transactions = transactionUploader.parseTransactions(filename)
   		new_transactions.each do |trans|
   			p trans	
   		end
  		assert(new_transactions.size > 0, "#{new_transactions.size} TRANSACTIONS")
	end
	
	def test_account_upload_transactions_xml
		filename = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/transactionDataStore.xml")
		
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.add_upload_transactions(filename)
		
		assert(chase_account.transactions.size > 0, "#{chase_account.transactions.size} TRANSACTIONS")
	end
	
	def test_account_upload_transactions_chase
		filename = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/chaseAccountDetails.html")
		
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.add_upload_transactions(filename, 'Chase')
		
		assert(chase_account.transactions.size > 0, "#{chase_account.transactions.size} TRANSACTIONS")
	end

	def test_account_upload_transactions_boa
		filename = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/january.html")
		
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.add_upload_transactions(filename, 'BOA')
		
		assert(chase_account.transactions.size > 0, "#{chase_account.transactions.size} TRANSACTIONS")
	end
	
	def test_reject_duplicate_uploaded_transactions
		filename = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/chaseAccountDetails.html")
		
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.save
		
		chase_account.add_upload_transactions(filename, 'Chase')
		
		num_transactions = chase_account.transactions.size
		
		chase_account.add_upload_transactions(filename, 'Chase')
		
		assert(chase_account.transactions.size == num_transactions, "#{chase_account.transactions.size} TRANSACTIONS")
	end
	
	def uploaded_file(path, content_type="text/xml", filename=nil)
 		filename ||= File.basename(path)
  		t = Tempfile.new(filename)
  		FileUtils.copy_file(path, t.path)
  		(class << t; self; end;).class_eval do
    		alias local_path path
    		define_method(:original_filename) { filename }
    		define_method(:content_type) { content_type }
  		end
 		return t
	end
	
	def test_upload_apply_rules
		
		puts "HERE"
		filename = uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/JPMC.CSVg", "text")
		
		chase_account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, :type => accounts(:chase).type, :balance => accounts(:chase).balance, :active => accounts(:chase).active)
		
		chase_account.save
		
		chase_account.add_upload_transactions(filename, 'Chase')
		
		assert(chase_account.transactions.size > 0, "#{chase_account.transactions.size} TRANSACTIONS")
		
		rule = RuleName.new(:name => rules(:boa_payment).name, :comp_type => rules(:boa_payment).comp_type, :comp_string => rules(:boa_payment).comp_string, :comp_date => rules(:boa_payment).comp_date, :comp_action => rules(:boa_payment).comp_action, :type => rules(:boa_payment).type, :rank => rules(:boa_payment).rank, :contract_id => rules(:boa_payment).contract_id)
		
		chase_account.rules << rule
		
		chase_account.apply_rules
	end
end
