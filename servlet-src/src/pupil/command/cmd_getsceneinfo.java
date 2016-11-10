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

public class cmd_getsceneinfo extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_getsceneinfo.class);

  public cmd_getsceneinfo(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_getsceneinfo()");

    String scenename = cmd.getParameter("scenename");
    String projectname = cmd.getParameter("projectname");

    log.debug("Scenename: " + scenename);
    log.debug("projectname: " + projectname);

    String pattern = "";
    String scenetype = "";
    String sceneid = "";
    String correctkey = "";
    String timeout = "0";
    String lead = "";
    int images = -1;

    try
    {

      String sql = "select project.name as project, scene.*, pattern.images, pattern.mnemonic as pattern, scenetype.mnemonic as scenetype ";
      sql = sql + "FROM project,scene,pattern,scenetype where ";
      sql = sql + "project.project_id = scene.project_id AND ";
      sql = sql + "scene.pattern_id = pattern.pattern_id AND ";
      sql = sql + "scenetype.scenetype_id = scene.scenetype_id AND ";
      sql = sql + "project.name = ? AND ";
      sql = sql + "scene.description = ?";

      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,projectname);
      ps.setString(2,scenename);

      ResultSet r = ps.executeQuery();

      r.first();

      pattern = r.getString("pattern");
      scenetype = r.getString("scenetype");
      images = r.getInt("images");
      sceneid = r.getString("scene_id");
      correctkey = r.getString("correctkey");
      timeout = r.getString("timeout");
      lead = r.getString("lead");

      log.debug("scene_id is " + sceneid);

      r.close();
      ps.close();

    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("building new scene info document");

    log.debug("description: " + scenename);
    log.debug("project: " + projectname);
    log.debug("pattern: " + pattern);
    log.debug("scenetype: " + scenetype);
    log.debug("timeout: " + timeout);
    log.debug("lead: " + lead);

    Document d = XMLWrapper.getEmptyDocument("sceneinfo");

    Element rootElement = d.getDocumentElement();

    Element eleDesc = d.createElement("description");
    eleDesc.setTextContent(scenename);

    Element eleProj = d.createElement("project");
    eleProj.setTextContent(projectname);

    Element elePattern = d.createElement("pattern");
    elePattern.setTextContent(pattern);

    Element eleType = d.createElement("scenetype");
    eleType.setTextContent(scenetype);

    Element eleKey = d.createElement("correctkey");
    eleKey.setTextContent(correctkey);

    Element eleTime = d.createElement("timeout");
    eleTime.setTextContent(timeout);

    Element eleLead = d.createElement("lead");
    eleLead.setTextContent(lead);

/*    Element eleImages = d.createElement("images");
    eleImages.setAttribute("num","" + images);*/

    rootElement.appendChild(eleDesc);
    rootElement.appendChild(eleProj);
    rootElement.appendChild(elePattern);
    rootElement.appendChild(eleType);
    rootElement.appendChild(eleKey);
    rootElement.appendChild(eleTime);
    rootElement.appendChild(eleLead);
//    rootElement.appendChild(eleImages);

    Element extraInfo;
    Element entry;

    boolean validType = false;

    if(scenetype.equals("static_image"))
    {
      validType = true;
      extraInfo = d.createElement("ssi");
      rootElement.appendChild(extraInfo);

      String filename;
      String category;
      String keychar;
      String position;

      log.debug("about to build ssi element");

      try
      {
        String sql = "select image.file_name as image, category.name as category, ssi.* ";
        sql = sql + "FROM image,category,ssi WHERE ";
        sql = sql + "ssi.image_id = image.image_id AND ";
        sql = sql + "category.category_id = image.category_id AND ";
        sql = sql + "ssi.scene_id = ? ";
        sql = sql + "ORDER BY ssi.position";
       
        PreparedStatement ps = db.getPreparedStatement(sql);
        ps.setString(1,sceneid);

        ResultSet r = ps.executeQuery();

        r.beforeFirst();

        while(r.next())
        {
          entry = d.createElement("ssientry");

          filename = r.getString("image");
          category = r.getString("category");
          keychar = r.getString("keychar");
          position = r.getString("position");

          log.debug("SSI: " + position + " " + category + "/" + filename + " " + keychar);

          entry.setAttribute("image", category + "/" + filename);
          entry.setAttribute("keychar", keychar);
          entry.setAttribute("position", position);

          extraInfo.appendChild(entry);
        }

        r.close();
        ps.close();

      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
        return;
      }
    }

    if(scenetype.equals("static_category_random_image"))
    {
      validType = true;
      extraInfo = d.createElement("scri");
      rootElement.appendChild(extraInfo);

      String category;
      String keychar;
      String position;

      log.debug("about to build ssi element");

      try
      {
        String sql = "select category.name as category, scri.* ";
        sql = sql + "FROM category,scri WHERE ";
        sql = sql + "category.category_id = scri.category_id AND ";
        sql = sql + "scri.scene_id = ? ";
        sql = sql + "ORDER BY scri.position";
       
        PreparedStatement ps = db.getPreparedStatement(sql);
        ps.setString(1,sceneid);

        ResultSet r = ps.executeQuery();

        r.beforeFirst();

        while(r.next())
        {
          entry = d.createElement("scrientry");

          category = r.getString("category");
          keychar = r.getString("keychar");
          position = r.getString("position");

          log.debug("SCRI: " + position + " " + category + " " + keychar);

          entry.setAttribute("category", category);
          entry.setAttribute("keychar", keychar);
          entry.setAttribute("position", position);

          extraInfo.appendChild(entry);
        }

        r.close();
        ps.close();

      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
        return;
      }
    }

    if(scenetype.equals("select_option_static_image"))
    {
      validType = true;
      extraInfo = d.createElement("sosi");
      rootElement.appendChild(extraInfo);

      String category;
      String image;
      String opttxt;
      String keychar;
      String position;

      log.debug("about to build sosi image elements");

      try
      {
        String sql = "select image.file_name as image, category.name as category, sosiimg.* ";
        sql = sql + "FROM image,category,sosiimg WHERE ";
        sql = sql + "sosiimg.image_id = image.image_id AND ";
        sql = sql + "category.category_id = image.category_id AND ";
        sql = sql + "sosiimg.scene_id = ? ";
        sql = sql + "ORDER BY sosiimg.position";
      
        PreparedStatement ps = db.getPreparedStatement(sql);
        ps.setString(1,sceneid);

        ResultSet r = ps.executeQuery();

        r.beforeFirst();

        while(r.next())
        {
          entry = d.createElement("sosiimg");

          image = r.getString("image");
          category = r.getString("category");
          position = r.getString("position");

          log.debug("SOSIIMG: " + position + " " + category + " " + image);

          entry.setAttribute("category", category);
          entry.setAttribute("position", position);
          entry.setAttribute("image", image);

          extraInfo.appendChild(entry);
        }

        r.close();
        ps.close();

      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
        return;
      }

      log.debug("about to build sosi option elements");

      try
      {
        String sql = "select * FROM sosiopt WHERE scene_id = ? ";
      
        PreparedStatement ps = db.getPreparedStatement(sql);
        ps.setString(1,sceneid);

        ResultSet r = ps.executeQuery();

        r.beforeFirst();

        while(r.next())
        {
          entry = d.createElement("sosiopt");

          keychar = r.getString("keychar");
          opttxt = r.getString("optiontxt");

          log.debug("SOSIOPT: ('" + keychar  + "') " + opttxt);

          entry.setAttribute("keychar", keychar);
          entry.setAttribute("optiontxt", opttxt);

          extraInfo.appendChild(entry);
        }

        r.close();
        ps.close();

      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
        return;
      }
    }

    if(scenetype.equals("select_option_random_image"))
    {
      validType = true;
      extraInfo = d.createElement("sori");
      rootElement.appendChild(extraInfo);

      String category;
      String opttxt;
      String keychar;
      String position;

      log.debug("about to build sori category elements");

      try
      {
        String sql = "select category.name as category, soricat.* ";
        sql = sql + "FROM category,soricat WHERE ";
        sql = sql + "category.category_id = soricat.category_id AND ";
        sql = sql + "soricat.scene_id = ? ";
        sql = sql + "ORDER BY soricat.position";
      
        PreparedStatement ps = db.getPreparedStatement(sql);
        ps.setString(1,sceneid);

        ResultSet r = ps.executeQuery();

        r.beforeFirst();

        while(r.next())
        {
          entry = d.createElement("soricat");

          category = r.getString("category");
          position = r.getString("position");

          log.debug("SORICAT: " + position + " " + category);

          entry.setAttribute("category", category);
          entry.setAttribute("position", position);

          extraInfo.appendChild(entry);
        }

        r.close();
        ps.close();

      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
        return;
      }

      log.debug("about to build sori option elements");

      try
      {
        String sql = "select * FROM soriopt WHERE scene_id = ? ";
      
        PreparedStatement ps = db.getPreparedStatement(sql);
        ps.setString(1,sceneid);

        ResultSet r = ps.executeQuery();

        r.beforeFirst();

        while(r.next())
        {
          entry = d.createElement("soriopt");

          keychar = r.getString("keychar");
          opttxt = r.getString("optiontxt");

          log.debug("SORIOPT: ('" + keychar  + "') " + opttxt);

          entry.setAttribute("keychar", keychar);
          entry.setAttribute("optiontxt", opttxt);

          extraInfo.appendChild(entry);
        }

        r.close();
        ps.close();

      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
        return;
      }
    }

    if(scenetype.equals("text"))
    {
      validType = true;
    }

    if(validType)
    {
      xib.setResponse(d);
    }
    else
    {
      xib.setErrorResponse("Unknown scene type");
    }

    log.trace("Leave cmd_getsceneinfo()");

  }
}

