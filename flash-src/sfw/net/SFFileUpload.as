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



package sfw.net
{
  import flash.display.*;
  import flash.events.*;
  import flash.text.*;

  import flash.net.*;
  import sfw.*;

  public class SFFileUpload extends FileReference
  {
    private var extOnComplete:Function = null;
    private var extOnSelect:Function = null;
    private var extOnCancel:Function = null;
    private var extOnError:Function = null;
    private var extOnProgress:Function = null;

    private var myUrl:URLRequest = null;
    private var myField:String = "";

    public function SFFileUpload(url:String, fieldName:String, onSelect:Function, onCancel:Function, onComplete:Function = null, onError:Function = null, onProgress:Function = null) 
    {
      super();
      extOnComplete = onComplete;
      extOnSelect = onSelect;
      //extOnSelect = flum;
      extOnCancel = onCancel;
      extOnError = onError;
      extOnProgress = onProgress;

      myUrl = new URLRequest(url);
      myField = fieldName;

      this.addEventListener(Event.CANCEL, internalOnCancel);
      this.addEventListener(Event.SELECT, internalOnSelect);
      this.addEventListener(Event.COMPLETE, internalOnComplete);
      this.addEventListener(IOErrorEvent.IO_ERROR, internalOnError);
      this.addEventListener(ProgressEvent.PROGRESS, internalOnProgress);
    }

    public function doUpload():void
    {
      upload(myUrl,myField);
    }

    private function internalOnSelect(ev:Event):void
    {
//      SFScreen.addDebug("SFFileUpload - SelectEvent: " + ev);
      if(extOnSelect != null)
      {
        try
        {
           extOnSelect();
        }
        catch(e:Error)
        {
          SFScreen.addDebug(e.toString());
        }
      }
    }

    private function internalOnCancel(ev:Event):void
    {
      SFScreen.addDebug("SFFileUpload - CancelEvent: " + ev);
      if(extOnCancel != null)
      {
        extOnCancel(ev);
      }
    }

    private function internalOnError(ev:IOErrorEvent):void
    {
      SFScreen.addDebug("SFFileUpload - IoErrorEvent: " + ev);
      if(extOnError != null)
      {
        extOnError(ev);
      }
    }

    private function internalOnComplete(ev:Event):void
    {
//      SFScreen.addDebug("SFFileUpload - CompleteEvent: " + ev);
      if(extOnComplete != null)
      {
        extOnComplete(ev);
      }
    }

    private function internalOnProgress(ev:ProgressEvent):void
    {
//      SFScreen.addDebug("SFFileUpload - ProgressEvent: " + ev);
      if(extOnProgress != null)
      {
        extOnProgress(ev);
      }
    }
  }
}

