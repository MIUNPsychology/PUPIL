package pupil;

import pupil.core.*;
import pupil.sql.*;
import pupil.util.*;
import pupil.command.*;

import javax.naming.*;
import javax.naming.directory.*;

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

public class Pupil extends UtilityServlet 
{
  public static final long serialVersionUID = 0L;

  private static Pupil myInstance = null;

  private File imageDir = null;

  private DBManager db = null;
 
  private HashMap<String,Command> commands = null;

  //private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(Pupil.class);
  private static LogWrapper log = new LogWrapper();

  /** processNormalRequest */
  public void processNormalRequest(StaticInfoBlob sib,RequestInfoBlob rib) throws IOException, ServletException
  {
    log.trace("Enter processNormalRequest()");

    String poke = rib.request().getParameter("poke");
    if(poke != null && !poke.equals(""))
    {
      rib.println("<!-- poke -->");
      return;
    }

    rib.println("<html>");
    rib.println("<body bgcolor=\"white\">");
    rib.println("<h1>Test data</h1>");

    String sql = "select project.name as project,testcase.*,scene.description as scene,input.* from project, testcase, scene, input ";
    sql = sql + "where project.project_id = scene.project_id ";
    sql = sql + "and project.project_id = testcase.project_id ";
    sql = sql + "and input.testcase_id = testcase.testcase_id ";
    sql = sql + "and input.scene_id = scene.scene_id ORDER BY project.project_id, testcase.testcase_id, input.input_id";

    try
    {      
      PreparedStatement ps = db.getPreparedStatement(sql);
      ResultSet r = ps.executeQuery();

      rib.println("<table border=\"1\" width=\"100%\">");
      rib.print("<tr>");
      rib.print("<td><b>project</b></td>");
      rib.print("<td><b>testcase_id</b></td>");
      rib.print("<td><b>scene</b></td>");
      rib.print("<td><b>time_start</b></td>");
      rib.print("<td><b>time_end</b></td>");
      rib.print("<td><b>time_delta</b></td>");
      rib.print("<td><b>actual_input</b></td>");
      rib.print("<td><b>correct_input</b></td>");
      rib.println("</tr>");
      r.beforeFirst();
      while(r.next())
      {
        rib.print("<tr>");

        rib.print("<td>" + r.getString("project") + "</td>");
        rib.print("<td>" + r.getString("testcase_id") + "</td>");
        rib.print("<td>" + r.getString("scene") + "</td>");
        rib.print("<td>" + r.getString("time_start") + "</td>");
        rib.print("<td>" + r.getString("time_end") + "</td>");
        rib.print("<td>" + r.getString("time_delta") + "</td>");
        rib.print("<td>" + r.getString("actual_input") + "</td>");
        rib.print("<td>" + r.getString("correct_input") + "</td>");

        rib.println("</tr>");
      }
      rib.println("</table>");

      r.close();
      ps.close();
    }
    catch(Exception e)
    {
      log.debug("Urgh... " + e.getMessage(),e);
    }
    rib.println("</body>");
    rib.println("</html>");

    log.trace("Leave processNormalRequest()");
  }

  /** processNormalRequest */
  public void processXMLRequest(StaticInfoBlob sib,RequestInfoBlob rib,XMLInfoBlob xib) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter processXMLRequest()");

    boolean validpath = false;

    log.debug("path is: " + rib.path());

    if(rib.path() != null && rib.path().equals("/teacher"))
    {
      log.debug("path matches /teacher");
      validpath = true;
      if(isTeacher(rib.session()))
      {
        processTeacherXML(sib,rib,xib);
      }
      else
      {
        xib.setErrorResponse("Permission denied. Are you logged in?");
      }
    }

    if(rib.path() != null && rib.path().equals("/experiment"))
    {
      log.debug("path matches /experiment");
      validpath = true;
      if(isStudent(rib.session()))
      {
        processExperimentXML(sib,rib,xib);
      }
      else
      {
        xib.setErrorResponse("Permission denied. Are you logged in?");
      }
    }

    if(!validpath)
    {
      log.debug("path did not match anything recognizable, returning error");
      xib.setErrorResponse("Invalid path");
    }

    log.trace("Leave processXMLRequest()");
  }

  private void processExperimentXML(StaticInfoBlob sib,RequestInfoBlob rib,XMLInfoBlob xib) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter processExperimentXML()");

    Document request = xib.getRequestXML();
    boolean wasvalidcommand = false;

    if(XMLWrapper.isCommand(request))
    {
      log.debug("request wraps a command");
      XMLCommand cmd = XMLWrapper.asCommand(request);
      if(cmd != null)
      {
        log.debug("command is: " + cmd);
        String function = cmd.getFunction();

        if(function != null)
        {
          Command c = commands.get(function);

          if(c != null && c instanceof pupil.command.cmd_getprojectdetails)
          {
            HttpSession session = rib.session();
            String login = (String)session.getAttribute("login");
            String name = cmd.getParameter("name");

            try
            {
              String sql = "select count(*) numperm from permission, project, student ";
              sql = sql + "where permission.project_id = project.project_id ";
              sql = sql + "and student.student_id = permission.student_id ";
              sql = sql + "and student.login = ? ";
              sql = sql + "and project.name = ?";

              PreparedStatement ps = db.getPreparedStatement(sql);
              ps.setString(1,login);
              ps.setString(2,name);

              ResultSet r = ps.executeQuery();
              r.first();
              int numperm = r.getInt("numperm");

              r.close();
              ps.close();

              if(numperm < 1)
              {
                xib.setErrorResponse("You do not have permission to view this project");
                return;
              }
            }
            catch(SQLException e)
            {
              log.error(e.getMessage(),e);
              xib.setErrorResponse("SQLException: " + e.getMessage());
            }
          }


          if(c != null)
          {
            log.debug("Command " + function + " links to " + c.getClass().getName());
            log.info("Will execute experiment command " + function + " (user is " + rib.session().getAttribute("login") + ")");
            c.process(rib,xib,cmd);
            wasvalidcommand = true;
          }
          else
          {
            log.error("Command " + function + " has no reference in command database");
          }
        }
        else
        {
          log.error("function name is null!?");
        }
      }
      else
      {
        log.error("document wrapped command, but object could not be constructed");
      }
    }

    if(!wasvalidcommand)
    {      
      xib.setErrorResponse("not a valid command");
    }

    log.trace("Leave processExperimentXML()");
  }
 
  private void processTeacherXML(StaticInfoBlob sib,RequestInfoBlob rib,XMLInfoBlob xib) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter processTeacherXML()");

    Document request = xib.getRequestXML();
    boolean wasvalidcommand = false;

    if(XMLWrapper.isCommand(request))
    {
      log.debug("request wraps a command");
      XMLCommand cmd = XMLWrapper.asCommand(request);
      if(cmd != null)
      {
        log.debug("command is: " + cmd);
        String function = cmd.getFunction();

        if(function != null)
        {
          Command c = commands.get(function);
          if(c != null)
          {
            log.debug("Command " + function + " links to " + c.getClass().getName());
            log.info("Will execute teacher command " + function + " (user is " + rib.session().getAttribute("login") + ")");
            c.process(rib,xib,cmd);
            wasvalidcommand = true;
          }
          else
          {
            log.error("Command " + function + " has no reference in command database");
          }
        }
        else
        {
          log.error("function name is null!?");
        }
      }
      else
      {
        log.error("document wrapped command, but object could not be constructed");
      }
    }

    if(!wasvalidcommand)
    {      
      xib.setErrorResponse("not a valid command");
    }

    log.trace("Leave processTeacherXML()");
  }

  public void copyCategory(String oldname, String newname) throws IOException
  {
    File oldCatDir = new File(imageDir,oldname);
    File newCatDir = new File(imageDir,newname);

    log.debug("Old cat dir is: " + oldCatDir.getAbsolutePath());
    log.debug("New cat dir is: " + newCatDir.getAbsolutePath());

    org.apache.commons.io.FileUtils.copyDirectory(oldCatDir,newCatDir);

    log.debug("copy successful");
  }

  public void processFileUpload(StaticInfoBlob sib,RequestInfoBlob rib, String fieldName, String fileName, String ContentType, long sizeInBytes, FileItem item) throws IOException, ServletException, FileUploadException
  {
    log.trace("Enter processFileUpload()");

    String cleanedfn = FilenameUtils.getName(fileName.toLowerCase());
    String ext = FilenameUtils.getExtension(cleanedfn);

    log.debug("cleaned file name is: " + cleanedfn);
    log.debug("extension is: " + ext);

    File catdir = new File(imageDir,fieldName);

    log.debug("catdir is: " + catdir.getAbsolutePath());

    if(!catdir.exists())
    {
      catdir.mkdir();
    }

    File outfile = new File(catdir,cleanedfn);

    log.debug("outfile is: " + outfile.getAbsolutePath());

    try
    {
      PreparedStatement ps = db.getPreparedStatement("select category_id from category where name = ?");
      ps.setString(1,fieldName);

      ResultSet r = ps.executeQuery();
      r.first();
      String id = r.getString(1);
      r.close();
      ps.close();
      
      log.debug("category_id is " + id);

      ps = db.getPreparedStatement("INSERT INTO image(category_id,file_name) VALUES(?,?)");
      ps.setString(1,id);
      ps.setString(2,cleanedfn);

      db.executeAsUpdate(ps,true);

      log.debug("successfully added new row in image table");
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      throw(new IOException(e));
    }
    
    try
    {      
      item.write(outfile);
      log.debug("successfully wrote file");
    }
    catch(Exception e)
    {
      log.error(e.getMessage(),e);
      throw(new IOException(e));
    }


    log.trace("Leave processFileUpload()");
  }

  public boolean isStudent(HttpSession session)
  {
    log.trace("Enter isStudent()");
    if(session == null)
    {
      log.debug("session is null");
      return false;
    }

    Boolean isStudent = (Boolean)session.getAttribute("isStudent");

    log.debug("isStudent from session: " + isStudent);

    if(isStudent != null)
    {
      log.debug("login already validated as student");
      return true;
    }
    else
    {
      log.debug("Did not have isStudent in session");
    }

    String login = "";
    String pass = "";

    try
    {
      login = (String)session.getAttribute("login");
      pass = (String)session.getAttribute("pass");
    }
    catch(Exception e)
    {
      log.debug("could not read login info from session");
    }

    if(login == null || login.equals("") )
    {
      log.debug("login is empty");
      return false;
    }

    if(pass == null || pass.equals("") ) 
    {
      log.debug("pass is empty");
      return false;
    }

    // login and pass are given at least

    boolean isValid = false;

    try
    {
      String sql = "SELECT count(*) AS numvalid FROM student WHERE login = ? AND pass = ?";

      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,login);
      ps.setString(2,pass);
      ResultSet r = ps.executeQuery();

      r.first();

      int val = r.getInt(1);

      log.debug("number of valid hits: " + val);

      isValid = val > 0;

      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error("SQL Exeption: " + e.getMessage(),e);
      return false;
    }

    log.debug("isValid after DB check: " + isValid);

    if(!isValid)
    {
      log.debug("Credentials given, but no match in DB");

      try
      {
        String sql = "SELECT count(*) AS numvalid FROM student WHERE login = ?";

        PreparedStatement ps = db.getPreparedStatement(sql);
        ps.setString(1,login);
        ResultSet r = ps.executeQuery();

        r.first();

        int val = r.getInt(1);

        log.debug("number of valid hits with only login: " + val);

        r.close();
        ps.close();

        if(val < 1)
        {
          log.debug("student not existing in DB, giving up");
          return false;
        }
      }
      catch(SQLException e)
      {
        log.error("SQL Exeption: " + e.getMessage(),e);
        return false;
      }

      log.debug("Student exists in DB, but password was wrong. Trying LDAP.");
      //log.warn("LDAP DISABLED.");
      
      Hashtable<Object,String> env = new Hashtable<Object,String>();
      env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
      env.put(Context.PROVIDER_URL, "ldap://pluto2.miun.se:389");

      env.put(Context.SECURITY_AUTHENTICATION, "simple");
      env.put(Context.SECURITY_PRINCIPAL, "uid=" + login + ", ou=people, o=student.mh.se, o=mh.se");
      env.put(Context.SECURITY_CREDENTIALS, pass);

      try
      {
        DirContext ctx = new InitialDirContext(env);
        log.debug("Got match from LDAP");
        isValid = true;
      }
      catch(Exception e)
      {
        log.debug("no match in LDAP");
      }
    }

    log.debug("isValid: " + isValid);

    if(isValid)
    {
      session.setAttribute("isStudent", Boolean.TRUE);
    }

    log.trace("Leave isStudent()");
    return isValid;
  }

  public boolean isTeacher(HttpSession session)
  {
    log.trace("Enter isTeacher()");
    if(session == null)
    {
      log.debug("session is null");
      return false;
    }

    String login = "";
    String pass = "";

    try
    {
      login = (String)session.getAttribute("login");
      pass = (String)session.getAttribute("pass");
    }
    catch(Exception e)
    {
      log.debug("could not read login info from session");
    }

    if(login == null || login.equals("") )
    {
      log.debug("login is empty");
      return false;
    }

    if(pass == null || pass.equals("") ) 
    {
      log.debug("pass is empty");
      return false;
    }

    // login and pass are given at least

    boolean isValid = false;

    try
    {
      String sql = "SELECT count(*) AS numvalid FROM teacher WHERE login = ? AND pass = ?";

      PreparedStatement ps = db.getPreparedStatement(sql);
      ps.setString(1,login);
      ps.setString(2,pass);
      ResultSet r = ps.executeQuery();

      r.first();

      int val = r.getInt(1);

      log.debug("number of valid hits: " + val);

      isValid = val > 0;

      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error("SQL Exeption: " + e.getMessage(),e);
      return false;
    }

    log.debug("isValid: " + isValid);

    log.trace("Leave isTeacher()");
    return isValid;  
  }

  /** init */
  public void init(StaticInfoBlob sib)
  {
    log.trace("Enter init()");

    File tmp = new File(sib.getPhysicalPath(),"flash");
    imageDir = new File(tmp,"images");

    if(!imageDir.exists())
    {
      log.error("Image directory does not exist");
    }

    if(!imageDir.canRead())
    {
      log.error("Image directory is not readable");
    }

    if(!imageDir.canWrite())
    {
      log.error("Image directory is not writable");
    }

    try
    {
      db = new DBManager("jdbc:mysql://localhost:3306/","pupil","com.mysql.jdbc.Driver","pupil","pupil");
    }
    catch(SQLException e)
    {
      log.debug("Could not set up DB connection: " + e.getMessage(),e);
    }

    commands = new HashMap<String,Command>();

    commands.put("addblock", new cmd_addblock(db,sib));
    commands.put("addcategory", new cmd_addcategory(db,sib));
    commands.put("addcodepermission", new cmd_addcodepermission(db,sib));
    commands.put("addpermission", new cmd_addpermission(db,sib));
    commands.put("addscenetoblock", new cmd_addscenetoblock(db,sib));
    commands.put("addstudent", new cmd_addstudent(db,sib));
    commands.put("blocksettings", new cmd_blocksettings(db,sib));
    commands.put("cloneproject", new cmd_cloneproject(db,sib));
    commands.put("clonescene", new cmd_clonescene(db,sib));
    commands.put("createproject", new cmd_createproject(db,sib));
    commands.put("createscri", new cmd_createscri(db,sib));
    commands.put("createssi", new cmd_createssi(db,sib));
    commands.put("createsosi", new cmd_createsosi(db,sib));
    commands.put("createsori", new cmd_createsori(db,sib));
    commands.put("createtext", new cmd_createtext(db,sib));
    commands.put("deleteblock", new cmd_deleteblock(db,sib));
    commands.put("deletecategory", new cmd_deletecategory(db,sib));
    commands.put("deleteimage", new cmd_deleteimage(db,sib));
    commands.put("deleteproject", new cmd_deleteproject(db,sib));
    commands.put("deletescene", new cmd_deletescene(db,sib));
    commands.put("deletesql", new cmd_deletesql(db,sib));
    commands.put("deletestudent", new cmd_deletestudent(db,sib));
    commands.put("getallimages", new cmd_getallimages(db,sib));
    commands.put("getallstudents", new cmd_getallstudents(db,sib));
    commands.put("getblocklist", new cmd_getblocklist(db,sib));
    commands.put("getblockscenelist", new cmd_getblockscenelist(db,sib));
    commands.put("getblocksettings", new cmd_getblocksettings(db,sib));
    commands.put("getcategorylist", new cmd_getcategorylist(db,sib));
    commands.put("getimagesforcategory", new cmd_getimagesforcategory(db,sib));
    commands.put("getprojectdetails", new cmd_getprojectdetails(db,sib));
    commands.put("getprojectlist", new cmd_getprojectlist(db,sib));
    commands.put("getwithpermission", new cmd_getwithpermission(db,sib));
    commands.put("getwithoutpermission", new cmd_getwithoutpermission(db,sib));
    commands.put("getsceneinfo", new cmd_getsceneinfo(db,sib));
    commands.put("getscenelist", new cmd_getscenelist(db,sib));
    commands.put("getsqlfile", new cmd_getsqlfile(db,sib));
    commands.put("importlist", new cmd_importlist(db,sib));
    commands.put("importstudents", new cmd_importstudents(db,sib));
    commands.put("listsql", new cmd_listsql(db,sib));
    commands.put("listuniqueimages", new cmd_listuniqueimages(db,sib));
    commands.put("registerinput", new cmd_registerinput(db,sib));
    commands.put("replacecategory", new cmd_replacecategory(db,sib));
    commands.put("replaceimage", new cmd_replaceimage(db,sib));
    commands.put("remcodepermission", new cmd_remcodepermission(db,sib));
    commands.put("removescenefromblock", new cmd_removescenefromblock(db,sib));
    commands.put("rempermission", new cmd_rempermission(db,sib));
    commands.put("resetdata", new cmd_resetdata(db,sib));
    commands.put("savesql", new cmd_savesql(db,sib));
    commands.put("scenesinblock", new cmd_scenesinblock(db,sib));
    commands.put("scenesnotinblock", new cmd_scenesnotinblock(db,sib));
    commands.put("updateproject", new cmd_updateproject(db,sib));
    commands.put("updatescri", new cmd_updatescri(db,sib));
    commands.put("updatesori", new cmd_updatesori(db,sib));
    commands.put("updatesosi", new cmd_updatesosi(db,sib));
    commands.put("updatessi", new cmd_updatessi(db,sib));
    commands.put("updatetext", new cmd_updatetext(db,sib));
    commands.put("updatestudent", new cmd_updatestudent(db,sib));

    log.trace("Leave init()");

    myInstance = this;
  }

  public void destroy()
  {
    db.quit();
  }
  
  public static Pupil getInstance()
  {
    return myInstance;
  }

  /** getServletInfo
   * Returns a version string describing this servlet. */
  public String getServletInfo() {
    return "Pupil v0.0";
  }
}




