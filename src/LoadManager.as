package
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class LoadManager
	{
		
		private static var loaders:Array = new Array;
		public static function load(url:String, callback:Function, contextFlag:Boolean = false, loaderIndex:int = -100):int
		{
			var context:LoaderContext;
			if(contextFlag)
			{
				context = new LoaderContext(true);
			}
			var ld:Loader2;
			if(loaderIndex == -100)
			{
				ld = new Loader2;
			}
			else
			{
				if(loaderIndex == -1)
				{
					ld = new Loader2;
					loaders.push(ld);
					loaderIndex = loaders.length;
				}
				else
				{
					ld = loaders[loaderIndex];
				}
			}
			ld.callback = callback;
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
			ld.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onerr);
			ld.load(new URLRequest(url), context);
			return loaderIndex;
		}
		
		private static function onLoad(e:Event):void
		{
			var ld:LoaderInfo = e.currentTarget as LoaderInfo;
			var ld2:Loader2 = ld.loader as Loader2;
			if(ld && ld2.callback != null)
			{
				ld2.callback.apply(null, [ld.content]);
			}
		}
		private static function onerr(e:IOErrorEvent):void
		{
			var ld:LoaderInfo = e.currentTarget as LoaderInfo;
//			var filename:String = ld.url.substr(ld.url.lastIndexOf("/") + 1);
		}
		public function LoadManager()
		{
		}
		
		/**
		 * ByteArray 相关
		 * @param url
		 * @param callback
		 * 
		 */		
		public static function loadByteArray(url:String, callback:Function):void
		{
			load2(url, callback, true);
		}
		
		/**
		 * URLLoader 相关
		 * @param url
		 * @param callback
		 * 
		 */		
		public static function load2(url:String, callback:Function, byteFlag:Boolean = false):void
		{
			var urlLoader:URLLoader2 = new URLLoader2();
			if(byteFlag)
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.callback = callback;
			urlLoader.addEventListener(Event.COMPLETE, onByteArrayLoaded);
			urlLoader.load(new URLRequest(url));
		}
		
		private static function onByteArrayLoaded(e:Event):void
		{
			if (e.target.data)
			{
				e.target.callback(e.target.data);
			}
		}
	}
}
import flash.display.Loader;
import flash.net.URLLoader;

class Loader2 extends Loader
{
	public var callback:Function;
}

class URLLoader2 extends URLLoader
{
	public var callback:Function;
}