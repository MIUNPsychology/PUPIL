/* --- START OF LICENSE AND COPYRIGHT BLURB ---

   This file is a part of the PUPIL project, see
   
     http://github.com/MIUNPsychology/PUPIL

   Copyright 2016 Department of Psychology, Mid Sweden University

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   --- END OF LICENSE AND COPYRIGHT BLURB --- */



package sfw
{
  import flash.display.*;
  import flash.events.*;
  import flash.text.*;

  public class SFProgressBar extends SFComponent
  {
    private var myMax:uint = 100;
    private var myCurrent:uint = 1;
    private var shape:Shape = null;

    private static const COLOR_PROGRESS:uint = 0x0000FF;

    public function SFProgressBar(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,max:uint = 100) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);
      drawBevel(BEVEL_DOWN);
      myMax = max;

      setPos(0);
    }

    public function setPos(current:uint):void
    {

      if(current == myCurrent) { return; }

      // Ok, this is ugly and will load the garbage collector a bit, 
      // but it is a quick and dirty solution.
    
      if(shape != null)
      {
        removeChild(shape);
      }

      shape = new Shape();

      shape.graphics.lineStyle(1,COLOR_PANEL);
      shape.graphics.beginFill(COLOR_PANEL);
      shape.graphics.drawRect(0,0,pW(),pH());

      if(current > 0)
      {
        //SFScreen.addDebug("new position: " + current + " / " + myMax);

        var percentage:Number = current / myMax;
        if(percentage < 0) { percentage = 0; }
        if(percentage > 1) { percentage = 1; }

        var calcWidth:Number = Math.floor(shape.width * percentage);

        shape.graphics.lineStyle(1,COLOR_PROGRESS);
        shape.graphics.beginFill(COLOR_PROGRESS);
        shape.graphics.drawRect(0,0,calcWidth,pH());
      }

      shape.x = pX(0);
      shape.y = pY(0);

      myCurrent = current;
      addChild(shape);
    }
  }
}
