package pupil.util;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.exception.ExceptionUtils;
import java.io.*;

public class LogWrapper
{
  private final int maxLogLevel = 3;

  private String[] logLevels = new String[]{
                                "ERROR", // 0
                                "WARN ", // 1
                                "INFO ", // 2
                                "DEBUG", // 3
                                "TRACE"  // 4
                                };

  private File logFile = null;

  public LogWrapper()
  {
    String catalina = System.getProperty("catalina.base");
    if(catalina != null)
    {
      File tomcatRoot = new File(catalina);
      File logDir = new File(tomcatRoot,"logs");
      
      if(logDir.exists())        
      {
        logFile = new File(logDir,"pupil.log");
      }
    }    
  }
  
  private void message(int level, Object msg, Object extra)
  {
    if(level > maxLogLevel) return;

    StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
    StackTraceElement sourceElement = stackTraceElements[3];
    
    String method = sourceElement.getMethodName();
    String classname = sourceElement.getClassName();
    int linenr = sourceElement.getLineNumber();    

    String line = logLevels[level] + " -- " + classname + "." + method + "():" + linenr + " -- ";

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

    if(logFile == null) 
    {
      System.out.println(line);
      return;
    }

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
    this.message(4,msg,null);
  }

  public void trace(Object msg, Object extra)
  {
    this.message(4,msg,extra);
  }

  public void debug(Object msg)
  {
    this.message(3,msg,null);
  }

  public void debug(Object msg, Object extra)
  {
    this.message(3,msg,extra);
  }

  public void info(Object msg)
  {
    this.message(2,msg,null);
  }

  public void info(Object msg, Object extra)
  {
    this.message(2,msg,extra);
  }

  public void warn(Object msg)
  {
    this.message(1,msg,null);
  }

  public void warn(Object msg, Object extra)
  {
    this.message(1,msg,extra);
  }

  public void error(Object msg)
  {
    this.message(0, msg,null);
  }

  public void error(Object msg, Object extra)
  {
    this.message(0, msg,extra);
  }

}

