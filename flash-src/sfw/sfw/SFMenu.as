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

  import sfw.textformat.*;

  public class SFMenu extends SFComponent 
  {
    private var tf_txt:TextField = new TextField();
    private static const TEXTFORMAT_MENUITEM:TextFormat = new SFMenuItemTextFormat();

    private var subPanel:SFPanel = null;

    public function SFMenu(label:String, items:Array) 
    {
      super(null,0,0,1,1,COLOR_PANEL,0.0);

      tf_txt.autoSize = TextFieldAutoSize.LEFT;
      tf_txt.text = label;
      tf_txt.selectable = false;
      tf_txt.multiline = false;
      tf_txt.setTextFormat( TEXTFORMAT_MENUITEM );

      var shape:Shape=new Shape();
      shape.graphics.lineStyle(1,COLOR_PANEL);
      shape.graphics.beginFill(COLOR_PANEL);
      shape.graphics.drawRect(0,0,tf_txt.width+2,tf_txt.height+2);

      addChild(shape);
      addChild(tf_txt);

      var maxWidth:Number = tf_txt.width+2;
      var aHeight:Number = 0;

      var mi:SFMenuItem = null;
      var i:Number;

      for(i = 0; i < items.length; i++)
      {
        mi = SFMenuItem(items[i]);
        if((mi.width+4) > maxWidth) { maxWidth = mi.width + 4; }
        aHeight += mi.height;
      }

      aHeight += 4,

      subPanel = new SFPanel(this,0,tf_txt.height,maxWidth,aHeight);

      var yPos:Number = 2;

      for(i = 0; i < items.length; i++)
      {
        mi = SFMenuItem(items[i]);
        mi.x = 2;
        mi.y = yPos;
        subPanel.addChild(mi);
        yPos += mi.height;
      }

      subPanel.visible = false;
      subPanel.buttonMode = true;
      subPanel.addEventListener(MouseEvent.CLICK, clickEvent);

      tf_txt.addEventListener(MouseEvent.CLICK,clickEvent);
      tf_txt.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
      
    }

    public function barHeight():Number
    {
      return tf_txt.height;
    }

    private function onMouseOver(e:MouseEvent):void 
    {
      showMenu();
    }

    public function showMenu():void
    {
      subPanel.visible = true;
    }

    public function hideMenu():void
    {
      subPanel.visible = false;
    }

    private function clickEvent(e:MouseEvent):void 
    {
      hideMenu();
    }
  }
}
