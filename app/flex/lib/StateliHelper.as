package lib{
	
		import mx.collections.ArrayCollection;
		import mx.charts.series.LineSeries;
		import mx.utils.ArrayUtil;
		
		import lib.JournalAccount;
		import lib.Account;
		import lib.Transaction;
		
	public class StateliHelper{
	
		public static function myParseFunction(t:String):Date { 
			trace(t);
			var yearMonthDay:Array = t.split("-");
            var newDate:Date = new Date(yearMonthDay[0], yearMonthDay[1]-1, yearMonthDay[2]);
            return newDate;
        }
        
        public static function getJournalAccountList(accountAC:ArrayCollection):ArrayCollection{
		
			var journalAccountList:ArrayCollection = new ArrayCollection();
		 
			for(var countAcc:int = 0; countAcc < accountAC.length; countAcc++){
				var acc:Object = accountAC.getItemAt(countAcc, 0);
				if(acc){
					if(acc.length){
						for(var countAcc2:int = 0; countAcc2 < acc.length; countAcc2++){
		
							var account1:Account = new Account(acc[countAcc2].account.name, acc[countAcc2].account.description);
							var transactionAC:ArrayCollection = new ArrayCollection(Array(acc[countAcc2].transactions.transaction));
					
							var transactionList1:ArrayCollection = getTransactionList(transactionAC);
					
							var ja1:JournalAccount = new JournalAccount(account1, transactionList1);
							journalAccountList.addItem(ja1);
						}
					}
					else{
						var account2:Account = new Account(acc.account.name, acc.account.description);
						var transactionAC:ArrayCollection = new ArrayCollection(Array(acc.transactions.transaction));
						var transactionList2:ArrayCollection = getTransactionList(transactionAC);
						
						var ja2:JournalAccount = new JournalAccount(account2, transactionList2);
						journalAccountList.addItem(ja2);
					}
				}
			}
			
			
			return journalAccountList;
		}
		
		public static function getTransactionList(transactionAC:ArrayCollection):ArrayCollection{
			var newAC:ArrayCollection = new ArrayCollection();
		 
			for(var countTrans:int = 0; countTrans < transactionAC.length; countTrans++){
				var p:Object = transactionAC.getItemAt(countTrans, 0);
				
				if(p.length){
					for(var countTrans2:int = 0; countTrans2 < p.length; countTrans2++){
						var tr1:Transaction = new Transaction(p[countTrans2]["name"], p[countTrans2]["description"], p[countTrans2]["scheduled_date"], p[countTrans2]["executed_date"], p[countTrans2]["account_balance"]);
						newAC.addItem(tr1);
					}
				}
				else{
					var tr2:Transaction = new Transaction(p["name"], p["description"], p["scheduled_date"], p["executed_date"], p["account_balance"]);
					newAC.addItem(tr2);
				}
			}
			
			return newAC;
		}
		
        public static function getTotalJournalAccount(transactionAC:ArrayCollection):JournalAccount{
		
			var account:Account = new Account("Total", "Total");
	
			var transactionList = getTotalTransactionList(transactionAC);
					
			var ja:JournalAccount = new JournalAccount(account, transactionList);

			return ja;
		}

		
		public static function getTotalTransactionList(transactionAC:ArrayCollection):ArrayCollection{
			var newAC:ArrayCollection = new ArrayCollection();
		 
			for(var countTrans:int = 0; countTrans < transactionAC.length; countTrans++){
				var p:Object = transactionAC.getItemAt(countTrans, 0);
				
				if(p.length){
					for(var countTrans2:int = 0; countTrans2 < p.length; countTrans2++){
						var tr1:Transaction = new Transaction(p[countTrans2]["name"], p[countTrans2]["description"], p[countTrans2]["scheduled_date"], p[countTrans2]["executed_date"], p[countTrans2]["account_balance"]);
						newAC.addItem(tr1);
					}
				}
				else{
					var tr2:Transaction = new Transaction(p["name"], p["description"], p["scheduled_date"], p["executed_date"], p["account_balance"]);
					newAC.addItem(tr2);
				}
			}
			
			return newAC;
		}
	
	
		public static function filterTransactions(accountList:ArrayCollection, startDateStr:String, endDateStr:String, use_scheduled:Boolean):void {
			
			for(var accCount:int = 0; accCount < accountList.length; accCount++){
				var account:JournalAccount = accountList.getItemAt(accCount, 0) as JournalAccount;
				account.filterTransactions(startDateStr, endDateStr, use_scheduled);
			}
		}	
		
		public static function filterAccountTransactions(account:JournalAccount, startDateStr:String, endDateStr:String, use_scheduled:Boolean):void{
			
			account.filterTransactions(startDateStr, endDateStr, use_scheduled);
	}
	
	public static function getMultiAccountChartSeries(accountList:ArrayCollection, use_scheduled:Boolean):Array{
			
			var temp:Array = new Array();
			
			for(var jacount:int = 0;jacount < accountList.length;jacount++){
				var jax:JournalAccount = accountList.getItemAt(jacount, 0) as JournalAccount;
				var newlineseries:LineSeries = getAccountLineSeries(jax, use_scheduled);
				
				temp.push(newlineseries);
			}
			
			return temp;
		}
		
		public static function getAccountLineSeries(jax:JournalAccount, use_scheduled:Boolean):LineSeries{
			
			var temp:Array = new Array();
			
			var newlineseries:LineSeries = new LineSeries();
			newlineseries.yField = "balance";
			newlineseries.displayName = jax.account.name;
			if(use_scheduled){
				newlineseries.xField = "date_scheduled";
			}
			else{
				newlineseries.xField = "date_executed";
			}
			newlineseries.dataProvider = jax.transactionsFiltered;
				
			return newlineseries;
		}
	}
}