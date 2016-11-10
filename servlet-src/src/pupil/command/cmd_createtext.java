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

public class cmd_createtext extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_createtext.class);

  public cmd_createtext(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_createtext()");

    String project = cmd.getParameter("project");
    String label = cmd.getParameter("label");
    String text = cmd.getParameter("text");

    log.debug("project is: " + project);
    log.debug("text is: " + text);
    log.debug("label is: " + label);

    String patternid = "1"; // Ugly, but text scenes don't use patterns
    String projectid = "";
    String sceneid = "";

    // This is ugly but valid since we know we always have SSI here
    String scenetypeid = "5";

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

    // if we haven't crashed this far, we should have all required info
    // to dare create scene etc.

    String info = "About to create a scene: ";
    info = info + "scenetype_id=" + scenetypeid + " ";
    info = info + "pattern_id=" + patternid + " ";
    info = info + "project_id=" + projectid + " ";
    info = info + "description='" + label + "' ";
    info = info + "lead='" + text + "' ";

    log.info(info); 

    try
    {
      String sql = "INSERT INTO scene(scenetype_id,pattern_id,project_id,description,lead) VALUES(?,?,?,?,?)";

      ps = db.getPreparedStatement(sql);

      ps.setString(1,scenetypeid);
      ps.setString(2,patternid);
      ps.setString(3,projectid);
      ps.setString(4,label);
      ps.setString(5,text);

      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("Inserted scene");

    try
    {
      ps = db.getPreparedStatement("SELECT max(scene_id) AS scene FROM scene WHERE scenetype_id = ? AND project_id = ? AND description = ?");
      ps.setString(1,scenetypeid);
      ps.setString(2,projectid);
      ps.setString(3,label);
      r = ps.executeQuery();
      r.first();
      sceneid = r.getString("scene");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("scene_id is: " + sceneid);

    log.trace("Leave cmd_createtext()");

  }
}

