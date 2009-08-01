package lib{

import mx.collections.ArrayCollection;

	[Bindable]
	public class JournalAccount{
		public var account:Account
		public var transactions:ArrayCollection;
		
		public function JournalAccount(_account:Account, _transactions:ArrayCollection){
			account = _account;
			transactions = _transactions;
		}
	}
}