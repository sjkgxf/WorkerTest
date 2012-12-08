package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class FWorker extends Sprite
	{
		private var worker:Worker;
		private var channel0:MessageChannel;
		private var channel1:MessageChannel;
		
		public function FWorker()
		{
			this.addChild(ui);
			init();
		}
		
		private function init():void
		{
			var bytes:ByteArray = new ByteArray();
			bytes = this.loaderInfo.bytes;
			
			if(Worker.current.isPrimordial)
			{
				worker = WorkerDomain.current.createWorker(bytes);
				worker.addEventListener(Event.WORKER_STATE, workerEvent);
				
				channel0 = Worker.current.createMessageChannel(worker);
				channel1 = worker.createMessageChannel(Worker.current);
				
				worker.setSharedProperty("c0", channel0);
				worker.setSharedProperty("c1", channel1);
				
				channel1.addEventListener(Event.CHANNEL_MESSAGE, thread0);
				
				worker.start();
			}
			else
			{
				channel0 = Worker.current.getSharedProperty("c0");
				channel1 = Worker.current.getSharedProperty("c1");
				channel0.addEventListener(Event.CHANNEL_MESSAGE, thread1);
			}
			
		}
		
		private function workerEvent(e:Event):void
		{
		}
		
		private function thread0(e:Event):void
		{
			var message:Object = e.target.receive();
		}
		
		private function thread1(e:Event):void
		{
			var obj:Object = e.target.receive();
			var time:Number = getTimer();
			
			var temp:int = 0;
			for (var i:int = 0; i < obj.num; i ++)
			{
				++ temp ;
			}
			time = getTimer()-time;
			channel1.send({str:"循环用时:"+time});
		}
		
		private function ok(e:Event):void
		{
			var obj:Object = {};
			obj.num = ui.Num;
			
			channel0.send(obj);
		}
		
	}
}