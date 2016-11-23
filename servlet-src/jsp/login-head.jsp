<%

  if(pupil.Pupil.getInstance() == null)
  {
    request.getRequestDispatcher("/pupil/pupil/pupil?poke=1").include(request,response);
  }

  pupil.Pupil p = pupil.Pupil.getInstance();

//  out.println(p);

  String login = request.getParameter("login");
  String pass = request.getParameter("pass");

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

  boolean isStudent = p.isStudent(session);
  boolean isTeacher = p.isTeacher(session);

  out.println("<!-- isStudent: " + isStudent + " -->");
  out.println("<!-- isTeacher: " + isTeacher + " -->");

  boolean requireTeacher = request.getAttribute("requireteacher") != null;

  out.println("<!-- requireTeacher: " + requireTeacher + " -->");

  if(requireTeacher && !isTeacher) 
  {
    login = "";
    pass = "";
  }

  if(!requireTeacher && !isStudent)
  {
    login = "";
    pass = "";
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
%>


