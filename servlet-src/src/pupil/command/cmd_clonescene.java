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

public class cmd_clonescene extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_clonescene.class);

  public cmd_clonescene(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_clonescene()");

    String project = cmd.getParameter("project");
    String original = cmd.getParameter("original");
    String clone = cmd.getParameter("clone");

    log.debug("project is: " + project);
    log.debug("clone is: " + clone);
    log.debug("original is: " + original);

    String clonesceneid = "";
    String originalsceneid = "";
    String projectid = "";

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

    HashMap<String,String> originalscene = new HashMap<String,String>();

    try
    {
      ps = db.getPreparedStatement("SELECT * FROM scene WHERE project_id = ? AND description = ?");
      ps.setString(1,projectid);
      ps.setString(2,original);
      r = ps.executeQuery();
      r.first();

      originalsceneid = r.getString("scene_id");

      originalscene.put("scenetype_id",r.getString("scenetype_id"));
      originalscene.put("pattern_id",r.getString("pattern_id"));
      originalscene.put("project_id",r.getString("project_id"));
      originalscene.put("timeout",r.getString("timeout"));
      originalscene.put("description",r.getString("description"));
      originalscene.put("lead",r.getString("lead"));
      originalscene.put("correctkey",r.getString("correctkey"));

      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("original scene_id is: " + originalsceneid);

    try
    {
      String sql = "INSERT INTO scene(scenetype_id,pattern_id,project_id,description,correctkey,timeout,lead) VALUES(?,?,?,?,?,?,?)";

      ps = db.getPreparedStatement(sql);

      ps.setString(1,originalscene.get("scenetype_id"));
      ps.setString(2,originalscene.get("pattern_id"));
      ps.setString(3,originalscene.get("project_id"));
      ps.setString(4,clone);
      ps.setString(5,originalscene.get("correctkey"));
      ps.setString(6,originalscene.get("timeout"));
      ps.setString(7,originalscene.get("lead"));

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
      ps = db.getPreparedStatement("SELECT max(scene_id) AS scene FROM scene WHERE project_id = ? AND description = ?");
      ps.setString(1,projectid);
      ps.setString(2,clone);
      r = ps.executeQuery();
      r.first();
      clonesceneid = r.getString("scene");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("clone scene_id is: " + clonesceneid);
    
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

    String sql,colname;
    ResultSetMetaData meta;
    Vector<String> columns;
    PreparedStatement updateps;

    for (String table : tables)
    {
      try
      {
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
//            log.debug("Column: " + colname);
          }
        }

//        log.debug("number of columns: " + columns.size());

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

        while(r.next())
        {
          int colno = 2;
          updateps.setString(1, clonesceneid);

//          log.debug("number of columns: " + columns.size());
          for (String col : columns)
          {
            log.debug(colno + " (" + col + ")");
            updateps.setString(colno++, r.getString(col));
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

    log.trace("Leave cmd_clonescene()");

  }
}

