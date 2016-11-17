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

  public class SFMenuItem extends SFComponent 
  {
    private var tf_txt:TextField = new TextField();

    private static const TEXTFORMAT_MENUITEM:TextFormat = new SFMenuItemTextFormat();

    public function SFMenuItem(label:String,clickEvent:Function = null) 
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

      buttonMode = true;

      if(clickEvent != null)
      {
        addEventListener(MouseEvent.CLICK, clickEvent);
      }
    }
  }
}
