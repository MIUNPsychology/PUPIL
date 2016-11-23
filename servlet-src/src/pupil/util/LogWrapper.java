package pupil.util;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.exception.ExceptionUtils;
import java.io.*;

public class LogWrapper
{
  private File logFile = new File("/tmp/pupil.log");

  public LogWrapper()
  {
  }
  
  private void message(Object msg, Object extra)
  {
    String line = "PUPIL -- ";

    if(msg != null)
    {
      line = line + msg.toString();
    }
    else
    {
      line = line + "null";
    }

    if(extra != null)
    {
      if(extra instanceof Throwable)
      {
        line = line + "\n" + ExceptionUtils.getStackTrace((Throwable)extra);
      }
      else
      {
        line = line + " ";
        line = line + extra.toString();
      }
    }

    line = line + "\n";

    try
    {
      FileUtils.writeStringToFile(logFile,line,true);
    }
    catch(Exception e)
    {
    }
  }

  public void trace(Object msg)
  {
    this.message(msg,null);
  }

  public void trace(Object msg, Object extra)
  {
    this.message(msg,extra);
  }

  public void debug(Object msg)
  {
    this.message(msg,null);
  }

  public void debug(Object msg, Object extra)
  {
    this.message(msg,extra);
  }

  public void info(Object msg)
  {
    this.message(msg,null);
  }

  public void info(Object msg, Object extra)
  {
    this.message(msg,extra);
  }

  public void warn(Object msg)
  {
    this.message(msg,null);
  }

  public void warn(Object msg, Object extra)
  {
    this.message(msg,extra);
  }

  public void error(Object msg)
  {
    this.message(msg,null);
  }

  public void error(Object msg, Object extra)
  {
    this.message(msg,extra);
  }

}

