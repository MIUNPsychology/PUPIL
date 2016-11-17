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

  public class SFBulkImageLoader extends Loader
  {

    private var myComplete:Function = internalOnComplete;
    private var myError:Function = internalOnError;
    private var myProgress:Function = internalOnProgress;
    private var myInit:Function = internalOnInit;
    private var myOpen:Function = internalOnOpen;
    private var myUnload:Function = internalOnUnload;
    private var myStatus:Function = internalOnStatus;

    private var bulkComplete:Function = null;
    private var bulkError:Function = null;
    private var bulkProgress:Function = null;

    private var images:Array = null;
    private var imageUrls:Array = null;

    private var currentlyLoading:uint = 0;
    private var maxLoading:uint = 0;

    private var currentlyLoadingImage:SFRemoteImage = null;

    public function SFBulkImageLoader(urls:Array,onComplete:Function = null, onError:Function = null, onProgress:Function = null) 
    {
      maxLoading = urls.length;

      imageUrls = urls;
      images = new Array();

      bulkComplete = onComplete;
      bulkError = onError;
      bulkProgress = onProgress;

      loadNext();
    }

    public function getImageByUrl(url:String):SFRemoteImage
    {
      try
      {

      var nr:Number = -1;
      for(var i:uint = 0; i < imageUrls.length; i++)
      {
        if( imageUrls[i] == url ) { nr = i; }
      }

      if(nr >= 0) { return images[nr]; }
      else { return null; }      

      }
      catch(e:Error)
      {
        SFScreen.addDebug("BULK: " + e.toString());
      }

      return null;

    }

    public function getImageByIndex(idx:uint):SFRemoteImage
    {
      return images[idx];
    }

    public function imageByIndexAsComponent(idx:uint,owner:SFComponent,xPos:Number,yPos:Number,bevelPolicy:Number = SFComponent.BEVEL_NONE, bgcol:uint = SFComponent.COLOR_PANEL, alphaValue:Number = 0.0):SFComponent
    {
      var img:SFRemoteImage = getImageByIndex(idx);
      return img.asComponent(owner,xPos,yPos,bevelPolicy,bgcol,alphaValue);

    }

    public function imageByUrlAsComponent(url:String,owner:SFComponent,xPos:Number,yPos:Number,bevelPolicy:Number = SFComponent.BEVEL_NONE, bgcol:uint = SFComponent.COLOR_PANEL, alphaValue:Number = 0.0):SFComponent
    {
      var img:SFRemoteImage = getImageByUrl(url);
      return img.asComponent(owner,xPos,yPos,bevelPolicy,bgcol,alphaValue);
    }

    private function loadNext():void
    {
      if(currentlyLoading >= maxLoading) 
      { 
        if(bulkComplete != null) { bulkComplete(); }
        return; 
      }

      var url:String = imageUrls[currentlyLoading];

//      SFScreen.addDebug("Starting to load: " + url);

      currentlyLoadingImage = new SFRemoteImage(url,myComplete,myError,myProgress,myInit,myOpen,myUnload,myStatus) 
    }

    private function internalOnError(ev:IOErrorEvent):void
    {
      SFScreen.addDebug("SFBulkImageLoader - IoErrorEvent: " + ev);
      if(bulkError != null) { bulkError(ev); }
    }

    private function internalOnComplete(ev:Event):void
    {
//      SFScreen.addDebug("SFBulkImageLoader - CompleteEvent: " + ev);

      images[currentlyLoading] = currentlyLoadingImage;

      currentlyLoading++;
      if(bulkProgress != null) { bulkProgress(currentlyLoading,maxLoading); }
      loadNext();
    }

    private function internalOnProgress(ev:ProgressEvent):void
    {
//      SFScreen.addDebug("SFBulkImageLoader - ProgressEvent: " + ev);
    }

    private function internalOnInit(ev:Event):void
    {
//      SFScreen.addDebug("SFBulkImageLoader - InitEvent: " + ev);
    }

    private function internalOnOpen(ev:Event):void
    {
//      SFScreen.addDebug("SFBulkImageLoader - OpenEvent: " + ev);
    }

    private function internalOnUnload(ev:Event):void
    {
//      SFScreen.addDebug("SFBulkImageLoader - UnloadEvent: " + ev);
    }

    private function internalOnStatus(ev:HTTPStatusEvent):void
    {
//      SFScreen.addDebug("SFBulkImageLoader - HttpStatusEvent: " + ev);
    }

  }
}

