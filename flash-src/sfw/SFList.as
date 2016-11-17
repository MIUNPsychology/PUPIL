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

  public class SFList extends SFComponent
  {
    public const TEXTFORMAT_LIST:SFTextFormat = new SFListTextFormat();

    private var myBevelPolicy:Number = BEVEL_DOWN;
    private var myItems:Array = null;

    private var scrollPane:SFScrollPane = null;
    private var listPanel:SFComponent = null;

    private var textFields:Array = null;

    private var selectedIndex:Number = -1;

    private var myOnSelect:Function = null;

    public function SFList(owner:SFComponent, xPos:Number,yPos:Number,aWidth:Number,aHeight:Number,items:Array,bevelPolicy:Number = BEVEL_NONE, onSelectionChange:Function = null) 
    {
      super(owner,xPos,yPos,aWidth,aHeight);
      myBevelPolicy = bevelPolicy;
      drawBevel(myBevelPolicy);

      var i:Number = 0;

      textFields = new Array();
      var tf_txt:TextField = null;

      var totalHeight:Number = 0;
      var maxWidth:Number = aWidth-SFScrollPane.BARSIZE;

      for(i = 0; i < items.length; i++)
      {
        tf_txt = new TextField();
        tf_txt.defaultTextFormat = TEXTFORMAT_LIST;
        tf_txt.autoSize = TextFieldAutoSize.LEFT;
        tf_txt.setTextFormat( TEXTFORMAT_LIST );
        tf_txt.text = items[i];
        tf_txt.setTextFormat( TEXTFORMAT_LIST );
        tf_txt.background = true;
        tf_txt.backgroundColor = 0xFFFFFF;
        totalHeight += tf_txt.height;
        if(tf_txt.width > maxWidth) { maxWidth = tf_txt.width; }
        addEventListener(MouseEvent.CLICK,itemClick);
        textFields[i] = tf_txt;
      }

      if(totalHeight < (aHeight-SFScrollPane.BARSIZE)) { totalHeight = aHeight-SFScrollPane.BARSIZE; }

      listPanel = new SFComponent(null,0,0,maxWidth,totalHeight,0xFFFFFF);

      var yPos:Number = 0;

      for(i = 0; i < items.length; i++)
      {
        tf_txt = textFields[i];
        tf_txt.y = yPos;
        tf_txt.x = 0;
        tf_txt.autoSize = TextFieldAutoSize.NONE;
        tf_txt.width = maxWidth;
        yPos += tf_txt.height;
        listPanel.addChild(tf_txt);
      }
      scrollPane = new SFScrollPane(this,0,0,aWidth,aHeight,listPanel);

      myOnSelect = onSelectionChange;
    }

    public function getHorizontalScrollBar():SFHorizontalScrollBar
    {
      if(scrollPane == null)
      {
        return null;
      }
      return scrollPane.getHorizontalScrollBar();
    }

    public function getVerticalScrollBar():SFVerticalScrollBar
    {
      if(scrollPane == null)
      {
        return null;
      }
      return scrollPane.getVerticalScrollBar();
    }

    public function clearSelection():void
    {
      selectedIndex = -1;

      var f:TextField = null;

      for(var i:uint = 0; i < textFields.length; i++)      
      {
        f = TextField(textFields[i]);
        f.backgroundColor = 0xFFFFFF;
      }
    }

    public function setSelectedIndex(idx:Number):void
    {
      selectedIndex = idx;

      if(idx >= 0)
      {
        var f:TextField = null;
        f = TextField(textFields[idx]);
        f.backgroundColor = SFComponent.COLOR_SELECTION;
      }
    }

    public function getSelectedIndex():Number
    {
      return selectedIndex;
    }

    public function getSelectedText():String
    {
      if(selectedIndex >= 0)
      {
        var f:TextField = TextField(textFields[selectedIndex]);
        return f.text;
      }

      return "";
    }

    private function itemClick(e:MouseEvent):void
    {
      //      SFScreen.addDebug("click()" + e.target);
      var f1:TextField = TextField(e.target);
      var f2:TextField = null;

      var selidx:Number = -1;

      for(var i:uint = 0; i < textFields.length; i++)
      {
        f2 = textFields[i];
        if(f1 == f2)
        {
          selidx = i;
          //          SFScreen.addDebug("Index " + i + " matches");
        }
      }

      if(selidx >= 0)
      {
        clearSelection();
        setSelectedIndex(selidx);
      }

      // SFScreen.addDebug("Index " + getSelectedIndex());
      // SFScreen.addDebug("Text " + getSelectedText());

      if(myOnSelect != null)
      {
        myOnSelect(getSelectedIndex(),getSelectedText());
      }
    }
  }
}
