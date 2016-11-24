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

public class cmd_getimagesforcategory extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_getimagesforcategory.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_getimagesforcategory(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_getimagesforcategory()");

    try
    {
      String name = cmd.getParameter("name");

      String sql = "select category.name as category, image.* from category, image WHERE ";
      sql = sql + "category.category_id = image.category_id AND ";
      sql = sql + "category.name = ? ";
      sql = sql + "ORDER BY file_name";

      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,name);
      Document d = db.getResultAsXML(ps,true);
      xib.setResponse(d);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_getimagesforcategory()");

  }
}

