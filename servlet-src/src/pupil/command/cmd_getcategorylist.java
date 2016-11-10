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

public class cmd_getcategorylist extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_getcategorylist.class);

  public cmd_getcategorylist(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_getcategorylist()");

    String project = cmd.getParameter("project");

    if(project == null || project.equals(""))
    {
      xib.setErrorResponse("project cannot be unset");
      return;
    }

    try
    {
      String sql = "select category.* from category,project ";
      sql = sql + "WHERE category.project_id = project.project_id ";
      sql = sql + "AND project.name = ? ";
      sql = sql + "ORDER BY category.name";
      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,project);
      Document d = db.getResultAsXML(ps,true);
      xib.setResponse(d);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.trace("Leave cmd_getcategorylist()");

  }
}

