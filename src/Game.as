package {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import mx.controls.Label;
	import org.merrynet.Cirrus;
	
	public class Game
	{
		
		public static var debugLabel:Label
		private static var topMessageLabel:Label
		private static var bottomMessageLabel:Label
		
		private var followerLayer:Sprite = new Sprite()
		private var himLayer:Sprite = new Sprite()
		private var guiLayer:Sprite = new Sprite()
		
		private var followers:CustomDictionary = new CustomDictionary() // store them in dictionary for constant access time
		private var they:Array = new Array()
		
		private var previousFrameTime:Number
		
		
		private var timer:Timer
		private var cirrus:Cirrus
		
		public function Game(gameWindow:Sprite, topMessageLabel:Label, bottomMessageLabel:Label, debugLabel:Label) {
			
			Game.topMessageLabel = topMessageLabel
			Game.bottomMessageLabel = bottomMessageLabel
			Game.debugLabel = debugLabel
			Dude.gameWindow = gameWindow
			
			// put followers to the bottommost and gui to the topmost layer
			gameWindow.addChild(followerLayer)
			gameWindow.addChild(himLayer)
			gameWindow.addChild(guiLayer)
			
			// create the first Him
			they.push(new Him(himLayer, they))
			
			previousFrameTime = getTimer()
			
			timer = new Timer(3000)
			timer.addEventListener(TimerEvent.TIMER, timerTick)
			timer.start()
			timerTick(null)
			
			cirrus = new Cirrus("a24")
		}
		
		// register only one enter frame event for better performace, call others manually
		public function enterFrame(event:Event):void {
			
			var now:Number = getTimer()
			var deltaTime:Number = now - previousFrameTime
			previousFrameTime = now
			
			for each(var follower:Follower in followers) {
				follower.enterFrame(event, deltaTime)
			}
			
			for each(var him:Him in they) {
				him.enterFrame(event, deltaTime)
			}
			
			
			// remove inactive followers
			for each(var follower:Follower in followers) {
				if (follower.isHeadDown) {
					follower.lastHeadDownTime = now
				} else {
					if (now - follower.lastHeadDownTime > Follower.disappearTime) {
						follower.clear()
						delete followers[follower.key]
					}
				}
			}
			
			// remove unfollowed Hims
			for (var i:Number = 0; i < they.length; i++)
            {
				var him:Him = they[i]
				
				// check if Him has an active follower
                var hasActiveFollower:Boolean = false
                for each(var follower:Follower in him.followers)
                {
                    hasActiveFollower = hasActiveFollower || follower.FollowRatio > 0.8
					if (hasActiveFollower) {
						break
					}
                }
				
                if (hasActiveFollower) {
                    him.lastActiveTime = now
				} else {
                    if (now - him.lastActiveTime > Him.disappearTime) {
						him.clear()
						they.splice(i, 1)
					}
                }
            }
			
			// add new Him if necessary
            while (they.length <= followers.length / 5 && they.length < 5) // todo make 5 randomized (5+-1)
            {
                they.push(new Him(himLayer, they))
            }
			
			// determine which follower follows which Him
			for each(var him:Him in they)
			{
				him.followers.length = 0
			}
			for each(var follower:Follower in followers)
			{
				var minAngle:Number = 20
				var following:Him = null
				for each(var him:Him in they)
				{
					var angle:Number = him.angle - follower.angle
					if (angle < 0)
					{
						angle += Math.PI * 2
					}
					if (angle < minAngle)
					{
						minAngle = angle
						following = him
					}
				}
				follower.him = following
				if (following != null) {
					following.followers.push(follower)
				}
			}
			
			
			drawMessageBubbles()
			
		}
		
		private function drawMessageBubbles():void {
			
			if (they.length == 0) {
				return
			}
			
			var horizontalPadding:Number = 10
			var verticalPadding:Number = 7
			
			var him:Him = they[0] // todo, choose the most followed him
			guiLayer.transform.colorTransform = him.colorTransform
			
			var g:Graphics = guiLayer.graphics
			g.clear()
			g.lineStyle(2,0x888888,1,true)
			g.beginFill(0xFFFFFF)
			SpeechBubble.drawSpeechBubble(guiLayer, new Rectangle(topMessageLabel.x - horizontalPadding, topMessageLabel.y - verticalPadding, topMessageLabel.textWidth + horizontalPadding * 2, topMessageLabel.textHeight + verticalPadding * 2), 10, new Point(topMessageLabel.x + topMessageLabel.textWidth + horizontalPadding * 2, topMessageLabel.y - verticalPadding * 2))
			g.endFill()
			g.beginFill(0xFFFFFF)
			SpeechBubble.drawSpeechBubble(guiLayer, new Rectangle(bottomMessageLabel.x - horizontalPadding, bottomMessageLabel.y - verticalPadding, bottomMessageLabel.textWidth + horizontalPadding * 2, bottomMessageLabel.textHeight + verticalPadding * 2), 10, new Point(bottomMessageLabel.x - horizontalPadding * 2, bottomMessageLabel.y + bottomMessageLabel.textHeight + verticalPadding * 2))
			g.endFill()
			
		}
		
		public function keyDown(key:String):void {
			
			// ensure a Him exists for the following lines
			if (they.length == 0) {
				return
			}
			
			// create the follower if its key is pressed for the first time
			if (followers[key] == null) {
				followers[key] = new Follower(followerLayer, key, they[0], followers)
			}
			
			followers[key].isHeadDown = true
			followers[key].lastActiveTime = getTimer()
			
			
			cirrus.call("a23")
		}
		
		public function keyUp(key:String):void {
			
			// follower may be null if key was being pressed before the application started
			if (followers[key] != null) {
				followers[key].isHeadDown = false
				followers[key].lastActiveTime = getTimer()
			}
			
			cirrus.send(key)
		}
		
		private function timerTick(e:TimerEvent):void {
			
			topMessageLabel.text = Common.getNextTopWelcomeMessage()
			
			if (followers.length == 0) {
				bottomMessageLabel.text = "Press any key to start following Him"
			}
			if (followers.length > 0 && Common.randomHit(0.6)) {
				bottomMessageLabel.text = "Press other keys to join following Him"
			}
			if (they.length > 1 && Common.randomHit(0.3)) {
				bottomMessageLabel.text = "Follow the One in front of you"
			}
			
		}
	}
}
/* TODOS
 * better random colors
 * smooth transition of speech bubbles
 * hint messages
 * need more hint/tip for making user understand when to press (Him may say press now release now maybe) (FINGER on ANY button)
 * */
/*
 * TODOS 2
 * speech sound
 * no sound option
*/
/*
 * TODOS 3
 * cirrus
*/
/*
 * TODOS 4
 * assertions and stats and debug log
*/