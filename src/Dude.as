package {
	
	import flash.display.*
	import flash.events.*
	import flash.geom.*
	import flash.net.URLRequest
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	public class Dude {
		
		public static var gameWindow:Sprite = null
		
		private static const walkImageCount:Number = 8
		private static const walkImageWidth:Number = 200
		private static const walkImageHeight:Number = 350
		
		private static const walkAnimationSpeed:Number = 0.25
		private static const walkRotationSpeed:Number = Math.PI / 180 / 40
		
		private var parentSprite:Sprite
		
		private var transformMatrix:Matrix
		public var colorTransformOfHeadUp:ColorTransform
		public var colorTransformOfHeadDown:ColorTransform
		
		private var walkImageFillMatrix:Matrix
		private var walkImageMap:BitmapData
		private var walkImageState:Number
		
		private var walkSprite:Sprite
		
		protected var scale:Number
		
		public var angle:Number
		public var isHeadDown:Boolean
		
		private var speechBubble:Sprite
		private var speechBubbleLabel:TextField
		
		private var creationTime:Number
		public var lastActiveTime:Number
		
		public function Dude(parentSprite:Sprite, dudes:*) {
			
			this.parentSprite = parentSprite
			
			walkSprite = new Sprite()
			parentSprite.addChild(walkSprite)
			//walkSprite.addEventListener(Event.ENTER_FRAME, enterFrame)
				
			scale = 0.3
			angle = 0
			angle = Common.NextFollowerAngle(dudes)
			isHeadDown = false
			
			transformMatrix = new Matrix()
			
			colorTransformOfHeadUp = new ColorTransform()
			colorTransformOfHeadUp.redMultiplier = Math.random() / 2 + 0.5
			colorTransformOfHeadUp.greenMultiplier = Math.random() / 2 + 0.5
			colorTransformOfHeadUp.blueMultiplier = Math.random() / 2 + 0.5
			colorTransformOfHeadDown = new ColorTransform()
			colorTransformOfHeadDown.redMultiplier = colorTransformOfHeadUp.redMultiplier * 0.9
			colorTransformOfHeadDown.greenMultiplier = colorTransformOfHeadUp.greenMultiplier * 0.9
			colorTransformOfHeadDown.blueMultiplier = colorTransformOfHeadUp.blueMultiplier * 0.9
			
			walkImageMap = null
			walkImageState = 0
			walkImageFillMatrix = new Matrix()
			
			var url:URLRequest = new URLRequest("../images/walk.png")
			var loader:Loader = new Loader()
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete)
			loader.load(url)
			
			
			speechBubble = new Sprite()
			parentSprite.addChild(speechBubble)
			
			speechBubbleLabel = new TextField()
			speechBubbleLabel.selectable = false
			speechBubbleLabel.width = 0
			speechBubbleLabel.height = 0
			
			var textFormat:TextFormat = new TextFormat()
			textFormat.size = 90
			speechBubbleLabel.setTextFormat(textFormat)
			
			speechBubbleLabel.textColor = 0x000000
			speechBubble.addChild(speechBubbleLabel)
			
			var now:Number = getTimer()
			creationTime = now
			lastActiveTime = now
			
		}
		
		public function clear():void {
			parentSprite.removeChild(walkSprite)
			parentSprite.removeChild(speechBubble)
		}
		
		private function loaderComplete(event:Event):void {
			walkImageMap = Bitmap(event.target.content).bitmapData
		}
		
		public function enterFrame(event:Event, dt:Number):void {
			
			if (walkImageMap == null) {
				return // walk image still loading
			}
			
			angle += walkRotationSpeed * dt
			angle %= Math.PI * 2
			
			walkImageState += walkAnimationSpeed
			if (walkImageState >= walkImageCount) {
				walkImageState -= walkImageCount
			}
			var walkImageStateFloored:Number = Math.floor(walkImageState)
			
			var verticalDistance:Number = 100 + scale * walkImageHeight * 0.9 // 0.9 should be the cause of blank space below the foot in the image
			var horizontalDistance:Number = 0
			
			if (isHeadDown) {
				horizontalDistance = walkImageCount * walkImageWidth
			}
			
				
			walkSprite.graphics.clear()
			
			walkImageFillMatrix.identity()
			walkImageFillMatrix.translate(-walkImageStateFloored * walkImageWidth - walkImageWidth / 2 + horizontalDistance, 0)
			
			transformMatrix.identity()
			transformMatrix.scale(scale, scale)
			transformMatrix.translate(0, -verticalDistance)
			transformMatrix.rotate(angle)
			transformMatrix.translate(gameWindow.width / 2, gameWindow.height / 2)
			
			walkSprite.transform.matrix = transformMatrix
			walkSprite.transform.colorTransform = colorTransform	
			
			walkSprite.graphics.beginBitmapFill(walkImageMap, walkImageFillMatrix)
			walkSprite.graphics.drawRect(-walkImageWidth / 2, 0, walkImageWidth, walkImageHeight)
			walkSprite.graphics.endFill()
			
			var now:Number = getTimer()
			
			// remove followers' speech bubbles after 3 seconds
			if (this is Follower && now - creationTime > 3000) {
				speechBubble.visible = false
				speechBubbleLabel.visible = false
			} else {
				drawSpeechBubble(verticalDistance)
			}
			
			// make it transparent in the last second before disappearing
			if (now - lastActiveTime > disappearTime - 1000) {
				var alpha:Number = (disappearTime - (now - lastActiveTime)) / 1000
				walkSprite.alpha = alpha
				speechBubble.alpha = alpha
			} else {
				walkSprite.alpha = 1
				speechBubble.alpha = 1
			}
		}
		
		private function drawSpeechBubble(verticalDistanceFromOrigin:Number):void
		{
			var bubbleWidth:Number = 200, bubbleHeight:Number = 100
			var distanceToMouth:Number = 50 // make sure its lesser than bubbleHeight
			var labelPadding:Number = 10
			
			bubbleWidth = speechBubbleLabel.textWidth + labelPadding * 4
			bubbleHeight = speechBubbleLabel.textHeight + labelPadding * 3
			
			var bubblePos:Point = new Point()
			if (Math.cos(angle) >= 0) {
				bubblePos.y = -bubbleHeight - distanceToMouth
			} else {
				bubblePos.y = distanceToMouth
			}
			if (Math.sin(angle) >= 0) {
				bubblePos.x = 0
			} else {
				bubblePos.x = -bubbleWidth
			}
			
			transformMatrix.identity()
			transformMatrix.scale(scale, scale)
			transformMatrix.rotate(-angle)
			transformMatrix.translate(0, -verticalDistanceFromOrigin)
			transformMatrix.rotate(angle)
			transformMatrix.translate(gameWindow.width / 2, gameWindow.height / 2)
			
			var g:Graphics = speechBubble.graphics
			speechBubble.transform.matrix = transformMatrix
			speechBubble.transform.colorTransform = colorTransform

			var m:Matrix = new Matrix();
			//m.createGradientBox(200,100,90*Math.PI/180,80,80);
			m.createGradientBox(bubbleWidth, bubbleHeight, 0, bubblePos.x, bubblePos.y);
			g.clear();
			g.lineStyle(2,0x888888,1,true);
			
			beginSpeechBubbleGradientFill(g, m)
			
			/*
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle(0, distanceToMouth,		bubbleWidth, bubbleHeight), 20, new Point(0, 0))
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle( -bubbleWidth, distanceToMouth,	bubbleWidth, bubbleHeight), 20, new Point(0, 0))
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle(0, -bubbleHeight - distanceToMouth,		bubbleWidth, bubbleHeight), 20, new Point(0, 0))
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle( -bubbleWidth, -bubbleHeight - distanceToMouth,	bubbleWidth, bubbleHeight), 20, new Point(0, 0))
			*/
			
			/*
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle(0, 50, 200, 100), 20, new Point(0, 0))
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle( -200, 50, 200, 100), 20, new Point(0, 0))
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle(0, -150, 200, 100), 20, new Point(0, 0))
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle( -200, -150, 200, 100), 20, new Point(0, 0))
			*/
			
			SpeechBubble.drawSpeechBubble(speechBubble, new Rectangle(bubblePos.x, bubblePos.y, bubbleWidth, bubbleHeight), 20, new Point(0, 0))
			
			speechBubbleLabel.x = bubblePos.x + labelPadding * 2
			speechBubbleLabel.y = bubblePos.y + labelPadding
			
			speechBubbleLabel.width = bubbleWidth
			speechBubbleLabel.height = bubbleHeight
			
			g.endFill();
			
			
			drawSpeechBubbleAux(speechBubble, m, bubblePos, bubbleWidth, bubbleHeight)
			
		}
		
		protected function drawSpeechBubbleAux(sprite:Sprite, matrix:Matrix, bubblePos:Point, bubbleWidth:Number, bubbleHeight:Number):void {
			
		}
		
		protected function setSpeechBubbleText(text:String):void {
			speechBubbleLabel.text = text
			var textFormat:TextFormat = new TextFormat()
			textFormat.size = 90
			speechBubbleLabel.setTextFormat(textFormat)
		}
		
		protected function beginSpeechBubbleGradientFill(graphics:Graphics, matrix:Matrix):void {
			graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [1, 1], [0, 255], matrix, "repeat", "rgb", 0);
		}
		
		public function get colorTransform():ColorTransform {
			if (isHeadDown) {
				return colorTransformOfHeadDown
			} else {
				return colorTransformOfHeadUp
			}
		}
		
		private function get disappearTime():Number {
			if (this is Him) {
				return Him.disappearTime
			} else {
				return Follower.disappearTime
			}
		}
		
		
	}
}