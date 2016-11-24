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

public class cmd_listsql extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_listsql.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_listsql(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  @SuppressWarnings("unchecked")
  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_listsql()");

    Document d = XMLWrapper.getEmptyDocument("sqlfiles");

    Element rootElement = d.getDocumentElement();

    Element eleFile = null;
    
    String rootdir = rib.servlet().getSIB().getPhysicalPath();

    log.debug("rootdir: " + rootdir);

    File dir = new File(rootdir,"sql");

    Collection<File> c = FileUtils.listFiles(dir,new String[] {"sql"}, false);

    TreeSet<File> t = new TreeSet<File>(c);

    SortedSet<File> s = Collections.synchronizedSortedSet(t);

    for(File f : s)
    {
      log.debug(f.getName());
      eleFile = d.createElement("file");
      eleFile.setTextContent(f.getName());
      rootElement.appendChild(eleFile);
    }

    xib.setResponse(d);

    log.trace("Leave cmd_listsql()");

  }
}

