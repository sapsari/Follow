package  
{
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.*
	
	/**
	$(CBI)* ...
	$(CBI)* @author SARI
	$(CBI)*/
	public class Him extends Dude
	{
		// +3 sec for initial follow message/order
		public static const disappearTime:Number = 13000 // in milliseconds
		
		private var rhythmTimes:Array // in milliseconds
		public var totalRhythmTime:Number // in milliseconds //todo get?
		
		private var currentRhythmIndex:Number
        private var currentRhythmElapsedTime:Number // in milliseconds
		
		private var speechBubbleGradientFillColors:Array
		private var speechBubbleGradientFillAlphas:Array
		private var speechBubbleGradientFillRatios:Array
		
		public var followers:Array = new Array()
		
		public function Him(parentSprite:Sprite, they:Array)
		{
			super(parentSprite, they)
			
			currentRhythmIndex = 0
			currentRhythmElapsedTime = 0
			
			rhythmTimes = new Array()
			var rhythmCount:Number = 4 + Common.randomInt(3)

            while (rhythmCount > 0)
            {
                rhythmCount--
                rhythmTimes.push(300 + Common.randomInt(8) * 100)
            }
			
			totalRhythmTime = 0
            for each(var rhythmTime:Number in rhythmTimes)
            {
                totalRhythmTime += rhythmTime
            }
			
			
			
			speechBubbleGradientFillColors = new Array()
			speechBubbleGradientFillAlphas = new Array()
			speechBubbleGradientFillRatios = new Array()
			
			var curTotalRhythmTime:Number = 0
			var lastFillRatio:Number = 0
			var maxFillRatio:Number = 255
			
			for (var i:Number = 0; i < rhythmTimes.length; i++) {
				curTotalRhythmTime += rhythmTimes[i]
				
				if (i % 2 == 0) {
					speechBubbleGradientFillColors.push(0xFFFFFF)
					speechBubbleGradientFillColors.push(0xFFFFFF)
				} else {
					speechBubbleGradientFillColors.push(0xAAAAAA)
					speechBubbleGradientFillColors.push(0xAAAAAA)
				}
				
				speechBubbleGradientFillAlphas.push(1)
				speechBubbleGradientFillAlphas.push(1)
				
				speechBubbleGradientFillRatios.push(lastFillRatio)
				lastFillRatio = curTotalRhythmTime / totalRhythmTime * maxFillRatio
				speechBubbleGradientFillRatios.push(lastFillRatio)
			}
			
			setSpeechBubbleText(Common.getNextOrderMessage())
		}
		
		override public function clear():void 
		{
			super.clear();
			
			for each(var follower:Follower in followers) {
				follower.him = null
			}
			followers.length = 0
		}
		
		override protected function beginSpeechBubbleGradientFill(graphics:Graphics, matrix:Matrix):void 
		{
			//super.beginSpeechBubbleGradientFill(graphics, matrix);
			
			//graphics.beginGradientFill(GradientType.LINEAR, [0xFF0000, 0xFF0000, 0x00FF00, 0x00FF00], [1, 1, 1, 1], [0, 127, 127, 255], matrix, "repeat", "rgb", 0);
			graphics.beginGradientFill(GradientType.LINEAR, speechBubbleGradientFillColors, speechBubbleGradientFillAlphas, speechBubbleGradientFillRatios, matrix, "repeat", "rgb", 0);
			
		}
		
		override public function enterFrame(event:Event, dt:Number):void 
		{
			super.enterFrame(event, dt);
			
			
			currentRhythmElapsedTime += dt
			
            while (currentRhythmElapsedTime > rhythmTimes[currentRhythmIndex])
            {
                currentRhythmElapsedTime -= rhythmTimes[currentRhythmIndex];
                currentRhythmIndex++;
                if (currentRhythmIndex >= rhythmTimes.length)
                {
                    currentRhythmIndex = 0;
                }
            }

            var wasHeadDown:Boolean = isHeadDown
            isHeadDown = currentRhythmIndex % 2 == 1

            if (!wasHeadDown && isHeadDown)
            {
                //ss.SpeakAsync(voice);
            }
            if (wasHeadDown && !isHeadDown)
            {
                //ss.SpeakAsyncCancelAll();
            }
			
			
		}
		
		// draw the rhythm indicator
		override protected function drawSpeechBubbleAux(sprite:Sprite, matrix:Matrix, bubblePos:Point, bubbleWidth:Number, bubbleHeight:Number):void 
		{
			super.drawSpeechBubbleAux(sprite, matrix, bubblePos, bubbleWidth, bubbleHeight);
			
			
			var currentRhythmTime:Number = 0
			for (var i:Number = 0; i < rhythmTimes.length; i++)
			{
				var rhythmTime:Number = rhythmTimes[i]
				if (i < currentRhythmIndex)
					currentRhythmTime += rhythmTime
				else if (i == currentRhythmIndex)
					currentRhythmTime += currentRhythmElapsedTime
				else
					break;
			}
			
			var indicatorPosition:Number = currentRhythmTime / totalRhythmTime * 0xFF
			var indicatorWidth:Number = 10
			var ratios:Array = new Array()
			
			ratios.push(0)
			ratios.push(indicatorPosition - indicatorWidth)
			ratios.push(indicatorPosition - indicatorWidth)
			ratios.push(indicatorPosition + indicatorWidth)
			ratios.push(indicatorPosition + indicatorWidth)
			ratios.push(0xFF)
			
			
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [0xCDCDCD, 0xCDCDCD, 0xCDCDCD, 0xCDCDCD, 0xCDCDCD, 0xCDCDCD], [0, 0, 0.7, 0.7, 0, 0], ratios, matrix, "repeat", "rgb", 0)
			SpeechBubble.drawSpeechBubble(sprite, new Rectangle(bubblePos.x, bubblePos.y, bubbleWidth, bubbleHeight), 20, new Point(0, 0))
			sprite.graphics.endFill()
		}
		
	}

}