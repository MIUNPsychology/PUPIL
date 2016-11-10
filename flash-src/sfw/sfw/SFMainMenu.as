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

  public class SFMainMenu extends SFComponent 
  {
    private var myMenus:Array = null;
    private var myPanel:SFPanel = null;

    private var myFrame:SFFrame = null;
    private var maxHeight:Number = 0;

    public function SFMainMenu(menus:Array) 
    {
      super(null,0,0,1,1,COLOR_PANEL,0.0);

      myMenus = menus;
    }

    public function attach(aframe:SFFrame,title:SFFrameTitle):void
    {
      var maxWidth:Number = title.width;

      myFrame = aframe;

      var menu:SFMenu = null;
      var i:Number;

      for(i = 0; i < myMenus.length; i++)
      {
        menu = SFMenu(myMenus[i]);
        if((menu.barHeight()+4) > maxHeight) { maxHeight = menu.barHeight()+4; }
      }

      var shape:Shape=new Shape();
      shape.graphics.lineStyle(1,COLOR_PANEL);
      shape.graphics.beginFill(COLOR_PANEL);
      shape.graphics.drawRect(0,0,maxWidth-BEVEL_WIDTH,maxHeight);
      shape.graphics.lineStyle(1,COLOR_DARK);
      shape.graphics.beginFill(COLOR_DARK);
      shape.graphics.drawRect(0,maxHeight-1,maxWidth-BEVEL_WIDTH+1,0);
      addChild(shape);

      var xPos:Number = BEVEL_WIDTH;

      for(i = 0; i < myMenus.length; i++)
      {
        menu = SFMenu(myMenus[i]);
        menu.x = xPos;
        menu.y = 0;
        addChild(menu);
        xPos += menu.width;
      }

      y = title.height+BEVEL_WIDTH*2;
      x = BEVEL_WIDTH;

      addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
      aframe.addChild(this);
    }

    private function onMouseOver(e:MouseEvent):void 
    {
      var maxpos:uint = myFrame.numChildren-1;
      myFrame.setChildIndex(this,maxpos);
    }

    public function barHeight():Number
    {
      return maxHeight;
    }
  }
}
