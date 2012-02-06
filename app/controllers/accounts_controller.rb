class AccountsController < ApplicationController
  
  include StateliHelper
  
  before_filter :login_required
   	
  def index
    @accounts = Account.activeAccounts(@current_user.id)
   
	@navkey = "accounts"
	session[SESSION_MAIN_PAGE] = MAIN_PAGE_LISTING_ACCOUNTS
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end
  
  def journal
  	@account = Account.find(params[:id])
  	respond_to do |format|
      format.html # journal.html.erb
    end
  end
  
  def delete_log
  	
  	@account = Account.find(params[:id])
	@transactions = @account.deleted_transactions
	
	@showBalance = true
  	respond_to do |format|
      format.html # delete_log.html.erb
    end
  end
  
  def month_pocket_journal
  	@account = Account.find(params[:id])
  	set_filtered_transactions
  	yrMonth = params[:yrMonth].to_i
  	if yrMonth == -1
  		@year =-1
  		@month = -1
  	else
  		@year = yrMonth / 100
  		@month = yrMonth % 100
  	end
  	unless params[:pocket_id] == '-1'
  		@pocket = Pocket.find_pocket(params[:pocket_id])
  	end
  	
  	@transactions = @filtered_transactions.select do |trans|
  		pocket_id = trans.pocket_id
  		(@pocket.nil? || pocket_id == @pocket.id) && (@month == -1 || (trans.trans_date.month == @month && trans.trans_date.year == @year))
  	end
  end
  
  def month_pocket_totals

  	@account = Account.find(params[:id])
  	set_filtered_transactions
  	@month_pocket_totals = @account.month_pocket_map(@filtered_transactions)
  	months_hash = {}
  	pockets_hash = {}
  	@month_totals = {}
  	@pocket_totals = {}
  	@grand_total = 0
	@month_pocket_totals.each do |month_pocket_key, total|
		month_pocket_arr = month_pocket_key.split(/_/)
		month = month_pocket_arr[0].to_i
		pocket = month_pocket_arr[1].to_i
		months_hash[month] = 1
		pockets_hash[pocket] = 1
		
		@month_totals[month] ||= 0
		@month_totals[month] = @month_totals[month] + total
		
		@pocket_totals[pocket] ||= 0
		@pocket_totals[pocket] = @pocket_totals[pocket] + total
		
		@grand_total = @grand_total + total
		
	end
	temp_months = months_hash.keys.sort
	@months = []
	next_yrMonth = -1
	temp_months.each do |yrMonth|
		
		while next_yrMonth > 0 && next_yrMonth != yrMonth
			@months << next_yrMonth
			next_yrMonth = get_next_yrMonth(next_yrMonth)
		end
		@months << yrMonth
		next_yrMonth = get_next_yrMonth(yrMonth)
	end
	@pockets = pockets_hash.keys.sort
	p @months
	p @pockets
	
  	respond_to do |format|
      format.html # pocket_totals.html.erb
      format.js {render :action => 'update_filter', :layout => false}
    end
  end
  
  def get_next_yrMonth(yrMonth)
  	year = (yrMonth / 100)
	month = (yrMonth % 100) + 1
	if month > 12
		month = 1
		year = year + 1
	end
	next_yrMonth = ((year*100)+month)
  end
  
  def set_filtered_transactions
  	if params[:filter_commit].eql?('update')
  		reselect_filters
  	end
  	@account = Account.find(params[:id])
  	@filtered_transactions = @account.filtered_transactions(session[:selector])
	p "#{@filtered_transactions.length} TRANSACTIONS" 
	
  end
  
  def reselect_filters
  	@account = Account.find(params[:id])
  	logger.info "RESELECTING FILTERS"
	@account.transactions.each do |trans| 
		pocket_id = trans.pocket_id
		if (not params[:pocket_id].nil?) && (params[:pocket_id][pocket_id.to_s] == '1')
			session[:selector].selectedPockets[pocket_id] = '1'
		else
			session[:selector].selectedPockets[pocket_id] = '0'
		end
	end
	
	session[:selector].startDate = Date.parse(params[:start_date_field])
	session[:selector].endDate = Date.parse(params[:end_date_field]) + 1
	session[:selector].show_incomplete = params[:show_incomplete]
  end
  
  #Displays popup form (Ajax)
  def withdraw
  	@account = Account.find(params[:id])
  	@transaction = Transaction.new
  	@type = TRANSACTION_CREDIT
  	respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  #Displays popup form (Ajax)
  def deposit
  	@account = Account.find(params[:id])
  	@transaction = Transaction.new
  	@type = TRANSACTION_DEBIT
  	respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  #Displays popup form (Ajax)
  def new
  	@account = Account.new
	@navkey = "account_new"
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  def create
  	@account = Account.new(params[:account])
	
	@account.user_id = @current_user.id
	
    respond_to do |format|
    	logger.info "FORMAT: #{format}"
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to(accounts_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def execute_transaction
  	
  	@account = Account.find(params[:id])
  	type = params[:type]
  	logger.info "TYPE: #{type}"
  	if type == TRANSACTION_CREDIT
  		@transaction = @account.execute_withdrawal(params[:transaction])
  	else
  		@transaction = @account.execute_deposit(params[:transaction])
	end
 	
    respond_to do |format|
        flash[:notice] = 'Transactions executed'
        format.html { redirect_to(account_journal_url(@account)) }
    end
  end
  
  def edit
    @account = Account.find(params[:id])
  end

  def update
  	@account = Account.find(params[:id])
	@account.user_id = @current_user.id

    respond_to do |format|
      if @account.update_account_attributes(params[:account])
        flash[:notice] = 'Account updated'
        format.html { redirect_to(accounts_url) }
   	  else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def show
    @account = Account.find(params[:id])
	@title = @account.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  def upload_file
  	
  	account = Account.find(params[:id])
  	account.add_upload_transactions(params[:file], params[:upload_type])
	account.apply_rules
	account.reload_transactions
	session[:selector].confirm_pocket_data
	respond_to do |format|
        flash[:notice] = 'File successfully uploaded'
        format.html { redirect_to(accounts_url) }
    end
  end
  
  def apply_rules
  	account = Account.find(params[:id])
  	account.apply_rules
	account.reload_transactions
    session[:selector].confirm_pocket_data
  	respond_to do |format|
        flash[:notice] = 'Rules applied'
        format.html { redirect_to(account_journal_url(account.id)) }
    end
  end
  
  def show_upload
    @account = Account.find(params[:id])
  end
  
  def delete_all_transactions
  	@account = Account.find(params[:id])
  	@account.removeAllTransactions()
  	respond_to do |format|
        flash[:notice] = 'Transactions deleted'
        format.html { redirect_to(accounts_url) }
    end
  end
  
  def destroy
    @account = Account.find(params[:id])
    @account.destroy
	
    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
  
  private 
  
   def get_pending_psuedo_transaction(transaction_list, user_id, pending_end_date)
  	
	end_balance = 0.0.to_d
	transaction_list.each do |trans|
		end_balance = end_balance + trans.amount
	end
	
	trans = Transaction.new
	trans.trans_date = pending_end_date.to_s
	trans.completed = false
	trans.user_id = user_id
	trans.name = "end"
	trans.description = "end"
	trans.amount = 0.0
	trans.account_balance = end_balance
	return trans
		
  end
end
