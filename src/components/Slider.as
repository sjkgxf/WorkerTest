package components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class Slider extends Sprite {
		
		protected var color:uint = 0x458aef;

		protected var callback:Function;
		
		public var head:Sprite;
		public var track:Bitmap;
		protected var _isMouseDown:Boolean;
		
		public function Slider(callback:Function, width:int = 600) {
			this.callback = callback;
			
			head = new Sprite();
			head.graphics.beginFill(color, .8);
			head.graphics.drawCircle(30, 30, 30);
			head.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addChild(head);
			
			track = new Bitmap(new BitmapData(width - head.width, 4, false, color));
			track.x = head.width/2;
			addChild(track);
			
			head.x = track.x - head.width/2;
			head.y = track.y - head.height/2;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, function(){
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			});
		}
		
		override public function get width():Number {
			return track.width + head.width;
		}
		
		protected function onEnterFrame(event:Event):void {
			if(!isMouseDown){ return; }
			if(callback){
				callback((head.x) / (track.width));
			}
		}
		
		protected function onMouseUp(event:Event):void {
			isMouseDown = false;
			head.stopDrag();	
		}
		
		protected function onMouseDown(event:Event):void {
			isMouseDown = true;
			head.startDrag(false, new Rectangle(0, -head.width/2, track.width, 0));
		}
		
		public function get isMouseDown():Boolean{
			return _isMouseDown;
		}
		
		public function set isMouseDown(value:Boolean):void {
			_isMouseDown = value;
		}
	}
}