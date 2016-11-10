package pupil.util;

import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.*;
import org.xml.sax.*;
import java.io.*;
import java.util.*;

public class XMLWrapper
{
  private static DocumentBuilderFactory factory = null;
  private static DocumentBuilder builder = null;
  private static TransformerFactory tfactory = null;
  private static Transformer transform = null;

  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(XMLWrapper.class);

  private static void setup() throws ParserConfigurationException, TransformerConfigurationException
  {
    if(factory == null)
    {
      factory = DocumentBuilderFactory.newInstance();
    }
    if(builder == null)
    {      
      builder = factory.newDocumentBuilder();
    }
    if(tfactory == null)
    {
      tfactory = TransformerFactory.newInstance();
    }
    if(transform == null)
    {    
      transform = tfactory.newTransformer();
      transform.setOutputProperty(OutputKeys.VERSION, "1.0");
      transform.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
//      transform.setOutputProperty(OutputKeys.STANDALONE, "yes"); 
      transform.setOutputProperty(OutputKeys.INDENT, "yes"); 
      transform.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
    }
  }

  public static boolean isCommand(Document d) throws SAXException, ParserConfigurationException, TransformerConfigurationException
  {
    if(d == null) return false;

    Element e = d.getDocumentElement();
    String s = e.getTagName();

    return (s != null && s.equals("command"));
  }

  public static XMLCommand asCommand(Document d) throws SAXException, ParserConfigurationException, TransformerConfigurationException
  {
    if(!isCommand(d))
    {
      return null;
    }

    Element root = d.getDocumentElement();
    NodeList nl = root.getElementsByTagName("function");
    Element function = (Element)nl.item(0);

    String funcName = function.getTextContent();

    HashMap<String,String> h = new HashMap<String,String>();

    String name = "";
    String value = "";
    Element param = null;

    nl = root.getElementsByTagName("parameter");
    for(int i = 0; i < nl.getLength(); i++)
    {
      param = (Element)nl.item(i);
      name = param.getAttribute("name");
      value = param.getAttribute("value");
      h.put(name,value);
    }

    nl = root.getElementsByTagName("data");

    log.debug("data items: " + nl.getLength());

    if(nl.getLength() > 0)
    {
      Element data = (Element)nl.item(0);
      log.debug("data element: " + data);
      return new XMLCommand(funcName,h,data);
    }

    return new XMLCommand(funcName,h);
  }


  public static Document getEmptyDocument(String rootNodeName) throws SAXException, ParserConfigurationException, TransformerConfigurationException
  {
    return stringToXML("<" + rootNodeName + "></" + rootNodeName + ">");
  }

  public static Document stringToXML(String xml) throws SAXException, ParserConfigurationException, TransformerConfigurationException
  {
    setup();

    if(xml == null || xml.equals(""))
    {
      return null;
    }

    Document d = null;

    try
    {
      d = builder.parse(new InputSource(new StringReader(xml)));
    }
    catch(IOException e)
    {
      // never happens since we're not working with files
    }

    return d;
  }

  public static String xmlToString(Document d) throws ParserConfigurationException, TransformerException
  {
    setup();

    if(d == null)
    {
      return "";
    }

    StringWriter out = new StringWriter();
    DOMSource domS = new DOMSource(d);
    transform.transform(domS, new StreamResult(out));
    
    return out.toString();
  }

}



