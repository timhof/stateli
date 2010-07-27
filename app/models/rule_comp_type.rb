class RuleCompType < StateliEnumeration

	self.add_item(:LESS_THAN, '<')
	self.add_item(:LESS_THAN_EQUAL, '<=')
	self.add_item(:GREATER_THAN, '>')
	self.add_item(:GREATER_THAN_EQUAL, '>=')
	self.add_item(:EQUAL, '==')
	self.add_item(:CONTAINS, 'Contains')
	self.add_item(:STARTS_WITH, 'Starts With')
end
