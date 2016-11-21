#!/usr/bin/perl

open(FIL,"efternamn.txt") || die;
@enamnarr = <FIL>;
close(FIL);


open(FIL,"man.txt") || die;
@manarr = <FIL>;
close(FIL);

open(FIL,"kvinna.txt") || die;
@kvinnaarr = <FIL>;
close(FIL);

for($grupp = 1; $grupp < 4; $grupp++)
{
  for($antal = 0; $antal < 20; $antal++)
  {
    $randnr = int( rand(scalar(@enamnarr)) );
    $efternamn = $enamnarr[$randnr];
    chomp($efternamn);
    $randnr = int( rand(scalar(@manarr)) );
    $fornamn = $manarr[$randnr];
    chomp($fornamn);

    $langd = 160 + int( rand(25) );
    $skostorlek = 40 + int( rand(7) );

    print "INSERT INTO person(testgrupp_id,fornamn,efternamn,kon,langd,skostorlek) ";
    print "VALUES($grupp,'$fornamn','$efternamn',1,$langd,$skostorlek);\n";
  }
  for($antal = 0; $antal < 20; $antal++)
  {
    $randnr = int( rand(scalar(@enamnarr)) );
    $efternamn = $enamnarr[$randnr];
    chomp($efternamn);
    $randnr = int( rand(scalar(@kvinnaarr)) );
    $fornamn = $kvinnaarr[$randnr];
    chomp($fornamn);

    $langd = 150 + int( rand(20) );
    $skostorlek = 35 + int( rand(6) );

    print "INSERT INTO person(testgrupp_id,fornamn,efternamn,kon,langd,skostorlek) ";
    print "VALUES($grupp,'$fornamn','$efternamn',0,$langd,$skostorlek);\n";

  }
}

for($omgang = 1; $omgang < 4; $omgang++)
{
  for($person = 1; $person < 121; $person++)
  {
    print "INSERT INTO testresultat(person_id, testomgang, obs1, obs2, obs3, obs4, obs5) ";
    print "VALUES($person,$omgang";
  
    for($obs = 1; $obs < 6; $obs++)
    {
      print "," . (int(rand(5)) + 1);
    }

    print ");\n";
  }
}

