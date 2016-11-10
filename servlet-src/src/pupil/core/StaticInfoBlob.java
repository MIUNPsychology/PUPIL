package pupil.core;

import javax.servlet.*;
import javax.servlet.http.*;

public class StaticInfoBlob
{
  private String servletPhysicalPath = "";
  private String servletWebInfPath = "";
  private ServletContext servletContext = null;
  private String servletLogConf = "";

  private UtilityServlet servletMain = null;

  public StaticInfoBlob(UtilityServlet servlet)
  {
    servletContext = servlet.getServletContext();
    servletPhysicalPath = servletContext.getRealPath("/");
    servletWebInfPath = servletPhysicalPath + "WEB-INF";
    servletLogConf = servletWebInfPath + "/log.properties";
    servletMain = servlet;
  }

  public String getPhysicalPath()
  {
    return servletPhysicalPath;
  }

  public String getWebInfPath()
  {
    return servletWebInfPath;
  }

  public ServletContext getServletContext()
  {
    return servletContext;
  }

  public UtilityServlet getServlet()
  {
    return servletMain;
  }

  public String getLogConf()
  {
    return servletLogConf;
  }

}

