require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  class AccountsController < ApplicationController
	
  before_filter :login_required
   	
  def test_account_listing
    @accountsDebit = AccountDebit.activeAccounts(@current_user.id)
    logger.info "#{@accountsDebit.size} Debit Accounts"
	@accountsCredit = AccountCredit.activeAccounts(@current_user.id)
	logger.info "#{@accountsCredit.size} Credit Accounts"
	
	@navkey = "accounts"
	@navsubkey = "listing"
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  def test_account_history
  	@account = Account.find(params[:id])
  	transaction_hash = @account.completed_transaction_hash(Date.today, Date.today)
  	@transactions_credit = transaction_hash[:credit]
  	@transactions_debit = transaction_hash[:debit]
  	@transactions_reconcile = transaction_hash[:reconcile]
  	
  	@navkey = "accounts"
	@navsubkey = "listing"
	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => @accounts }
    end
    
  end
  

  def test_account_pending
  	@account = Account.find(params[:id])
  	@start_date = params[:start_date]
  	if @start_date.nil?
  		@start_date = Date.today
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today >> 12
  	end
  	
  	transaction_hash = @account.uncompleted_transaction_hash(@start_date, @end_date)
  	@transactions_credit = transaction_hash[:credit]
  	@transactions_debit = transaction_hash[:debit]
  	
  	@navkey = "accounts"
	@navsubkey = "listing"
	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => @accounts }
      format.js {render :action => "update_pending"}
    end
    
  end
  
  def test_account_journal
  	@account = Account.find(params[:id])
  	@start_date = params[:start_date]
  	if @start_date.nil?
  		@start_date = Date.today >> -12
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today
  	end
  	
  	transactions_asc = @account.completed_transactions_by_date(@start_date, @end_date)
  	
  	@transactions = transactions_asc.reverse
  	@navkey = "accounts"
	@navsubkey = "listing"
	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => @accounts }
      format.js { render :action => "update_journal" }
    end
    
  end
  
  #Displays popup form (Ajax)
  def test_account_withdraw
  	@account = Account.find(params[:id])
  	@transaction = TransactionCredit.new
  	@start_date = params[:start_date]
  	@end_date = params[:end_date]
  	respond_to do |format|
      format.js
    end
  end
  
  #Displays popup form (Ajax)
  def test_account_deposit
  	@account = Account.find(params[:id])
  	@transaction = TransactionDebit.new
  	@start_date = params[:start_date]
  	@end_date = params[:end_date]
  	respond_to do |format|
      format.js
    end
  end
  
  #Displays popup form (Ajax)
  def test_account_new_account
  	 @account = Account.new
	@navkey = "account_new"
    respond_to do |format|
      format.js
    end
  end
  
  def test_account_create_account
  	accountType = params[:account][:type]
	if accountType == 'AccountDebit'
		 @account = AccountDebit.new(params[:account])
	elsif accountType == 'AccountCredit'
		 @account = AccountCredit.new(params[:account])
	end
	
	@account.user_id = @current_user.id
	
    respond_to do |format|
    	logger.info "FORMAT: #{format}"
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.js
      else
        format.js { render :action => "account_new_account" }
      end
    end
  end
  
  def test_execute_transaction
  	
  	@account = Account.find(params[:id])
  	type = params[:type]
  	if type == 'TransactionCredit'
  		@transaction = @account.execute_withdrawal(params[:transaction])
  	else
  		@transaction = @account.execute_deposit(params[:transaction])
	end
	
  	start_date = params[:start_date]
  	end_date = params[:end_date]
  	logger.info "START DATE: #{start_date}"
  	unless start_date.nil?
  		transactions_asc = @account.completed_transactions_by_date(start_date, end_date)
  		logger.info "TRANSACTIONS: #{transactions_asc.size}"
  		@transactions = transactions_asc.reverse
  	end
  	
    respond_to do |format|
    
        flash[:notice] = 'Transaction was successfully executed.'
        format.js {render :action => "execute_transaction"}
    end
  end
  
  def test_account_edit
    @account = Account.find(params[:account_id])
  end

  def test_account_update
  	@account = Account.find(params[:account_id])
	@account.user_id = @current_user.id
	
	@start_date = params[:start_date]
  	if @start_date.nil?
  		@start_date = Date.today >> -12
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today
  	end
  	
	
    respond_to do |format|
      if @account.update_account_attributes(params[:account])
      	
      	transactions_asc = @account.completed_transactions_by_date(@start_date, @end_date)
  		@journal_transactions = transactions_asc.reverse
  	
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to(account_path(params[:account_id])) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
    def test_account_journal_flex
  	
  	accountsDebit = AccountDebit.activeAccounts(@current_user.id)
    logger.info "#{accountsDebit.size} Debit Accounts"
	
	@start_date = params[:start_date]
  	if @start_date.nil?
  		@start_date = Date.today >> -12
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today
  	end
  	
	debit_account_array = [];
  	accountsDebit.each do |acc|
  		transactions = acc.completed_transactions
  		logger.info "#{transactions.size} Transactions"
  		account_hash = {:account => acc, :transactions => transactions}
  		debit_account_array << account_hash
  	end
  	
  	@navkey = "flex"
  	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => {:debits => debit_account_array, :startdate => @start_date.to_s, :enddate => @end_date.to_s} }
    end
    
  end
  
  def test_account_pending_flex
  	
  	accountsDebit = AccountDebit.activeAccounts(@current_user.id)
    logger.info "#{accountsDebit.size} Debit Accounts"
	
	if @start_date.nil?
  		@start_date = Date.today
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today >> 12
  	end
	
	debit_account_array = [];
  	accountsDebit.each do |acc|
		
		transactions = acc.uncompleted_transactions()
		
		trans = get_pending_psuedo_transaction(transactions, acc.user_id, Date.today >> 120)
		transactions << trans
		
		account_hash = {:account => acc, :transactions => transactions}
		debit_account_array << account_hash
	
	end
 
  	@navkey = "flex"
  	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => {:debits => debit_account_array, :startdate => @start_date.to_s, :enddate => @end_date.to_s} }
    end
    
  end
  
  def test_account_details
  	get :account_details, {}, {}
  	assert_reponse :success
  	assert_template :show
    @account = Account.find(params[:id])
	@title = @account.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end
end

end
