class StateliController < ApplicationController
	
  before_filter :login_required, :except => ['index', 'signup', 'register', 'cancel_popup']
  
  def index
  	respond_to do |format|
      format.html # index.html.erb
    end
  end
   
  def account_listing
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

  def account_history
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
  
  def account_pending
  	@account = Account.find(params[:id])
  	@account.set_overdue_transactions()
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
  
  def transactions_pending
  	
  	@start_date = params[:start_date]
  	if @start_date.nil?
  		@start_date = Date.today
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today >> 12
  	end
  	
  	@transactions = Account.uncompleted_transactions_all_accounts_by_date(@current_user.id, @start_date, @end_date)
  	
  	@navkey = "pending"
	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => @transactions }
      format.js { render :action => "update_transactions_pending" }
    end
    
  end
  
   def account_journal
  	@account = Account.find(params[:id])
  	@account.set_overdue_transactions()
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
  
  def account_journal_flex
  	
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
  
  def account_pending_flex
  	
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
  
  def get_pending_psuedo_transaction(transaction_list, user_id, pending_end_date)
  	
	end_balance = 0
	transaction_list.each do |trans|
		end_balance = end_balance + trans.amount
	end
	
	trans = Transaction.new
	trans.scheduled_date = pending_end_date.to_s
	trans.executed_date = pending_end_date.to_s
	trans.completed = false
	trans.user_id = user_id
	trans.name = "end"
	trans.description = "end"
	trans.amount = 0
	trans.account_balance = end_balance
	return trans
		
  end
  
  def total_journal_flex

	@start_date = params[:start_date]
  	if @start_date.nil?
  		@start_date = Date.today >> -12
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today
  	end
  	
	transactions = Transaction.completed_by_user(@current_user.id)

	@navkey = "flex"
	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => {:records => transactions, :startdate => @start_date.to_s, :enddate => @end_date.to_s} }
    end
    
  end
  
  def total_pending_flex
	
	if @start_date.nil?
  		@start_date = Date.today
  	end
  	@end_date = params[:end_date]
  	if @end_date.nil?
  		@end_date = Date.today >> 12
  	end
	
  	transactions = Transaction.uncompleted_by_user(@current_user.id)
		
	@navkey = "flex"
	
  	respond_to do |format|
      format.html # entries.html.erb
      format.xml  { render :xml => {:records => transactions, :startdate => @start_date.to_s, :enddate => @end_date.to_s} }
    end
    
  end
  
  def account_withdraw
  	@account = Account.find(params[:id])
  	@transaction = TransactionCredit.new
  end
  
  def account_deposit
  	@account = Account.find(params[:id])
  	@transaction = TransactionDebit.new
  end
  
  def account_new_account
  	 @account = Account.new
	@navkey = "account_new"
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
      format.js
    end
  end
  
  def account_create_account
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
        format.html { redirect_to listing_path }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
        format.js
      else
        format.js { render :action => "account_new_account" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def execute_withdraw
  	@account = Account.find(params[:id])
  	@transaction = TransactionCredit.new(params[:transaction])
  	@transaction.scheduled_date = Date.today
    @transaction.executed_date = Date.today
    @transaction.completed = true
    @transaction.user_id = @account.user_id
    @transaction.account_id_source = @account.id
    
    respond_to do |format|
      if @transaction.save
      	
      	@account.updateBalance(@transaction)
    
        flash[:notice] = 'Withdraw was successfully executed.'
        format.html { redirect_to listing_url }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
        format.js {render :action => "execute_transaction"}
      else
        format.html { render :action => "withdraw" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def execute_deposit
  	@account = Account.find(params[:id])
  	@transaction = TransactionDebit.new(params[:transaction])
  	@transaction.scheduled_date = Date.today
    @transaction.executed_date = Date.today
    @transaction.completed = true
    @transaction.user_id = @account.user_id
    @transaction.account_id_dest = @account.id
    
    respond_to do |format|
    	
      if @transaction.save
      	
      	@account.updateBalance(@transaction)
      	
        flash[:notice] = 'Deposit was successfully executed.'
        format.html {redirect_to(listing_url)}
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
        format.js {render :action => "execute_transaction"}
      else
        format.html { render :action => "deposit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def account_edit
    @account = Account.find(params[:account_id])
  end

  def account_update
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
      if @account.update_attributes(params[:account])
      	
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
  
  def autopay
 
    @transaction = Transaction.find(params[:transaction_id])
    @transaction.executed_date = @transaction.scheduled_date
    @transaction.completed = true
						
    @account_changed = false
    			
    respond_to do |format|
      if @transaction.save
      	
      	if(@transaction.type == 'TransactionCredit')
      		@account = @transaction.sourceAccount
  		elsif(@transaction.type == 'TransactionDebit')
  			@account = @transaction.destinationAccount
  		end
  		
      	@account.updateBalance(@transaction)
      	
        flash[:notice] = 'Transaction was successfully updated.'
        format.html { redirect_to(pending_path(params[:account_id])) }
        format.js { render :action => "transaction_update"}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def expense_listing
    @contracts = Contract.activeCreditContracts(@current_user.id)
	logger.info "#{@contracts.size} Credit Contracts"
	
	@navkey = "expenses"
	@navsubkey = "listing"
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contracts }
    end
  end
  
  def income_listing
    @contracts = Contract.activeDebitContracts(@current_user.id)
    logger.info "#{@contracts.size} Debit Contracts"
    
	@navkey = "income"
	@navsubkey = "listing"
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contracts }
    end
  end
  
  def contract_credit
  	@contract = Contract.new
  	@navkey = "add_bill"
  end
  
  def contract_debit
  	@contract = Contract.new
  	@navkey = "add_income"
  end
  
  def build_contract_credit
  
  	logger.info "BUILDING CREDIT CONTRACT"
	@contract = build_new_contract
	@contract.transaction_type = 'TransactionCredit'
	
    respond_to do |format|
      if @contract.save
        flash[:notice] = 'Contract was successfully created.'
        format.html { redirect_to(contract_path(@contract)) }
        format.xml  { render :xml => @contract, :status => :created, :location => @contract }
        format.js {render :action => "build_contract"}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contract.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def build_contract_debit
  
  	logger.info "BUILDING DEBIT CONTRACT"
	@contract = build_new_contract
	@contract.transaction_type = 'TransactionDebit'
	
    respond_to do |format|
      if @contract.save
        flash[:notice] = 'Contract was successfully created.'
        format.html { redirect_to(contract_path(@contract)) }
        format.xml  { render :xml => @contract, :status => :created, :location => @contract }
        format.js {render :action => "build_contract"}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contract.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def build_new_contract
  	contractType =  params[:contract][:type]
    if contractType == 'ContractYearly'
		contract = ContractYearly.new(params[:contract])
	elsif contractType == 'ContractMonthly'
		contract = ContractMonthly.new(params[:contract])
	elsif contractType == 'ContractBimonthly'
		contract = ContractBimonthly.new(params[:contract])
	elsif contractType == 'ContractWeekly'
		contract = ContractWeekly.new(params[:contract])
	elsif contractType == 'ContractOnce'
		contract = ContractOnce.new(params[:contract])
	end
	
	logger.info "CONTRACT TYPE: #{contract.type}"
	contract.user_id = @current_user.id
	return contract
  end
  
  def transaction_edit
    @transaction = Transaction.find(params[:transaction_id])
  end
  
  def transaction_do
    @transaction = Transaction.find(params[:transaction_id])
  end
  
  def transaction_update
  	@transaction = Transaction.find(params[:transaction_id])
	@transaction.user_id = @current_user.id
	
	@account_changed = false
	param_acc_dest = params[:transaction][:account_id_dest]
	param_acc_src = params[:transaction][:account_id_source]
	if param_acc_dest && @transaction.account_id_dest != param_acc_dest.to_i
		logger.info "Destination Account exists but not equal"
		logger.info "Original Destination Account: #{@transaction.account_id_dest}"
		logger.info "     New Destination Account: #{param_acc_dest}"
		@account_changed = true
	end
	if param_acc_src && @transaction.account_id_source != param_acc_src.to_i
		logger.info "Source Account exists but not equal"
		@account_changed = true
	end
    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
      	
        flash[:notice] = 'Transaction was successfully updated.'
        format.html { redirect_to(journal_path(params[:account_id])) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :actionF => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def transaction_complete
    @transaction = Transaction.find(params[:transaction_id])
	@transaction.user_id = @current_user.id
	@transaction.executed_date = Date.today
	@transaction.completed = true;
						
	if @transaction.type == 'TransactionCredit'
		@account = Account.find(params[:account_id_source])
	elsif @transaction.type == 'TransactionDebit'
		@account = Account.find(params[:account_id_dest])
	end
	
    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
      
      	@account.updateBalance(@transaction)
      	
        flash[:notice] = 'Transaction was successfully updated.'
        format.html { redirect_to(pending_path(@account.id)) }
        format.xml  { head :ok }
        format.js { render :action => "transaction_update"}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def cancel_popup
  	
  end
    
  def transaction_details
    @transaction = Transaction.find(params[:id])
	@title = @transaction.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction }
    end
  end
  
  def contract_details
    @contract = Contract.find(params[:id])
	@title = @contract.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contract }
    end
  end
  
  def clean_transactions
    @transaction = Transaction.delete_all

    respond_to do |format|
      format.html { redirect_to(transactions_url) }
      format.xml  { head :ok }
    end
  end
  
  def account_details
    @account = Account.find(params[:id])
	@title = @account.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  def signup
    @user = User.new
  end
  
  
  def register
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'signup'
    end
  end
end
