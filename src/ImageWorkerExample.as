package
{
	import components.Slider;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	[SWF(width="650", height="400", backgroundColor="#000000")]
	public class ImageWorkerExample extends Sprite
	{
		
		[Embed(source="WildLlama.jpg")]
		public var Image:Class;
		
		/**
		 * Main Worker Props
		 **/
		private var slider:Slider;
		protected var image:Bitmap;
		
		protected var sharpenValue:Number;
		protected var worker:Worker;
		
		protected var mainToBack:MessageChannel;
		protected var backToMain:MessageChannel;
		
		protected var useWorker:Boolean = true;
		
		protected var origImage:BitmapData;
		protected var imageBytes:ByteArray;
		
		/**
		 * Bg Worker Props
		 **/
		protected var sharpenWorker:SharpenWorker;
		
		public function ImageWorkerExample(){
			
			//Main thread
			if(Worker.current.isPrimordial){
				stage.frameRate = 30;
				initUi();
				if(useWorker){
					initWorker();
				}
			} 
			//If not the main thread, we're the worker
			else {
				stage.frameRate = 2;
				sharpenWorker = new SharpenWorker();
			}
		}
		
		protected function initWorker():void {
			//Create worker from the main swf 
			worker = WorkerDomain.current.createWorker(loaderInfo.bytes);//WorkerFactory.getWorkerFromClass(SharpenWorker, loaderInfo.bytes);
			
			//Create message channel TO the worker
			mainToBack = Worker.current.createMessageChannel(worker);
			
			//Create message channel FROM the worker, add a listener.
			backToMain = worker.createMessageChannel(Worker.current);
			backToMain.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain, false, 0, true);
			
			//Now that we have our two channels, inject them into the worker as shared properties.
			//This way, the worker can see them on the other side.
			worker.setSharedProperty("backToMain", backToMain);
			worker.setSharedProperty("mainToBack", mainToBack);
			
			//Init worker with width/height of image
			worker.setSharedProperty("imageWidth", origImage.width);
			worker.setSharedProperty("imageHeight", origImage.height);
			
			
			//Convert image data to (shareable) byteArray, and share it with the worker.
			imageBytes = new ByteArray();
			origImage.copyPixelsToByteArray(origImage.rect, imageBytes);
			worker.setSharedProperty("imageBytes", imageBytes);
			
			//Lastly, start the worker.
			worker.start();
		}
		
		protected function onBackToMain(event:Event):void {
			var msg:String = backToMain.receive();
			if(msg == "SHARPEN_COMPLETE"){
				imageBytes = backToMain.receive();
				imageBytes.position = 0;
				image.bitmapData.setPixels(image.bitmapData.rect, imageBytes);
			}
			trace(msg);
		}
				
		protected function onSliderChanged(value:Number):void {
			sharpenValue = value * 80;
			
			if(!useWorker){
				image.bitmapData = ImageUtils.SharpenImage(origImage, sharpenValue);
			} else {
				//Send the sharpen command to our worker.
				mainToBack.send("SHARPEN");
				mainToBack.send(sharpenValue);
			}
		}
		
		protected function initUi():void {
			//Create Slider
			slider = new Slider(onSliderChanged);
			slider.x = stage.stageWidth - slider.width >> 1;
			slider.y = stage.stageHeight - slider.height;
			addChild(slider);
			
			//Create Image (upscale it to exagerate the slowdown when sharpening)
			image = new Image();
			var scale:Number = 3;
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			var bigBitmap:BitmapData = new BitmapData(image.width * scale, image.height * scale, false, 0x0);
			bigBitmap.draw(image.bitmapData, m, null, null, null, true);
			image.bitmapData = bigBitmap;
			image.width = stage.stageWidth;
			image.scaleY = image.scaleX;
			image.x = stage.stageWidth - image.width >> 1;
			image.y = stage.stageHeight - image.height >> 1;
			addChildAt(image, 0);
			
			//Save a copy of the unsharpened image data
			origImage = image.bitmapData;
		}
	}
}