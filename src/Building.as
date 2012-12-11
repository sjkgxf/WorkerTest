package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.ColorFilter;
	import flare.materials.filters.TextureFilter;

	/**
	 * 
	 * @author chenchao
	 * 
	 */
	public class Building extends Pivot3D
	{
		private var buildingModel:Pivot3D;
		
		private var timer:Timer;
		private var loaded:Boolean = false;
		
		private var worker:*;
		
		public function Building()
		{
			super("building");
		}
		
		public function workerLoadComplete(model:Pivot3D):void
		{
			buildingModel = model;
			
			this.addChild(buildingModel);
			
			timer = new Timer(5000, 1);
			timer.addEventListener(TimerEvent.TIMER, cloneBuilding);
			timer.start();
		}
		
		private function cloneBuilding(e:Event):void
		{
			timer.removeEventListener(TimerEvent.TIMER, cloneBuilding);
			
			for each (var child:Pivot3D in buildingModel.children)
			{
				if (child is Mesh3D)
				{
					// 材质相关
					if (child.name == "default")
					{
						disableNightLights(child as Mesh3D);
						disableNightLights1(child as Mesh3D);
					}
					else if (child.name == "house1" || child.name == "house2" || child.name == "house3" || child.name == "sky")
					{
						disableNightLights(child as Mesh3D);
					}
					else if (child.name == "ludeng1" || child.name == "ludeng2" || child.name == "ludeng3" || child.name == "ludeng4" || child.name == "ludeng5")
					{
						child.setLayer(5);
					}
					else
					{
						enableLights(child as Mesh3D);
					}
					
					if (child.userData)
					{
						if (child.userData.hasAlpha)
							child.setLayer(8);
						
						if (child.userData.clone)
						{
							var data:Array = (child.userData.clone as String).split("&");
							for each (var posStr:String in  data)
							{
								var pos:Array = posStr.split("|");
								var clone:Pivot3D = child.clone();
								clone.setPosition(-pos[0], pos[1] + 10, -pos[2]);
								clone.setRotation(0, -pos[3] + 180, 0);
								this.addChild(clone);
								
								if (child.userData.hasAlpha)
									clone.setLayer(8);
								
								// 材质相关
								if (child.name == "default")
								{
									disableNightLights(clone as Mesh3D);
									disableNightLights1(clone as Mesh3D);
								}
								else if (child.name == "house1" || child.name == "house2" || child.name == "house3")
								{
									disableNightLights(clone as Mesh3D);
								}
								else
								{
									enableLights(clone as Mesh3D);
								}
							}
						}
					}
				}
			}
			
			loaded = true;
			changeMode("day");
		}
		
		public function changeMode(mode:String):void
		{
			if (!loaded)
				return;
			
			for each (var child:Pivot3D in buildingModel.children)
			{
				if (child is Mesh3D)
				{
					changeFilterMode(child as Mesh3D, mode);
				}
			}
			
			for each (var child1:Pivot3D in this.children)
			{
				if (child1 != buildingModel && child1 is Mesh3D)
				{
					changeFilterMode(child1 as Mesh3D, mode);
				}
			}
		}
		
		private function changeFilterMode(child:Mesh3D, mode:String):void
		{
			if (child.name == "default")
			{
				((child.getMaterialByName("night") as Shader3D).filters[0] as ColorFilter).a = (mode == "day" ? 0 : 1);
				((child.getMaterialByName("nightludeng") as Shader3D).filters[0] as TextureFilter).alpha = (mode == "day" ? 0 : 1.3);
			}
			else if (child.name == "sky")
			{
				((child.getMaterialByName("night") as Shader3D).filters[0] as TextureFilter).alpha = (mode == "day" ? 0 : 1);
				((child.getMaterialByName("moon") as Shader3D).filters[0] as TextureFilter).alpha = (mode == "day" ? 0 : 1);
			}
			else if (child.name == "house1" || child.name == "house2" || child.name == "house3")
			{
				((child.getMaterialByName("night") as Shader3D).filters[0] as TextureFilter).alpha = (mode == "day" ? 0 : 1);
			}
			else if (child.name == "ludeng1" || child.name == "ludeng2" || child.name == "ludeng3"
				|| child.name == "ludeng4" || child.name == "ludeng5")
			{
				((child.getMaterialByName("ludeng") as Shader3D).filters[0] as TextureFilter).alpha = (mode == "day" ? 0 : 1);
			}
		}
		
		private function enableLights(model:Mesh3D):void
		{
			// 另所有材质都可以感光
			for each (var surface:Surface3D in model.surfaces)
			{
				(surface.material as Shader3D).enableLights = true;
			}
		}
		
		private function disableNightLights(model:Mesh3D):void
		{
			var nightShader:Shader3D = model.getMaterialByName("night") as Shader3D;
			if (nightShader)
				nightShader.enableLights = false;
			
			var moonShader:Shader3D = model.getMaterialByName("moon") as Shader3D;
			if (moonShader)
				moonShader.enableLights = false;
		}
		
		private function disableNightLights1(model:Mesh3D):void
		{
			var nightShader:Shader3D = model.getMaterialByName("nightludeng") as Shader3D;
			if (nightShader)
			{
				nightShader.enableLights = false;
				(nightShader.filters[0] as TextureFilter).alpha = 1.3;
			}
		}
	}
}