package
{
	import com.jiuji.myhome.as3.engine.BaseModel3D;
	import com.jiuji.myhome.as3.events.SocketRelatedEvent;
	import com.jiuji.myhome.as3.events.UserRelatedEvent;
	import com.jiuji.myhome.as3.manager.ActionManager;
	import com.jiuji.myhome.as3.manager.EffectManager;
	import com.jiuji.myhome.as3.manager.FeedManager;
	import com.jiuji.myhome.as3.manager.Popup2DManager;
	import com.jiuji.myhome.as3.manager.RoleManager;
	import com.jiuji.myhome.as3.manager.WeatherManager;
	import com.jiuji.myhome.as3.model.HouseModel;
	import com.jiuji.myhome.as3.model.UserModel;
	import com.jiuji.myhome.as3.service.SocketService;
	import com.jiuji.myhome.as3.service.ValueService;
	import com.jiuji.myhome.as3.utils.CurrentState;
	import com.jiuji.myhome.as3.utils.EkoFPS;
	import com.jiuji.myhome.as3.utils.GuideManager;
	import com.jiuji.myhome.as3.utils.LoadManager;
	import com.jiuji.myhome.as3.utils.Stats;
	import com.jiuji.myhome.as3.utils.UtilsFor3D;
	import com.jiuji.myhome.as3.view.Room3DView;
	
	import flash.display.StageDisplayState;
	
	import org.robotlegs.mvcs.Actor;

	public class Config extends Actor
	{
		public static var SERVER_TIME_OFFSET:Number = 0;
		
		public static function get currentTime():Number
		{
			var t:Date = new Date;
			return t.time - SERVER_TIME_OFFSET;
		}
		
		//public static var CONNECT_URL:String = "http://web3d.cc/myqq";		// 工作站
		//public static var CONNECT_URL:String = "http://web3d.cc:8888/myhome";	// 工作站
		//public static var CONNECT_URL:String = "http://web3d.cc:8888/myqq";		// 工作站 Qzone
		public static var CONNECT_URL:String = "http://app100668966.qzone.qzoneapp.com";			// 线上 Qzone
		//public static var CONNECT_URL:String = "http://192.168.0.254:8888/myqq";
		//public static var CONNECT_URL:String = "http://web3d.cc:8081/myhome";//桂
		//public static var CONNECT_URL:String = "http://192.168.0.226:8081/myhome";
		//public static var CONNECT_URL:String = "http://web3d.cc:8251/MyHome";
		//public static var CONNECT_URL:String = "http://192.168.0.251:8251/MyHome";
		//public static var CONNECT_URL:String = "http://homelover.cc/myhome";
		//public static const CONNECT_URL:String = "http://192.168.0.100:8888/myhome";
		//public static const CONNECT_URL:String = "http://192.168.0.125:8088/MyHome";
		//public static const CONNECT_URL:String = "http://192.168.0.126:8081/myhome";
		//public static var CONNECT_URL:String = "http://192.168.0.252:4321/myhome";	// 林 QZONE
		
		public static const CONNECT_IP_URL:String = "http://211.144.120.43/myhome";
		
		public static function getConnectUrl():String
		{
			return CONNECT_URL;
		}
		
		public static var wyx_user_id:String = "";
		public static var weiyouxiId:String = "";
		
		//public static var SOCKET_URL:String = "web3d.cc";
		public static var SOCKET_URL:String = "app100668966.qzone.qzoneapp.com";		// QZone
		//public static var SOCKET_URL:String = "192.168.0.252";
		//public static var SOCKET_URL:String = "192.168.0.226";
		//public static var SOCKET_URL:String = "211.144.120.40";
		//public static const SOCKET_URL:String = "192.168.0.100";
		//public static var SOCKET_URL:String = "192.168.0.251";
		//public static var SOCKET_URL:String = "192.168.0.254";
		
		//public static const PORT_NUMBER:int = 80;
		//public static const PORT_NUMBER:int = 1863;	// 工作站 myqq
		public static const PORT_NUMBER:int = 8004;	// QZone
		//public static const PORT_NUMBER:int = 1864;	// 冠军
		
		public static function initParams(params:Object):void
		{
			if (params.hasOwnProperty("connectUrl") && params.connectUrl != "")
			{
				Config.CONNECT_URL = params.connectUrl;
			}
			if (params.hasOwnProperty("socketUrl") && params.socketUrl != "")
			{
				Config.SOCKET_URL = params.socketUrl;
			}
			if (params.hasOwnProperty("wyx_user_id") && params.wyx_user_id != "")
			{
				Config.wyx_user_id = params.wyx_user_id;
			}
			if (params.hasOwnProperty("weiyouxiId") && params.weiyouxiId != "")
			{
				Config.weiyouxiId = params.weiyouxiId;
			}
		}
		
		[Inject]
		public var userModel:UserModel;
		
		[Inject]
		public var houseModel:HouseModel;
		
		[Inject]
		public var socketService:SocketService;
		
		[Inject]
		public var valueService:ValueService;
		
		[Inject]
		public var feedManager:FeedManager;
		
		[Inject]
		public var popup2DManager:Popup2DManager;
		
		[Inject]
		public var actionManager:ActionManager;
		
		[Inject]
		public var roleManager:RoleManager;
		
		[Inject]
		public var effectManager:EffectManager;
		
		[Inject]
		public var guideManager:GuideManager;
		
		[Inject]
		public var weatherManger:WeatherManager;
		
		public function debugCommand(str:String):Boolean
		{
			//return false;
			
			var flag:Boolean;
			if (str == "fullpower")
			{
				valueService.fullPower();
				flag = true;
			}
			else if (str == "badstate")
			{
				valueService.badState();
				flag = true;
			}
			else if (str.indexOf("charm") != -1)
			{
				var offset:int = int(str.substr(6));
				valueService.changeCharm(offset);
				flag = true;
			}
			else if (str.indexOf("gold") != -1)
			{
				var goldOffset:int = int(str.substr(5));
				valueService.changeCoin("jinbi", goldOffset);
				flag = true;
			}
			else if (str.indexOf("money") != -1)
			{
				var moneyOffset:int = int(str.substr(6));
				valueService.changeCoin("lbi", moneyOffset);
				flag = true;
			}
			else if (str.indexOf("deleteuser") != -1)
			{
				valueService.changeCoin("deleteUser", -1);
				flag = true;
			}
			else if (str == "feed")
			{
				feedManager.showFeedDialog(FeedManager.FEED_EVERYDAY_PRICE);
				flag = true;
			}
			else if (str == "lang")
			{
				this.dispatch(new UserRelatedEvent(UserRelatedEvent.GET_CUSTOM_LANG_LIST));
				flag = true;
			}
			else if (str.substr(0, 5) == "guide")
			{
				// 新手引导
				guideManager.newGuide(popup2DManager.mainSprite.stage, 0, int(str.substr(6)));
				flag = true;
			}
			else if (str.substr(0, 4) == "grass")
			{
				var shineModel:BaseModel3D = UtilsFor3D.getNeedModelByPos(-744, -3, -400);
				if (shineModel)//左侧草
				{
					effectManager.showStarterGuideEffect(shineModel);
				}
				shineModel = UtilsFor3D.getNeedModelByPos(-108,0,-344);
				if (shineModel)//马桶
				{
					effectManager.showStarterGuideEffect(shineModel);
				}
				flag = true;
			}
			else if (str.substr(0, 4) == "goto")
			{
				houseModel.furClickX = popup2DManager.mainSprite.stage.mouseX;
				houseModel.furClickY = popup2DManager.mainSprite.stage.mouseY;
				
				userModel.tempFriendId = userModel.currentFriendId;
				userModel.currentFriendId = int(str.substr(5));
				
				this.dispatch(new SocketRelatedEvent(SocketRelatedEvent.CHANGE_SOCKET_ROOM));
				flag = true;
			}
			else if (str.indexOf("relation") != -1)
			{
				var relationContent:String = str.substr(8);
				valueService.setFriendship(relationContent);
				flag = true;
			}
			else if (str.indexOf("night") != -1)
			{
				weatherManger.changeToNightMode();
			}
			else if (str.indexOf("day") != -1)
			{
				weatherManger.changeToDayMode();
			}
			else if (str == "buildguide")
			{
				MyHome.stage.dispatchEvent(new UserRelatedEvent(UserRelatedEvent.CLOSE_GUIDE));
				
				GuideManager.isNeedBuildGuide = true;
				GuideManager.startBuildGuide = true;
				if (userModel.currentFriendId == -1 || (userModel.hostUser && userModel.hostUser.userId != 152974))
				{
					houseModel.furClickX = MyHome.stage.mouseX;
					houseModel.furClickY = MyHome.stage.mouseY;
					
					userModel.tempFriendId = userModel.currentFriendId;
					userModel.currentFriendId = 152974;
					
					this.dispatch(new SocketRelatedEvent(SocketRelatedEvent.CHANGE_SOCKET_ROOM));
				}
				LoadManager.load2("assets/xml/buildGuide.xml", function onload(txt:String):void{
					GuideManager.buildGuideXML = new XML(txt);
				});
				flag = true;
			}
			return flag;
		}
		public static function debugTools(myhome:MyHome):void
		{
			/*var fpsView:Stats = new Stats();
			myhome.addChild(fpsView);
			fpsView.y = 130;
			fpsView.x = 120;*/
			
			/*var fpsView:EkoFPS = new EkoFPS();
			myhome.addChild(fpsView);
			fpsView.y = 130;
			fpsView.x = 120;*/
			
			/*Cc.startOnStage(myhome, "");
			Cc.visible = false;
			Cc.config.keystrokePassword = "debug";
			Cc.config.commandLineAllowed = true;*/
		}
		public static function initUserModel(userModel:UserModel, initData:Object):void
		{
			/*userModel.signature = "com.9miracle";
			wyx_user_id = "F0F3F570E51B5E446197FBEFEA03539F";
			initData.openid = "F0F3F570E51B5E446197FBEFEA03539F";
			userModel.weiyouxiId = "F0F3F570E51B5E446197FBEFEA03539F";*/
			//9DD41EC043A0A738B8241197AD5EB4F5
			//F0F3F570E51B5E446197FBEFEA03539F
			//userModel.weiyouxiId = "1689715690";
			//userModel.weiyouxiId = "2945714534";
			// yihua
			//userModel.weiyouxiId = "1644467902";
			//userModel.weiyouxiId = "2425610483";
			//userModel.weiyouxiId = "2663073181";
			// zhanggong
			//userModel.weiyouxiId = "1646624114";
			// chenzhou
			//userModel.weiyouxiId = "2460693670";
			// jiujitest
			//userModel.weiyouxiId = "2663073181";
			// cuicui
			//userModel.weiyouxiId = "2354982714";
			// zhanghanqi
			//userModel.weiyouxiId = "2720192571";
			// hongjun
			//userModel.weiyouxiId = "1865694535";
			// zhanghanqi
			//userModel.weiyouxiId = "2720192571";
			// zhanghanqi wife
			//userModel.weiyouxiId = "2806849512";
			// dongdong
			//userModel.weiyouxiId = "2237883612";
			// wangbin
			//userModel.weiyouxiId = "1933974600";
			// npc
			//userModel.weiyouxiId = "2425610483";
			// lurenjie
			//userModel.weiyouxiId = "2000364777";
			//initData.wyx_user_id = "2359164763";
			//userModel.weiyouxiId = "1865694535";
		}
	}
}