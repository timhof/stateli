class AccountsController < ApplicationController
	
  before_filter :login_required
   	
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.user_only(@current_user.id).find(:all)
    @accountsDebit = AccountDebit.user_only(@current_user.id).find(:all)
	@accountsCredit = AccountCredit.user_only(@current_user.id).find(:all)
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end
  
  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
   accountType = params[:account][:type]
	if accountType == 'AccountDebit'
		 @account = AccountDebit.new(params[:account])
	elsif accountType == 'AccountCredit'
		 @account = AccountCredit.new(params[:account])
	end
	
	@account.user_id = @current_user.id
	
    respond_to do |format|
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to(account_path(@account)) }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:id])

	@account.user_id = @current_user.id
    
    respond_to do |format|
    	
      if @account.update_attributes(params[:account])
        flash[:notice] = 'Account was successfully updated.'
        
        format.html { redirect_to(account_path(@account)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  
  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
  
end
