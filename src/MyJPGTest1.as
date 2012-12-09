package
{
	import com.adobe.images.JPGEncoder;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import utils.Stats;
	
	[SWF(width="800", height="600", frameRate="60")]
	public class MyJPGTest1 extends Sprite
	{
		private var sprite:Sprite;
		private var clickSprite:Sprite;
		
		public function MyJPGTest1()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			this.addChild(new Stats());
			
			sprite = new Sprite();
			sprite.graphics.clear();
			sprite.graphics.beginFill(0xff0000);
			sprite.graphics.drawCircle(50, 50, 20);
			
			this.addChild(sprite);
			sprite.x = 100;
			sprite.y = 100;
			
			var myTween:TweenLite = new TweenLite(sprite, 1, {x: 700,
					onComplete: function reverseTween():void {
						myTween.reverse();
					},
					onReverseComplete: function restartTween():void {
						myTween.restart();
					},
					ease: Linear.easeNone
				}
			);
			
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
		
		protected function onClick(event:MouseEvent):void
		{
			var bmp:BitmapData = new BitmapData(500, 500);
			var byteArray : ByteArray = new JPGEncoder(90).encode(bmp);
			
			var f:FileReference = new FileReference;
			f.save(byteArray, "test.jpg");
		}
	}
}