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

  public class SFComponent extends Sprite 
  {
    public static const COLOR_PANEL:uint     = 0xCCCCCC;
    public static const COLOR_DARK:uint      = 0x999999;
    public static const COLOR_LIGHT:uint     = 0xE5E5E5;
    public static const COLOR_INPUT:uint     = 0xFFFFFF;
    public static const COLOR_TEXT:uint      = 0x000000;
    public static const COLOR_FRAME:uint     = 0x000000;
    public static const COLOR_TITLETEXT:uint = 0xFFFFFF;
    public static const COLOR_TITLEBAR:uint  = 0x5555FF;
    public static const COLOR_SELECTION:uint = 0x7777FF;

    public static const BEVEL_WIDTH:Number   = 2;

    public static const BEVEL_NONE:Number    = 0;
    public static const BEVEL_UP:Number      = 1;
    public static const BEVEL_DOWN:Number    = 2;
    public static const BEVEL_FRAME:Number   = 3;

    private var myOwner:SFComponent = null;

    private var currentBevelPolicy:Number = BEVEL_NONE;

    private var rx:Number = 0;
    private var ry:Number = 0;
    private var rw:Number = 0;
    private var rh:Number = 0;

    public function SFComponent(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number, backgroundColor:uint = COLOR_PANEL, alphaValue:Number = 1.0) 
    {
      if(owner != null)
      {
        owner.add(this);
      }

      tabEnabled = false;

      var shape:Shape=new Shape();
      shape.graphics.lineStyle(1,backgroundColor, alphaValue, true);
      shape.graphics.beginFill(backgroundColor, alphaValue);
      shape.graphics.drawRect(0,0,aWidth,aHeight);

      x = xPos;
      y = yPos;

      rx = 0;
      ry = 0;
      rh = aHeight;
      rw = aWidth;

      addChild(shape);
    }

    public function getOwner():SFComponent
    {
      return myOwner;
    }

    public function pX(unmodifiedX:Number):Number
    {
      return rx + unmodifiedX;
    }

    public function pY(unmodifiedY:Number):Number
    {
      return ry + unmodifiedY;
    }

    public function pW():Number
    {
      return rw;
    }

    public function pH():Number
    {
      return rh;
    }

    public function pXNeg(pixels:Number):Number
    {
      var modifiedX:Number = rx; // Add bevel if any

      modifiedX += rw; // Add width modified for bevel
      modifiedX -= pixels; // Subtract specified pixels
      modifiedX -= 1; // We start counting from 0, while width is specified as from 1

      return modifiedX;
    }

    public function pYNeg(pixels:Number):Number
    {
      var modifiedY:Number = ry; // Add bevel if any

      modifiedY += rh; // Add height modified for bevel
      modifiedY -= pixels; // Subtract specified pixels
      modifiedY -= 1; // We start counting from 0, while width is specified as from 1

      return modifiedY;
    }

    public function sloppyLine(shape:Shape,x1:Number,y1:Number,x2:Number,y2:Number,color:uint,alphaValue:Number = 1.0):void
    {
      shape.graphics.lineStyle(1,color,alphaValue,true);
      shape.graphics.moveTo(x1,y1);
      shape.graphics.lineTo(x2,y2);
    }

    public function drawBevel(bevelPolicy:Number = BEVEL_UP, bevelWidth:Number = BEVEL_WIDTH, alphaValue:Number = 1.0):void
    {
      if( (bevelPolicy != BEVEL_NONE) && (BEVEL_WIDTH > 0) )
      {
        rx = bevelWidth;
        ry = bevelWidth;

        // width and height seem to be 1 more than the 
        // actual contents

        rw = this.width-(bevelWidth*2)-1;
        rh = this.height-(bevelWidth*2)-1;
        
/*        SFScreen.addDebug("width: " + this.width);
        SFScreen.addDebug("height: " + this.height); */

        var bevelShape:Shape = new Shape();

        var northWest:uint = COLOR_FRAME;
        var southEast:uint = COLOR_FRAME;

        if(bevelPolicy == BEVEL_UP)
        {
          northWest = COLOR_LIGHT;      
          southEast = COLOR_DARK;      
        }

        if(bevelPolicy == BEVEL_DOWN)
        {
          northWest = COLOR_DARK;      
          southEast = COLOR_LIGHT;      
        }

        // There seems to be a bug with coordinates
        // when using moveTo and lineTo combined with
        // this.width. Thus I'm saving width and height
        // to variables to avoid these values shifting
        // inside the loop

        // Also, width and height seems to be one more
        // than the actual contents of the sprite. Thus
        // the -1 modifications.

        var north:Number = 0;
        var south:Number = this.height-1;
        var west:Number = 0;
        var east:Number = this.width-1;

        for(var i:Number = 0; i < bevelWidth; i++)
        {        
          sloppyLine(bevelShape,west,north+i,east-i,north+i,northWest,alphaValue);
          sloppyLine(bevelShape,west+i,north,west+i,south-i,northWest,alphaValue);
          sloppyLine(bevelShape,east-i,south,east-i,north+i,southEast,alphaValue);
          sloppyLine(bevelShape,west+i,south-i,east,south-i,southEast,alphaValue);
        }

        addChild(bevelShape);
      }
    } 

    public function add(child:SFComponent):void
    {
      addChild(child);
    }   
  }
}
