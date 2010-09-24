class ContractsController < ApplicationController
  include StateliHelper
  
  before_filter :login_required
  
  def index

    @contracts = Contract.activeContracts(@current_user.id)
  	@account = Account.find(params[:account_id])
    respond_to do |format|
      format.html
    end
  end
 
  def new
  	@contract = Contract.new
  	@contract.date_start = Date.today
  	@contract.date_end = Date.today >> 12
  	@contract.full_date = Date.today
  	@account = Account.find(params[:account_id])
  end
  
  def create
	@contract = Contract.build_new_contract(params[:contract], @current_user.id)
  	@account = Account.find(params[:account_id])
	@contract.account_id = @account.id
	success = @contract.save
	logger.info "ACCOUNT ID: #{@contract.account_id}"
    respond_to do |format|
      if success
        flash[:notice] = 'Contract was successfully created.'
       	format.html { redirect_to(account_contracts_url(@account)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def show
    @contract = Contract.find(params[:id])	
  end
  
  def journal
  	@contract = Contract.find(params[:id])
  	@account = Account.find(params[:account_id])
	@transactions = @contract.transactions
end
  
 def destroy
    @contract = Contract.find(params[:id])
	@account = Account.find(params[:account_id])
    @contract.destroy

    respond_to do |format|
      format.html { redirect_to(account_contracts_url(@account)) }
      format.xml  { head :ok }
    end
  end
  
end
