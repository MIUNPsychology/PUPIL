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

import org.apache.commons.lang.*;

public class cmd_cloneproject extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_cloneproject.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_cloneproject(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_cloneproject()");

    Pupil pupil = (Pupil)rib.servlet();

    String name = cmd.getParameter("name");
    String description = cmd.getParameter("description");
    String oldname = cmd.getParameter("oldname");

    log.debug("name is: " + name);
    log.debug("description is: " + description);
    log.debug("oldname is: " + oldname);

    PreparedStatement ps;
    ResultSet r;
    HashMap<String,String> originalProject;
    String sql;

/*
project_id
teacher_id
name
description
displaywelcome
displaythanks
welcometop
welcomemid
welcomebottom
thankstop
thanksmid
thanksbottom
urlredirect
maxwidth
maxheight
flashright
flashwrong
flashwhite
whitemin
whitemax
hideopts
displaypolicy
splicearray
subsetsize
pauseimage_id
wrongimage_id
rightimage_id
*/

    try
    {
      sql = "select * FROM project where name = ?";
      ps = db.getPreparedStatement(sql);
      ps.setString(1,oldname);
      originalProject = db.getResultAsHash(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }


    try
    {
      sql = "INSERT INTO project(";
      sql = sql + "teacher_id,";
      sql = sql + "name,";
      sql = sql + "description,";
      sql = sql + "displaywelcome,";
      sql = sql + "displaythanks,";
      sql = sql + "welcometop,";
      sql = sql + "welcomemid,";
      sql = sql + "welcomebottom,";
      sql = sql + "thankstop,";
      sql = sql + "thanksmid,";
      sql = sql + "thanksbottom,";
      sql = sql + "urlredirect,";
      sql = sql + "maxwidth,";
      sql = sql + "maxheight,";
      sql = sql + "flashright,";
      sql = sql + "flashwrong,";
      sql = sql + "flashwhite,";
      sql = sql + "whitemin,";
      sql = sql + "whitemax,";
      sql = sql + "hideopts,";
      sql = sql + "displaypolicy,";
      sql = sql + "splicearray,";
      sql = sql + "subsetsize";

      sql = sql + ") VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";

      log.debug(sql);

      ps = db.getPreparedStatement(sql);

      ps.setString(1,originalProject.get("teacher_id"));
      ps.setString(2,name);
      ps.setString(3,description);
      ps.setString(4,originalProject.get("displaywelcome"));
      ps.setString(5,originalProject.get("displaythanks"));
      ps.setString(6,originalProject.get("welcometop"));
      ps.setString(7,originalProject.get("welcomemid"));
      ps.setString(8,originalProject.get("welcomebottom"));
      ps.setString(9,originalProject.get("thankstop"));
      ps.setString(10,originalProject.get("thanksmid"));
      ps.setString(11,originalProject.get("thanksbottom"));
      ps.setString(12,originalProject.get("urlredirect"));
      ps.setString(13,originalProject.get("maxwidth"));
      ps.setString(14,originalProject.get("maxheight"));
      ps.setString(15,originalProject.get("flashright"));
      ps.setString(16,originalProject.get("flashwrong"));
      ps.setString(17,originalProject.get("flashwhite"));
      ps.setString(18,originalProject.get("whitemin"));
      ps.setString(19,originalProject.get("whitemax"));
      ps.setString(20,originalProject.get("hideopts"));
      ps.setString(21,originalProject.get("displaypolicy"));
      ps.setString(22,originalProject.get("splicearray"));
      ps.setString(23,originalProject.get("subsetsize"));

      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_cloneproject()");

    String newProjectID, oldProjectID;

    try
    {
      sql = "select max(project_id) as prid FROM project where name = ? and description = ?";
      ps = db.getPreparedStatement(sql);
      ps.setString(1,name);
      ps.setString(2,description);
      newProjectID = db.getSingleString(ps,"prid",true);
      oldProjectID = originalProject.get("project_id");
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("old project id: " + oldProjectID);
    log.debug("new project id: " + newProjectID);

    HashMap<String,String> categoryReplacement = new HashMap<String,String>();

    try
    {
      sql = "select * from category where project_id = ?";
      ps = db.getPreparedStatement(sql);
      ps.setString(1,oldProjectID);

      Vector<HashMap<String,String>> categoryHash = db.getResultAsHashVector(ps,true);

      String category_id, project_id, catname, newcatid;

      for(HashMap<String,String> row : categoryHash)
      {

        category_id = row.get("category_id");
        project_id = row.get("project_id");
        catname = row.get("name");

        log.debug("category_id: " + category_id);
        log.debug("project_id: " + project_id);
        log.debug("name: " + catname);

        String newCatName = StringUtils.remove(catname,oldname + "_");
        newCatName = name + "_" + newCatName;

        log.debug("newname: " + newCatName);

        sql = "INSERT INTO category (project_id,name) VALUES(?,?);";        

        ps = db.getPreparedStatement(sql);
        ps.setString(1,newProjectID);
        ps.setString(2,newCatName);

        db.executeAsUpdate(ps,true);

        sql = "SELECT max(category_id) as catid FROM category WHERE project_id = ? and name = ?";

        ps = db.getPreparedStatement(sql);
        ps.setString(1,newProjectID);
        ps.setString(2,newCatName);

        newcatid = db.getSingleString(ps,"catid",true);

        categoryReplacement.put(category_id,newcatid);

        log.debug("Category " + category_id + " is replaced by " + newcatid + " (" + catname + ")");

        pupil.copyCategory(catname,newCatName);
      }

      log.debug("There were " + categoryHash.size() + " categories in the old project");
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }
    catch(IOException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("IOException: " + e.getMessage());
      return;
    }

    HashMap<String,String> imageReplacements = new HashMap<String,String>();

    try
    {
      
      sql = "select image.image_id as image_id, image.file_name as file_name, category.category_id as category_id ";
      sql = sql + "from image, category WHERE image.category_id = category.category_id and category.project_id = ?";

      ps = db.getPreparedStatement(sql);
      ps.setString(1,oldProjectID);

      Vector<HashMap<String,String>> imageTable = db.getResultAsHashVector(ps,true);

      String oldImgID, newImgID, oldCatID, filename, newCatID; 

      for(HashMap<String,String> row : imageTable)
      {
        oldImgID = row.get("image_id");
        oldCatID = row.get("category_id");
        filename = row.get("file_name");

        newCatID = categoryReplacement.get(oldCatID);
        
        log.debug("oldImgID:" + oldImgID);
        log.debug("oldCatID:" + oldCatID);
        log.debug("filename:" + filename);
        log.debug("newCatID:" + newCatID);

        sql = "INSERT INTO image(category_id,file_name) VALUES(?,?)";

        ps = db.getPreparedStatement(sql);
        ps.setString(1,newCatID);
        ps.setString(2,filename);

        db.executeAsUpdate(ps,true);

        sql = "SELECT max(image_id) as imgid from image where category_id = ? AND file_name = ?";

        ps = db.getPreparedStatement(sql);
        ps.setString(1,newCatID);
        ps.setString(2,filename);

        newImgID = db.getSingleString(ps,"imgid",true);

        log.debug("newImgID:" + newImgID);

        imageReplacements.put(oldImgID,newImgID);

        log.debug("Image " + oldImgID + " is replaced by " + newImgID + " (" + filename + ")");
      }
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

// scene_id | scenetype_id | pattern_id | project_id | timeout | description  | lead             | correctkey 

    HashMap<String,String> sceneReplacements = new HashMap<String,String>();

    try
    {
      sql = "select * from scene WHERE project_id = ?";

      ps = db.getPreparedStatement(sql);
      ps.setString(1,oldProjectID);

      Vector<HashMap<String,String>> sceneTable = db.getResultAsHashVector(ps,true);

      String scene_id;
      String scenetype_id;
      String pattern_id;
      String timeout;
      String scenedesc;
      String lead;
      String correctkey;

      String newSceneID;

      for(HashMap<String,String> row : sceneTable)
      {
        scene_id = row.get("scene_id");
        scenetype_id = row.get("scenetype_id");
        pattern_id = row.get("pattern_id");
        timeout = row.get("timeout");
        scenedesc = row.get("description");
        lead = row.get("lead");
        correctkey = row.get("correctkey");
        
        sql = "INSERT INTO scene (scenetype_id,pattern_id,project_id,timeout,description,lead,correctkey) ";
        sql = sql + "VALUES(?,?,?,?,?,?,?);";

        ps = db.getPreparedStatement(sql);

        ps.setString(1,scenetype_id);
        ps.setString(2,pattern_id);
        ps.setString(3,newProjectID);
        ps.setString(4,timeout);
        ps.setString(5,scenedesc);
        ps.setString(6,lead);
        ps.setString(7,correctkey);

        db.executeAsUpdate(ps,true);

        sql = "SELECT max(scene_id) as scid from scene where project_id = ? and description = ?";

        ps = db.getPreparedStatement(sql);
        ps.setString(1,newProjectID);
        ps.setString(2,scenedesc);

        newSceneID = db.getSingleString(ps,"scid",true);

        log.debug("Scene " + scene_id + " is replaced by " + newSceneID + " (" + scenedesc + ")");

        sceneReplacements.put(scene_id,newSceneID);
      }

    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    String originalsceneid, clonesceneid;

    for(String key : sceneReplacements.keySet())
    {
      originalsceneid = key;
      clonesceneid = sceneReplacements.get(key);

      log.debug("clone scene_id is: " + clonesceneid);
      log.debug("orig. scene_id is: " + originalsceneid);

      String[] tables = new String[] {
        "ssi",
          "sri",
          "scri",
          "scriscene",
          "sosiimg",
          "sosiopt",
          "soricat",
          "soriopt"
      };

      String colname;
      ResultSetMetaData meta;
      Vector<String> columns;
      PreparedStatement updateps;

      for (String table : tables)
      {
        try
        {
          log.debug("Table: " + table);

          sql = "SELECT * FROM " + table + " WHERE scene_id = ?";

          ps = db.getPreparedStatement(sql);
          ps.setString(1,originalsceneid);
          r = ps.executeQuery();
          r.beforeFirst();

          meta = ps.getMetaData();
          columns = new Vector<String>();

          int colNum = meta.getColumnCount();

          for(int i = 2; i <= colNum; i++)
          {
            colname = meta.getColumnLabel(i);
            if(!colname.equals("scene_id"))
            {
              columns.add(colname);
              log.debug("Column: " + colname);
            }
          }

          log.debug("number of columns: " + columns.size());

          sql = "INSERT INTO " + table + "(scene_id";
          for (String col : columns)
          {
            sql = sql + "," + col;
          }
          sql = sql + ") VALUES(?";
          for (String col : columns)
          {
            sql = sql + ",?";
          }
          sql = sql + ")";

          log.debug(sql);

          updateps = db.getPreparedStatement(sql);

          String orig;

          while(r.next())
          {
            int colno = 2;
            updateps.setString(1, clonesceneid);

            log.debug("number of columns: " + columns.size());
            for (String col : columns)
            {
              log.debug(colno + " (" + col + ")");
              if(col.equals("category_id") || col.equals("image_id"))
              {
                orig = r.getString(col);
                if(col.equals("category_id"))
                {
                  updateps.setString(colno++, categoryReplacement.get(orig));
                }
                if(col.equals("image_id"))
                {
                  updateps.setString(colno++, imageReplacements.get(orig));
                }
              }
              else
              {
                updateps.setString(colno++, r.getString(col));
              }
            }
            updateps.executeUpdate();
          }

          updateps.close();

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
    }
  }
}

