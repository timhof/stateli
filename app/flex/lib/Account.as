package lib{

	[Bindable]
	public class Account{
		public var name:String
		public var description:String;
		
		public function Account(_name:String, _description:String){
			name = _name;
			description = _description;
		}
	}
}