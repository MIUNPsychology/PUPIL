package pupil.util;

import java.util.*;

import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.*;
import org.xml.sax.*;
import java.io.*;
import java.util.*;


public class XMLCommand
{
  private String functionName = "";
  private HashMap<String,String> parameters = null;
  private Element extraData = null;

  public XMLCommand(String name, HashMap<String,String> params)
  {
    functionName = name;
    parameters = params;
  }

  public XMLCommand(String name, HashMap<String,String> params, Element data)
  {
    this(name,params);
    extraData = data;
  }
  
  public Element getData()
  {
    return extraData;
  }

  public String getFunction()
  {
    return functionName;
  }

  public String getParameter(String param)
  {
    return parameters.get(param);
  }

  public HashMap getParameters()
  {
    return parameters;
  }

  public String toString()
  {
    String s = "[XMLCommand " + functionName + "(";
    boolean first = true;
    String[] keys = parameters.keySet().toArray(new String[] {});
    for(int i = 0; i < keys.length; i++)
    {
      if(!first)
      {
        s = s + ",";
      }
      else
      {
        first = false;
      }
      s = s + keys[i] + "=" + parameters.get(keys[i]);
    }
    s = s + ") ]";
    return s;
  }

}

