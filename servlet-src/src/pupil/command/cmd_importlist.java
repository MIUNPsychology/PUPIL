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

public class cmd_importlist extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_importlist.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_importlist(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_importlist()");

    String kod = cmd.getParameter("kod");

    log.debug("kod is: " + kod);

    if(kod == null || kod.equals("") )
    {
      xib.setErrorResponse("Kod must be given");
      return;
    }

    Connection conn = null;

    // TODO: Remove or read from config
    String url = "EXTERNAL_JDBC_URI";
    String dbName = "EXTERNAL_JDBC_DB";
    String driver = "com.mysql.jdbc.Driver";
    String userName = "EXTERNAL_JDBC_USER"; 
    String password = "EXTERNAL_JDBC_PASS";

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

        r.close();

        Document d = db.getResultAsXML(ps,true);
        xib.setResponse(d);
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
 
    log.trace("Leave cmd_importlist()");

  }
}

