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

public class cmd_addscenetoblock extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_addscenetoblock.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_addscenetoblock(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_addscenetoblock()");

    String project = cmd.getParameter("project");
    String scene = cmd.getParameter("scene");
    String block = cmd.getParameter("block");

    log.debug("project is: " + project);
    log.debug("scene is: " + scene);
    log.debug("block is: " + block);

    String projectid = "";
    String sceneid = "";
    String blockid = "";

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
      ps = db.getPreparedStatement("SELECT max(scene_id) AS scene FROM scene WHERE project_id = ? AND description = ?");
      ps.setString(1,projectid);
      ps.setString(2,scene);
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

    try
    {
      String sql = "SELECT block_id from block ";
      sql = sql + "WHERE project_id = ?";
      sql = sql + "AND name = ?";

      ps = db.getPreparedStatement(sql);
      ps.setString(1,projectid);
      ps.setString(2,block);
      r = ps.executeQuery();
      r.first();
      blockid = r.getString("block_id");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("block_id is: " + blockid);

    try
    {
      String sql = "INSERT INTO sceneblock values(?,?)";

      ps = db.getPreparedStatement(sql);
      ps.setString(1,blockid);
      ps.setString(2,sceneid);
      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.trace("Leave cmd_addscenetoblock()");

  }
}

