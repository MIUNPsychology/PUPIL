import java.sql.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.*;
import org.xml.sax.*;
import java.io.*;
import java.util.*;

public class Test
{


  public static void main(String[] args) throws Exception
  {
    Connection myConnection = null;

    try
    {
      Class.forName("com.mysql.jdbc.Driver").newInstance();
      myConnection = DriverManager.getConnection("jdbc:mysql://localhost:3306/pupil", "pupil", "pupil");
      myConnection.setAutoCommit(true);

      PreparedStatement ps = myConnection.prepareStatement("INSERT INTO ? (?) VALUES(?)");
      ps.setObject(1,"testtabell", java.sql.Types.REF);
      ps.setObject(2,"namn", java.sql.Types.REF);
      ps.setString(3,"Agda");
      System.out.println(ps);
      ps.executeUpdate();
      ps.close();
    }
    catch(ClassNotFoundException e)
    {
      throw new SQLException(e);
    }
    catch(InstantiationException e)
    {
      throw new SQLException(e);
    }
    catch(IllegalAccessException e)
    {
      throw new SQLException(e);
    }

    myConnection.close();
  }
}


