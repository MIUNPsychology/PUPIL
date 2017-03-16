package pupil;

import pupil.core.*;
import pupil.sql.*;
import pupil.util.*;
import pupil.command.*;

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

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;

import org.apache.commons.io.*;

public class SQL extends UtilityServlet 
{
  public static final long serialVersionUID = 0L;

  private DBManager db = null;
 
  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(SQL.class);
  private static LogWrapper log = new LogWrapper();

  private File sqldir = null;

  /** processNormalRequest */
  public void processNormalRequest(StaticInfoBlob sib,RequestInfoBlob rib) throws IOException, ServletException
  {
    log.trace("Enter processNormalRequest()");
    String name,ext;
    boolean validreq = false;
    rib.println("<html>");

    name = FilenameUtils.getName(rib.path());

    if(name != null && !name.equals(""))
    {
      ext = FilenameUtils.getExtension(name);
      if(ext != null && ext.equals("sql"))
      {
        validreq = true;
        File f = new File(sqldir,name);
        if(f.exists())
        {
          String sql = FileUtils.readFileToString(f);
          //rib.println(sql);

          try
          {      
            PreparedStatement ps = db.getPreparedStatement(sql);
            ResultSetMetaData meta = ps.getMetaData();
            int colNum = meta.getColumnCount();
            String cname;
            String type;
            String table;
            String value;

            for(int i = 1; i < 10; i++)
            {
              value = rib.request().getParameter("" + i);
              if(value != null)
              {
                ps.setString(i,value);
              }
            }

            rib.println("<table cols=\"" + colNum + "\" border=\"1\">");
            rib.print("<tr>");

            for(int i = 1; i <= colNum; i++)
            {
              cname = meta.getColumnLabel(i);
              type = meta.getColumnTypeName(i);
              table = meta.getTableName(i);
              rib.print("<td><b>" + cname + "</b></td>");
            }
            rib.println("</tr>");

            ResultSet r = ps.executeQuery();

            r.beforeFirst();
            while(r.next())
            {
              rib.print("<tr>");
              for(int i = 1; i <= colNum; i++)
              {
                value = r.getString(i);
                if(value == null || value.equals(""))
                {
                  value = "&nbsp;";
                }
                rib.print("<td>" + value + "</td>");
              }
              rib.println("</tr>");
            }

            rib.println("</table>");

            r.close();
            ps.close();
          }
          catch(Exception e)
          {
            rib.println("<h1>SQL Exception</h1>");
            rib.println(e.getMessage());
          }

        }
        else
        {
          rib.println("File does not exist" + f.toString());
        }
      }
    }

    if(!validreq)
    {
      rib.println("illegal request");
    }

    rib.println("</html>");
    log.trace("Leave processNormalRequest()");
  }

  /** processNormalRequest */
  public void processXMLRequest(StaticInfoBlob sib,RequestInfoBlob rib,XMLInfoBlob xib) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter processXMLRequest()");

    xib.setErrorResponse("The SQL servlet does not accept XML requests");

    log.trace("Leave processXMLRequest()");
  }


  public void processFileUpload(StaticInfoBlob sib,RequestInfoBlob rib, String fieldName, String fileName, String ContentType, long sizeInBytes, FileItem item) throws IOException, ServletException, FileUploadException
  {
    log.trace("Enter processFileUpload()");

    throw(new IOException("The SQL servlet does not accept file uploads"));

//    log.trace("Leave processFileUpload()");
  }

  /** init */
  public void init(StaticInfoBlob sib)
  {
    log.trace("Enter init()");

    sqldir = new File(sib.getPhysicalPath(),"sql");

    ServletContext context = sib.getServletContext();

    String databaseName = context.getInitParameter("databaseName");
    String databaseUser = context.getInitParameter("databaseUser");
    String databasePassword = context.getInitParameter("databasePassword");
    String databaseUrl = context.getInitParameter("databaseUrl");
    String databaseDriver = context.getInitParameter("databaseDriver");

    try
    {
      db = new DBManager(databaseUrl,databaseName,databaseDriver,databaseUser,databasePassword);
      //db = new DBManager("jdbc:mysql://localhost:3306/","pupil","com.mysql.jdbc.Driver","pupil","pupil");
    }
    catch(SQLException e)
    {
      log.debug("Could not set up DB connection: " + e.getMessage(),e);
    }

    log.trace("Leave init()");
  }
  
  /** getServletInfo
   * Returns a version string describing this servlet. */
  public String getServletInfo() {
    return "Pupil v0.0";
  }
}




