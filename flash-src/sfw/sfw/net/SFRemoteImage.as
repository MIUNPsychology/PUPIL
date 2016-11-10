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

  public class SFRemoteImage extends Loader
  {
    private var myInfo:LoaderInfo = null;

    private var myComplete:Function = internalOnComplete;
    private var myError:Function = internalOnError;
    private var myProgress:Function = internalOnProgress;
    private var myInit:Function = internalOnInit;
    private var myOpen:Function = internalOnOpen;
    private var myUnload:Function = internalOnUnload;
    private var myStatus:Function = internalOnStatus;

      /* complete, httpStatus, init, ioError, open, progress, unload 

         Event.COMPLETE, HTTPStatusEvent.HTTP_STATUS, Event.INIT, IOErrorEvent.IO_ERROR
         Event.OPEN, ProgressEvent.PROGRESS, Event.UNLOAD
      */

    public function SFRemoteImage(url:String,onComplete:Function = null, onError:Function = null, onProgress:Function = null, onInit:Function = null, onOpen:Function = null, onUnload:Function = null, onStatus:Function = null) 
    {
      super();
      var req:URLRequest = new URLRequest(url);

      if(onError != null) { myError = onError; }
      if(onComplete != null) { myComplete = onComplete; }
      if(onProgress != null) { myProgress = onProgress; }
      if(onInit != null) { myInit = onInit; }
      if(onOpen != null) { myOpen = onOpen; }
      if(onUnload != null) { myUnload = onUnload; }
      if(onStatus != null) { myStatus = onStatus; }

      myInfo = contentLoaderInfo;
      myInfo.addEventListener(Event.COMPLETE, myComplete);
      myInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, myStatus);
      myInfo.addEventListener(Event.INIT, myInit);
      myInfo.addEventListener(IOErrorEvent.IO_ERROR, myError);
      myInfo.addEventListener(Event.OPEN, myOpen);
      myInfo.addEventListener(ProgressEvent.PROGRESS, myProgress);
      myInfo.addEventListener(Event.UNLOAD, myUnload);

      load(req);

    }

    public function asBitmapClone():Bitmap
    {
      var bm:Bitmap = Bitmap(content);
      return new Bitmap(bm.bitmapData.clone());
    }

    public function asComponent(owner:SFComponent,xPos:Number,yPos:Number,bevelPolicy:Number = SFComponent.BEVEL_NONE, bgcol:uint = SFComponent.COLOR_PANEL, alphaValue:Number = 0.0):SFComponent
    {
      var bm:Bitmap = asBitmapClone();

      var bWidth:Number = bm.width;
      var bHeight:Number = bm.height;

      if(bevelPolicy != SFComponent.BEVEL_NONE)
      {
        bWidth += SFComponent.BEVEL_WIDTH;
        bHeight += SFComponent.BEVEL_WIDTH;
        bm.x = SFComponent.BEVEL_WIDTH;
        bm.y = SFComponent.BEVEL_WIDTH;
      }

      var comp:SFComponent = new SFComponent(owner,xPos,yPos,bWidth,bHeight,bgcol,alphaValue);
      comp.addChild(bm);
      if(bevelPolicy != SFComponent.BEVEL_NONE)
      {
        bm.x = SFComponent.BEVEL_WIDTH;
        bm.y = SFComponent.BEVEL_WIDTH;
        comp.drawBevel(bevelPolicy);
      }

      return comp;
    }
    

    private function internalOnError(ev:IOErrorEvent):void
    {
      SFScreen.addDebug("SFRemoteImage - IoErrorEvent: " + ev);
    }

    private function internalOnComplete(ev:Event):void
    {
      SFScreen.addDebug("SFRemoteImage - CompleteEvent: " + ev);
    }

    private function internalOnProgress(ev:ProgressEvent):void
    {
      SFScreen.addDebug("SFRemoteImage - ProgressEvent: " + ev);
    }

    private function internalOnInit(ev:Event):void
    {
      SFScreen.addDebug("SFRemoteImage - InitEvent: " + ev);
    }

    private function internalOnOpen(ev:Event):void
    {
      SFScreen.addDebug("SFRemoteImage - OpenEvent: " + ev);
    }

    private function internalOnUnload(ev:Event):void
    {
      SFScreen.addDebug("SFRemoteImage - UnloadEvent: " + ev);
    }

    private function internalOnStatus(ev:HTTPStatusEvent):void
    {
      SFScreen.addDebug("SFRemoteImage - HttpStatusEvent: " + ev);
    }

  }
}

