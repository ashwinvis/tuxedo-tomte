#!/usr/bin/perl
    use strict;
    use warnings;
    use Tk;
    my $mw = Tk::MainWindow->new(-title => 'Mein Programm');
    # Größe des Fensters:
    my      $windowHeight       = 600;
    my      $windowWidth        = 800;
    # Bildschirmgröße holen:
    my      $screenHeight       = $mw->screenheight;
    my      $screenWidth        = $mw->screenwidth;
    # MamaGUI zentrieren:
    $mw->geometry($windowWidth."x".$windowHeight);
    $mw->geometry("+" .
                       int($screenWidth/2 - $windowWidth/2) .
                       "+" .
                       int($screenHeight/2 - $windowHeight/2)
                      );
    # minimale Größe festlegen:
    $mw->minsize(400, 300);
    $mw->MainLoop;
    exit(0);
