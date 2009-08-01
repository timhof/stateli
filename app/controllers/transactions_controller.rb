class TransactionsController < ApplicationController
	
  before_filter :login_required
  
  # GET /transactions
  # GET /transactions.xml
  def index
    @transactions = Transaction.user_only(@current_user.id).find(:all)
    @transactionsDebit = TransactionDebit.user_only(@current_user.id).find(:all)
	@transactionsCredit = TransactionCredit.user_only(@current_user.id).find(:all)
	@transactionsTransfer = TransactionTransfer.user_only(@current_user.id).find(:all)
	@transactionReconcile = TransactionReconcile.user_only(@current_user.id).find(:all)
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transactions }
    end
  end

  def pending
  	
  	@transactions = Transaction.pendingTransactions(@current_user.id)
    @transactionsDebit = TransactionDebit.pendingTransactions(@current_user.id)
	@transactionsCredit = TransactionCredit.pendingTransactions(@current_user.id)
	@transactionsTransfer = TransactionTransfer.pendingTransactions(@current_user.id)
	@transactionReconcile = TransactionReconcile.pendingTransactions(@current_user.id)
	
	respond_to do |format|
      format.html # pending.html.erb
      format.xml  { render :xml => @transactions }
    end
  end
  
  # GET /transactions/1
  # GET /transactions/1.xml
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.xml
  def new
    @transaction = Transaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    @transaction = Transaction.new(params[:transaction])

	transactionType = params[:transaction][:type]
	if transactionType == 'TransactionDebit'
		 @transaction = TransactionDebit.new(params[:transaction])
	elsif transactionType == 'TransactionCredit'
		 @transaction = TransactionCredit.new(params[:transaction])
	elsif transactionType == 'TransactionTransfer'
		 @transaction = TransactionTransfer.new(params[:transaction])
	end
	
	@transaction.user_id = @current_user.id
	
    respond_to do |format|
      if @transaction.save
        flash[:notice] = 'Transaction was successfully created.'
        format.html { redirect_to(transaction_path(@transaction)) }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.xml
  def update
    @transaction = Transaction.find(params[:id])
	@transaction.user_id = @current_user.id
									
    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        flash[:notice] = 'Transaction was successfully updated.'
        format.html { redirect_to(transaction_path(@transaction)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to(transactions_url) }
      format.xml  { head :ok }
    end
  end
  
end
