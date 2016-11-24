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

public class cmd_scenesnotinblock extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_scenesnotinblock.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_scenesnotinblock(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_scenesnotinblock()");

    String project = cmd.getParameter("project");
    String block = cmd.getParameter("block");

    log.debug("project is: " + block);
    log.debug("block is: " + block);

    String projectid = "";
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
      ps = db.getPreparedStatement("SELECT * FROM block WHERE name = ? and project_id = ?");
      ps.setString(1,block);
      ps.setString(2,projectid);
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
      String sql = "SELECT scene.description as scene ";
      sql = sql + "FROM scene ";
      sql = sql + "WHERE description not in (";
      sql = sql + "SELECT scene.description ";
      sql = sql + "FROM scene, sceneblock ";
      sql = sql + "WHERE block_id = ? ";
      sql = sql + "AND scene.scene_id = sceneblock.scene_id) ";
      sql = sql + "AND scene.project_id = ? ";
      sql = sql + "ORDER BY description";
        
      ps = db.getPreparedStatement(sql);
      ps.setString(1,blockid);
      ps.setString(2,projectid);
      Document d = db.getResultAsXML(ps,true);
      xib.setResponse(d);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.trace("Leave cmd_scenesnotinblock()");
  }
}

