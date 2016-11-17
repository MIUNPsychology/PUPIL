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

public class cmd_addstudent extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_addstudent.class);

  public cmd_addstudent(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_addstudent()");

    String login = cmd.getParameter("login");
    String pass = cmd.getParameter("pass");

    log.debug("login is: " + login);
    log.debug("pass is: " + pass);

    try
    {
      PreparedStatement ps = db.getPreparedStatement("INSERT INTO student(login,pass) VALUES(?,?)");
      ps.setString(1,login);
      ps.setString(2,pass);

      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_addstudent()");
  }
}
