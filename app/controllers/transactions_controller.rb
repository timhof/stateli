class TransactionsController < ApplicationController
  
  include StateliHelper
  	
  before_filter :login_required
 
  def deactivate
  	
  	transaction = Transaction.find(params[:id])
  	transaction.deactivate
  	
  	@account = Account.find(params[:account_id])
  	@account.reload_transactions
    
    @removed_transactions = []
    @removed_transactions << transaction
  	respond_to do |format|
      format.js {render :action => 'remove_transactions', :layout => false}
    end
  end
  
  def deactivate_checked

	@removed_transactions = []
  	params[:transactions].each do |trans_id, value|
  		transaction = Transaction.find(trans_id)
  		transaction.deactivate
    	@removed_transactions << transaction
  	end
  	
  	#Set up for Journal display
  	@account = Account.find(params[:account_id])
  	@account.reload_transactions
  	
  	respond_to do |format|
      format.js {render :action => 'remove_transactions', :layout => false}
    end
  end
  
  def destroy_checked

	@removed_transactions = []
  	params[:transactions].each do |trans_id, value|
  		transaction = Transaction.find(trans_id)
  		transaction.destroy
    	@removed_transactions << transaction
  	end
  	
  	#Set up for Journal display
  	@account = Account.find(params[:account_id])
    respond_to do |format|
      format.js {render :action => 'remove_transactions', :layout => false}
    end
  end
  
  def restore_checked

	@removed_transactions = []
  	params[:transactions].each do |trans_id, value|
  		transaction = Transaction.find(trans_id)
  		transaction.activate
    	@removed_transactions << transaction
  	end
  	
  	@account = Account.find(params[:account_id])
    @account.reload_transactions
	respond_to do |format|
      format.js {render :action => 'remove_transactions', :layout => false}
    end
  end
  
  def edit
    @transaction = Transaction.find(params[:id])
    @account = Account.find(params[:account_id])
	@pockets = Pocket.user_pockets(@current_user.id)
    respond_to do |format|
      format.xml  { render :xml => @transactions }
      format.js {render :action => 'edit', :layout => false}
    end
  end
  
  def complete
    @transaction = Transaction.find(params[:id])
    @transaction.completed = true
    @account = Account.find(params[:account_id])
    
    respond_to do |format|
      flash[:notice] = 'Transaction was successfully updated.'
      format.html { redirect_to(account_journal_url(@account)) }
    end
  end
  
  def update
  	
  	@transaction = Transaction.find(params[:id])
    @account = Account.find(params[:account_id])
    params[:transaction][:pocket_id] = params[:prefix][:pocket_id]
    respond_to do |format|
      if params[:edit_commit].eql?('update')
      	success = @transaction.update_transaction_attributes(params[:transaction])
   		session[:selector].confirm_pocket_data(@current_user.id)
      end
      if success.nil?
      logger.info "UNSUCCESSFUL"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      else
      	logger.info "UNSUCCESSFUL"
        flash[:notice] = 'Transaction was successfully updated.'
      	format.js {render :layout => false}
 	  end
    end
  end
    
  def show
    @transaction = Transaction.find(params[:id])
  end
  
end
