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
  public class SFRadioButtonGroup
  {
    private var rbs:Array = null;

    public function SFRadioButtonGroup(items:Array) 
    {
      rbs = items;
      var rb:SFRadioButton = null;

      for(var i:uint = 0; i < rbs.length; i++)
      {
        rb = SFRadioButton(rbs[i]);
        rb.registerInGroup(this);
      }
    }

    public function registerCheck(item:SFRadioButton):void
    {
      var rb:SFRadioButton = null;

      for(var i:uint = 0; i < rbs.length; i++)
      {
        rb = SFRadioButton(rbs[i]);
        if(rb != item)
        {
          rb.unCheck();
        }
      }
    }

    public function getCheckedIndex():Number
    {
      var rb:SFRadioButton = null;

      for(var i:uint = 0; i < rbs.length; i++)
      {
        rb = SFRadioButton(rbs[i]);
        if(rb.isChecked())
        {
          return i;
        }
      }
      return -1;
    }

    public function getCheckedRadioButton():SFRadioButton
    {
      var rb:SFRadioButton = null;

      for(var i:uint = 0; i < rbs.length; i++)
      {
        rb = SFRadioButton(rbs[i]);
        if(rb.isChecked())
        {
          return rb;
        }
      }
      return null;
    }

    public function getCheckedText():String
    {
      var rb:SFRadioButton = null;

      for(var i:uint = 0; i < rbs.length; i++)
      {
        rb = SFRadioButton(rbs[i]);
        if(rb.isChecked())
        {
          return rb.getText();
        }
      }
      return "";
    }
  }
}
