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

  public class SFFrame extends SFComponent
  {
    private var frameTitle:SFFrameTitle = null;
    private var subPanel:SFPanel = null;
    private var myMainMenu:SFMainMenu = null;
    private var myScreen:SFScreen = null;

    private var tabComponents:Array = new Array();

    public function SFFrame(owner:SFScreen, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,title:String,mainmenu:SFMainMenu = null) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);
      drawBevel(BEVEL_UP);

      myScreen = owner;

      frameTitle = new SFFrameTitle(this,BEVEL_WIDTH,BEVEL_WIDTH,aWidth-BEVEL_WIDTH*2+1,20,title);

      if(mainmenu != null)
      {
        myMainMenu = mainmenu;
        myMainMenu.attach(this,frameTitle);
        subPanel = new SFPanel(this,
            BEVEL_WIDTH,
            BEVEL_WIDTH*2+frameTitle.height+myMainMenu.barHeight()+2,
            aWidth-BEVEL_WIDTH*2,
            aHeight-BEVEL_WIDTH*2-frameTitle.height-myMainMenu.barHeight()-2,
            BEVEL_NONE);
      }
      else
      {
        subPanel = new SFPanel(this,BEVEL_WIDTH,BEVEL_WIDTH+frameTitle.height,aWidth-BEVEL_WIDTH*2,aHeight-BEVEL_WIDTH*2-frameTitle.height,BEVEL_NONE);
      }

      addEventListener(MouseEvent.MOUSE_DOWN, pickUp);
      addEventListener(MouseEvent.MOUSE_UP, dropIt);

      buttonMode = true;

      subPanel.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
      subPanel.addEventListener(MouseEvent.CLICK, mouseClick);

    }

    public function registerTabComponent(comp:SFComponent):void
    {
      comp.tabEnabled = false;
      tabComponents[tabComponents.length] = comp;
    }

    public function grabTabControl():void
    {
      var i:Number;
      var c:SFComponent;
      var t:SFTextField;

      var tmod:Number = 0;

      for(i = 0; i < tabComponents.length; i++)
      {
        c = SFComponent(tabComponents[i]);
        c.tabIndex = i + tmod;
        c.tabEnabled = true;

        if(c is SFTextField)
        {
          tmod++;
          t = SFTextField(c);
          t.getTextField().tabIndex = i+tmod;
          t.getTextField().tabEnabled = true;
        }
      }
    }

    public function releaseTabControl():void
    {
      var i:Number;
      var c:SFComponent;

      for(i = 0; i < tabComponents.length; i++)
      {
        c = SFComponent(tabComponents[i]);
        c.tabEnabled = false;
      }

      myScreen.stage.focus = null;
    }

    private function mouseDown(e:MouseEvent):void 
    {
      e.stopImmediatePropagation();
    }

    private function mouseClick(e:MouseEvent):void 
    {
      e.stopImmediatePropagation();
    }

    private function pickUp(e:MouseEvent):void 
    {
      startDrag(false, new Rectangle(BEVEL_WIDTH,BEVEL_WIDTH,myScreen.width-this.width-BEVEL_WIDTH*2,myScreen.height-this.height-BEVEL_WIDTH*2));
    }

    private function dropIt(e:MouseEvent):void 
    {
      stopDrag();
    }

    public function getPanel():SFPanel
    {
      return subPanel;
    }

    public function getScreen():SFScreen
    {
      return myScreen;
    }
  }
}

