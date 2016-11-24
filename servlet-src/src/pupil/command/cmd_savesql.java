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

public class cmd_savesql extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_savesql.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_savesql(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  @SuppressWarnings("unchecked")
  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_savesql()");

    try
    {
      String name = cmd.getParameter("name");

      log.debug("name: " + name);

      String rootdir = rib.servlet().getSIB().getPhysicalPath();
      log.debug("rootdir: " + rootdir);
      File dir = new File(rootdir,"sql");
      File file = new File(dir,name);

      log.debug("file: " + file);

      Element data = cmd.getData();
      String contents = data.getTextContent();

      log.debug("Text content: " + contents);

      FileUtils.writeStringToFile(file,contents);

      log.debug("Wrote data");
    }
    catch(IOException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("IOException: " + e.getMessage());
      return;
    }

    log.trace("Leave cmd_savesql()");

  }
}

