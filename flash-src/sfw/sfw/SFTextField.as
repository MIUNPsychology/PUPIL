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

  public class SFTextField extends SFComponent
  {
    public static const TEXTFORMAT_TEXT:TextFormat = new SFTextFieldTextFormat();
    private var tf_txt:TextField = new TextField();

    public function SFTextField(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number = 22,defaultText:String = "",multiline:Boolean = false) 
    {
      super(owner,xPos,yPos,aWidth,aHeight,0xFFFFFF);
      drawBevel(BEVEL_DOWN);

      tf_txt.defaultTextFormat = TEXTFORMAT_TEXT;

      tf_txt.autoSize = TextFieldAutoSize.NONE;
      tf_txt.type = TextFieldType.INPUT;
      tf_txt.width = aWidth-BEVEL_WIDTH;
      tf_txt.setTextFormat( TEXTFORMAT_TEXT );
      tf_txt.text = defaultText;
      tf_txt.height = pH();
      tf_txt.x = BEVEL_WIDTH;
      tf_txt.y = BEVEL_WIDTH;
      tf_txt.selectable = true;
      tf_txt.alwaysShowSelection = true;
      tf_txt.multiline = multiline;

      tf_txt.setTextFormat( TEXTFORMAT_TEXT );

      addEventListener(FocusEvent.FOCUS_IN,focusInEvent);
      
      addChild(tf_txt);

    }

    public function focusInEvent(e:Event):void
    {
      stage.focus = tf_txt;
    }

    public function getTextField():TextField
    {
      return tf_txt;
    }

    public function getText():String
    {
      return tf_txt.text;
    }

    public function setText(txt:String):void
    {
      tf_txt.text = txt;
    }
  }
}

