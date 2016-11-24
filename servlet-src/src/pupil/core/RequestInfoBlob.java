package pupil.core;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import pupil.util.*;

public class RequestInfoBlob
{
  private HttpServletRequest myRequest = null;
  private HttpServletResponse myResponse = null;
  private UtilityServlet myServlet = null;
  private HttpSession mySession = null;
  private String myPath = null;

  private PrintWriter out = null;

  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(RequestInfoBlob.class);
  private static LogWrapper log = new LogWrapper();

  public RequestInfoBlob(UtilityServlet servlet,HttpServletRequest request,HttpServletResponse response) throws IOException, ServletException    
  {
    log.trace("enter RequestInfoBlob()");
    log.debug("Constructing new RequestInfoBlob");

    myServlet = servlet;
    myRequest = request;
    myResponse = response;

    mySession = request.getSession(true);

    myPath = request.getPathInfo();
    log.trace("leave RequestInfoBlob()");
  }

  public HttpServletRequest request()
  {
    log.trace("enter request()");
    log.trace("leave request()");
    return myRequest;
  }

  public HttpServletResponse response()
  {
    log.trace("enter response()");
    log.trace("leave response()");
    return myResponse;
  }

  public UtilityServlet servlet()
  {
    log.trace("enter session()");
    log.trace("leave session()");
    return myServlet;
  }

  public HttpSession session()
  {
    log.trace("enter session()");
    log.trace("leave session()");
    return mySession;
  }

  public String path()
  {
    log.trace("enter path()");
    log.trace("leave path()");
    return myPath;
  }

  public void print(String text) throws IOException
  {
    PrintWriter o = getWriter();
    o.print(text);
    o = null;
  }

  public void println(String text) throws IOException
  {
    PrintWriter o = getWriter();
    o.println(text);
    o = null;
  }

  public PrintWriter getWriter() throws IOException
  {
    log.trace("enter getWriter()");
    if(out == null)
    {
      out = myResponse.getWriter();
    }
    log.trace("leave getWriter()");
    return out;
  }

  public void release() throws IOException
  {
    log.trace("enter release()");
    myRequest = null;
    myResponse = null;
    myServlet = null;
    mySession = null;
    myPath = null;

    if(out != null)
    {
      out.flush();
      out = null;
    }
    log.trace("leave release()");
  }
}

