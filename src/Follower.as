package
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.geom.*
	
	
	public class Follower extends Dude
	{
		
		public static const disappearTime:Number = 5000 // in milliseconds
		
		public var key:String
		public var him:Him
		
		private var hasFollowed:Array = new Array() // use it as a queue
		private var followTimes:Array = new Array() // use it as a queue
		private var totalFollowTime:Number = 0
		private var totalMissTime:Number = 0
		
		// use it as last user input time
		public var lastHeadDownTime:Number
		
		private var currentColorTransformOfHeadUp:ColorTransform
		private var currentColorTransformOfHeadDown:ColorTransform
		
		public function Follower(parentSprite:Sprite, key:String, him:Him, followers:*)
		{
			super(parentSprite, followers)
			
			this.key = key
			this.him = him
			him.followers.push(this)
			
			scale = 0.2
			
			lastHeadDownTime = getTimer()
			
			setSpeechBubbleText(Common.getNextIntroductionMessage(key))
			
			currentColorTransformOfHeadUp = new ColorTransform(colorTransformOfHeadUp.redMultiplier, colorTransformOfHeadUp.greenMultiplier,
				colorTransformOfHeadUp.blueMultiplier)
			currentColorTransformOfHeadDown = new ColorTransform(colorTransformOfHeadDown.redMultiplier, colorTransformOfHeadDown.greenMultiplier,
				colorTransformOfHeadDown.blueMultiplier)
			
		}
		
		
		override public function enterFrame(event:Event, dt:Number):void 
		{
			super.enterFrame(event, dt);
			
			updateFollow(dt)
			updateCurrentColor(dt)
			
		}
		
		private function updateFollow(dt:Number):void {
			
			if (him == null) {
				return
			}
			
			if (totalFollowTime + totalMissTime > him.totalRhythmTime) // if more than a sec
            {
                var wasFollowing:Boolean = hasFollowed.shift()
				var time:Number = followTimes.shift()

                if (wasFollowing)
                    totalFollowTime -= time;
                else
                    totalMissTime -= time;
            }

			
            if (him.isHeadDown == isHeadDown)
            {
                hasFollowed.push(true);
                followTimes.push(dt);
                totalFollowTime += dt;
            }
            else
            {
                hasFollowed.push(false);
                followTimes.push(dt);
                totalMissTime += dt;
            }
			
		}
		
		/// <summary>
        /// if > .9 its nice follow
        /// if > .8 its bad follow
        /// if < .8 no follow
        /// </summary>
        public function get FollowRatio():Number
        {
			if (totalFollowTime + totalMissTime == 0) {
				return 0;
			}
			else {
				return 1.0 * totalFollowTime / (totalFollowTime + totalMissTime);
			}
        }
		
		override public function get colorTransform():ColorTransform 
		{
			if (isHeadDown) {
				return currentColorTransformOfHeadDown
			} else {
				return currentColorTransformOfHeadUp
			}
		}
		
		private function updateCurrentColor(dt:Number):void {
			
			if (isHeadDown) {
				
				var targetColorTransformOfHeadUp:ColorTransform
				var targetColorTransformOfHeadDown:ColorTransform
				if (him.isHeadDown) {
					targetColorTransformOfHeadUp = him.colorTransformOfHeadUp
					targetColorTransformOfHeadDown = him.colorTransformOfHeadDown
				}else {
					targetColorTransformOfHeadUp = this.colorTransformOfHeadUp
					targetColorTransformOfHeadDown = this.colorTransformOfHeadDown
				}
				
				var change:Number = dt * 0.00003
				
				if (currentColorTransformOfHeadUp.redMultiplier < targetColorTransformOfHeadUp.redMultiplier) {
					currentColorTransformOfHeadUp.redMultiplier += change
					currentColorTransformOfHeadDown.redMultiplier += change
				}else {
					currentColorTransformOfHeadUp.redMultiplier -= change
					currentColorTransformOfHeadDown.redMultiplier -= change
				}
				if (currentColorTransformOfHeadUp.greenMultiplier < targetColorTransformOfHeadUp.greenMultiplier) {
					currentColorTransformOfHeadUp.greenMultiplier += change
					currentColorTransformOfHeadDown.greenMultiplier += change
				}else {
					currentColorTransformOfHeadUp.greenMultiplier -= change
					currentColorTransformOfHeadDown.greenMultiplier -= change
				}
				if (currentColorTransformOfHeadUp.blueMultiplier < targetColorTransformOfHeadUp.blueMultiplier) {
					currentColorTransformOfHeadUp.blueMultiplier += change
					currentColorTransformOfHeadDown.blueMultiplier += change
				}else {
					currentColorTransformOfHeadUp.blueMultiplier -= change
					currentColorTransformOfHeadDown.blueMultiplier -= change
				}
				
			}
		}
		
	}
}