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

public class cmd_updatestudent extends Command
{
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_updatestudent.class);
  private static LogWrapper log = new LogWrapper();

  public cmd_updatestudent(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_updatestudent()");

    String login = cmd.getParameter("login");
    String pass = cmd.getParameter("pass");

    log.debug("login is: " + login);
    log.debug("pass is: " + pass);

    try
    {
      String sql = "UPDATE student SET ";
      sql = sql + "pass = ? ";
      sql = sql + "WHERE login = ? ";

      PreparedStatement ps = db.getPreparedStatement(sql);

      ps.setString(1,pass);
      ps.setString(2,login);

      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_updatestudent()");

  }
}

