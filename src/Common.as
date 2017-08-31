package  
{
	/**
	$(CBI)* ...
	$(CBI)* @author SARI
	$(CBI)*/
	public class Common
	{
		
		private static var followerIntroductionMessages:Array = new Array
		(
			"{0} following",
			"I'm Mrs {0}",
			"Me Junior {0}",
			"I am princess {0}",
			"Mr {0} here"
		)
		
		private static var orderMessages:Array = new Array
		(
			"Follow me plz",
			"Follow ME!",
			"Follow me",
			"Plz follow me",
			"FOLLOW ME!!!"
		)
		
		

		private static var topWelcomeMessages:Array = new Array
		(
			"Press any key to join. Everyone is welcomed.",
			"Press ANY key to join. Everyone is welcomed!"
		)
		

		
		public static function getNextIntroductionMessage(key:String):String {
			var message:String = followerIntroductionMessages[Common.randomInt(followerIntroductionMessages.length)]
			return message.replace("{0}", key)
		}
		
		public static function getNextOrderMessage():String {
			return orderMessages[Common.randomInt(orderMessages.length)]
		}
		
		public static function getNextTopWelcomeMessage():String {
			return topWelcomeMessages[Common.randomInt(topWelcomeMessages.length)]
		}
		
		// returns [0, max-1]
		public static function randomInt(max:Number):Number {
			return Math.floor(Math.random() * max)
		}
		
		public static function randomHit(probability:Number):Boolean {
			return Math.random() < probability
		}
		
		/// <summary>
        /// distribute the followers on the earth more precisely with randomness
        /// </summary>
        /// <param name="followers"></param>
        /// <returns></returns>
        public static function NextFollowerAngle(followers:*):Number
        {
            var unoccupiedSlots:Array = new Array()
            var count:Number = followers.length + 1
            var pieAngle:Number = Math.PI * 2 / count;
            for (var i:Number = 0; i < count; i++)
            {
                var minAngle:Number = pieAngle * i
                var maxAngle:Number = pieAngle * (i + 1)
                var isOccupied:Boolean = false
                for each (var follower:Dude in followers)
                {
                    if (follower.angle >= minAngle && follower.angle <= maxAngle)
                    {
                        isOccupied = true;
                        break;
                    }
                }
                if (!isOccupied)
				{
                    unoccupiedSlots.push(i)
				}
            }
            if (unoccupiedSlots.length > 0)
            {
                var pie:Number = randomInt(unoccupiedSlots.length)
                return Math.random() * pieAngle + unoccupiedSlots[pie] * pieAngle;
            }
            else
            {
                return Math.random() * Math.PI * 2;
            }
        }
		
	}

}