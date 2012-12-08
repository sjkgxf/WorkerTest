package
{
	import com.gskinner.filters.SharpenFilter;
	
	import flash.display.BitmapData;
	import flash.geom.Point;

	public class ImageUtils
	{
		public static function SharpenImage(bitmapData:BitmapData, amount:Number):BitmapData {
			
			var sf:SharpenFilter = new SharpenFilter(amount);
			var sharpenedData:BitmapData = bitmapData.clone(); 
			sharpenedData.applyFilter(bitmapData, bitmapData.rect, new Point(), sf);
			return sharpenedData;
		}
	}
}