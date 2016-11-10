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

  public class SFFrameTitle extends SFComponent
  {
    public static const TEXTFORMAT_TITLETEXT:TextFormat = new SFFrameTitleTextFormat();

    public function SFFrameTitle(owner:SFFrame, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,titleText:String) 
    {
      super(owner,xPos,yPos,aWidth,aHeight,COLOR_TITLEBAR);

      var tf_txt:TextField = new TextField();
      tf_txt.text = titleText;
      tf_txt.autoSize = TextFieldAutoSize.LEFT;
      tf_txt.x = BEVEL_WIDTH;
      tf_txt.width = aWidth-BEVEL_WIDTH;
      tf_txt.selectable = false;

      tf_txt.setTextFormat( TEXTFORMAT_TITLETEXT );

      tf_txt.y = Math.floor( (aHeight / 2) - (tf_txt.height / 2) );

      addChild(tf_txt);
    }

  }
}
