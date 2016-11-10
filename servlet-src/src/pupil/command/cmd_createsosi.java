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

public class cmd_createsosi extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_createsosi.class);

  public cmd_createsosi(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_createsosi()");

    String project = cmd.getParameter("project");
    String pattern = cmd.getParameter("pattern");
    String label = cmd.getParameter("label");
    String correct = cmd.getParameter("correct");
    String timeout = cmd.getParameter("timeout");
    String numopts = cmd.getParameter("numopts");
    String lead = cmd.getParameter("lead");

    log.debug("project is: " + project);
    log.debug("pattern is: " + pattern);
    log.debug("correct is: " + correct);
    log.debug("timeout is: " + timeout);
    log.debug("label is: " + label);
    log.debug("numopts is: " + numopts);
    log.debug("lead is: " + lead);

    int images = -1;
    String patternid = "";
    String projectid = "";
    String sceneid = "";
    int numopt = 0;

    try
    {
      numopt = Integer.parseInt(numopts);
    }
    catch(Exception e)
    {
      // not a valid number I guess
      log.error(e.getMessage(),e);
      xib.setErrorResponse("Exception: " + e.getMessage());
      return;
    }

    String[] opts = new String[numopt];
    String[] keys = new String[numopt];

    for(int i = 0; i < numopt; i++)
    {
      opts[i] = cmd.getParameter("option " + (i+1));
      keys[i] = cmd.getParameter("key " + (i+1));

      log.debug("found option '" + opts[i] + "' for key '" + keys[i] + "'");
    }

    // This is ugly but valid since we know we always have SOSI here
    String scenetypeid = "3";

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
      ps = db.getPreparedStatement("SELECT * FROM pattern WHERE mnemonic = ?");
      ps.setString(1,pattern);
      r = ps.executeQuery();
      r.first();
      patternid = r.getString("pattern_id");
      images = r.getInt("images");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("Pattern_id is: " + patternid);
    log.debug("Pattern requires " + images + " images");

    String[] categories = new String[images];
    String[] files = new String[images];

    for(int i = 0; i < images; i++)
    {
      categories[i] = cmd.getParameter("category " + (i+1));
      files[i] = cmd.getParameter("file " + (i+1));

      log.debug("Image " + (i+1) + ": " + categories[i] + "/" + files[i] + " (" + keys[i] + ")");
    }

    HashMap<String,String> catmap = new HashMap<String,String>();
    HashMap<String,String> imgmap = new HashMap<String,String>();

    String sql,catid,imgid;

    try
    {
      sql = "SELECT category.category_id,image.image_id FROM category,image ";
      sql = sql + "WHERE category.category_id = image.category_id ";
      sql = sql + "AND category.name = ? ";
      sql = sql + "AND image.file_name = ?";

      ps = db.getPreparedStatement(sql);

      for(int i = 0; i < images; i++)
      {
        ps.setString(1,categories[i]);
        ps.setString(2,files[i]);
        r = ps.executeQuery();
        r.first();
        catid = r.getString("category_id");
        imgid = r.getString("image_id");

        log.debug("category '" + categories[i] + "' has id " + catid);
        log.debug("image '" + files[i] + "' has id " + imgid);
        r.close();

        catmap.put(categories[i],catid);
        imgmap.put(categories[i] + "/" + files[i],imgid);
      }
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    // if we haven't crashed this far, we should have all required info
    // to dare create scene etc.

    String info = "About to create a scene: ";
    info = info + "scenetype_id=" + scenetypeid + " ";
    info = info + "pattern_id=" + patternid + " ";
    info = info + "project_id=" + projectid + " ";
    info = info + "description='" + label + "'";

    log.info(info); 

    try
    {
      sql = "INSERT INTO scene(scenetype_id,pattern_id,project_id,description,correctkey,timeout,lead) VALUES(?,?,?,?,?,?,?)";

      ps = db.getPreparedStatement(sql);

      ps.setString(1,scenetypeid);
      ps.setString(2,patternid);
      ps.setString(3,projectid);
      ps.setString(4,label);
      ps.setString(5,correct);
      ps.setString(6,timeout);
      ps.setString(7,lead);

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

    try
    {
      sql = "INSERT INTO sosiimg(image_id,scene_id,position) VALUES(?,?,?)";

      ps = db.getPreparedStatement(sql);

      String pathstr;

      for(int i = 0; i < files.length; i++)
      {
        pathstr = imgmap.get(categories[i] + "/" + files[i]);
        log.debug("image_id for position " + (i+1) + " is " + pathstr);
        ps.setString(1,pathstr);
        ps.setString(2,sceneid);
        ps.setInt(3,i+1);
        db.executeAsUpdate(ps,false);
      }
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    try
    {
      sql = "INSERT INTO sosiopt(scene_id,optiontxt,keychar) VALUES(?,?,?)";

      ps = db.getPreparedStatement(sql);

      for(int i = 0; i < numopt; i++)
      {
        log.debug("Inserting option: (" + (i+1) + ") ('" + keys[i] + "') " + opts[i]);
        ps.setString(1,sceneid);
        ps.setString(2,opts[i]);
        ps.setString(3,keys[i]);
        db.executeAsUpdate(ps,false);
      }

      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }


    log.trace("Leave cmd_createsosi()");

  }
}

