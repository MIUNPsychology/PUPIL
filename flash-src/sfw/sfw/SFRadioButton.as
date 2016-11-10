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

  public class SFRadioButton extends SFComponent
  {
    public static const TEXTFORMAT_BUTTON:TextFormat = new SFButtonTextFormat();

    private var checkPanel:SFComponent = null;
    private var checkShape:Shape = new Shape();

    private var checked:Boolean = false;

    private var myGroup:SFRadioButtonGroup = null;
    private var myText:String = "";

    public function SFRadioButton(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,buttonText:String) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);

      checkPanel = new SFComponent(this,3,BEVEL_WIDTH+3,12,12);

      var roundShape:Shape = new Shape();

      var xModif:Number = -2;
      var yModif:Number = -2;

      roundShape.graphics.lineStyle(BEVEL_WIDTH,COLOR_PANEL);
      roundShape.graphics.beginFill(0xFFFFFF);
      roundShape.graphics.drawCircle(10+xModif,10+yModif,6);

      roundShape.graphics.lineStyle(BEVEL_WIDTH,COLOR_DARK);
      roundShape.graphics.beginFill(COLOR_DARK);
      roundShape.graphics.moveTo(6+xModif,14+yModif);
      roundShape.graphics.curveTo(2+xModif,2+yModif,14+xModif,6+yModif);

      roundShape.graphics.lineStyle(BEVEL_WIDTH,COLOR_LIGHT);
      roundShape.graphics.beginFill(COLOR_LIGHT);
      roundShape.graphics.moveTo(6+xModif,14+yModif);
      roundShape.graphics.curveTo(18+xModif,18+yModif,14+xModif,6);

      roundShape.graphics.lineStyle(0,0xFFFFFF);
      roundShape.graphics.beginFill(0xFFFFFF);
      roundShape.graphics.drawCircle(10+xModif,10+yModif,4);

      checkPanel.addChild(roundShape);
      
      checkShape.graphics.lineStyle(1,0x000000);
      checkShape.graphics.beginFill(0x000000);
      checkShape.graphics.drawCircle(10+xModif,10+yModif,2);

      checkPanel.addChild(checkShape);
      checkShape.visible = false;
    
      var tf_txt:TextField = new TextField();
      tf_txt.defaultTextFormat = TEXTFORMAT_BUTTON;
      tf_txt.text = buttonText;
      tf_txt.autoSize = TextFieldAutoSize.LEFT;
      tf_txt.x = BEVEL_WIDTH+17;
      tf_txt.selectable = false;

      tf_txt.setTextFormat( TEXTFORMAT_BUTTON );

      tf_txt.y = BEVEL_WIDTH+1;

      addChild(tf_txt);

      buttonMode = true;

      if(clickEvent != null)
      {
        addEventListener(MouseEvent.CLICK, clickEvent);
      }

      myText = buttonText;
    }

    public function registerInGroup(group:SFRadioButtonGroup):void
    {
      myGroup = group;
    }

    public function check():void
    {
      checked = true;
      checkShape.visible = true;
      if(myGroup != null)
      {
        myGroup.registerCheck(this);
      }
    }

    public function unCheck():void
    {
      checked = false;
      checkShape.visible = false;
    }

    public function isChecked():Boolean
    {
      return checked;
    }

    private function clickEvent(e:MouseEvent):void
    {
      check();
    }

    public function getText():String
    {
      return myText;
    }
  }
}
