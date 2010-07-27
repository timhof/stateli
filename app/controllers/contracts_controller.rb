class ContractsController < ApplicationController
  include StateliHelper
  
  before_filter :login_required
  
  def index

  	@account = Account.find(params[:account_id])
    @contracts = @account.contracts
	
	session[SESSION_MAIN_PAGE] = MAIN_PAGE_LISTING_CONTRACTS
    respond_to do |format|
      format.html
    end
  end
 
  def new
  	@contract = Contract.new
  	@account = Account.find(params[:account_id])
  end
  
  def create
  	
  	@account = Account.find(params[:account_id])
	@contract = Contract.build_new_contract(params[:contract], @current_user.id)
	@contract.account = @account
	
    respond_to do |format|
      if @contract.save
        flash[:notice] = 'Contract was successfully created.'
       	format.html { redirect_to(account_contracts_url(@account)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def show
  	@account = Account.find(params[:account_id])
    @contract = Contract.find(params[:id])
	@title = @contract.name
  end
  
  
end
