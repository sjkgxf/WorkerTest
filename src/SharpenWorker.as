package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class SharpenWorker extends Sprite
	{
		protected var mainToBack:MessageChannel;
		protected var backToMain:MessageChannel;
		
		protected var imageBytes:ByteArray;
		protected var imageData:BitmapData;
		
		protected var currentSharpen:Number = 0;
		protected var targetSharpen:Number = 0;
		private var timer:Timer;
		
		public function SharpenWorker(){
			var worker:Worker = Worker.current;
			
			//Listen on mainToBack for SHARPEN events
			mainToBack = worker.getSharedProperty("mainToBack");
			mainToBack.addEventListener(Event.CHANNEL_MESSAGE, onMainToBack);
			//Use backToMain to dispatch SHARPEN_COMPLETE
			backToMain = worker.getSharedProperty("backToMain");
			
			//Get the image data from the shareProperty pool
			imageBytes = worker.getSharedProperty("imageBytes");
			var w:int = worker.getSharedProperty("imageWidth");
			var h:int = worker.getSharedProperty("imageHeight");
			
			imageBytes.position = 0;
			imageData = new BitmapData(w, h, false, 0x0);
			backToMain.send(imageBytes.length);
			imageData.setPixels(imageData.rect, imageBytes);
			
			//Create timmer to check whether sharpenValue has been dirtied
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			timer.start();
			
			backToMain.send("INIT_STARTED");
		}
		
		protected function onTimer(event:TimerEvent):void {
			if(targetSharpen == currentSharpen){ return; } //Don't sharpen unless the value has changed
			currentSharpen = targetSharpen;
			
			//Sharpen image and copy into ByteArray
			var data:BitmapData = ImageUtils.SharpenImage(imageData, currentSharpen);
			imageBytes.length = 0;
			data.copyPixelsToByteArray(data.rect, imageBytes);
			
			//Notify main thread that the sharpen operation is complete
			backToMain.send("SHARPEN_COMPLETE");
			backToMain.send(imageBytes);
		}

		protected function onMainToBack(event:Event):void {
			if(mainToBack.messageAvailable){
				//Get the message type.
				var msg:* = mainToBack.receive();
				//Sharpen
				if(msg == "SHARPEN"){
					targetSharpen = mainToBack.receive();
				}
				
			}
		}
	}
}