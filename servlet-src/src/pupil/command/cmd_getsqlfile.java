package pupil.command;

import pupil.*;
import pupil.sql.*;
import pupil.core.*;
import pupil.util.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.*;
import org.xml.sax.*;
import org.apache.commons.io.*;

public class cmd_getsqlfile extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_getsqlfile.class);

  public cmd_getsqlfile(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  @SuppressWarnings("unchecked")
  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_getsqlfile()");

    try
    {
      String name = cmd.getParameter("name");

      log.debug("name: " + name);

      String rootdir = rib.servlet().getSIB().getPhysicalPath();
      log.debug("rootdir: " + rootdir);
      File dir = new File(rootdir,"sql");
      File file = new File(dir,name);

      log.debug("file: " + file);

      String contents = FileUtils.readFileToString(file);

      Document d = XMLWrapper.getEmptyDocument("sql");
      Element rootElement = d.getDocumentElement();

      rootElement.setTextContent(contents);

      xib.setResponse(d);
    }
    catch(IOException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }



    log.trace("Leave cmd_getsqlfile()");

  }
}

