class TransactionUploader
	
	require 'csv'

  	include StateliHelper
	include ApplicationHelper
	
	attr_accessor :type
	
	def parseTransactions(filename)
		
		puts "TYPE: #{@type}"
		if @type == 'Chase'
			return parseTransactionsChaseCSV(filename)
		elsif @type == 'BOA'
			return parseTransactionsBOACSV(filename)
		end
	end

	def parseTransactionsChaseCSV(tempfile)
		
		transactions = []
		
		## parse file, add transactions to transactions
		parsed_file=CSV::Reader.parse(tempfile)
		parsed_file.shift
		parsed_file.each  do |row|
			next if row[1].include? 'Pending'
	        
			params = {}
			params[:name] = "CHASE: #{row[2]}"
			params[:description] = "CHASE: #{row[2]}"
			params[:trans_date] = row[1]
			params[:amount] = row[3]
			params[:completed] = true
			
			transactions << saveParsedTransaction(params)
		end
		return transactions      
	end
	
		def parseTransactionsBOACSV(tempfile)
		
		transactions = []
		
		## parse file, add transactions to transactions
		parsed_file=CSV::Reader.parse(tempfile)
		parsed_file.shift
		parsed_file.each do |row| 
			next if row[0].include? 'Pending'
	        
			params = {}
			params[:name] = "BOA: #{row[2]} #{row[3]}"
			params[:description] = "BOA: #{row[2]} #{row[3]}"
			params[:trans_date] = row[0]
			params[:amount] = row[4]
			params[:completed] = true
			
			transactions << saveParsedTransaction(params)
		end
		return transactions      
	end

	def saveParsedTransaction(params)
		
		transaction = Transaction.new
		transaction.pocket_id = Pocket.unclassified.id
		transaction.update_transaction_attributes(params, false)   
	end
end
