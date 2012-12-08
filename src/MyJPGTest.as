package
{
	import com.adobe.images.JPGEncoder;
	import com.greensock.TweenLite;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	[SWF(width="800", height="600")]
	public class MyJPGTest extends Sprite
	{
		protected var mainToWorker:MessageChannel;
		protected var workerToMain:MessageChannel;
		
		protected var worker:Worker;

		private var sprite:Sprite;
		private var clickSprite:Sprite;
		
		public function MyJPGTest()
		{
			if (Worker.current.isPrimordial)
			{
				worker = WorkerDomain.current.createWorker(this.loaderInfo.bytes);
				
				mainToWorker = Worker.current.createMessageChannel(worker);
				workerToMain = worker.createMessageChannel(Worker.current);
				
				worker.setSharedProperty("mainToWorker", mainToWorker);
				worker.setSharedProperty("workerToMain", workerToMain);
				
				workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
				
				worker.start();
				
				// 创建移动动画
				init();
			}
			else
			{
				mainToWorker = Worker.current.getSharedProperty("mainToWorker");
				workerToMain = Worker.current.getSharedProperty("workerToMain");
				
				mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
			}
		}
		
		private function createJPG():void
		{
			var bmp:BitmapData = new BitmapData(500, 500);
			var byteArray : ByteArray = new JPGEncoder(90).encode(bmp);
			
			workerToMain.send(byteArray);
			
			/*var now:Date = new Date;
			var month:int = now.month + 1;
			var str:String = "爱情公寓Online_" + now.fullYear.toString() + (month<10?"0"+month:month) + (now.date<10?"0"+now.date:now.date) + "_" + "xxx" + ".jpg";
			var f:FileReference = new FileReference;
			f.save(byteArray, str);
			if(bmp)
			{
				bmp.dispose();
				bmp = null;
			}*/
			
			
		}
		
		private function init():void
		{
			sprite = new Sprite();
			sprite.graphics.clear();
			sprite.graphics.beginFill(0xff0000);
			sprite.graphics.drawCircle(50, 50, 20);
			
			this.addChild(sprite);
			sprite.x = 100;
			sprite.y = 100;
			
			//TweenLite.to(sprite, 5, {x: 700});
			//mainToWorker.send("CLICK");
		}
		
		protected function onClick(event:MouseEvent):void
		{
			var f:FileReference = new FileReference;
			f.save(byteArray, "test.jpg");
		}
		
		private var byteArray:ByteArray;
		
		protected function onWorkerToMain(event:Event):void
		{
			byteArray = workerToMain.receive();
			
			clickSprite = new Sprite();
			clickSprite.graphics.clear();
			clickSprite.graphics.beginFill(0xffff00);
			clickSprite.graphics.drawCircle(50, 50, 20);
			
			this.addChild(clickSprite);
			clickSprite.x = 100;
			clickSprite.y = 200;
			
			clickSprite.buttonMode = true;
			clickSprite.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected function onMainToWorker(event:Event):void
		{
			if (mainToWorker.receive() == "CLICK")
			{
				// 构建JPG图片
				createJPG();
			}
		}
	}
}