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

public class cmd_listuniqueimages extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_listuniqueimages.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_listuniqueimages(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_listuniqueimages()");

    Vector<String> ssi = new Vector<String>();
    Vector<String> scri = new Vector<String>();
    Vector<String> sosi = new Vector<String>();
    Vector<String> sori = new Vector<String>();

    String projectid = "";

    try
    {
      String name = cmd.getParameter("name");

      String sql = "select project.project_id, project.name as project, scene.scene_id, scene.description, pattern.images, pattern.mnemonic as pattern, scenetype.mnemonic as scenetype ";
      sql = sql + "FROM project,scene,pattern,scenetype where ";
      sql = sql + "project.project_id = scene.project_id AND ";
      sql = sql + "scene.pattern_id = pattern.pattern_id AND ";
      sql = sql + "scenetype.scenetype_id = scene.scenetype_id AND ";
      sql = sql + "project.name = ?";

      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,name);
      ResultSet r = ps.executeQuery();

      r.beforeFirst();

      String s = "";
      String i = "";

      while(r.next())
      {
        projectid = r.getString("project_id");
        s = r.getString("scenetype");
        i = r.getString("scene_id");

        log.debug("scene " + i + " has type " + s);

        if(s != null)
        {
          if(s.equals("static_image"))
          {
            ssi.add(i);
          }
          if(s.equals("static_category_random_image"))
          {
            scri.add(i);
          }
          if(s.equals("select_option_static_image"))
          {
            sosi.add(i);
          }
          if(s.equals("select_option_random_image"))
          {
            sori.add(i);
          }
        }
      }
      
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    Vector<String> imageids = new Vector<String>();

    String tmp;

    try
    {
      String sql = "select * FROM project where project_id = ?";

      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,projectid);

      ResultSet r = ps.executeQuery();
      r.first();

      tmp = r.getString("rightimage_id");
      if(tmp != null && !imageids.contains(tmp))
      {
        imageids.add(tmp);
        log.debug("Adding rightimage_id " + tmp);
      }

      tmp = r.getString("wrongimage_id");
      if(tmp != null && !imageids.contains(tmp))
      {
        imageids.add(tmp);
        log.debug("Adding wrongimage_id " + tmp);
      }

      tmp = r.getString("pauseimage_id");
      if(tmp != null && !imageids.contains(tmp))
      {
        imageids.add(tmp);
        log.debug("Adding pauseimage_id " + tmp);
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

    if(sosi.size() > 0)
    {
      try
      {
        PreparedStatement ps = db.getPreparedStatement("select * from sosiimg where scene_id = ?");
        ResultSet r;
        String i = "";

        for(String scene_id : sosi)
        {
          log.debug("scene_id: " + scene_id);
          ps.setString(1,scene_id);
          r = ps.executeQuery();

          r.beforeFirst();

          while(r.next())
          {
            i = r.getString("image_id");
            if(!imageids.contains(i))
            {
              log.debug("Adding image_id " + i);
              imageids.add(i);
            }
            else
            {
              log.debug("Image " + i + " was already added");
            }
          }

          r.close();
        }
        ps.close();
      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
      }
    }

    if(ssi.size() > 0)
    {
      try
      {
        PreparedStatement ps = db.getPreparedStatement("select * from ssi where scene_id = ?");
        ResultSet r;
        String i = "";

        for(String scene_id : ssi)
        {
          log.debug("scene_id: " + scene_id);
          ps.setString(1,scene_id);
          r = ps.executeQuery();

          r.beforeFirst();

          while(r.next())
          {
            i = r.getString("image_id");
            if(!imageids.contains(i))
            {
              log.debug("Adding image_id " + i);
              imageids.add(i);
            }
            else
            {
              log.debug("Image " + i + " was already added");
            }
          }

          r.close();
        }
        ps.close();
      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
      }
    }

    if(scri.size() > 0)
    { 
      try
      {
        PreparedStatement ps = db.getPreparedStatement("select distinct image.image_id from scri,image where scri.category_id = image.category_id and scri.scene_id = ?");
        ResultSet r;
        String i = "";

        for(String scene_id : scri)
        {
          log.debug("scene_id: " + scene_id);
          ps.setString(1,scene_id);
          r = ps.executeQuery();

          r.beforeFirst();

          while(r.next())
          {
            i = r.getString("image_id");
            if(!imageids.contains(i))
            {
              log.debug("Adding image_id " + i);
              imageids.add(i);
            }
            else
            {
              log.debug("Image " + i + " was already added");
            }
          }

          r.close();
        }
        ps.close();
      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
      }

    }

    if(sori.size() > 0)
    { 
      log.debug("SORI length is " + sori.size());
      try
      {
        PreparedStatement ps = db.getPreparedStatement("select distinct image.image_id from soricat,image where soricat.category_id = image.category_id and soricat.scene_id = ?");      
        ResultSet r;
        String i = "";

        for(String scene_id : sori)
        {
          log.debug("scene_id: " + scene_id);
          ps.setString(1,scene_id);
          r = ps.executeQuery();

          r.beforeFirst();

          while(r.next())
          {
            i = r.getString("image_id");
            if(!imageids.contains(i))
            {
              log.debug("Adding image_id " + i);
              imageids.add(i);
            }
            else
            {
              log.debug("Image " + i + " was already added");
            }
          }

          r.close();
        }
        ps.close();
      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
      }

    }


    if(imageids.size() > 0)
    { 
      try
      {
        PreparedStatement ps = db.getPreparedStatement("select category.name as category, image.file_name as image from image,category where category.category_id = image.category_id and image_id = ?");
        ResultSet r;
        String image = "";
        String cat = "";

        Document d = XMLWrapper.getEmptyDocument("imagelist");

        Element rootElement = d.getDocumentElement();
        Element img;

        for(String image_id : imageids)
        {
          ps.setString(1,image_id);
//          log.debug("image_id: " + image_id);
          r = ps.executeQuery();

          r.first();

          image = r.getString("image");
          cat = r.getString("category");

          log.debug("image: " + image_id + " " + cat + " " + image);

          img = d.createElement("image");
          img.setAttribute("category",cat);
          img.setAttribute("file",image);

          rootElement.appendChild(img);

          r.close();
        }
        ps.close();

        xib.setResponse(d);
      }
      catch(SQLException e)
      {
        log.error(e.getMessage(),e);
        xib.setErrorResponse("SQLException: " + e.getMessage());
      }
    }

    log.trace("Leave cmd_listuniqueimages()");

  }
}

