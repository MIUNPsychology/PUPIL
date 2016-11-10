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

public class cmd_importstudents extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_importstudents.class);

  public cmd_importstudents(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_importstudents()");

    String kod = cmd.getParameter("kod");

    log.debug("kod is: " + kod);

    if(kod == null || kod.equals("") )
    {
      xib.setErrorResponse("Kod must be given");
      return;
    }

    Connection conn = null;

    String url = "jdbc:mysql://makemake.miun.se:3306/";
    String dbName = "sic";
    String driver = "com.mysql.jdbc.Driver";
    String userName = "nlostapp"; 
    String password = "SYdfQRMXW";

    try 
    {
      Class.forName(driver).newInstance();
      conn = DriverManager.getConnection(url+dbName,userName,password);

      log.debug("Connected to the database");

      String sql = "SELECT * FROM kurs_tillfalle ";
      sql = sql + "WHERE kod = ? LIMIT 0,1";
      
      log.debug("About to prepare: " + sql);

      PreparedStatement ps = conn.prepareStatement(sql);
      ps.setString(1,kod);

      log.debug("About to execute");
      
      ResultSet r = ps.executeQuery();

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

        Vector<String> anv = new Vector<String>();

        String anvid = null;

        try
        {
          r.first();
          log.debug("There seems to be student rows");
          r.beforeFirst();


          while(r.next())
          {
            anvid = r.getString("anvid");
            if(anvid != null && !anvid.equals(""))
            {
              log.debug("STUDENT: " + anvid);
              anv.add(anvid);
            }            
          }
          r.close();
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
        
        ps.close();

        log.debug("We have " + anv.size() + " students to import");

        Vector<String> ex = new Vector<String>();

        try
        {
          PreparedStatement ps2 = db.getPreparedStatement("select login from student ORDER BY login");

          r = ps2.executeQuery();

          while(r.next())
          {
            anvid = r.getString("login");
            if(anvid != null && !anvid.equals(""))
            {
              log.debug("EXISTING: " + anvid);
              ex.add(anvid);
            }            
          }

          r.close();
          ps2.close();
        }
        catch(SQLException e)
        {
          log.error(e.getMessage(),e);
          xib.setErrorResponse("SQL error: " + e.getMessage());
          conn.close();
          return;
        }

        log.debug("We have " + ex.size() + " existing students");

        int nya = 0;

        try
        {
          String ins = "INSERT INTO student (login,pass) ";
          ins = ins + "VALUES (?,'')";

          PreparedStatement ps2 = db.getPreparedStatement(ins);

          for(String a : anv)
          {
            if(ex.contains(a))
            {
              log.debug("Login '" + a + "' already existed. Ignoring.");
            }
            else
            {
              log.debug("Login '" + a + "' did not exist. Inserting.");
              ps2.setString(1,a);
              ps2.executeUpdate();
              nya++;
            }
          }

          ps2.close();

          log.debug("inserted " + nya + " students");
        }
        catch(SQLException e)
        {
          log.error(e.getMessage(),e);
          xib.setErrorResponse("SQL error: " + e.getMessage());
          conn.close();
          return;
        }
      }
      else
      {
        xib.setErrorResponse("KTO is null!?");
      }

      conn.close();

      xib.setOkResponse();

      log.debug("Disconnected from database");
    } 
    catch (Exception e) 
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }
 
    log.trace("Leave cmd_importstudents()");

  }
}

