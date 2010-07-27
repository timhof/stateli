package lib{

import mx.collections.ArrayCollection;

	[Bindable]
	public class JournalAccount{
	
		public var account:Account
		public var transactions:ArrayCollection;
		public var transactionsFiltered:ArrayCollection;
		
		public function JournalAccount(_account:Account, _transactions:ArrayCollection){
			account = _account;
			transactions = _transactions;
		}
		
		public function filterTransactions(startDateStr:String, endDateStr:String, use_scheduled:Boolean):void{
		
			
			var startDate:Date = StateliHelper.myParseFunction(startDateStr);
			var endDate:Date = StateliHelper.myParseFunction(endDateStr);
	
			var startDateTime:Number = startDate.time;
			var endDateTime:Number = endDate.time;
			
			
			this.transactionsFiltered = new ArrayCollection();
			var startingBalance:Number = 0;
			var endingBalance:Number = 0;
			
			var hasTransOnStartDate:Boolean = false;
			var hasTransOnEndDate:Boolean = false;
			
			for(var countTrans:int = 0; countTrans < this.transactions.length; countTrans++){
				var trans:Transaction = this.transactions.getItemAt(countTrans, 0) as Transaction;
				var tdate:String = trans.date_scheduled;
				if(use_scheduled){
					tdate = trans.date_scheduled;
				}
				
				var transDate:Date = StateliHelper.myParseFunction(tdate);
				var transTime:Number = transDate.time;
				if(transTime < startDateTime){
					startingBalance = trans.balance;
				}
				if(transTime < endDateTime){
					endingBalance = trans.balance;
				}
				
				if(transTime == startDateTime){
					hasTransOnStartDate = true;
				}
				if(transTime == endDateTime){
					hasTransOnEndDate = true;
				}
				
				transactionsFiltered.addItem(trans);
				
			}
			
			if(!hasTransOnStartDate){
				var trStart:Transaction = new Transaction("start", "start", startDateStr, startingBalance);
				transactionsFiltered.addItemAt(trStart, 0)
				trace("adding trans: " + startDateStr);
			}
			if(!hasTransOnEndDate){
				var trLast:Transaction = new Transaction("last", "last", endDateStr, endingBalance);
				transactionsFiltered.addItem(trLast);
				trace("adding trans: " + endDateStr);
			}
			
		}
	}
}