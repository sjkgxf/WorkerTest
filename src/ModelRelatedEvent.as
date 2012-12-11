package
{
	import flash.events.Event;
	
	public class ModelRelatedEvent extends Event
	{
		public static const WORKER_LOAD_COMPLETE:String = "workerLoadComplete";
		
		public function ModelRelatedEvent(type:String)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			return new ModelRelatedEvent(type);
		}
	}
}