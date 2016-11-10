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

public class cmd_updateproject extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_updateproject.class);

  public cmd_updateproject(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_updateproject()");

    String name = cmd.getParameter("name");
    String displaywelcome = cmd.getParameter("displaywelcome");
    String displaythanks = cmd.getParameter("displaythanks");
    String welcometop = cmd.getParameter("welcometop");
    String welcomemid = cmd.getParameter("welcomemid");
    String welcomebottom = cmd.getParameter("welcomebottom");
    String thankstop = cmd.getParameter("thankstop");
    String thanksmid = cmd.getParameter("thanksmid");
    String thanksbottom = cmd.getParameter("thanksbottom");
    String urlredirect = cmd.getParameter("urlredirect");
    String maxwidth = cmd.getParameter("maxwidth");
    String maxheight = cmd.getParameter("maxheight");
    String flashright = cmd.getParameter("flashright");
    String flashwrong = cmd.getParameter("flashwrong");
    String displaypolicy = cmd.getParameter("displaypolicy");
    String subsetsize = cmd.getParameter("subsetsize");
    String flashwhite = cmd.getParameter("flashwhite");
    String whitemin = cmd.getParameter("whitemin");
    String whitemax = cmd.getParameter("whitemax");
    String hideopts = cmd.getParameter("hideopts");
    String splicearray = cmd.getParameter("splicearray");
    String blockrandom = cmd.getParameter("blockrandom");

    String rightimage = cmd.getParameter("rightimage");
    String wrongimage = cmd.getParameter("wrongimage");
    String pauseimage = cmd.getParameter("pauseimage");

    log.debug("name is: " + name);
    log.debug("displaywelcome is " + displaywelcome);
    log.debug("displaythanks is " + displaythanks);
    log.debug("welcometop is " + welcometop);
    log.debug("welcomemid is " + welcomemid);
    log.debug("welcomebottom is " + welcomebottom);
    log.debug("thankstop is " + thankstop);
    log.debug("thanksmid is " + thanksmid);
    log.debug("thanksbottom is " + thanksbottom);
    log.debug("urlredirect is " + urlredirect);
    log.debug("maxwidth is " + maxwidth);
    log.debug("maxheight is " + maxheight);
    log.debug("flashright is " + flashright);
    log.debug("flashwrong is " + flashwrong);
    log.debug("displaypolicy is " + displaypolicy);
    log.debug("subsetsize is " + subsetsize);
    log.debug("flashwhite is " + flashwhite);
    log.debug("whitemin is " + whitemin);
    log.debug("whitemax is " + whitemax);
    log.debug("hideopts is " + hideopts);
    log.debug("splicearray is " + splicearray);
    log.debug("blockrandom is " + blockrandom);

    log.debug("rightimage is " + rightimage);
    log.debug("wrongimage is " + wrongimage);
    log.debug("pauseimage is " + pauseimage);

    try
    {
      String sql = "UPDATE project SET ";

      sql = sql + "displaywelcome = ?, ";
      sql = sql + "displaythanks = ?, ";
      sql = sql + "welcometop = ?, ";
      sql = sql + "welcomemid = ?, ";
      sql = sql + "welcomebottom = ?, ";
      sql = sql + "thankstop = ?, ";
      sql = sql + "thanksmid = ?, ";
      sql = sql + "thanksbottom = ?, ";
      sql = sql + "urlredirect = ?, ";
      sql = sql + "maxwidth = ?, ";
      sql = sql + "maxheight = ?, ";
      sql = sql + "flashright = ?, ";
      sql = sql + "flashwrong = ?, ";
      sql = sql + "displaypolicy = ?, ";
      sql = sql + "subsetsize = ?, ";
      sql = sql + "flashwhite = ?, ";
      sql = sql + "whitemin = ?, ";
      sql = sql + "whitemax = ?, ";
      sql = sql + "hideopts = ?, ";
      sql = sql + "splicearray = ?, ";
      sql = sql + "blockrandom = ? ";
      sql = sql + "WHERE name = ? ";

      PreparedStatement ps = db.getPreparedStatement(sql);

      int i = 1;
      ps.setString(i++,displaywelcome);
      ps.setString(i++,displaythanks);
      ps.setString(i++,welcometop);
      ps.setString(i++,welcomemid);
      ps.setString(i++,welcomebottom);
      ps.setString(i++,thankstop);
      ps.setString(i++,thanksmid);
      ps.setString(i++,thanksbottom);
      ps.setString(i++,urlredirect);
      ps.setString(i++,maxwidth);
      ps.setString(i++,maxheight);
      ps.setString(i++,flashright);
      ps.setString(i++,flashwrong);
      ps.setString(i++,displaypolicy);
      ps.setString(i++,subsetsize);
      ps.setString(i++,flashwhite);
      ps.setString(i++,whitemin);
      ps.setString(i++,whitemax);
      ps.setString(i++,hideopts);
      ps.setString(i++,splicearray);
      ps.setString(i++,blockrandom);

      ps.setString(i++,name);

      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    String projectid = "";

    try
    {
      PreparedStatement ps = db.getPreparedStatement("SELECT * FROM project WHERE name = ?");
      ps.setString(1,name);
      ResultSet r = ps.executeQuery();
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

    String imageid = null;

    if(!rightimage.equals(""))
    {
      String[] parts = rightimage.split("/");
      log.debug("rightcategory: " + parts[0]);
      log.debug("rightimage: " + parts[1]);

      try
      {
        PreparedStatement ps = db.getPreparedStatement("select image_id from filenames where category = ? and image = ? and project_id = ?");
        ps.setString(1,parts[0]);
        ps.setString(2,parts[1]);
        ps.setString(3,projectid);

        ResultSet r = ps.executeQuery();
        r.first();

        imageid = r.getString("image_id");

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

    log.debug("image_id is: " + imageid);

    try
    {
      PreparedStatement ps = db.getPreparedStatement("update project set rightimage_id = ? where project_id = ?");
      ps.setString(1,imageid);
      ps.setString(2,projectid);
      ps.executeUpdate();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("successfully update rightimage");

    imageid = null;

    if(!wrongimage.equals(""))
    {
      String[] parts = wrongimage.split("/");
      log.debug("wrongcategory: " + parts[0]);
      log.debug("wrongimage: " + parts[1]);

      try
      {
        PreparedStatement ps = db.getPreparedStatement("select image_id from filenames where category = ? and image = ? and project_id = ?");
        ps.setString(1,parts[0]);
        ps.setString(2,parts[1]);
        ps.setString(3,projectid);

        ResultSet r = ps.executeQuery();
        r.first();

        imageid = r.getString("image_id");

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

    log.debug("image_id is: " + imageid);

    try
    {
      PreparedStatement ps = db.getPreparedStatement("update project set wrongimage_id = ? where project_id = ?");
      ps.setString(1,imageid);
      ps.setString(2,projectid);
      ps.executeUpdate();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("successfully update wrongimage");

    imageid = null;

    if(!pauseimage.equals(""))
    {
      String[] parts = pauseimage.split("/");
      log.debug("pausecategory: " + parts[0]);
      log.debug("pauseimage: " + parts[1]);

      try
      {
        PreparedStatement ps = db.getPreparedStatement("select image_id from filenames where category = ? and image = ? and project_id = ?");
        ps.setString(1,parts[0]);
        ps.setString(2,parts[1]);
        ps.setString(3,projectid);

        ResultSet r = ps.executeQuery();
        r.first();

        imageid = r.getString("image_id");

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

    log.debug("image_id is: " + imageid);

    try
    {
      PreparedStatement ps = db.getPreparedStatement("update project set pauseimage_id = ? where project_id = ?");
      ps.setString(1,imageid);
      ps.setString(2,projectid);
      ps.executeUpdate();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("successfully update pauseimage");


    log.trace("Leave cmd_updateproject()");

  }
}

