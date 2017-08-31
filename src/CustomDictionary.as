package 
{
	import flash.utils.Dictionary;
	
	/**
	$(CBI)* ...
	$(CBI)* @author SARI
	$(CBI)*/
	public dynamic class CustomDictionary extends Dictionary 
	{
		// todo, store size var instead of calculating it each time
		
		// returns number of stored items
		public function get length():Number {
			var len:uint = 0
			for each(var item:* in this) {
				len++
			}
			return len
		}
		
	}
	
}