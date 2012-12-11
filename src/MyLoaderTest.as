package
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.system.MessageChannel;
	import flash.system.Security;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Pivot3D;
	import flare.loaders.Flare3DLoader;
	import flare.loaders.Flare3DLoader1;
	import flare.materials.filters.AlphaMaskFilter;
	import flare.materials.filters.SpecularFilter;
	import flare.system.Device3D;
	
	import utils.Stats;

	[SWF(width="800", height="600", frameRate="60")]
	public class MyLoaderTest extends Sprite
	{
		private var scene:Scene3D;
		private var camera:Camera3D;
		
		private var worker:Worker;
		
		private var mainToWorker:MessageChannel;
		private var workerToMain:MessageChannel;
		
		public var model:Pivot3D;
		
		private var sprite:Sprite;
		private var clickSprite:Sprite;

		private var building:Building;
		
		private var data:ByteArray;
		
		public function MyLoaderTest()
		{
			if (Worker.current.isPrimordial)
			{
				scene = new Scene3D(this);
				scene.antialias = 2;
				scene.clearColor.setTo(0.69, 0.85, 1);
				
				scene.showMenu = false;
				scene.autoResize = true;
				
				scene.registerClass(Flare3DLoader1);
				scene.registerClass(SpecularFilter);
				scene.registerClass(AlphaMaskFilter);
				
				scene.lights.ambientColor = new Vector3D(0.65, 0.65, 0.65);
				scene.lights.maxDirectionalLights = 1;
				
				//scene.defaultLight = null;
				scene.defaultLight.color = new Vector3D(0.3, 0.3, 0.3);
				//scene.defaultLight.color = new Vector3D(0.188, 0.188, 0.188);
				
				scene.lights.maxPointLights = 0;
				
				scene.setLayerSortMode(8, Scene3D.SORT_BACK_TO_FRONT);
				
				// 从上往下的平行光
				var directionalLight:Light3D = new Light3D("directional", Light3D.DIRECTIONAL);
				directionalLight.color = new Vector3D(0.2, 0.2, 0.2);
				directionalLight.setOrientation(new Vector3D(0, -1, 0));
				scene.addChild(directionalLight);
				
				camera = new Camera3D("myOwnCamera");
				camera.far = 20000;
				scene.camera = camera;
				
				building = new Building();
				scene.addChild(building);
				
				worker = WorkerDomain.current.createWorker(this.loaderInfo.bytes);
				
				mainToWorker = Worker.current.createMessageChannel(worker);
				workerToMain = worker.createMessageChannel(Worker.current);
				
				worker.setSharedProperty("mainToWorker", mainToWorker);
				worker.setSharedProperty("workerToMain", workerToMain);
				
				workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
				
				worker.start();
				
				init();
			}
			else
			{
				mainToWorker = Worker.current.getSharedProperty("mainToWorker");
				workerToMain = Worker.current.getSharedProperty("workerToMain");
				
				mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
			}
		}
		
		protected function onClick(event:MouseEvent):void
		{
			mainToWorker.send(this.data);
			//mainToWorker.send(scene);
		}
		
		protected function onWorkerToMain(event:Event):void
		{
			model = mainToWorker.receive();
			//this.dispatchEvent(new ModelRelatedEvent(ModelRelatedEvent.WORKER_LOAD_COMPLETE));
			building.workerLoadComplete(model);
		}
		
		protected function onMainToWorker(event:Event):void
		{
			this.data = mainToWorker.receive();
			if (this.data)
			{
				var model:Flare3DLoader = new Flare3DLoader(this.data);
				model.addEventListener(Scene3D.COMPLETE_EVENT, function loadComplete(event:Event):void {
					model.removeEventListener(Scene3D.COMPLETE_EVENT, loadComplete);
					
					workerToMain.send(model);
				});
				//var scene:Scene3D = mainToWorker.receive();
				//scene.library.push(model as Flare3DLoader);
				model.load();
			}
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
			
			clickSprite.visible = false;
			
			clickSprite.buttonMode = true;
			clickSprite.addEventListener(MouseEvent.CLICK, onClick);
			
			LoadManager.loadByteArray("background.f3d", onModelLoadComplete);
		}
		
		private function onModelLoadComplete(data:ByteArray):void
		{
			clickSprite.visible = true;
			
			this.data = data;
		}
	}
}