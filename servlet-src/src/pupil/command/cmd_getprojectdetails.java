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

public class cmd_getprojectdetails extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_getprojectdetails.class);

  public cmd_getprojectdetails(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_getprojectdetails()");

    HttpSession session = rib.session();
    String login = (String)session.getAttribute("login");
    String name = cmd.getParameter("name");

    try
    {

      String sql = "select teacher.login, project.*, blinkfilenames.* FROM teacher,project,blinkfilenames where teacher.teacher_id = project.teacher_id ";
      sql = sql + "and project.project_id = blinkfilenames.project_id and project.name = ?";

      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,name);
      Document d = db.getResultAsXML(ps,true);
      xib.setResponse(d);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_getprojectdetails()");

  }
}

