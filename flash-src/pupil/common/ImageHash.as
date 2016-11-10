package pupil.common
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class ImageHash
  {
    private var categoryHash:Object = new Object();
    private var myBulk:SFBulkImageLoader = null;
    private var myPrefix:String = "";

    private var randomSets:Object = new Object();

    public function ImageHash()
    {
      //
    }

    public function registerImages(bulk:SFBulkImageLoader, imagelist:Array, prefix:String = "images/"):void
    {
      var tmp:Array;
      var obj:Object;
      var cat:Array;

      myBulk = bulk;
      myPrefix = prefix;

      var l:Number = prefix.length;

      for(var i:uint = 0; i < imagelist.length; i++)
      {
        tmp = imagelist[i].substr(l).split("/");

        obj = categoryHash[tmp[0]];
        if(obj == null)
        {
          obj = new Array();
          categoryHash[tmp[0]] = obj;
        }

        cat = obj as Array;

        cat[cat.length] = tmp[1];

//        SFScreen.addDebug(tmp[0] + " " + tmp[1]);
      }
    }

    public function getImageFromPath(path:String):SFRemoteImage
    {
      return myBulk.getImageByUrl(myPrefix + path);
    }

    public function getImage(category:String, name:String):SFRemoteImage
    {
      var url:String = myPrefix + category + "/" + name;
      return myBulk.getImageByUrl(url);
    }

    public function getRandomImage(category:String, uniqueRandomSet:String = "", splicearray:Boolean = false):SFRemoteImage
    {
//      SFScreen.addDebug("getRandomImage()");

      var obj:Object = categoryHash[category];
      if(obj != null)
      {
        var arr:Array = obj as Array;
        
        var r:Number;
        var fn:String;

        if(uniqueRandomSet == "")
        {
          r = Math.floor(Math.random() * arr.length);
          fn = arr[r];
        }
        else
        {
          var rndsetid:String = category + "_" + uniqueRandomSet;
          var rarr:Array;
          var rndset:Object = randomSets[rndsetid];

//          SFScreen.addDebug("rndsetid: " + rndsetid);
//          SFScreen.addDebug("rndset: " + rndset);

          if(rndset == null)
          {
            rarr = new Array();
            for(var i:uint = 0; i < arr.length; i++)
            {
              rarr[i] = arr[i];
            }
            rndset = rarr;
            randomSets[rndsetid] = rarr;
          }

          rarr = rndset as Array;

//          SFScreen.addDebug("rarr: " + rarr.length);

          r = Math.floor(Math.random() * rarr.length);
          fn = rarr[r];
          
          var poppedarr:Array = new Array();
          for(var n:uint = 0; n < rarr.length; n++)
          {
            if(n != r)
            {
              poppedarr[poppedarr.length] = rarr[n];
            }
//            SFScreen.addDebug("poppedarr --: " + poppedarr.length);
          }
//          SFScreen.addDebug("poppedarr: " + poppedarr.length);

          randomSets[rndsetid] = poppedarr;
        }

        var rimg:SFRemoteImage = getImage(category,fn);

        if(splicearray)
        {
          // SFScreen.addDebug("about to splice");

          var newarr:Array = new Array();
          var na:uint;

          for(na = 0; na < arr.length; na++)
          {
            if(arr[na] != fn)
            {
              newarr[newarr.length] = arr[na];
            }
          }
          categoryHash[category] = newarr;

          // SFScreen.addDebug("SPLICE: " + arr.length + " - " + newarr.length);
        }

        return rimg;
      }
      else
      {
        SFScreen.addDebug("Category hash is null. Expect a crash in the next few lines of code.");
      }

      return null;
    }
  }
}

