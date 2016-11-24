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

public class cmd_addblock extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_addblock.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_addblock(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_addblock()");

    String name = cmd.getParameter("name");
    String project = cmd.getParameter("project");

    log.debug("project is: " + project);
    log.debug("name is: " + name);

    String projectid = "";

    PreparedStatement ps;
    ResultSet r;

    try
    {
      ps = db.getPreparedStatement("SELECT * FROM project WHERE name = ?");
      ps.setString(1,project);
      r = ps.executeQuery();
      r.first();
      projectid = r.getString("project_id");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("project_id is: " + projectid);

    try
    {
      ps = db.getPreparedStatement("INSERT INTO block(name,project_id) VALUES(?,?)");
      ps.setString(1,name);
      ps.setString(2,projectid);

      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_addblock()");

  }
}

