package pupil.core;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.*;
import org.xml.sax.*;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;

import pupil.util.*;


public abstract class UtilityServlet extends HttpServlet 
{
  public static final long serialVersionUID = 0L;
 
  private StaticInfoBlob sib = null;
  public static org.apache.log4j.Logger log = null;

  public StaticInfoBlob getSIB()
  {
    return sib;
  }

  /** processRequest */
  public void processRequest(HttpServletRequest request,HttpServletResponse response) throws IOException, ServletException
  {
    log.trace("enter processRequest()");

    RequestInfoBlob rib = new RequestInfoBlob(this,request,response);

    log.debug("RIB Dump:");
    log.debug("request: " + rib.request());
    log.debug("response: " + rib.response());
    log.debug("servlet: " + rib.servlet());
    log.debug("session: " + rib.session());
    log.debug("path: " + rib.path());


    boolean isMultiPart = ServletFileUpload.isMultipartContent(request);

    if(!isMultiPart)
    {
      String xml = request.getParameter("xml");

      if(xml == null || xml.equals(""))
      {
        log.debug("XML parameter is empty, assuming normal request");
        response.setContentType("text/html");
        processNormalRequest(sib,rib);
      }
      else
      {
        log.debug("XML parameter is present, assuming XML request");

        response.setContentType("text/plain");

        Document d = null;

        try
        {        
          d = XMLWrapper.stringToXML(xml);
        }
        catch(Exception e)
        {
          log.error("Failed to build an XML document",e);
        }

        if(d != null)
        {
          log.debug("We have a valid XML document, building XIB");
          XMLInfoBlob xib = new XMLInfoBlob(d,xml);
          try
          {          
            processXMLRequest(sib,rib,xib);

            Document xresp = xib.getResponse();
            if(xresp == null)
            {
              xib.setOkResponse();
              xresp = xib.getResponse();
            }

            rib.print(XMLWrapper.xmlToString(xresp));
          }
          catch(SAXException e)
          {
            log.error("Unhandled SAXException",e);
            rib.println("<error>SAXException: " + e.getMessage());
          }
          catch(ParserConfigurationException e)
          {
            log.error("Unhandled ParserConfigurationException",e);
            rib.println("<error>ParserConfigurationException: " + e.getMessage());
          }
          catch(TransformerConfigurationException e)
          {
            log.error("Unhandled TransformerConfigurationException",e);
            rib.println("<error>TransformerConfigurationException: " + e.getMessage());
          }
          catch(TransformerException e)
          {
            log.error("Unhandled TransformerException",e);
            rib.println("<error>TransformerException: " + e.getMessage());
          }
          catch(DOMException e)
          {
            log.error("Unhandled DOMException",e);
            rib.println("<error>DOMException: " + e.getMessage());
          }

          log.debug("Releasing XIB");
        }
        else
        {
          log.debug("No valid xml document, outputting standard error");
          log.debug("XML string follows");
          log.debug(xml);
          rib.println("<error>Input XML document was malformed</error>");
        }
      }
    }
    else
    {
      log.debug("Multipart submit detected, assuming file upload");
      try
      {
        // Create a factory for disk-based file items
        DiskFileItemFactory factory = new DiskFileItemFactory();

        // Set factory constraints
        //factory.setSizeThreshold(yourMaxMemorySize);
        //factory.setRepository(yourTempDirectory);

        // Create a new file upload handler
        ServletFileUpload upload = new ServletFileUpload(factory);

        // Set overall request size constraint
        //upload.setSizeMax(yourMaxRequestSize);

        // Parse the request
        List /* FileItem */ items = upload.parseRequest(request);

        Iterator iter = items.iterator();
        while (iter.hasNext()) 
        {
          FileItem item = (FileItem) iter.next();

          if (!item.isFormField()) 
          {
            String fieldName = item.getFieldName();
            String fileName = item.getName();
            String contentType = item.getContentType();
            boolean isInMemory = item.isInMemory();
            long sizeInBytes = item.getSize();

            log.debug("upload fieldname: " + fieldName);
            log.debug("upload filename: " + fileName);
            log.debug("upload content: " + contentType);
            log.debug("upload isInMemory: " + isInMemory);
            log.debug("upload sizeInBytes: " + sizeInBytes);

            processFileUpload(sib,rib,fieldName,fileName,contentType,sizeInBytes,item);

            log.debug("after processFileUpload()");
          }
        }
      }
      catch(FileUploadException e)
      {
        log.error("FileUploadException: " + e.getMessage(), e);
      }
      catch(IOException e)
      {
        log.error("IOException: " + e.getMessage(), e);
      }

      rib.println("OK");
      // Multipart
    }

    log.debug("releasing RIB");
    rib.release();

    log.trace("leave processRequest()");
  }

  public abstract void processNormalRequest(StaticInfoBlob sib,RequestInfoBlob rib) throws IOException, ServletException;
  public abstract void processXMLRequest(StaticInfoBlob sib,RequestInfoBlob rib,XMLInfoBlob xib) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException;
  public abstract void processFileUpload(StaticInfoBlob sib,RequestInfoBlob rib, String fieldName, String fileName, String contentType, long sizeInBytes, FileItem item) throws IOException, ServletException, FileUploadException;

  /** doPost */
  public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException, ServletException
  {
    log.trace("enter doPost()");
    log.debug("new POST request");
    processRequest(request,response);
  }
  
  
  /** doGet */
  public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException, ServletException
  {
    log.trace("enter doGet()");
    log.debug("new GET request");
    processRequest(request,response);
  }

  
  public final void init()
  {
    sib = new StaticInfoBlob(this);
    org.apache.log4j.PropertyConfigurator.configure(sib.getLogConf());
    log = org.apache.log4j.Logger.getLogger(UtilityServlet.class);

    log.debug("At this point, the logger should be initialized");

    log.debug("SIB Dump:");
    log.debug("Physical path: " + sib.getPhysicalPath());
    log.debug("WEB-INF path: " + sib.getWebInfPath());
    log.debug("Log configuration file: " + sib.getLogConf());
    log.debug("Context: " + sib.getServletContext());
    log.debug("Servlet: " + sib.getServlet());

    init(sib);

    log.trace("Leaving init()");
  }

  /** init */
  public abstract void init(StaticInfoBlob sib);
  
  /** getServletInfo
   * Returns a version string describing this servlet. */
  public abstract String getServletInfo();
}



