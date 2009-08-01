package lib{
	[Bindable]
	public class TimelineEvent{
		public var id:Number
		public var eventDate:String;
		public var description:String;
		public var name:String;
		
		public function TimelineEvent(_id:Number, _eventDate:String, _description:String, _name:String){
			id = _id;
			eventDate = _eventDate;
			description = _description;
			name = _name;
		}
	}
}