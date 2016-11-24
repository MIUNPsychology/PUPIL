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

public class cmd_replacecategory extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_replacecategory.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_replacecategory(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_replacecategory()");

    String sourcecat = cmd.getParameter("sourcecat");
    log.debug("source category is: " + sourcecat);
    String destcat = cmd.getParameter("destinationcat");
    log.debug("dest category is: " + destcat);

    String sourcecategoryid = "";
    String destcategoryid = "";

    PreparedStatement ps;
    ResultSet r;

    try
    {
      ps = db.getPreparedStatement("SELECT * FROM category WHERE name = ?");
      ps.setString(1,sourcecat);
      r = ps.executeQuery();
      r.first();
      sourcecategoryid = r.getString("category_id");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("source category_id is: " + sourcecategoryid);

    try
    {
      ps = db.getPreparedStatement("SELECT * FROM category WHERE name = ?");
      ps.setString(1,destcat);
      r = ps.executeQuery();
      r.first();
      destcategoryid = r.getString("category_id");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("dest category_id is: " + destcategoryid);

    try
    {
      ps = db.getPreparedStatement("UPDATE scri SET category_id = ? WHERE category_id = ?");
      ps.setString(1,destcategoryid);
      ps.setString(2,sourcecategoryid);
      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    try
    {
      ps = db.getPreparedStatement("UPDATE soricat SET category_id = ? WHERE category_id = ?");
      ps.setString(1,destcategoryid);
      ps.setString(2,sourcecategoryid);
      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.trace("Leave cmd_replacecategory()");
  }
}

