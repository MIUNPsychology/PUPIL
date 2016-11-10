#!/usr/bin/perl

$mergename = "db.sql";

print "\nRoot password: ";
$pwd = <STDIN>;
chomp($pwd);

unlink $mergename;

if(open(PIPE,"find sql -name \"*.sql\" | sort |"))
{
  while($sql = <PIPE>)
  {
    chomp($sql);
    print "$sql\n";
    system "cat $sql >> $mergename";
    system "echo >> $mergename";
  }
  close(PIPE);
}
else
{
  die "Could not open pipe\n";
}

system "mysql -vvv -u root --password=$pwd < $mergename > db.log";
#print "mysql -u root --password=$pwd < $mergename > db.log\n";

