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

  public class SFVerticalScrollBar extends SFComponent
  {
    private var myMax:uint = 100;
    private var myCurrent:uint = 0;
    private var shape:Shape = null;

    private var btnUp:SFButton = null;
    private var btnDown:SFButton = null;
    private var pnlBack:SFPanel = null;
    private var pnlSlider:SFPanel = null;

    private var sliderBounds:Rectangle = null;

    private var change:Function = null;

    public function SFVerticalScrollBar(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,max:uint = 100, onChange:Function = null) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);
      drawBevel(BEVEL_DOWN);

      change = onChange;

      myMax = max;
      btnUp = new SFButton(this,0,0,aWidth,aWidth,"-",decClick);
      btnDown = new SFButton(this,0,aHeight-aWidth,aWidth,aWidth,"+",incClick);

      var sliderSize:Number = pW();

      pnlBack = new SFPanel(this,pX(0),pY(aWidth)-1,pW(),pH()-(2*aWidth)+2,BEVEL_NONE);

      sliderBounds = new Rectangle(0,0,0,pnlBack.height-sliderSize-1);

      pnlSlider = new SFPanel(pnlBack,0,0,sliderSize,sliderSize);

      pnlBack.addEventListener(MouseEvent.CLICK, backClick);

      pnlSlider.addEventListener(MouseEvent.MOUSE_DOWN, sliderMouseDown);
      pnlSlider.addEventListener(MouseEvent.MOUSE_UP, sliderMouseUp);
      pnlSlider.addEventListener(MouseEvent.MOUSE_OUT, sliderMouseUp);
      pnlSlider.addEventListener(MouseEvent.CLICK, sliderClick);
    }

    public function getPos():uint
    {
      return myCurrent;
    }

    private function updatePos():void
    {
      var yPos:Number = pnlSlider.y;
      var yMax:Number = sliderBounds.height;
      var fraction:Number = yPos/yMax;
      var newCurrent:uint = Math.floor(fraction * myMax);
      if(newCurrent == myCurrent) { return; }
      myCurrent = newCurrent; 
      if(change != null) { change(); }
    }

    public function setPos(current:uint):void
    {
      if(current < 0) { current = 0; }
      if(current > myMax) { current = myMax; }
      if(current == myCurrent) { return; }
      myCurrent = current;
      var fraction:Number = myCurrent/myMax;
      pnlSlider.y = Math.floor(fraction*sliderBounds.height);
      if(change != null) { change(); }
    }

    private function sliderMouseDown(e:MouseEvent):void 
    {
      pnlSlider.startDrag(false,sliderBounds);
      e.stopImmediatePropagation();
    }

    private function sliderMouseUp(e:MouseEvent):void 
    {
      pnlSlider.stopDrag();
      e.stopImmediatePropagation();
      updatePos();
    }

    private function sliderClick(e:MouseEvent):void 
    {
      e.stopImmediatePropagation();
    }

    private function decClick(e:MouseEvent = null):void
    {
      if(myCurrent > 0) { setPos(myCurrent-1); }
    }

    private function incClick(e:MouseEvent = null):void
    {
      if(myCurrent < myMax) { setPos(myCurrent+1); }
    }

    private function backClick(e:MouseEvent = null):void
    {
      var ly:Number = e.localY;
      var cy:Number = pnlSlider.y;

      if(ly < cy)
      {
        // move upwards
        setPos(getPos()-1);
      }
      else
      {
        // move downwards
        setPos(getPos()+1);
      }
    }
    
  }
}
