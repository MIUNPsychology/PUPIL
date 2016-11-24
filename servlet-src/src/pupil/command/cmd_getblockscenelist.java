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

public class cmd_getblockscenelist extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_getblockscenelist.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_getblockscenelist(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_getblockscenelist()");

    try
    {
      String name = cmd.getParameter("name");

      String sql = "select project.name as project, block.name as block, block.random, block.textfirst, ";
      sql = sql + "scene.description, pattern.images, pattern.mnemonic as pattern, scenetype.mnemonic as scenetype ";
      sql = sql + "FROM project,scene,pattern,scenetype,block,sceneblock where ";
      sql = sql + "project.project_id = scene.project_id AND ";
      sql = sql + "scene.pattern_id = pattern.pattern_id AND ";
      sql = sql + "sceneblock.scene_id = scene.scene_id AND ";
      sql = sql + "sceneblock.block_id = block.block_id AND ";
      sql = sql + "scenetype.scenetype_id = scene.scenetype_id AND ";
      sql = sql + "project.name = ? ORDER BY block.name, scene.description";

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

    log.trace("Leave cmd_getblockscenelist()");

  }
}

