#!/usr/bin/perl

my($incmd) = "find . -name \"*.as\"";
my($head) = "";

my($detection) = "START OF LICENSE AND COPYRIGHT BLURB";

if(open(FIL,"license-head.txt"))
{
  $head = join('',<FIL>);
  close(FIL);

#  print $head;
}
else
{
  die "Could not open license head template\n";
}

if(open(PIPE,"$incmd |"))
{
  while($inlin = <PIPE>)
  {
    chomp($inlin);
#    print "$inlin\n";

    if(open(FIL,$inlin))
    {
      $filedata = join('',<FIL>);
      close(FIL);

      if($filedata =~ m/$detection/)
      {
        print "File $inlin is already patched\n";
      }
      else
      {
        print "Patching $inlin with blurb\n";

        if(open(FIL,"> $inlin"))
        {
          $fileout = $head . $filedata; 
          $fileout =~ s/\x0d//g;
          $fileout =~ s/\xEF\xBB\xBF//g;

          print FIL $fileout;

          close(FIL);
        }
        else
        {
          die "Could not open $inlin for writing\n";
        }
      }
    }    
    else
    {
      print "Could open $inlin for reading\n;"
    }
  }
  close(PIPE);
}
else
{
  die "Could not open pipe\n";
}

