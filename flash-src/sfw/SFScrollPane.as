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

  import flash.geom.*;

  public class SFScrollPane extends SFComponent
  {
    private var myBevelPolicy:Number = BEVEL_NONE;
    private var myComponent:SFComponent = null;

    private var horiz:SFHorizontalScrollBar = null;
    private var vert:SFVerticalScrollBar = null;

    private var displayHeight:Number = 0;
    private var displayWidth:Number = 0;

    public static const BARSIZE:Number = 16;
    public static const STEPSIZEPIXELS:Number = 10;

    private var showVert:Boolean = false;
    private var showHoriz:Boolean = false;

    private var vertMax:uint = 0;
    private var horizMax:uint = 0;

    private var vertLeftOver:Number = 0;
    private var horizLeftOver:Number = 0;

    private var subRect:Rectangle = null;

    private var componentWidth:Number = 0;
    private var componentHeight:Number = 0;

    public function SFScrollPane(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,aComponent:SFComponent,bevelPolicy:Number = BEVEL_NONE) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);
      myBevelPolicy = bevelPolicy;
      myComponent = aComponent;
      drawBevel(myBevelPolicy);

      var shape:Shape = new Shape();

      shape.graphics.lineStyle(1,0xFFFFFF);
      shape.graphics.beginFill(0xFFFFFF);
      shape.graphics.drawRect(0,0,pW(),pH());
      shape.x = pX(0);
      shape.y = pY(0);

      addChild(shape);
      
//      SFScreen.addDebug("Display height:" + this.height);
//      SFScreen.addDebug("Component height:" + aComponent.height);

      displayWidth = this.width;
      displayHeight = this.height;

      if(displayHeight < aComponent.height)
      {
        // Need a vertical scroll bar
        displayWidth -= BARSIZE;
        showVert = true;
      }

      if(displayWidth < aComponent.width)
      {
        // Need a horizontal scroll bar
        displayHeight -= BARSIZE;
        showHoriz = true;

        // check if we need to redo height
        if(!showVert)
        {          
          if(displayHeight < aComponent.height)
          {
            // Need a vertical scroll bar
            displayWidth -= BARSIZE;
            showVert = true;
          }
        }
      }

      if(bevelPolicy != BEVEL_NONE)
      {
        myComponent.x = BEVEL_WIDTH;
        myComponent.y = BEVEL_WIDTH;

        displayWidth -= BEVEL_WIDTH*2;
        displayHeight -= BEVEL_WIDTH*2;
      }
      
      displayWidth--;
      displayHeight--;

      if(showVert)
      {
        // Ok, we need a vertical scrollbar. Now we need to calculate how many steps
        // of STEPSIZEPIXELS it should scroll over

        var yMod:Number = 0;

        if(bevelPolicy != BEVEL_NONE)
        {
          yMod = BEVEL_WIDTH;
        }

        vertLeftOver = myComponent.height-displayHeight;
        vertMax = Math.floor(vertLeftOver / STEPSIZEPIXELS);
        if(vertMax < 1) { vertMax = 1; }

        // take into account the leftover
        vertMax++;

        if(!showHoriz)
        {
          vert = new SFVerticalScrollBar(this,this.width-BARSIZE-yMod-1,yMod,BARSIZE,this.height-BEVEL_WIDTH-(yMod*2),vertMax,vertChange);
        }
        else
        {
          vert = new SFVerticalScrollBar(this,this.width-BARSIZE-yMod-1,yMod,BARSIZE,this.height-BARSIZE-BEVEL_WIDTH-(yMod*2),vertMax,vertChange);
        }
      }

      if(showHoriz)
      {
        horizLeftOver = myComponent.width-displayWidth;
        horizMax = Math.floor(horizLeftOver / STEPSIZEPIXELS);
        if(horizMax < 1) { horizMax = 1; }

        var xMod:Number = 0;

        if(bevelPolicy != BEVEL_NONE)
        {
          xMod = BEVEL_WIDTH;
        }

        // take into account the leftover
        horizMax++;

        horiz = new SFHorizontalScrollBar(this,xMod,this.height-BARSIZE-xMod-1,this.width-BARSIZE-BEVEL_WIDTH-(xMod*2),BARSIZE,horizMax,horizChange);
      }

      componentWidth = myComponent.width;
      componentHeight = myComponent.height;

      subRect = new Rectangle(0,0,displayWidth,displayHeight);
      myComponent.scrollRect = subRect;
      
      addChild(myComponent);

    }

    private function horizChange():void
    {
      var steps:Number = horiz.getPos();
      var pixels:Number = steps * STEPSIZEPIXELS;

      if( (pixels + displayWidth) > componentWidth ) { pixels = componentWidth-displayWidth; }
      subRect.x = pixels;

//      SFScreen.addDebug("horizChange: steps=" + steps + " pixels=" + pixels + " subrect.x=" + subRect.x);

      myComponent.scrollRect = subRect;
    }

    private function vertChange():void
    {
      var steps:Number = vert.getPos();
      var pixels:Number = steps * STEPSIZEPIXELS;

      if( (pixels + displayHeight) > componentHeight ) { pixels = componentHeight-displayHeight; }
      subRect.y = pixels;

//      SFScreen.addDebug("horizChange: steps=" + steps + " pixels=" + pixels + " subrect.x=" + subRect.y);

      myComponent.scrollRect = subRect;
    }

    public function getHorizontalScrollBar():SFHorizontalScrollBar
    {
      return horiz;
    }

    public function getVerticalScrollBar():SFVerticalScrollBar
    {
      return vert;
    }

  }
}
