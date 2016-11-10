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

  public class SFCheckBox extends SFComponent
  {
    public static const TEXTFORMAT_BUTTON:TextFormat = new SFButtonTextFormat();

    private var checkPanel:SFComponent = null;
    private var checkShape:Shape = new Shape();

    private var checked:Boolean = false;

    public function SFCheckBox(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,buttonText:String) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);

      checkPanel = new SFComponent(this,3,BEVEL_WIDTH+3,12,12,0xFFFFFF);
      checkPanel.drawBevel(BEVEL_DOWN);

      checkShape.graphics.lineStyle(1,0x000000);
      checkShape.graphics.beginFill(0x000000);
      checkShape.graphics.drawRect(checkPanel.pX(2),checkPanel.pY(2),checkPanel.pW()-4,checkPanel.pH()-4);

      checkPanel.addChild(checkShape);
      checkShape.visible = false;
      
      var tf_txt:TextField = new TextField();
      tf_txt.text = buttonText;
      tf_txt.autoSize = TextFieldAutoSize.LEFT;
      tf_txt.x = BEVEL_WIDTH+17;
      tf_txt.selectable = false;

      tf_txt.setTextFormat( TEXTFORMAT_BUTTON );

      tf_txt.y = BEVEL_WIDTH;

      addChild(tf_txt);

      buttonMode = true;

      if(clickEvent != null)
      {
        addEventListener(MouseEvent.CLICK, clickEvent);
      }
    }

    public function check():void
    {
      checked = true;
      checkShape.visible = true;
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
      checked = !checked;
      if(checked) { check(); } else { unCheck(); }
    }
  }
}
