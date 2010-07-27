require 'test_helper'

class RuleTest < ActiveSupport::TestCase
 
	fixtures :rules
	
	def test_initialize_rule
		p RuleCompType.values
		rule = RuleName.new(:name => rules(:boa_payment).name, :comp_type => rules(:boa_payment).comp_type, :comp_string => rules(:boa_payment).comp_string, :comp_date => rules(:boa_payment).comp_date, :comp_action => rules(:boa_payment).comp_action, :type => rules(:boa_payment).type, :rank => rules(:boa_payment).rank)
		
		rule.save
		
	end
end
