class Transaction < ActiveRecord::Base
	
	require 'rexml/document'
	include REXML
	
	include StateliHelper
	include ApplicationHelper
	
	require 'bigdecimal'
  	require 'bigdecimal/util'
  
	belongs_to :user
	belongs_to :account
	belongs_to :contract
	belongs_to :pocket

	validates_presence_of :name, :amount, :trans_date
	validates_numericality_of :amount
	
	def after_find
		if self.pocket_id.nil? || self.pocket_id == 0 || self.pocket_id == -1
			self.pocket_id = Pocket.unclassified.id
			self.pocket = Pocket.unclassified
		end
	end
	
	def update_transaction_attributes(params, doSave=true)

 		unless(params[:name].nil?)
 			self.name = params[:name]
 		end
 		unless(params[:description].nil?)
 			self.description = params[:description]
 		end
 		unless(params[:trans_date].nil?)
 			self.trans_date = params[:trans_date]
 		end
 		unless(params[:amount].nil?)
 			self.amount = params[:amount].to_d
 			#if self.type == TRANSACTION_CREDIT
			#	self.amount = 0.0.to_d - self.amount
			#end
			logger.info self.amount
 		end
 		unless(params[:completed].nil?)
 			self.completed = params[:completed]
 		end
 		unless(params[:account_id].nil?)
 			self.account_id = params[:account_id]
 		end
 		unless(params[:pocket_id].nil?)
 			self.pocket = Pocket.find_pocket(params[:pocket_id])
 		end
 		unless(params[:autopay].nil?)
 			self.autopay = params[:autopay]
 		end
    	unless(params[:user_id].nil?)
    		self.user_id = params[:user_id]
    	end
    	
    	if doSave
 			return self.save!
 		else
 			return self
 		end
 	end
 	
 	def update_and_complete(params)

		params[:trans_date] = Date.today
      	self.update_transaction_attributes(params)
      	self.complete
      	
  	end
  	
  	def within_range(startDate, endDate)
  		return trans_date >= startDate && trans_date <= endDate
  	end
  
	def complete
    	self.account.execute_transaction(self)
  	end
 	
	def overdue?
		self.trans_date < Date.today && !self.completed
	end
	
	def validate
		errors.add(:account_id, " must be assigned." ) if @autopay || @completed
	end
	
	def to_xml(options = {})
      options[:indent] ||= 2
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      xml.transaction do
       	xml.tag!(:name, self.name)
       	xml.tag!(:description, self.description)
       	xml.tag!(:trans_date, self.trans_date)
       	xml.tag!(:amount, self.amount)
       	xml.tag!(:account_balance, self.account_balance)
       	
      end
    end

end
