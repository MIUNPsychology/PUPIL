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

  public class SFLabel extends SFComponent
  {
    public static const TEXTFORMAT_LABEL:TextFormat = new SFLabelTextFormat();

    private var tf_txt:TextField = new TextField();

    public function SFLabel(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,labelText:String,bold:Boolean = false) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);

      tf_txt.selectable = false;
      tf_txt.multiline = true;

      var format:TextFormat = TEXTFORMAT_LABEL;
      format.bold = bold;
      tf_txt.defaultTextFormat = format;
      tf_txt.text = labelText;
      tf_txt.setTextFormat(format);
      tf_txt.x = pX(0);
      tf_txt.width = pW();
      tf_txt.height = pH();

      addChild(tf_txt);
    }

    public function setText(msg:String):void
    {
      tf_txt.text = msg;
    }

    public function getText():String
    {
      return tf_txt.text;
    }

    public function appendText(msg:String):void
    {
      tf_txt.appendText(msg);
    }
  }
}
