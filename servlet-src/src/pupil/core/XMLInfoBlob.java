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

import pupil.util.*;

public class XMLInfoBlob
{
  private String rawString = null;
  private Document myDoc = null;

  private Document myResponse = null;

  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(RequestInfoBlob.class);

  public XMLInfoBlob(Document d, String raw)
  {
    log.trace("enter XMLInfoBlob()");
    rawString = raw;
    myDoc = d;
    log.trace("leave XMLInfoBlob()");
  }

  public void setOkResponse() throws SAXException, ParserConfigurationException, TransformerConfigurationException
  {
    myResponse = XMLWrapper.getEmptyDocument("ok");
  }

  public void setErrorResponse(String message) throws SAXException, ParserConfigurationException, TransformerConfigurationException
  {
    myResponse = XMLWrapper.getEmptyDocument("error");
    Text txt = myResponse.createTextNode(message);
    myResponse.getDocumentElement().appendChild(txt);
  }

  public Document startNewResponse(String rootNodeName) throws SAXException, ParserConfigurationException, TransformerConfigurationException
  {
    myResponse = XMLWrapper.getEmptyDocument(rootNodeName);
    return myResponse;
  }

  public void setResponse(Document d)
  {
    log.trace("enter setResponse()");
    myResponse = d;
    log.trace("leave setResponse()");
  }

  public Document getResponse()
  {
    log.trace("enter getResponse()");
    log.trace("leave getResponse()");
    return myResponse;
  }

  public Document getRequestXML()
  {
    log.trace("enter getRequestXML()");
    log.trace("leave getRequestXML()");
    return myDoc;
  }

  public String getRequestString()
  {
    log.trace("enter getRequestString()");
    log.trace("leave getRequestString()");
    return rawString;
  }

  public void release()
  {
    log.trace("enter release()");
    rawString = null;
    myDoc = null;
    myResponse = null;
    log.trace("leave release()");
  }

}

