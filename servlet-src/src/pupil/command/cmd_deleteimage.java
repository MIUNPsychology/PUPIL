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

public class cmd_deleteimage extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_deleteimage.class);

  public cmd_deleteimage(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_deleteimage()");

    String category = cmd.getParameter("category");
    String image = cmd.getParameter("image");
    log.debug("category is: " + category);
    log.debug("image is: " + image);

    String categoryid = "";

    PreparedStatement ps;
    ResultSet r;

    try
    {
      ps = db.getPreparedStatement("SELECT * FROM category WHERE name = ?");
      ps.setString(1,category);
      r = ps.executeQuery();
      r.first();
      categoryid = r.getString("category_id");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("category_id is: " + categoryid);

    try
    {
      ps = db.getPreparedStatement("DELETE FROM image WHERE category_id = ? AND file_name = ?");
      ps.setString(1,categoryid);
      ps.setString(2,image);
      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_deleteimage()");
  }
}

