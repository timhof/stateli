class Rule < ActiveRecord::Base
	
  include StateliHelper
  
	belongs_to :account
	belongs_to :pocket
	belongs_to :user
	
	def self.build_rule(params)
		enumValue = EnumValue.new('dfs', 'adfa')
		if params[:type] == RuleType::RuleDate.key
		 	rule = RuleDate.new(params)
		elsif params[:type] == RuleType::RuleName.key
		 	rule = RuleName.new(params)
		elsif params[:type] == RuleType::RuleAmount.key
		 	rule = RuleAmount.new(params)
		end
		return rule
	end
	
	def match_value(transaction)
		return 20
	end
	
	def condition_match?(transaction)
		
		match = false
		enumValue = EnumValue.new('dfs', 'adfa')
		compareto = match_value(transaction)
		if comp_type == RuleCompType::LESS_THAN.key
			match = compareto < 0
		elsif comp_type == RuleCompType::LESS_THAN_EQUAL.key
			match = compareto <= 0
		elsif comp_type == RuleCompType::GREATER_THAN.key
			match = compareto > 0
		elsif comp_type == RuleCompType::GREATER_THAN_EQUAL.key
			match = compareto >= 0
		elsif comp_type == RuleCompType::EQUAL.key
			match = compareto == 0
		elsif comp_type == RuleCompType::CONTAINS.key
			match = compareto >= 0
		elsif comp_type == RuleCompType::STARTS_WITH.key
			match = compareto == 0
		end	
		return match
	end
	
	def apply_action(transaction)
		if comp_action == RuleActionType::ASSIGN_POCKET.key
			transaction.pocket_id = pocket_id
			puts "Assigning to Pocket: #{pocket_id}"
			transaction.save!
		elsif comp_action == RuleActionType::DELETE.key
			puts "Deleting #{transaction}"
			transaction.deactivate
		end
	end	
end
