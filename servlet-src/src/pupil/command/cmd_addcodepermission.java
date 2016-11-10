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

public class cmd_addcodepermission extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_addcodepermission.class);

  public cmd_addcodepermission(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_addcodepermission()");

    String kod = cmd.getParameter("code");
    String project = cmd.getParameter("project");

    log.debug("project is: " + project);
    log.debug("code is: " + kod);

    String projectid = "";
    String studentid = "";
    String login = null;

    PreparedStatement ps;
    ResultSet r;

    Connection conn = null;

    String url = "jdbc:mysql://makemake.miun.se:3306/";
    String dbName = "sic";
    String driver = "com.mysql.jdbc.Driver";
    String userName = "nlostapp"; 
    String password = "SYdfQRMXW";

    Vector<String> frommiun = new Vector<String>();

    try 
    {
      Class.forName(driver).newInstance();
      conn = DriverManager.getConnection(url+dbName,userName,password);

      log.debug("Connected to the database");

      String sql = "SELECT * FROM kurs_tillfalle ";
      sql = sql + "WHERE kod = ? LIMIT 0,1";
      
      log.debug("About to prepare: " + sql);

      ps = conn.prepareStatement(sql);
      ps.setString(1,kod);

      log.debug("About to execute");
      
      r = ps.executeQuery();

      log.debug("Execute succeeded");

      String kurs_tillfalle_oid = null;

      try
      {
        r.first();
        kurs_tillfalle_oid = r.getString("kurs_tillfalle_oid");
      }
      catch(SQLException e)
      {
        // no rows
        log.debug("no KTO rows");
        xib.setErrorResponse("This combination did not exist");
        r.close();
        ps.close();
        conn.close();
        return;
      }

      log.debug("KTO: " + kurs_tillfalle_oid);

      r.close();
      ps.close();

      if(kurs_tillfalle_oid != null)
      {      
        sql = "SELECT ";
        sql = sql + "person_kurs.person_oid, ";
        sql = sql + "person.fornamn, ";
        sql = sql + "person.efternamn, ";
        sql = sql + "anvandare.anvid ";
          
        sql = sql + "FROM person_kurs,person,anvandare ";
        sql = sql + "WHERE kurs_tillfalle_oid = ? ";
        sql = sql + "AND person_kurs.person_oid = person.person_oid ";
        sql = sql + "AND anvandare.person_oid = person.person_oid ";
        sql = sql + "ORDER BY anvid";

        log.debug("About to prepare: " + sql);

        ps = conn.prepareStatement(sql);
        ps.setString(1,kurs_tillfalle_oid);

        log.debug("About to execute");
        
        r = ps.executeQuery();

        try
        {
          r.first();
          log.debug("There seems to be student rows");
        }
        catch(SQLException e)
        {
          log.debug("no student rows");
          xib.setErrorResponse("This combination returned no students");
          r.close();
          ps.close();
          conn.close();
          return;
        }


        r.beforeFirst();

        String stud;

        while(r.next())
        {
          stud = r.getString("anvid");
          log.debug("STUDENT: " + stud);
          frommiun.add(stud);
        }

        log.debug(frommiun.size() + " students");

        r.close();
        ps.close();
      }
      else
      {
        xib.setErrorResponse("KTO is null!?");
      }

      conn.close();

      log.debug("Disconnected from database");
    } 
    catch (Exception e) 
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

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

    HashMap<String,String> studids = new HashMap<String,String>();
    Vector<String> noperm = new Vector<String>();

    try
    {
      String sql = "SELECT student.student_id, student.login FROM student WHERE NOT EXISTS ";
      sql = sql + "(SELECT * FROM permission ";
      sql = sql + "WHERE student.student_id = permission.student_id ";
      sql = sql + "AND project_id = ?) ORDER BY student.login";

      ps = db.getPreparedStatement(sql);
      ps.setString(1,projectid);

      r = ps.executeQuery();

      r.beforeFirst();

      String plogin;
      String pid;

      while(r.next())
      {
        plogin = r.getString("login");
        pid = r.getString("student_id");

        studids.put(plogin,pid);
        noperm.add(plogin);

        log.debug("NO PERMISSION: " + plogin + " (" + pid + ")");
      }

      log.debug("noperm size: " + noperm.size());

      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    try
    {
      ps = db.getPreparedStatement("INSERT INTO permission(student_id,project_id) VALUES(?,?)");
      ps.setString(2,projectid);

      String stid;

      for(String alogin : frommiun)
      {
        if(noperm.contains(alogin))
        {
          stid = studids.get(alogin);
          ps.setString(1,stid);

          log.debug("GIVING PERMISSION: " + alogin + " (" + stid + ")");

          db.executeAsUpdate(ps,false);
        }
        else
        {
          log.debug(alogin + " already had permission or did not exist");
        }
      }
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_addcodepermission()");

  }
}

