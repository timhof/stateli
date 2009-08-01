class ContractsController < ApplicationController
	
  before_filter :login_required
  
  # GET /contracts
  # GET /contracts.xml
  def index
    @contracts = Contract.user_only(@current_user.id).find(:all)
    @contractsOnce = ContractOnce.user_only(@current_user.id).find(:all)
    @contractsWeekly = ContractWeekly.user_only(@current_user.id).find(:all)
    @contractsBimonthly = ContractBimonthly.user_only(@current_user.id).find(:all)
	@contractsMonthly = ContractMonthly.user_only(@current_user.id).find(:all)
	@contractsYearly = ContractYearly.user_only(@current_user.id).find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contracts }
    end
  end
  
  # GET /contracts/1
  # GET /contracts/1.xml
  def show
    @contract = Contract.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contract }
    end
  end

  # GET /contracts/new
  # GET /contracts/new.xml
  def new
 
	@contract = Contract.new
	
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contract }
    end
  end

  # GET /contracts/1/edit
  def edit
    @contract = Contract.find(params[:id])
  end

  # POST /contracts
  # POST /contracts.xml
  def create
   
  	contractType =  params[:contract][:type]
    if contractType == 'ContractYearly'
		@contract = ContractYearly.new(params[:contract])
	elsif contractType == 'ContractMonthly'
		@contract = ContractMonthly.new(params[:contract])
	elsif contractType == 'ContractBimonthly'
		@contract = ContractBimonthly.new(params[:contract])
	elsif contractType == 'ContractWeekly'
		@contract = ContractWeekly.new(params[:contract])
	elsif contractType == 'ContractOnce'
		@contract = ContractOnce.new(params[:contract])
	end
	@contract.user_id = @current_user.id

    respond_to do |format|
      if @contract.save
        flash[:notice] = 'Contract was successfully created.'
        format.html { redirect_to(contract_path(@contract)) }
        format.xml  { render :xml => @contract, :status => :created, :location => @contract }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contract.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contracts/1
  # PUT /contracts/1.xml
  def update
    @contract = Contract.find(params[:id])
	@contract.user_id = @current_user.id
    respond_to do |format|
      if @contract.update_attributes(params[:contract])
        flash[:notice] = 'Contract was successfully updated.'
        format.html { redirect_to(@contract) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contract.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.xml
  def destroy
    @contract = Contract.find(params[:id])
    @contract.destroy

    respond_to do |format|
      format.html { redirect_to(contracts_url) }
      format.xml  { head :ok }
    end
  end
end
