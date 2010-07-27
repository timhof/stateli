package lib{

	[Bindable]
	public class Transaction{
		public var name:String
		public var description:String;
		public var date_scheduled:String;
		public var balance:Number;
		
		public function Transaction(_name:String, _description:String, _date_scheduled:String, _balance:Number){
			name = _name;
			description = _description;
			date_scheduled = _date_scheduled;
			balance = _balance;
		}
	}
}