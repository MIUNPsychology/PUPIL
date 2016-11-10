package pupil.sql;

import java.sql.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.*;
import org.xml.sax.*;
import java.io.*;
import java.util.*;

import pupil.util.*;


public class DBManager implements Runnable
{
  private String myUrl = "";
  private String myDbname = "";
  private String myDriver = "";
  private String myUsername = "";
  private String myPassword = "";

  private Connection myConnection = null;

  private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(DBManager.class);

  private Thread connectionCheck = null;

  private Vector<ResultSet> autoResultSets = new Vector<ResultSet>();
  private Vector<PreparedStatement> autoStatements = new Vector<PreparedStatement>();

  private static final int pollFrequency = 1000 * 60 * 5; // every five minutes

  public DBManager(String url, String dbname, String driver, String username, String password) throws SQLException
  {
    log.trace("enter DBManager()");
    myUrl = url;
    myDbname = dbname;
    myDriver = driver;
    myUsername = username;
    myPassword = password;

    log.debug("url: " + url);
    log.debug("dbname: " + dbname);
    log.debug("driver: " + driver);
    log.debug("username: " + username);
    log.debug("password: " + password);

    log.debug("Full url: " + url + dbname);

    try
    {
      Class.forName(driver).newInstance();
      myConnection = DriverManager.getConnection(myUrl + myDbname, myUsername, myPassword);
      myConnection.setAutoCommit(true);
    }
    catch(ClassNotFoundException e)
    {
      log.debug("Class not found: " + e.getMessage(), e);
      throw new SQLException(e);
    }
    catch(InstantiationException e)
    {
      log.debug("Error loading class: " + e.getMessage(), e);
      throw new SQLException(e);
    }
    catch(IllegalAccessException e)
    {
      log.debug("Crappy class: " + e.getMessage(), e);
      throw new SQLException(e);
    }

    log.debug("connection: " + myConnection);

    log.debug("about to start connection checker thread");

    connectionCheck = new Thread(this);
    connectionCheck.start();

    log.trace("leave DBManager()");

  }

  private synchronized void checkDBViability()
  {
    PreparedStatement ps = null;
    ResultSet r = null;

    try
    {
      ps = myConnection.prepareStatement("select * from pattern");
      r = ps.executeQuery();
      r.close();
      ps.close();
      log.debug("connection seems to be alive");
    }
    catch(Exception ex)
    {
      log.debug("connection refuses with message: " + ex.getMessage());
      log.debug("trying to build new connection");
      try
      {
        Class.forName(myDriver).newInstance();
        myConnection = DriverManager.getConnection(myUrl + myDbname, myUsername, myPassword);
        myConnection.setAutoCommit(true);
      }
      catch(ClassNotFoundException e)
      {
        log.error("Class not found: " + e.getMessage(), e);
        return;
      }
      catch(InstantiationException e)
      {
        log.error("Error loading class: " + e.getMessage(), e);
        return;
      }
      catch(IllegalAccessException e)
      {
        log.error("Crappy class: " + e.getMessage(), e);
        return;
      }
      catch(SQLException e)
      {
        log.error("SQL Failure: " + e.getMessage(), e);
        return;
      }

      log.debug("Connection is: " + myConnection);
      log.debug("Assuming communications are restored");
    }

    ps = null;
    r = null;
  }

  public void run()
  {
    while(!connectionCheck.interrupted() && !connectionCheck.isInterrupted())
    {
      try
      {
        connectionCheck.sleep(pollFrequency);
        checkDBViability();
      }
      catch(Exception e)
      {
        log.error("Poller thread interrupted: " + e.toString());
        return;
      }
    }
  }

  public void quit()
  {
    for(ResultSet r : autoResultSets)
    {
      try
      {
        r.clearWarnings();
        r.close();
      }
      catch(Exception e)
      {
      }
    }

    for(PreparedStatement ps : autoStatements)
    {
      try
      {
        ps.cancel();
        ps.clearWarnings();
        ps.close();
      }
      catch(Exception e)
      {
      }
    }


    try
    {
      connectionCheck.interrupt();
      connectionCheck = null;
    }
    catch(Exception e)
    {
    }


    for (Enumeration<Driver> dr = DriverManager.getDrivers(); dr.hasMoreElements();)
    {
      Driver d = dr.nextElement();
      try
      {
        DriverManager.deregisterDriver(d);
      }
      catch(Exception e)
      {
      }
    }
  }

  public PreparedStatement getPreparedStatement(String sql) throws SQLException
  {
    checkDBViability();
    log.trace("enter getPreparedStatement()");
    log.info("about to prepare statement: " + sql);
    PreparedStatement ps = myConnection.prepareStatement(sql);
    log.trace("leave getPreparedStatement()");

    autoStatements.add(ps);

    return ps;
  }

  public String getSingleString(PreparedStatement ps, String name, boolean closeStatement) throws SQLException
  {
    HashMap<String,String> results = getResultAsHash(ps,closeStatement);
    return results.get(name);
  }

  public HashMap<String,String> getResultAsHash(PreparedStatement ps, boolean closeStatement) throws SQLException
  {
    log.trace("enter getResultAsHash()");

    HashMap<String,String> result = new HashMap<String,String>();

    ResultSetMetaData meta = ps.getMetaData();
    int colNum = meta.getColumnCount();

    log.debug("number of columns: " + colNum);

    log.debug("fetching data");

    ResultSet r = ps.executeQuery();

    autoResultSets.add(r);

    r.first();

    String name;
    String type;
    String table;

    for(int i = 1; i <= colNum; i++)
    {
      name = meta.getColumnLabel(i);
      type = meta.getColumnTypeName(i);
      table = meta.getTableName(i);

      log.debug("Column " + i + ": name=" + name + " type=" + type + " table=" + table);

      result.put(name,r.getString(name));
    }

    r.close();

    if(closeStatement) 
    { 
      log.debug("Attempting to close statement");
      ps.close(); 
    }
    log.trace("leave getResultAsHash()");

    return result;
  }

  public Vector<HashMap<String,String>> getResultAsHashVector(PreparedStatement ps, boolean closeStatement) throws SQLException
  {
    log.trace("enter getResultAsHash()");

    Vector<HashMap<String,String>> result = new Vector<HashMap<String,String>>();

    ResultSetMetaData meta = ps.getMetaData();
    int colNum = meta.getColumnCount();

    log.debug("number of columns: " + colNum);

    log.debug("fetching data");

    ResultSet r = ps.executeQuery();

    autoResultSets.add(r);

    r.beforeFirst();

    String name;
    String type;
    String table;

    while(r.next())
    {
      HashMap<String,String> row = new HashMap<String,String>();

      for(int i = 1; i <= colNum; i++)
      {
        name = meta.getColumnLabel(i);
        type = meta.getColumnTypeName(i);
        table = meta.getTableName(i);

        log.debug("Column " + i + ": name=" + name + " type=" + type + " table=" + table);

        row.put(name,r.getString(name));
      }
      result.add(row);
    }

    r.close();

    if(closeStatement) 
    { 
      log.debug("Attempting to close statement");
      ps.close(); 
    }
    log.trace("leave getResultAsHash()");

    return result;
  }



  public Document getResultAsXML(PreparedStatement ps, boolean closeStatement) throws SQLException
  {
    log.trace("enter getResultAsXML()");

    Document d = null;

    try
    {
      log.debug("starting new document");

      d = XMLWrapper.getEmptyDocument("resultset");

      Element rootElement = d.getDocumentElement();
      Element metaData = d.createElement("metadata");
      Element data = d.createElement("data");

      rootElement.appendChild(metaData);
      rootElement.appendChild(data);

      log.debug("fetching meta data");

      ResultSetMetaData meta = ps.getMetaData();
      int colNum = meta.getColumnCount();

      log.debug("number of columns: " + colNum);
      metaData.setAttribute("columns","" + colNum);

      String name;
      String type;
      String table;

      Element columnInfo = null;

      for(int i = 1; i <= colNum; i++)
      {
        name = meta.getColumnLabel(i);
        type = meta.getColumnTypeName(i);
        table = meta.getTableName(i);

        log.debug("Column " + i + ": name=" + name + " type=" + type + " table=" + table);
        
        columnInfo = d.createElement("columninfo");
        columnInfo.setAttribute("num","" + i);
        columnInfo.setAttribute("name",name);
        columnInfo.setAttribute("type",type);
        columnInfo.setAttribute("table",table);
        metaData.appendChild(columnInfo);
      }

      log.debug("fetching data");

      ResultSet r = ps.executeQuery();

      autoResultSets.add(r);

      r.beforeFirst();

      String s;

      int rnum = 0;

      Element row = null;
      Element col = null;

      Text contents = null;

      while(r.next())
      {
        rnum++;

        log.debug("starting row number " + rnum);

        row = d.createElement("row");
        row.setAttribute("num","" + rnum);
        data.appendChild(row);

        for(int i = 1; i <= colNum; i++)
        {
          col = d.createElement("column");
          name = meta.getColumnLabel(i);
          col.setAttribute("name",name);         
          
          s = r.getString(i);
          if(s == null)
          {
            s = "";
          }

          contents = d.createTextNode(s);
          col.appendChild(contents);
          row.appendChild(col);

          log.debug("column " + i + " data: " + s);
        }
      }

      metaData.setAttribute("rows","" + rnum);

      r.close();
    }
    catch(SAXException e)
    {
      log.error("XML error: " + e.getMessage(),e);
      throw new SQLException(e);
    }
    catch(ParserConfigurationException e)
    {
      log.error("XML error: " + e.getMessage(),e);
      throw new SQLException(e);
    }
    catch(TransformerConfigurationException e)
    {
      log.error("XML error: " + e.getMessage(),e);
      throw new SQLException(e);
    }
    catch(DOMException e)
    {
      log.error("XML error: " + e.getMessage(),e);
      throw new SQLException(e);
    }

    if(closeStatement) 
    { 
      log.debug("Attempting to close statement");
      ps.close(); 
    }
    log.trace("leave getResultAsXML()");

    return d;
  }

  public void executeAsUpdate(PreparedStatement ps, boolean closeStatement) throws SQLException
  {
    log.trace("enter executeAsUpdate()");

    ps.executeUpdate();
    if(closeStatement)
    {
      ps.close();
    }

    log.trace("leave executeAsUpdate()");
  }

  public Connection getConnection()
  {
    return myConnection;
  }
}


