package
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.BitmapData;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class SaveFileTest
	{
		public function SaveFileTest()
		{
		}
		
		public function saveFile(bmp:BitmapData):void
		{
			var byteArray : ByteArray = new JPGEncoder(90).encode(bmp);
			var now:Date = new Date;
			var month:int = now.month + 1;
			var str:String = "爱情公寓Online_" + now.fullYear.toString() + (month<10?"0"+month:month) + (now.date<10?"0"+now.date:now.date) + "_" + "xxx" + ".jpg";
			var f:FileReference = new FileReference;
			f.save(byteArray, str);
			if(bmp)
			{
				bmp.dispose();
				bmp = null;
			}
		}
	}
}