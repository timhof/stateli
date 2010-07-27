require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  
	fixtures :contracts, :transactions, :accounts
	
	def test_create_l5m_contract
		contract = ContractBimonthly.new(:name => contracts(:l5m).name, 
								:description => contracts(:l5m).description,
  								:date_start => contracts(:l5m).date_start,
  								:date_end => contracts(:l5m).date_end,
  								:type => contracts(:l5m).type,
  								:user_id => contracts(:l5m).user_id,
  								:autopay => contracts(:l5m).autopay,
  								:autopay_account_id => contracts(:l5m).autopay_account_id,
  								:full_date => contracts(:l5m).full_date,
  								:day_of_month => contracts(:l5m).day_of_month,
  								:day_of_month_alt => contracts(:l5m).day_of_month_alt,
  								:weekday => contracts(:l5m).weekday,
  								:active => contracts(:l5m).active,
  								:amount => contracts(:l5m).amount,
  								:transaction_type => contracts(:l5m).transaction_type)
		contract.save
		num_transactions = contract.transactions.size
		contract.save
		
		assert(contract.transactions.size == num_transactions, "Contract has #{contract.transactions.size} transactions")
		
		assert(contract.transactions.size == num_transactions, "Contract has #{contract.transactions.size} transactions")
		
		
		
	end
	
	def test_add_transaction
		contract = ContractOnce.new(:name => contracts(:oil).name, 
								:description => contracts(:oil).description,
  								:date_start => contracts(:oil).date_start,
  								:date_end => contracts(:oil).date_end,
  								:type => contracts(:oil).type,
  								:user_id => contracts(:oil).user_id,
  								:autopay => contracts(:oil).autopay,
  								:autopay_account_id => contracts(:oil).autopay_account_id,
  								:full_date => contracts(:oil).full_date,
  								:day_of_month => contracts(:oil).day_of_month,
  								:day_of_month_alt => contracts(:oil).day_of_month_alt,
  								:weekday => contracts(:oil).weekday,
  								:active => contracts(:oil).active,
  								:amount => contracts(:oil).amount,
  								:transaction_type => contracts(:oil).transaction_type)
		contract.save
		
		account = Account.new(:name => accounts(:chase).name, :description => accounts(:chase).name, 							  :type => accounts(:chase).type,  :balance => accounts(:chase).balance, 							   :active => accounts(:chase).active)
		account.save
		
		num_transactions = contract.transactions.size
		account_balance = account.balance
		
		contract.addTransaction({:description => transactions(:oil_delivery).description, 
											:trans_date => transactions(:oil_delivery).trans_date, 
											:amount => transactions(:oil_delivery).amount,
											:account => account})
											
		assert(contract.transactions.size == num_transactions+1, "Contract has #{contract.transactions.size} transactions")
		assert(account.balance != account_balance)
	end
end
