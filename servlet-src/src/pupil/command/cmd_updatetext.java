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

public class cmd_updatetext extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_updatetext.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_updatetext(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_updatetext()");

    String project = cmd.getParameter("project");
    String label = cmd.getParameter("label");
    String text = cmd.getParameter("text");
    String scene = cmd.getParameter("scene");

    log.debug("project is: " + project);
    log.debug("text is: " + text);
    log.debug("label is: " + label);
    log.debug("scene is: " + scene);

    String projectid = "";
    String sceneid = "";

    // This is ugly but valid since we know we always have SSI here
    String scenetypeid = "5";

    String sql;

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
      ps = db.getPreparedStatement("SELECT max(scene_id) AS scene FROM scene WHERE scenetype_id = ? AND project_id = ? AND description = ?");
      ps.setString(1,scenetypeid);
      ps.setString(2,projectid);
      ps.setString(3,scene);
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

    String info = "About to update a scene: ";
    info = info + "scenetype_id=" + scenetypeid + " ";
    info = info + "project_id=" + projectid + " ";
    info = info + "description='" + label + "'";
    info = info + "scene_id='" + sceneid + "'";

    log.info(info); 

    try
    {
      sql = "UPDATE scene SET ";
      sql = sql + "description = ?, ";
      sql = sql + "lead = ? ";
      sql = sql + "WHERE scene_id = ?";

      ps = db.getPreparedStatement(sql);
      ps.setString(1,label);
      ps.setString(2,text);
      ps.setString(3,sceneid);

      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.trace("Leave cmd_updatetext()");

  }
}

