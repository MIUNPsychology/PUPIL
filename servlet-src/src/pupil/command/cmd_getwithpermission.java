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

public class cmd_getwithpermission extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_getwithpermission.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_getwithpermission(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_getwithpermission()");

    String project = cmd.getParameter("project");
    log.debug("project is: " + project);

    String projectid = "";

    PreparedStatement ps;
    ResultSet r;
    String sql;

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
      sql = "SELECT login FROM student WHERE EXISTS ";
      sql = sql + "(SELECT * FROM permission ";
      sql = sql + "WHERE student.student_id = permission.student_id ";
      sql = sql + "AND project_id = ?) ORDER BY student.login";

      ps = db.getPreparedStatement(sql);
      ps.setString(1,projectid);

      Document d = db.getResultAsXML(ps,true);
      xib.setResponse(d);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }


    log.trace("Leave cmd_getwithpermission()");
  }
}

