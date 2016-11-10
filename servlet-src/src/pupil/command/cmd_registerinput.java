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

public class cmd_registerinput extends Command
{
  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(cmd_registerinput.class);

  public cmd_registerinput(DBManager dbm, StaticInfoBlob info)
  {
    super(dbm,info);
  }

  public void process(RequestInfoBlob rib,XMLInfoBlob xib,XMLCommand cmd) throws IOException, ServletException, SAXException, ParserConfigurationException, TransformerConfigurationException, TransformerException, DOMException
  {
    log.trace("Enter cmd_registerinput()");

    String project = cmd.getParameter("project");
    String login = (String)rib.session().getAttribute("login");

    log.debug("project is: " + project);
    log.debug("login is: " + login);

    String projectid = "";
    String studentid = "";

    PreparedStatement ps;
    ResultSet r;

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
      ps = db.getPreparedStatement("SELECT * FROM student WHERE login = ?");
      ps.setString(1,login);
      r = ps.executeQuery();
      r.first();
      studentid = r.getString("student_id");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("student_id is: " + studentid);

    try
    {
      ps = db.getPreparedStatement("INSERT INTO testcase(project_id,student_id) VALUES(?,?)");
      ps.setString(1,projectid);
      ps.setString(2,studentid);
      db.executeAsUpdate(ps,true);
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
    }

    log.debug("inserted new test case");

    String testcaseid = "";

    try
    {
      ps = db.getPreparedStatement("SELECT max(testcase_id) as testcaseid FROM testcase WHERE project_id = ?");
      ps.setString(1,projectid);
      r = ps.executeQuery();
      r.first();
      testcaseid = r.getString("testcaseid");
      r.close();
      ps.close();
    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("testcaseid is: " + testcaseid);

    Element data = cmd.getData();

    log.debug("data is: " + data);

    NodeList nl = data.getElementsByTagName("scene");
    Element scene; 
    
    String displayno,start,end,delta,keychar,correct,name,sceneid;

    HashMap<String,String> sceneids = new HashMap<String,String>();

    try
    {
      ps = db.getPreparedStatement("SELECT scene_id FROM scene WHERE project_id = ? and description = ?");
      ps.setString(1,projectid);

      for(int i = 0; i < nl.getLength(); i++)
      {
        scene = (Element)nl.item(i);
        log.debug("scene: " + scene + " (" + i + ")");
        displayno = scene.getAttribute("displayno");
        start = scene.getAttribute("start");
        end = scene.getAttribute("end");
        delta = scene.getAttribute("delta");
        keychar = scene.getAttribute("keychar");
        correct = scene.getAttribute("correct");
        name = scene.getAttribute("name");

        log.debug(" -- displayno = " + displayno);
        log.debug(" -- start = " + start);
        log.debug(" -- end = " + end);
        log.debug(" -- delta = " + delta);
        log.debug(" -- keychar = " + keychar);
        log.debug(" -- correct = " + correct);
        log.debug(" -- name = " + name);

        ps.setString(2,name);
        r = ps.executeQuery();
        r.first();
        sceneid = r.getString("scene_id");
        r.close();

        log.debug(" ++ sceneid = " + sceneid);
        sceneids.put(name,sceneid);
      }
      ps.close();

    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("managed to populate scene ids");

    try
    {
      ps = db.getPreparedStatement("INSERT INTO input(testcase_id,scene_id,time_start,time_end,time_delta,actual_input,correct_input) VALUES(?,?,?,?,?,?,?)");
      ps.setString(1,testcaseid);

      int n;
      for(int i = 0; i < nl.getLength(); i++)
      {
        n = 2;
        scene = (Element)nl.item(i);
        displayno = scene.getAttribute("displayno");
        start = scene.getAttribute("start");
        end = scene.getAttribute("end");
        delta = scene.getAttribute("delta");
        keychar = scene.getAttribute("keychar");
        correct = scene.getAttribute("correct");
        name = scene.getAttribute("name");

        sceneid = sceneids.get(name);

        ps.setString(n++,sceneid);
        ps.setString(n++,start);
        ps.setString(n++,end);
        ps.setString(n++,delta);
        ps.setString(n++,keychar);
        ps.setString(n++,correct);

        ps.executeUpdate();
      }
      ps.close();

    }
    catch(SQLException e)
    {
      log.error(e.getMessage(),e);
      xib.setErrorResponse("SQLException: " + e.getMessage());
      return;
    }

    log.debug("managed to store input");

    log.trace("Leave cmd_registerinput()");

  }
}

