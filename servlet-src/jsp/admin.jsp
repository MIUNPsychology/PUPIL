<html>
  <head></head>
  <body>
<%

  if(pupil.Pupil.getInstance() == null)
  {
    request.getRequestDispatcher("/pupil/pupil/pupil?poke=1").include(request,response);
  }

  pupil.Pupil p = pupil.Pupil.getInstance();
  pupil.core.StaticInfoBlob sib = p.getSIB();

  String login = request.getParameter("login");
  String pass = request.getParameter("pass");
  String action = request.getParameter("action");

  if(login != null && !login.equals(""))
  {
    if(pass != null && !pass.equals(""))
    {
      session.setAttribute("login",login);
      session.setAttribute("pass",pass);
    }
  }
  
  login = (String)session.getAttribute("login");
  pass = (String)session.getAttribute("pass");

  String requiredLogin = sib.getServletContext().getInitParameter("adminUser");
  String requiredPassword = sib.getServletContext().getInitParameter("adminPassword");

  if(login == null || pass == null || !login.equals(requiredLogin) || !pass.equals(requiredPassword))
  {
    login = null;
    pass = null;
    session.setAttribute("login",null);
    session.setAttribute("pass",null);
  }

  if(login == null || login.equals(""))
  {
%>

<h1>LOGIN REQUIRED</h1>

<form action="#" method="post">
  <tt><b>User: </b></tt>
  <input type="text" name="login" /><br />
  <tt><b>Pass: </b></tt>
  <input type="password" name="pass" /><br />
  <br />
  <input type="submit" value="Login" />
</form>
<%
 }
 else
 {
 pupil.sql.DBManager db = p.getDBManager();

 String sql;
 java.sql.PreparedStatement ps;
 java.sql.ResultSet r;

 if(action != null)
 {
   if(action.equals("create"))
   {
     sql = "insert into teacher(login,pass) values(?,?)";
     ps = db.getPreparedStatement(sql);
     ps.setString(1,request.getParameter("tuser"));
     ps.setString(2,request.getParameter("tpass"));
     ps.executeUpdate();
     ps.close();
     out.println("<font style='color: red'>Teacher created</font><br /><br />");
   }

   if(action.equals("change"))
   {
     sql = "update teacher set pass = ? where login = ?";
     ps = db.getPreparedStatement(sql);
     ps.setString(1,request.getParameter("tpass"));
     ps.setString(2,request.getParameter("tuser"));
     ps.executeUpdate();
     ps.close();
     out.println("<font style='color: red'>Teacher changed</font><br /><br />");
   }
 }


 sql = "select * from teacher";

 ps = db.getPreparedStatement(sql);
 r = ps.executeQuery();

 java.util.Vector<String> teachers = new java.util.Vector<String>();

 r.beforeFirst();
 while(r.next())
 {
   teachers.add(r.getString("login"));
 }

 r.close();
 ps.close();


%>
<h1>Administrative tasks</h1>
<p>Here you can create teacher logins and change teacher passwords</p>
<hr />
<h2>Create teacher login</h1>
<form action="#" method="post">
  <input type="hidden" name="action" value="create" />
  <tt><b>Teacher username: </b></tt>
  <input type="text" name="tuser" /><br />
  <tt><b>Teacher password: </b></tt>
  <input type="password" name="tpass" /><br />
  <br />
  <input type="submit" value="Create" />
</form>
<hr />
<h2>Change teacher password</h1>
<form action="#" method="post">
  <input type="hidden" name="action" value="change" />
  <tt><b>Teacher username: </b></tt>
  <select name="tuser">
  <%
  for(String u : teachers)
  {
    out.println("<option>" + u + "</option>");
  }
  %>
  </select><br />
  <tt><b>Teacher password: </b></tt>
  <input type="password" name="tpass" /><br />
  <br />
  <input type="submit" value="Change" />
</form>
<%
 }
%>


  </body>
</html>


