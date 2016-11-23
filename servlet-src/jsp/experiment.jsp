<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>reaction</title>
<script language="javascript">AC_FL_RunContent = 0;</script>
<script src="AC_RunActiveContent.js" language="javascript"></script>
</head>
<body bgcolor="#ffffff">
  <%@ include file="login-head.jsp" %>
<%

String projname = request.getParameter("project");
if(projname == null || projname.equals(""))
{
  out.print("<!-- No project given -->");
}
else
{
  out.print("<!-- Project from parameter is " + projname + " -->");
}

%>
<!--url's used in the movie-->
<!--text used in the movie-->
<!-- saved from url=(0013)about:internet -->
<script language="javascript">
	if (AC_FL_RunContent == 0) {
		alert("This page requires AC_RunActiveContent.js.");
	} else {
		AC_FL_RunContent(
			'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0',
			'width', '100%',
			'height', '98%',
			'src', 'reaction',
			'quality', 'best',
			'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
			'align', 'left',
			'play', 'true',
			'loop', 'true',
			'scale', 'noscale',
			'wmode', 'window',
			'devicefont', 'false',
			'id', 'reaction',
			'bgcolor', '#ffffff',
			'name', 'reaction',
			'menu', 'true',
			'allowFullScreen', 'true',
			'allowScriptAccess','sameDomain',
                        'movie', 'reaction',<%

if(projname != null && !projname.equals(""))
{
out.print("\n'FlashVars', 'project=" + projname + "',\n");
}
                        %>'salign', 'lt'
			); //end AC code
	}
</script>
<noscript>
  <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="100%" height="100%" id="reaction" align="left">
    <param name="allowScriptAccess" value="sameDomain" />
    <param name="allowFullScreen" value="true" />
    <param name="movie" value="reaction.swf" />
    <param name="quality" value="best" />
    <param name="scale" value="noscale" />
    <param name="salign" value="lt" /><%

if(projname != null && !projname.equals(""))
{
out.print("\n<param name='FlashVars' value='project=" + projname + "' />\n");
}
                        
    %><param name="bgcolor" value="#ffffff" />	
    <embed src="reaction.swf" quality="best" scale="noscale" salign="lt" bgcolor="#ffffff" width="100%" height="98%" name="MyApp" align="left" allowScriptAccess="sameDomain" allowFullScreen="true" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
  </object>
</noscript>
  <%@ include file="login-foot.jsp" %>

