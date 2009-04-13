package Tk::ForDummies::Graph::Areas;

use warnings;
use strict;
use Carp;

#==================================================================
# Author    : Djibril Ousmanou
# Copyright : 2009
# Update    : 13/04/2009 02:08:45
# AIM       : Create area chart
#==================================================================

use vars qw($VERSION);
$VERSION = '1.03';

use base qw/Tk::Derived Tk::Canvas/;
use Tk::Balloon;

use Tk::ForDummies::Graph::Utils qw (:DUMMIES);
use Tk::ForDummies::Graph qw (:DUMMIES);

Construct Tk::Widget 'Areas';

sub Populate {

  my ( $CompositeWidget, $RefParameters ) = @_;

  # Get initial parameters
  $CompositeWidget->{RefInfoDummies} = _InitConfig();

  $CompositeWidget->SUPER::Populate($RefParameters);

  $CompositeWidget->Advertise( 'canvas' => $CompositeWidget );

  # ConfigSpecs
  $CompositeWidget->ConfigSpecs(
    -title      => [ 'PASSIVE', 'Title',      'Title',      undef ],
    -titlecolor => [ 'PASSIVE', 'Titlecolor', 'TitleColor', 'black' ],
    -titlefont  => [
      'PASSIVE',   'Titlefont',
      'TitleFont', $CompositeWidget->{RefInfoDummies}->{Font}{DefaultTitle}
    ],
    -titleposition => [ 'PASSIVE', 'Titleposition', 'TitlePosition', 'center' ],
    -titleheight   => [
      'PASSIVE',     'Titleheight',
      'TitleHeight', $CompositeWidget->{RefInfoDummies}->{Title}{Height}
    ],

    -xlabel      => [ 'PASSIVE', 'Xlabel',      'XLabel',      undef ],
    -xlabelcolor => [ 'PASSIVE', 'Xlabelcolor', 'XLabelColor', 'black' ],
    -xlabelfont  => [
      'PASSIVE',    'Xlabelfont',
      'XLabelFont', $CompositeWidget->{RefInfoDummies}->{Font}{DefaultLabel}
    ],
    -xlabelposition =>
      [ 'PASSIVE', 'Xlabelposition', 'XLabelPosition', 'center' ],
    -xlabelheight => [
      'PASSIVE', 'Xlabelheight', 'XLabelHeight',
      $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight}
    ],
    -xlabelskip => [ 'PASSIVE', 'Xlabelskip', 'XLabelSkip', 0 ],

    -xvaluecolor => [ 'PASSIVE', 'Xvaluecolor', 'XValueColor', 'black' ],
    -xvaluevertical => [ 'PASSIVE', 'Xvaluevertical', 'XValueVertical', 0 ],
    -xvaluespace    => [
      'PASSIVE', 'Xvaluespace', 'XValueSpace',
      $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight}
    ],
    -xvaluesregex => [ 'PASSIVE', 'Xvaluesregex', 'XValuesRegex', qr/.+/ ],

    -ylabel      => [ 'PASSIVE', 'Ylabel',      'YLabel',      undef ],
    -ylabelcolor => [ 'PASSIVE', 'Ylabelcolor', 'YLabelColor', 'black' ],
    -ylabelfont  => [
      'PASSIVE',    'Ylabelfont',
      'YLabelFont', $CompositeWidget->{RefInfoDummies}->{Font}{DefaultLabel}
    ],
    -ylabelposition =>
      [ 'PASSIVE', 'Ylabelposition', 'YLabelPosition', 'center' ],
    -ylabelwidth => [
      'PASSIVE', 'Ylabelwidth', 'YLabelWidth',
      $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth}
    ],

    -yvaluecolor => [ 'PASSIVE', 'Yvaluecolor', 'YValueColor', 'black' ],

    -labelscolor => [ 'PASSIVE', 'Labelscolor', 'LabelsColor', undef ],
    -valuescolor => [ 'PASSIVE', 'Valuescolor', 'ValuesColor', undef ],
    -textcolor   => [ 'PASSIVE', 'Textcolor',   'TextColor',   undef ],
    -textfont    => [ 'PASSIVE', 'Textfont',    'TextFont',    undef ],

    -boxaxis      => [ 'PASSIVE', 'Boxaxis',      'BoxAxis',      0 ],
    -noaxis       => [ 'PASSIVE', 'Noaxis',       'NoAxis',       0 ],
    -zeroaxisonly => [ 'PASSIVE', 'Zeroaxisonly', 'ZeroAxisOnly', 0 ],
    -zeroaxis     => [ 'PASSIVE', 'Zeroaxis',     'ZeroAxis',     1 ],

    -xtickheight => [
      'PASSIVE', 'Xtickheight', 'XTickHeight',
      $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight}
    ],
    -xtickview => [ 'PASSIVE', 'Xtickview', 'XTickView', 1 ],

    -yticknumber => [
      'PASSIVE', 'Yticknumber', 'YTickNumber',
      $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickNumber}
    ],
    -ytickwidth => [
      'PASSIVE', 'Ytickwidth', 'YtickWidth',
      $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth}
    ],
    -ytickview => [ 'PASSIVE', 'Ytickview', 'YTickView', 1 ],

    -alltickview => [ 'PASSIVE', 'Alltickview', 'AllTickView', 1 ],

    -width => [
      'SELF',  'width',
      'Width', $CompositeWidget->{RefInfoDummies}->{Canvas}{Width}
    ],
    -height => [
      'SELF',   'height',
      'Height', $CompositeWidget->{RefInfoDummies}->{Canvas}{Height}
    ],

    -linewidth => [ 'PASSIVE', 'Linewidth', 'LineWidth', 1 ],
    -colordata => [
      'PASSIVE',   'Colordata',
      'ColorData', $CompositeWidget->{RefInfoDummies}->{Legend}{Colors}
    ],
    -viewsection => [ 'PASSIVE', 'Viewsection', 'ViewSection', 1 ],
  );

  $CompositeWidget->Delegates( DEFAULT => $CompositeWidget, );
  $CompositeWidget->Tk::bind(
    '<Configure>' => [ \&_GraphForDummiesConstruction ] );
}

sub _Balloon {
  my ($CompositeWidget) = @_;

  # balloon defined and user want to stop it
  if ( defined $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}
    and $CompositeWidget->{RefInfoDummies}->{Balloon}{State} == 0 )
  {
    $CompositeWidget->_DestroyBalloonAndBind();
    return;
  }

  # balloon not defined and user want to stop it
  elsif ( $CompositeWidget->{RefInfoDummies}->{Balloon}{State} == 0 ) {
    return;
  }

  # balloon defined and user want to start it again (may be new option)
  elsif ( defined $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}
    and $CompositeWidget->{RefInfoDummies}->{Balloon}{State} == 1 )
  {

    # destroy the balloon, it will be re create above
    $CompositeWidget->_DestroyBalloonAndBind();
  }

  # Balloon creation
  $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}
    = $CompositeWidget->Balloon(
    -statusbar  => $CompositeWidget,
    -background => $CompositeWidget->{RefInfoDummies}->{Balloon}{Background},
    );
  $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}->attach(
    $CompositeWidget,
    -balloonposition => 'mouse',
    -msg => $CompositeWidget->{RefInfoDummies}->{Legend}{MsgBalloon},
  );

  # no legend, no bind
  unless ( my $LegendTextNumber
    = $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend} )
  {
    return;
  }

  # bind legend and lines
  for my $IndexLegend (
    1 .. $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend} )
  {

    my $LegendTag
      = $IndexLegend . $CompositeWidget->{RefInfoDummies}->{TAGS}{Legend};
    my $LineTag
      = $IndexLegend . $CompositeWidget->{RefInfoDummies}->{TAGS}{Line};

    $CompositeWidget->bind(
      $LegendTag,
      '<Enter>',
      sub {
        my $OtherColor
          = $CompositeWidget->{RefInfoDummies}->{Balloon}{ColorData}->[0];

        # Change color if line have the same color
        if ( $OtherColor eq
          $CompositeWidget->{RefInfoDummies}{Line}{$LineTag}{color} )
        {
          $OtherColor
            = $CompositeWidget->{RefInfoDummies}->{Balloon}{ColorData}->[1];
        }
        $CompositeWidget->itemconfigure( $LineTag, 
          -fill => $OtherColor, 
          -width => $CompositeWidget->cget( -linewidth ) 
            + $CompositeWidget->{RefInfoDummies}->{Balloon}{MorePixelSelected},     
        );
      }
    );

    $CompositeWidget->bind(
      $LegendTag,
      '<Leave>',
      sub {
        $CompositeWidget->itemconfigure( $LineTag,
          -fill => $CompositeWidget->{RefInfoDummies}{Line}{$LineTag}{color}, 
          -width => $CompositeWidget->cget( -linewidth )
        );
        
        # Allow dash line to display
        $CompositeWidget->itemconfigure(
          $CompositeWidget->{RefInfoDummies}->{TAGS}{DashLines},
          -fill => "black", );
      }
    );
  }

  return;
}

sub set_legend {
  my ( $CompositeWidget, %InfoLegend ) = @_;

  my $RefLegend = $InfoLegend{-data};
  unless ( defined $RefLegend ) {
    $CompositeWidget->_error(
      "Can't set -data in set_legend method. "
        . "May be you forgot to set the value\n"
        . "Ex : set_legend( -data => ['legend1', 'legend2', ...] );",
      1
    );
  }

  unless ( defined $RefLegend and ref($RefLegend) eq 'ARRAY' ) {
    $CompositeWidget->_error(
      "Can't set -data in set_legend method. Bad data\n"
        . "Ex : set_legend( -data => ['legend1', 'legend2', ...] );",
      1
    );
  }

  if ( defined $InfoLegend{-title} ) {
    $CompositeWidget->{RefInfoDummies}->{Legend}{title} = $InfoLegend{-title};
  }
  else {
    undef $CompositeWidget->{RefInfoDummies}->{Legend}{title};
    $CompositeWidget->{RefInfoDummies}->{Legend}{HeightTitle} = 5;
  }
  $CompositeWidget->{RefInfoDummies}->{Legend}{titlefont}
    = $InfoLegend{-titlefont}
    || $CompositeWidget->{RefInfoDummies}->{Font}{DefaultLegendTitle};
  $CompositeWidget->{RefInfoDummies}->{Legend}{legendfont}
    = $InfoLegend{-legendfont}
    || $CompositeWidget->{RefInfoDummies}->{Font}{DefaultLegendTitle};

  if ( defined $InfoLegend{-box} and $InfoLegend{-box} =~ m{^\d+$} ) {
    $CompositeWidget->{RefInfoDummies}->{Legend}{box} = $InfoLegend{-box};
  }
  if ( defined $InfoLegend{-titlecolors} ) {
    $CompositeWidget->{RefInfoDummies}->{Legend}{titlecolors}
      = $InfoLegend{-titlecolors};
  }
  if ( defined $InfoLegend{-legendmarkerheight}
    and $InfoLegend{-legendmarkerheight} =~ m{^\d+$} )
  {
    $CompositeWidget->{RefInfoDummies}->{Legend}{HCube}
      = $InfoLegend{-legendmarkerheight};
  }
  if ( defined $InfoLegend{-legendmarkerwidth}
    and $InfoLegend{-legendmarkerwidth} =~ m{^\d+$} )
  {
    $CompositeWidget->{RefInfoDummies}->{Legend}{WCube}
      = $InfoLegend{-legendmarkerwidth};
  }
  if ( defined $InfoLegend{-heighttitle}
    and $InfoLegend{-heighttitle} =~ m{^\d+$} )
  {
    $CompositeWidget->{RefInfoDummies}->{Legend}{HeightTitle}
      = $InfoLegend{-heighttitle};
  }

  # Check legend and data size
  if ( my $RefData = $CompositeWidget->{RefInfoDummies}->{Data}{RefAllData} ) {
    $CompositeWidget->_CheckSizeLengendAndData( $RefData, $RefLegend );
  }

  # Get the biggest length of legend text
  my @LengthLegend = map { length; } @{$RefLegend};
  my $BiggestLegend = _MaxArray( \@LengthLegend );

# 100 pixel =>  13 characters, 1 pixel =>  0.13 pixels then 1 character = 7.69 pixels
  $CompositeWidget->{RefInfoDummies}->{Legend}{WidthOneCaracter} = 7.69;

  # Max pixel width for a legend text for us
  $CompositeWidget->{RefInfoDummies}->{Legend}{LengthTextMax}
    = int( $CompositeWidget->{RefInfoDummies}->{Legend}{WidthText}
      / $CompositeWidget->{RefInfoDummies}->{Legend}{WidthOneCaracter} );

  # We have free space
  my $Diff = $CompositeWidget->{RefInfoDummies}->{Legend}{LengthTextMax}
    - $BiggestLegend;

  # Get new size width for a legend text with one pixel security
  $CompositeWidget->{RefInfoDummies}->{Legend}{WidthText} -= ( $Diff - 1 )
    * $CompositeWidget->{RefInfoDummies}->{Legend}{WidthOneCaracter};

  # Store Reference data
  $CompositeWidget->{RefInfoDummies}->{Legend}{DataLegend} = $RefLegend;
  $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend} = scalar @{$RefLegend};
  
  return 1;
}

sub _Legend {
  my ( $CompositeWidget, $RefLegend ) = @_;

  # One legend width
  $CompositeWidget->{RefInfoDummies}->{Legend}{LengthOneLegend}
    = +$CompositeWidget->{RefInfoDummies}
    ->{Legend}{SpaceBeforeCube}    # Espace entre chaque légende
    + $CompositeWidget->{RefInfoDummies}->{Legend}{WCube}    # Cube (largeur)
    + $CompositeWidget->{RefInfoDummies}
    ->{Legend}{SpaceAfterCube}                               # Espace apres cube
    + $CompositeWidget->{RefInfoDummies}
    ->{Legend}{WidthText}    # longueur du texte de la légende
    ;

  # Number of legends per line
  $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine}
    = int( $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width}
      / $CompositeWidget->{RefInfoDummies}->{Legend}{LengthOneLegend} );
  $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine} = 1
    if ( $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine} == 0 );

  # How many legend we will have
  $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend}
    = scalar @{ $CompositeWidget->{RefInfoDummies}->{Data}{RefAllData} } - 1;

=for NumberLines
  We calculate the number of lines set for the legend chart.
  If wa can set 11 legends per line, then for 3 legend, we will need one line
  and for 12 legends, we will need 2 lines
  If NbrLeg / NbrPerLine = integer => get number of lines
  If NbrLeg / NbrPerLine = float => int(float) + 1 = get number of lines

=cut

  $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLine}
    = $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend}
    / $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine};
  unless (
    int( $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLine} )
    == $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLine} )
  {
    $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLine}
      = int( $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLine} ) + 1;
  }

  # Total Height of Legend
  $CompositeWidget->{RefInfoDummies}->{Legend}{Height}
    = $CompositeWidget->{RefInfoDummies}
    ->{Legend}{HeightTitle}    # Hauteur Titre légende
    + $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLine}
    * $CompositeWidget->{RefInfoDummies}->{Legend}{HLine};

  # Get number legend text max per line to reajust our chart
  if ( $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend}
    < $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine} )
  {
    $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine}
      = $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend};
  }

  return;
}

sub _ViewLegend {
  my ($CompositeWidget) = @_;

  # legend option
  my $LegendTitle        = $CompositeWidget->{RefInfoDummies}->{Legend}{title};
  my $legendmarkercolors = $CompositeWidget->cget( -colordata );
  my $legendfont = $CompositeWidget->{RefInfoDummies}->{Legend}{legendfont};
  my $titlecolor = $CompositeWidget->{RefInfoDummies}->{Legend}{titlecolors};
  my $titlefont  = $CompositeWidget->{RefInfoDummies}->{Legend}{titlefont};

  if ( defined $LegendTitle ) {
    my $xLegendTitle = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin}
      + $CompositeWidget->{RefInfoDummies}->{Legend}{SpaceBeforeCube};
    my $yLegendTitle
      = $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin}
      + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight}
      + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight}
      + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight};

    $CompositeWidget->createText(
      $xLegendTitle, $yLegendTitle,
      -text   => $LegendTitle,
      -anchor => 'nw',
      -font   => $titlefont,
      -fill   => $titlecolor,
      -width  => $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width},
      -tags   => $CompositeWidget->{RefInfoDummies}->{TAGS}{TitleLegend},
    );
  }

  # Display legend
  my $IndexColor  = 0;
  my $IndexLegend = 0;
  $CompositeWidget->{RefInfoDummies}->{Legend}{GetIdLeg} = {};

  for my $NumberLine (
    0 .. $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLine} - 1 )
  {
    my $x1Cube = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin}
      + $CompositeWidget->{RefInfoDummies}->{Legend}{SpaceBeforeCube};
    my $y1Cube
      = ( $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin}
        + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight}
        + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight}
        + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight}
        + $CompositeWidget->{RefInfoDummies}->{Legend}{HeightTitle}
        + $CompositeWidget->{RefInfoDummies}->{Legend}{HLine} / 2 )
      + $NumberLine * $CompositeWidget->{RefInfoDummies}->{Legend}{HLine};

    my $x2Cube = $x1Cube + $CompositeWidget->{RefInfoDummies}->{Legend}{WCube};
    my $y2Cube = $y1Cube - $CompositeWidget->{RefInfoDummies}->{Legend}{HCube};
    my $xText
      = $x2Cube + $CompositeWidget->{RefInfoDummies}->{Legend}{SpaceAfterCube};
    my $yText     = $y2Cube;
    my $MaxLength = $CompositeWidget->{RefInfoDummies}->{Legend}{LengthTextMax};

  LEGEND:
    for my $NumberLegInLine (
      0 .. $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine} - 1 )
    {

      my $LineColor = $legendmarkercolors->[$IndexColor];
      unless ( defined $LineColor ) {
        $IndexColor = 0;
        $LineColor  = $legendmarkercolors->[$IndexColor];
      }

      my $Tag = ( $IndexLegend + 1 )
        . $CompositeWidget->{RefInfoDummies}->{TAGS}{Legend};
      $CompositeWidget->createRectangle(
        $x1Cube, $y1Cube, $x2Cube, $y2Cube,
        -fill    => $LineColor,
        -outline => $LineColor,
        -tags    => $Tag,
      );

      # Cut legend text if too long
      my $Legende = $CompositeWidget->{RefInfoDummies}->{Legend}{DataLegend}
        ->[$IndexLegend];
      my $NewLegend = $Legende;
      
      if ( length $NewLegend > $MaxLength ) {
        $MaxLength -= 3;
        $NewLegend =~ s/^(.{$MaxLength}).*/$1/;
        $NewLegend .= '...';
      }

      my $Id = $CompositeWidget->createText(
        $xText, $yText,
        -text   => $NewLegend,
        -anchor => 'nw',
        -tags   => $Tag,
      );
      if ($legendfont) {
        $CompositeWidget->itemconfigure( $Id, -font => $legendfont, );
      }
      $CompositeWidget->{RefInfoDummies}->{Legend}{GetIdLeg}{$Tag}
        = $IndexLegend;
      $CompositeWidget->{RefInfoDummies}->{Legend}{GetIdLeg}{$Tag}
        = $IndexLegend;

      $IndexColor++;
      $IndexLegend++;

      # cube
      $x1Cube += $CompositeWidget->{RefInfoDummies}->{Legend}{LengthOneLegend};
      $x2Cube += $CompositeWidget->{RefInfoDummies}->{Legend}{LengthOneLegend};

      # Text
      $xText += $CompositeWidget->{RefInfoDummies}->{Legend}{LengthOneLegend};

      my $LineTag
        = $IndexLegend . $CompositeWidget->{RefInfoDummies}->{TAGS}{Line};
      $CompositeWidget->{RefInfoDummies}->{Legend}{MsgBalloon}->{$Tag}
        = $Legende;
      $CompositeWidget->{RefInfoDummies}->{Legend}{MsgBalloon}->{$LineTag}
        = $Legende;

      if ( $IndexLegend
        == $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend} )
      {
        last LEGEND;
      }
    }

  }

  # box legend
  my $x1Box = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin};
  my $y1Box
    = $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight};
  my $x2Box
    = $x1Box
    + ( $CompositeWidget->{RefInfoDummies}->{Legend}{NbrPerLine}
      * $CompositeWidget->{RefInfoDummies}->{Legend}{LengthOneLegend} );

  # Reajuste box if width box < legend title text
  my @InfoLegendTitle = $CompositeWidget->bbox(
    $CompositeWidget->{RefInfoDummies}->{TAGS}{TitleLegend} );
  if ( $InfoLegendTitle[2] and $x2Box <= $InfoLegendTitle[2] ) {
    $x2Box = $InfoLegendTitle[2] + 2;
  }
  my $y2Box = $y1Box + $CompositeWidget->{RefInfoDummies}->{Legend}{Height};
  $CompositeWidget->createRectangle( $x1Box, $y1Box, $x2Box, $y2Box,
    -tags => $CompositeWidget->{RefInfoDummies}->{TAGS}{BoxLegend}, );

  return;
}

sub _title {
  my ($CompositeWidget) = @_;

  my $Title      = $CompositeWidget->cget( -title );
  my $TitleColor = $CompositeWidget->cget( -titlecolor );
  my $TitleFont  = $CompositeWidget->cget( -titlefont );

  # Title verification
  unless ($Title) {
    return;
  }

  # Space before the title
  my $WidthEmptyBeforeTitle
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{WidthEmptySpace}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ScaleValuesWidth}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth};

  # Coordinates title
  $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrex}
    = ( $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width} / 2 )
    + $WidthEmptyBeforeTitle;
  $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrey}
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{HeightEmptySpace}
    + ( $CompositeWidget->{RefInfoDummies}->{Title}{Height} / 2 );

  # -width to createText
  $CompositeWidget->{RefInfoDummies}->{Title}{'-width'}
    = $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width};

  # display title
  $CompositeWidget->{RefInfoDummies}->{Title}{IdTitre}
    = $CompositeWidget->createText(
    $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrex},
    $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrey},
    -text  => $Title,
    -width => $CompositeWidget->{RefInfoDummies}->{Title}{'-width'},
    );

  # get title information
  my ($Height);
  ( $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrex},
    $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrey},
    $CompositeWidget->{RefInfoDummies}->{Title}{Width},
    $Height
    )
    = $CompositeWidget->bbox(
    $CompositeWidget->{RefInfoDummies}->{Title}{IdTitre} );

  if ( $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrey}
    < $CompositeWidget->{RefInfoDummies}->{Canvas}{HeightEmptySpace} )
  {

    # cut title
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{Title}{IdTitre} );

    $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrex}
      = $WidthEmptyBeforeTitle;
    $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrey}
      = $CompositeWidget->{RefInfoDummies}->{Canvas}{HeightEmptySpace}
      + ( $CompositeWidget->{RefInfoDummies}->{Title}{Height} / 2 );

    $CompositeWidget->{RefInfoDummies}->{Title}{'-width'} = 0;

    # display title
    $CompositeWidget->{RefInfoDummies}->{Title}{IdTitre}
      = $CompositeWidget->createText(
      $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrex},
      $CompositeWidget->{RefInfoDummies}->{Title}{Ctitrey},
      -text   => $Title,
      -width  => $CompositeWidget->{RefInfoDummies}->{Title}{'-width'},
      -anchor => 'nw',

      );
  }

  $CompositeWidget->itemconfigure(
    $CompositeWidget->{RefInfoDummies}->{Title}{IdTitre},
    -font => $TitleFont,
    -fill => $TitleColor,
  );
  return;
}

sub _axis {
  my ($CompositeWidget) = @_;

  # x axis width
  $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width}
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{Width}
    - ( 2 * $CompositeWidget->{RefInfoDummies}->{Canvas}{WidthEmptySpace}
      + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth}
      + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ScaleValuesWidth}
      + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth} );

  # get Height legend
  if ( $CompositeWidget->{RefInfoDummies}->{Legend}{DataLegend} ) {
    $CompositeWidget->_Legend(
      $CompositeWidget->{RefInfoDummies}->{Legend}{DataLegend} );
  }

  # Height y axis
  $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Height}
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{Height}    # Largeur canvas
    - (
    2
      * $CompositeWidget->{RefInfoDummies}
      ->{Canvas}{HeightEmptySpace}    # 2 fois les espace vides
      + $CompositeWidget->{RefInfoDummies}->{Title}{Height}   # Hauteur du titre
      + $CompositeWidget->{RefInfoDummies}
      ->{Axis}{Xaxis}{TickHeight}    # Hauteur tick (axe x)
      + $CompositeWidget->{RefInfoDummies}
      ->{Axis}{Xaxis}{ScaleValuesHeight}    # Hauteur valeurs axe
      + $CompositeWidget->{RefInfoDummies}
      ->{Axis}{Xaxis}{xlabelHeight}                           # Hauteur x label
      + $CompositeWidget->{RefInfoDummies}->{Legend}{Height}  # Hauteur légende
    );

  #===========================
  # Y axis
  # Set 2 points (CxMin, CyMin) et (CxMin, CyMax)
  $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin}    # Coordonnées CxMin
    = $CompositeWidget->{RefInfoDummies}
    ->{Canvas}{WidthEmptySpace}                        # Largeur vide
    + $CompositeWidget->{RefInfoDummies}
    ->{Axis}{Yaxis}{ylabelWidth}                       # Largeur label y
    + $CompositeWidget->{RefInfoDummies}
    ->{Axis}{Yaxis}{ScaleValuesWidth}                  # Largeur valeur axe y
    + $CompositeWidget->{RefInfoDummies}
    ->{Axis}{Yaxis}{TickWidth};                        # Largeur tick axe y

  $CompositeWidget->{RefInfoDummies}->{Axis}{CyMax}         # Coordonnées CyMax
    = $CompositeWidget->{RefInfoDummies}
    ->{Canvas}{HeightEmptySpace}                            # Hauteur vide
    + $CompositeWidget->{RefInfoDummies}->{Title}{Height}   # Hauteur titre
    ;

  $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin}  # Coordonnées CyMin
    = $CompositeWidget->{RefInfoDummies}
    ->{Axis}{CyMax}                                  # Coordonnées CyMax (haut)
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Height}  # Hauteur axe Y
    ;

  # display Y axis
  $CompositeWidget->createLine(
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMax},
    -tags => [
      $CompositeWidget->{RefInfoDummies}->{TAGS}{yAxis},
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllAXIS}
    ],
  );

  #===========================
  # X axis
  # Set 2 points (CxMin,CyMin) et (CxMax,CyMin)
  # ou (Cx0,Cy0) et (CxMax,Cy0)
  $CompositeWidget->{RefInfoDummies}->{Axis}{CxMax}        # Coordonnées CxMax
    = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin}    # Coordonnées CxMin
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width}   # Largeur axe x
    ;

  # Bottom x axis
  $CompositeWidget->createLine(
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMax},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin},
    -tags => [
      $CompositeWidget->{RefInfoDummies}->{TAGS}{xAxis},
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllAXIS}
    ],
  );

  # POINT (0,0)
  # min positive value >= 0
  if ( $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} >= 0 ) {
    $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
      = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin};
    $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0}
      = $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin};

    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{HeightUnit}
      = $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Height}
      / ( $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue} - 0 );
  }

  # min positive value < 0
  else {

    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{HeightUnit}
      = $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Height}
      / ( $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue}
        - $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} );
    $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
      = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin};
    $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0}
      = $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin}
      + ( $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{HeightUnit}
        * $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} );

    # X Axis (0,0)
    $CompositeWidget->createLine(
      $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0},
      $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0},
      $CompositeWidget->{RefInfoDummies}->{Axis}{CxMax},
      $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0},
      -tags => [
        $CompositeWidget->{RefInfoDummies}->{TAGS}{xAxis0},
        $CompositeWidget->{RefInfoDummies}->{TAGS}{AllAXIS}
      ],
    );
  }

  return;
}

sub _box {
  my ($CompositeWidget) = @_;

  # close axis
  # X axis 2
  $CompositeWidget->createLine(
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMax},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMax},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMax},
    -tags => [
      $CompositeWidget->{RefInfoDummies}->{TAGS}{BoxAxis},
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllAXIS}
    ],
  );

  # Y axis 2
  $CompositeWidget->createLine(
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMax},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMax},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMax},
    -tags => [
      $CompositeWidget->{RefInfoDummies}->{TAGS}{BoxAxis},
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllAXIS}
    ],
  );

  return;
}

sub _xtick {
  my ($CompositeWidget) = @_;

  my $xvaluecolor = $CompositeWidget->cget( -xvaluecolor );

  # x coordinates y ticks on bottom x axis
  my $Xtickx1 = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin};
  my $Xticky1 = $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin};

  # x coordinates y ticks on 0,0 x axis if the chart have only y value < 0
  if (  $CompositeWidget->cget( -zeroaxisonly ) == 1
    and $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue} > 0 )
  {
    $Xticky1 = $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0};
  }

  my $Xtickx2 = $Xtickx1;
  my $Xticky2
    = $Xticky1 + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight};

  # Coordinates of x values (first value)
  my $XtickxValue = $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin};
  my $XtickyValue
    = $Xticky2
    + (
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight} / 2 );
  my $NbrLeg
    = scalar( @{ $CompositeWidget->{RefInfoDummies}->{Data}{RefXLegend} } );

  my $xlabelskip = $CompositeWidget->cget( -xlabelskip );

  # index of tick and vlaues that will be skip
  my %IndiceToSkip;
  if ( defined $xlabelskip ) {
    for ( my $i = 1; $i <= $NbrLeg; $i++ ) {
      $IndiceToSkip{$i} = 1;
      $i += $xlabelskip;
    }
  }

  for ( my $Indice = 1; $Indice <= $NbrLeg; $Indice++ ) {
    my $data
      = $CompositeWidget->{RefInfoDummies}->{Data}{RefXLegend}->[ $Indice - 1 ];

    # tick
    $Xtickx1
      += $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{SpaceBetweenTick};
    $Xtickx2 = $Xtickx1;

    # tick legend
    $XtickxValue
      += $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{SpaceBetweenTick};
    my $RegexXtickselect = $CompositeWidget->cget( -xvaluesregex );

    if ( $data =~ m{$RegexXtickselect} ) {
      next unless ( defined $IndiceToSkip{$Indice} );
      $CompositeWidget->createLine(
        $Xtickx1, $Xticky1, $Xtickx2, $Xticky2,
        -tags => [
          $CompositeWidget->{RefInfoDummies}->{TAGS}{xTick},
          $CompositeWidget->{RefInfoDummies}->{TAGS}{AllTick}
        ],
      );
      $CompositeWidget->createText(
        $XtickxValue,
        $XtickyValue,
        -text => $data,
        -fill => $xvaluecolor,
        -tags => [
          $CompositeWidget->{RefInfoDummies}->{TAGS}{xValues},
          $CompositeWidget->{RefInfoDummies}->{TAGS}{AllValues}
        ],
      );
    }
  }

  return;
}

sub _ytick {
  my ($CompositeWidget) = @_;

  $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickNumber}
    = $CompositeWidget->cget( -yticknumber );

  # space between y ticks
  my $Space = $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Height}
    / $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickNumber};
  my $UnitValue
    = ( $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue}
      - $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} )
    / $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickNumber};

  for my $TickNumber (
    1 .. $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickNumber} )
  {

    # Display y ticks
    my $Ytickx1 = $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0};
    my $Yticky1 = $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin}
      - ( $TickNumber * $Space );
    my $Ytickx2 = $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
      - $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth};
    my $Yticky2 = $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin}
      - ( $TickNumber * $Space );

    my $YValuex
      = $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
      - ( $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth}
        + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ScaleValuesWidth}
        / 2 );
    my $YValuey = $Yticky1;
    my $Value   = $UnitValue * $TickNumber
      + $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue};
    next if ( $Value == 0 );

    # round value if to long
    if ( $Value > 1000000 or length $Value > 7 ) {
      $Value = _roundValue($Value);
    }
    $CompositeWidget->createLine(
      $Ytickx1, $Yticky1, $Ytickx2, $Yticky2,
      -tags => [
        $CompositeWidget->{RefInfoDummies}->{TAGS}{yTick},
        $CompositeWidget->{RefInfoDummies}->{TAGS}{AllTick}
      ],
    );
    $CompositeWidget->createText(
      $YValuex, $YValuey,
      -text => $Value,
      -fill => $CompositeWidget->cget( -yvaluecolor ),
      -tags => [
        $CompositeWidget->{RefInfoDummies}->{TAGS}{yValues},
        $CompositeWidget->{RefInfoDummies}->{TAGS}{AllValues}
      ],
    );

  }

  # Display 0 value
  unless ( $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} == 0 ) {
    $CompositeWidget->createText(
      $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
        - ( $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth} ),
      $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0},
      -text => 0,
      -tags => [
        $CompositeWidget->{RefInfoDummies}->{TAGS}{xValue0},
        $CompositeWidget->{RefInfoDummies}->{TAGS}{AllValues}
      ],
    );
  }

  # Display the minimale value
  $CompositeWidget->createText(
    $CompositeWidget->{RefInfoDummies}->{Axis}{CxMin} - (
          $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth}
        + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ScaleValuesWidth}
        / 2
    ),
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin},
    -text =>
      _roundValue( $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} ),
    -fill => $CompositeWidget->cget( -yvaluecolor ),
    -tags => [
      $CompositeWidget->{RefInfoDummies}->{TAGS}{yValues},
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllValues}
    ],
  );

  $CompositeWidget->createLine(
    $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin} - $Space,
    $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
      - $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth},
    $CompositeWidget->{RefInfoDummies}->{Axis}{CyMin} - $Space,
    -tags => [
      $CompositeWidget->{RefInfoDummies}->{TAGS}{yTick},
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllTick}
    ],
  );

  return;
}

sub _ViewData {
  my ($CompositeWidget) = @_;

  my $legendmarkercolors = $CompositeWidget->cget( -colordata );
  my $viewsection        = $CompositeWidget->cget( -viewsection );

  # number of value for x axis
  $CompositeWidget->{RefInfoDummies}->{Data}{xtickNumber}
    = $CompositeWidget->{RefInfoDummies}->{Data}{NumberXValues};

  # Space between x ticks
  $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{SpaceBetweenTick}
    = $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width}
    / ( $CompositeWidget->{RefInfoDummies}->{Data}{xtickNumber} + 1 );

  my $IdData     = 0;
  my $IndexColor = 0;
  foreach my $RefArrayData (
    @{ $CompositeWidget->{RefInfoDummies}->{Data}{RefAllData} } )
  {
    if ( $IdData == 0 ) {
      $IdData++;
      next;
    }
    my $NumberData = 1;    # Number of data
    my @PointsData;        # coordinate x and y
    my @DashPointsxLines;

    # First point, in x axis
    my $Fisrtx = $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
      + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{SpaceBetweenTick};
    my $Fisrty = $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0};
    push( @PointsData, ( $Fisrtx, $Fisrty ) );

    foreach my $data ( @{$RefArrayData} ) {
      unless ( defined $data ) {
        $NumberData++;
        next;
      }

      # coordinates x and y values
      my $x
        = $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
        + $NumberData
        * $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{SpaceBetweenTick};
      my $y
        = $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0}
        - (
        $data * $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{HeightUnit} );

      push( @PointsData, ( $x, $y ) );

      push( @DashPointsxLines, $x, $y );
      $NumberData++;

    }

    # Last point, in x axis
    my $Lastx
      = $CompositeWidget->{RefInfoDummies}->{Axis}{Cx0}
      + ( $NumberData - 1 )
      * $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{SpaceBetweenTick};

    my $Lastty = $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0};
    push( @PointsData, ( $Lastx, $Lastty ) );

    my $LineColor = $legendmarkercolors->[$IndexColor];
    unless ( defined $LineColor ) {
      $IndexColor = 0;
      $LineColor  = $legendmarkercolors->[$IndexColor];
    }
    my $tag = $IdData . $CompositeWidget->{RefInfoDummies}->{TAGS}{Line};

    $CompositeWidget->createPolygon(
      @PointsData,
      -fill    => $LineColor,
      -tags    => [ $tag, $CompositeWidget->{RefInfoDummies}->{TAGS}{AllData} ],
      -width   => $CompositeWidget->cget( -linewidth ),
      -outline => "black",
    );

    # display Dash line
    if ( defined $viewsection and $viewsection == 1 ) {
      for ( my $i = 0; $i < scalar(@DashPointsxLines); $i++ ) {
        my $IndexX1 = $i;
        my $IndexY1 = $i + 1;
        my $IndexX2 = $i;
        $CompositeWidget->createLine(
          $DashPointsxLines[$IndexX1],
          $DashPointsxLines[$IndexY1],
          $DashPointsxLines[$IndexX2],
          $CompositeWidget->{RefInfoDummies}->{Axis}{Cy0},
          -dash => ".",
          -tags => [
            $tag,
            $CompositeWidget->{RefInfoDummies}->{TAGS}{AllData},
            $CompositeWidget->{RefInfoDummies}->{TAGS}{DashLines},
          ],
        );
        $i++;
      }
    }

    $CompositeWidget->{RefInfoDummies}{Line}{$tag}{color} = $LineColor;

    $IdData++;
    $IndexColor++;
  }

  return 1;
}

sub plot {
  my ( $CompositeWidget, $RefData, %option ) = @_;

  my $yticknumber = $CompositeWidget->cget( -yticknumber );

  if ( defined $option{-substitutionvalue}
    and _isANumber( $option{-substitutionvalue} ) )
  {
    $CompositeWidget->{RefInfoDummies}->{Data}{SubstitutionValue}
      = $option{-substitutionvalue};
  }

  unless ( defined $RefData ) {
    $CompositeWidget->_error("data not defined");
    return;
  }

  unless ( scalar @{$RefData} > 1 ) {
    $CompositeWidget->_error("You must have at least 2 arrays");
    return;
  }

  # Check legend and data size
  if ( my $RefLegend
    = $CompositeWidget->{RefInfoDummies}->{Legend}{DataLegend} )
  {
    $CompositeWidget->_CheckSizeLengendAndData( $RefData, $RefLegend );
  }

  # Check array size
  $CompositeWidget->{RefInfoDummies}->{Data}{NumberXValues}
    = scalar @{ $RefData->[0] };
  my $i = 0;
  foreach my $RefArray ( @{$RefData} ) {
    unless (
      scalar @{$RefArray}
      == $CompositeWidget->{RefInfoDummies}->{Data}{NumberXValues} )
    {
      $CompositeWidget->_error(
        "Make sure that every array has the same size in plot data method", 1 );
      return;
    }

    # Get min and max size
    if ( $i != 0 ) {

      # substitute none real value
      foreach my $data ( @{$RefArray} ) {
        if ( defined $data and !_isANumber($data) ) {
          $data = $CompositeWidget->{RefInfoDummies}->{Data}{SubstitutionValue};
        }
      }

      $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue} = _MaxArray(
        [ $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue},
          _MaxArray($RefArray)
        ]
      );
      $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} = _MinArray(
        [ $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue},
          _MinArray($RefArray)
        ]
      );
    }
    $i++;
  }
  $CompositeWidget->{RefInfoDummies}->{Data}{RefXLegend}  = $RefData->[0];
  $CompositeWidget->{RefInfoDummies}->{Data}{RefAllData}  = $RefData;
  $CompositeWidget->{RefInfoDummies}->{Data}{PlotDefined} = 1;

  if ( $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} > 0 ) {
    $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} = 0;
  }

  while (
    ( $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue} / $yticknumber ) % 5
    != 0 )
  {
    $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue}
      = int( $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue} + 1 );
  }

  $CompositeWidget->_GraphForDummiesConstruction;
  return 1;
}

sub _GraphForDummiesConstruction {
  my ($CompositeWidget) = @_;

  unless ( defined $CompositeWidget->{RefInfoDummies}->{Data}{PlotDefined} ) {
    return;
  }

  $CompositeWidget->clearchart();
  $CompositeWidget->_TreatParameters();

  # Height and Width canvas
  $CompositeWidget->{RefInfoDummies}->{Canvas}{Width} = $CompositeWidget->width;
  $CompositeWidget->{RefInfoDummies}->{Canvas}{Height}
    = $CompositeWidget->height;

  $CompositeWidget->_axis();
  $CompositeWidget->_box();
  $CompositeWidget->_YLabelPosition();
  $CompositeWidget->_XLabelPosition();
  $CompositeWidget->_title();
  $CompositeWidget->_ViewData();
  unless ( $CompositeWidget->cget( -noaxis ) == 1 ) {
    $CompositeWidget->_xtick();
    $CompositeWidget->_ytick();
  }

  if ( $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend} > 0 ) {
    $CompositeWidget->_ViewLegend();
    $CompositeWidget->_Balloon();
  }

  # If Y value < 0, don't display O x axis
  if ( $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue} < 0 ) {
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{xAxis0} );
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{xValue0} );
  }

  # Axis
  if ( $CompositeWidget->cget( -boxaxis ) == 0 ) {
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{BoxAxis} );
  }
  if ( $CompositeWidget->cget( -noaxis ) == 1 ) {
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllAXIS} );
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllTick} );
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{AllValues} );
  }
  if (  $CompositeWidget->cget( -zeroaxisonly ) == 1
    and $CompositeWidget->{RefInfoDummies}->{Data}{MaxYValue} > 0
    and $CompositeWidget->{RefInfoDummies}->{Data}{MinYValue} < 0 )
  {
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{xAxis} );
  }
  if ( $CompositeWidget->cget( -zeroaxis ) == 1 ) {
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{xAxis0} );
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{xTick} );
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{xValues} );
  }

  # ticks
  my $alltickview = $CompositeWidget->cget( -alltickview );
  if ( defined $alltickview ) {
    if ( $alltickview == 0 ) {
      $CompositeWidget->delete(
        $CompositeWidget->{RefInfoDummies}->{TAGS}{AllTick} );
    }
    else {
      $CompositeWidget->configure( -ytickview => 1 );
      $CompositeWidget->configure( -xtickview => 1 );
    }
  }
  else {
    if ( $CompositeWidget->cget( -xtickview ) == 0 ) {
      $CompositeWidget->delete(
        $CompositeWidget->{RefInfoDummies}->{TAGS}{xTick} );
    }
    if ( $CompositeWidget->cget( -ytickview ) == 0 ) {
      $CompositeWidget->delete(
        $CompositeWidget->{RefInfoDummies}->{TAGS}{yTick} );
    }
  }

  # Legend
  if ( $CompositeWidget->{RefInfoDummies}->{Legend}{box} == 0 ) {
    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{TAGS}{BoxLegend} );
  }

  return 1;
}

sub _XLabelPosition {
  my ($CompositeWidget) = @_;

  my $xlabel = $CompositeWidget->cget( -xlabel );

  # no x_label
  unless ( defined $xlabel ) {
    return;
  }

  # coordinate (CxlabelX, CxlabelY)
  my $BeforexlabelX
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{WidthEmptySpace}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ScaleValuesWidth}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth};
  my $BeforexlabelY
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{HeightEmptySpace}
    + $CompositeWidget->{RefInfoDummies}->{Title}{Height}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Height}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight}
    + $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight};

  $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelX} = $BeforexlabelX
    + ( $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width} / 2 );
  $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelY} = $BeforexlabelY
    + ( $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight} / 2 );

  # display xlabel
  $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Idxlabel}
    = $CompositeWidget->createText(
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelX},
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelY},
    -text  => $xlabel,
    -width => $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Width},
    );

  # get info ylabel xlabel
  my ( $width, $Height );
  ( $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelX},
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelY},
    $width, $Height
    )
    = $CompositeWidget->bbox(
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Idxlabel} );

  if ( $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelY}
    < $BeforexlabelY )
  {

    $CompositeWidget->delete(
      $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Idxlabel} );

    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelX}
      = $BeforexlabelX;
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelY} = $BeforexlabelY
      + ( $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight} / 2 );

    # display xlabel
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Idxlabel}
      = $CompositeWidget->createText(
      $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelX},
      $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{CxlabelY},
      -text   => $xlabel,
      -width  => 0,
      -anchor => 'nw',
      );
  }

  $CompositeWidget->itemconfigure(
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{Idxlabel},
    -font => $CompositeWidget->cget( -xlabelfont ),
    -fill => $CompositeWidget->cget( -xlabelcolor ),
  );

  return;
}

sub _YLabelPosition {
  my ($CompositeWidget) = @_;

  my $ylabel = $CompositeWidget->cget( -ylabel );

  # no y_label
  unless ( defined $ylabel ) {
    return;
  }

  # coordinate (CylabelX, CylabelY)
  $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{CylabelX}
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{WidthEmptySpace}
    + ( $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth} / 2 );
  $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{CylabelY}
    = $CompositeWidget->{RefInfoDummies}->{Canvas}{HeightEmptySpace}
    + $CompositeWidget->{RefInfoDummies}->{Title}{Height}
    + ( $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Height} / 2 );

  # display ylabel
  $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Idylabel}
    = $CompositeWidget->createText(
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{CylabelX},
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{CylabelY},
    -text  => $ylabel,
    -font  => $CompositeWidget->cget( -ylabelfont ),
    -width => $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth},
    -fill  => $CompositeWidget->cget( -ylabelcolor ),
    );

  # get info ylabel
  my ( $Width, $Height );
  ( $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{CylabelX},
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{CylabelY},
    $Width, $Height
    )
    = $CompositeWidget->bbox(
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{Idylabel} );

  return;
}

sub redraw {
  my ($CompositeWidget) = @_;

  $CompositeWidget->_GraphForDummiesConstruction;
  return;
}

sub add_data {
  my ( $CompositeWidget, $Refdata, $legend ) = @_;

  push( @{ $CompositeWidget->{RefInfoDummies}->{Data}{RefAllData} }, $Refdata );
  if ( $CompositeWidget->{RefInfoDummies}->{Legend}{NbrLegend} > 0 ) {
    push @{ $CompositeWidget->{RefInfoDummies}->{Legend}{DataLegend} }, $legend;
  }

  $CompositeWidget->plot(
    $CompositeWidget->{RefInfoDummies}->{Data}{RefAllData} );

  return;
}

sub delete_balloon {
  my ($CompositeWidget) = @_;

  $CompositeWidget->{RefInfoDummies}->{Balloon}{State} = 0;
  $CompositeWidget->_Balloon();

  return;
}

sub set_balloon {
  my ( $CompositeWidget, %options ) = @_;

  $CompositeWidget->{RefInfoDummies}->{Balloon}{State} = 1;

  if ( defined $options{-colordatamouse} ) {
    if ( scalar @{ $options{-colordatamouse} } < 2 ) {
      $CompositeWidget->_error(
        "Can't set -colordatamouse, you have to set 2 colors\n"
          . "Ex : -colordatamouse => ['red','green'],",
        1
      );
    }
    else {
      $CompositeWidget->{RefInfoDummies}->{Balloon}{ColorData}
        = $options{-colordatamouse};
    }
  }
  if ( defined $options{-morepixelselected} ) {
    $CompositeWidget->{RefInfoDummies}->{Balloon}{MorePixelSelected}
      = $options{-morepixelselected};
  }
  if ( defined $options{-background} ) {
    $CompositeWidget->{RefInfoDummies}->{Balloon}{Background}
      = $options{-background};
  }

  $CompositeWidget->_Balloon();

  return;
}

1;
__END__


=head1 NAME

Tk::ForDummies::Graph::Areas - Extension of Canvas widget to create area lines chart. 

=head1 SYNOPSIS

  #!/usr/bin/perl
  use strict;
  use warnings;
  use Tk;
  use Tk::ForDummies::Graph::Areas;

  my $mw = new MainWindow(
    -title      => 'Tk::ForDummies::Graph::Areas example',
    -background => 'white',
  );

  my $GraphDummies = $mw->Areas(
    -title  => 'My Area chart title',
    -xlabel => 'X Label',
    -ylabel => 'Y Label',
    -linewidth => 1,

  )->pack(qw / -fill both -expand 1 /);

  my @data = ( 
      ["1st","2nd","3rd","4th","5th","6th","7th", "8th", "9th"],
      [    5,   12,   24,   33,   19,    8,    6,    15,    21],
      [   -1,   -2,   -5,   -6,   -3,  1.5,    1,   1.3,     2]
  );

  # Add a legend to the chart
  my @Legends = ( 'legend 1', 'legend 2', );
  $GraphDummies->set_legend(
    -title       => "Title legend",
    -data        => \@Legends,
    -titlecolors => "blue",
  );

  # Add help identification
  $GraphDummies->set_balloon();

  # Create the chart
  $GraphDummies->plot( \@data );

  MainLoop();

=head1 DESCRIPTION

Tk::ForDummies::Graph::Areas is an extension of the Canvas widget. It is an easy way to build an 
interactive Area line graph into your Perl Tk widget. The module is written entirely in Perl/Tk.

You can change the color, font of title, labels (x and y) of the chart.
You can set an interactive legend.  
The axes can be automatically scaled or set by the code. 
With this module it is possible to plot quantitative variables according to qualitative variables.

When the mouse cursor passes over a plotted line or its entry in the legend, 
the line and its entry will be turned to a color (that you can change) to help identify it. 

=head1 STANDARD OPTIONS

B<-background>          B<-borderwidth>	      B<-closeenough>	         B<-confine>
B<-cursor>	            B<-height>	          B<-highlightbackground>	 B<-highlightcolor>
B<-highlightthickness>	B<-insertbackground>  B<-insertborderwidth>    B<-insertofftime>	
B<-insertontime>        B<-insertwidth>       B<-relief>               B<-scrollregion> 
B<-selectbackground>    B<-selectborderwidth> B<-selectforeground>     B<-takefocus> 
B<-width>               B<-xscrollcommand>    B<-xscrollincrement>     B<-yscrollcommand> 
B<-yscrollincrement>

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item Name:	B<Viewsection>

=item Class:	B<ViewSection>

=item Switch:	B<-viewsection>

If set to true value, We will see area sections separate by dash lines.

 -viewsection => 0, # 0 or 1

Default : B<1>

=back

=head1 WIDGET-SPECIFIC OPTIONS like Tk::ForDummies::Graph::Areas

Many options allow you to configure your chart as you want. 
The default configuration have already OK, but you can change it.

=over 4

=item Name:	B<Title>

=item Class:	B<Title>

=item Switch:	B<-title>

Title of your graph.
  
 -title => "My graph title",

Default : B<undef>

=item Name:	B<Titlecolor>

=item Class:	B<TitleColor>

=item Switch:	B<-titlecolor>

Title color of your graph.
  
 -titlecolor => "red",

Default : B<black>

=item Name:	B<Titlefont>

=item Class:	B<TitleFont>

=item Switch:	B<-titlefont>

Set the font for the title text. See also textfont option. 
  
 -titlefont => "Times 15 {normal}",

Default : B<{Times} 12 {bold}>

=item Name:	B<Titleheight>

=item Class:	B<TitleHeight>

=item Switch:	B<-titleheight>

Height for title graph space.
  
 -titleheight => 100,

Default : B<40>

=item Name:	B<Xlabel>

=item Class:	B<XLabel>

=item Switch:	B<-xlabel>

The label to be printed just below the x axis.
  
 -xlabel => "X label",

Default : B<undef>

=item Name:	B<Xlabelcolor>

=item Class:	B<XLabelColor>

=item Switch:	B<-xlabelcolor>

Set x label color. See also textcolor option.

 -xlabelcolor => "red",

Default : B<black>

=item Name:	B<Xlabelfont>

=item Class:	B<XLabelFont>

=item Switch:	B<-xlabelfont>

Set the font for the x label text. See also textfont option.
  
 -xlabelfont => "Times 15 {normal}",

Default : B<{Times} 10 {bold}>

=item Name:	B<Xlabelheight>

=item Class:	B<XLabelHeight>

=item Switch:	B<-xlabelheight>

Height for x label space.
  
 -xlabelheight => 50,

Default : B<30>

=item Name:	B<Xlabelskip>

=item Class:	B<XLabelSkip>

=item Switch:	B<-xlabelskip>

Print every xlabelskip number under the tick on the x axis. If you have a dataset wich contain many points, 
the tick and x values will be overwrite on the chart. This option can help you to clarify your chart.
Eg: 
  
  ["leg1", "leg2", ..."leg1000", "data1", ... "data1000"] => 2000 ticks and text values on x axis.
  -xlabelskip => 1 => ["leg1", "leg3", "leg5", ...] => 1000 ticks will be display.

See also xvaluesregex option.

 -xlabelskip => 2,

Default : B<0>

=item Name:	B<Xvaluecolor>

=item Class:	B<XValueColor>

=item Switch:	B<-xvaluecolor>

Set x values colors. See also textcolor option.
 
 -xvaluecolor => "red",

Default : B<black>

=item Name:	B<Xvaluespace>

=item Class:	B<XValueSpace>

=item Switch:	B<-xvaluespace>

Width for x values space.
 
 -xvaluespace => 50,

Default : B<30>

=item Name:	B<Xvaluesregex>

=item Class:	B<XValuesRegex>

=item Switch:	B<-xvaluesregex>

View the x values which will match with regex. It allows you to display tick on x axis and values 
that you want. You can combine it with -xlabelskip to perform what you want to display if you have many dataset.

 
 ...
 ["leg1", "leg2", "data1", "data2", "symb1", "symb2"]
 ...
 
 -xvaluesregex => qr/leg/i,

On the graph, just leg1 and leg2 will be display.

Default : B<qr/.+/>

=item Name:	B<Ylabel>

=item Class:	B<YLabel>

=item Switch:	B<-ylabel>

The labels to be printed next to y axis.
 
 -ylabel => "Y label",

Default : B<undef>

=item Name:	B<Ylabelcolor>

=item Class:	B<YLabelColor>

=item Switch:	B<-ylabelcolor>

Set the color of y label. See also textcolor option. 
 
 -ylabelcolor => 'red',

Default : B<black>

=item Name:	B<Ylabelfont>

=item Class:	B<YLabelFont>

=item Switch:	B<-ylabelfont>

Set the font for the y label text. See also textfont option. 
 
 -ylabelfont => "Times 15 {normal}",

Default : B<{Times} 10 {bold}>

=item Name:	B<Ylabelwidth>

=item Class:	B<YLabelWidth>

=item Switch:	B<-ylabelwidth>

Width of space for y label.
 
 -ylabelwidth => 30,

Default : B<5>

=item Name:	B<Yvaluecolor>

=item Class:	B<YValueColor>

=item Switch:	B<-yvaluecolor>

Set the color of y values. See also valuecolor option.
 
 -yvaluecolor => "red",

Default : B<black>

=item Name:	B<Labelscolor>

=item Class:	B<LabelsColor>

=item Switch:	B<-labelscolor>

Combine xlabelcolor and ylabelcolor options. See also textcolor option.
 
 -labelscolor => "red",

Default : B<undef>

=item Name:	B<Valuescolor>

=item Class:	B<ValuesColor>

=item Switch:	B<-valuescolor>

Set the color of x, y values in axis. It combines xvaluecolor and yvaluecolor options.
 
 -valuescolor => "red",

Default : B<undef>

=item Name:	B<Textcolor>

=item Class:	B<TextColor>

=item Switch:	B<-textcolor>

Set the color of x, y labels and title text. It combines titlecolor, xlabelcolor and ylabelcolor options.
 
 -textcolor => "red",

Default : B<undef>

=item Name:	B<Textfont>

=item Class:	B<TextFont>

=item Switch:	B<-textfont>

Set the font of x, y labels and title text. It combines titlefont, xlabelfont and ylabelfont options.
 
 -textfont => "Times 15 {normal}",

Default : B<undef>


=item Name:	B<Boxaxis>

=item Class:	B<BoxAxis>

=item Switch:	B<-boxaxis>

Draw the axes as a box.
 
 -boxaxis => 0, #  0 or 1

Default : B<1>

=item Name:	B<Noaxis>

=item Class:	B<NoAxis>

=item Switch:	B<-noaxis>

Hide the axis with ticks and values ticks.
 
 -noaxis => 1, # 0 or 1

Default : B<0>

=item Name:	B<Zeroaxisonly>

=item Class:	B<ZeroAxisOnly>

=item Switch:	B<-zeroaxisonly>

If set to a true value, the zero x axis will be drawn and no axis 
at the bottom of the graph will be drawn. 
The labels for X values will be placed on the zero x axis.
This works if there is at least one negative value in dataset.

 -zeroaxisonly => 1, # 0 or 1

Default : B<0>

=item Name:	B<Zeroaxis>

=item Class:	B<ZeroAxis>

=item Switch:	B<-zeroaxis>

If set to a true value, the axis for y values of 0 will always be drawn. 

 -zeroaxis => 0, # 0 or 1

Default : B<1>

=item Name:	B<Xtickheight>

=item Class:	B<XTickHeight>

=item Switch:	B<-xtickheight>

Set height of all x ticks.

 -xtickheight => 10,

Default : B<5>

=item Name:	B<Xtickview>

=item Class:	B<XTickView>

=item Switch:	B<-xtickview>

View x ticks of graph.
 
 -xtickview => 0, # 0 or 1

Default : B<1>

=item Name:	B<Yticknumber>

=item Class:	B<YTickNumber>

=item Switch:	B<-yticknumber>

Number of ticks to print for the Y axis.
 
 -yticknumber => 10,

Default : B<4>

=item Name:	B<Ytickwidth>

=item Class:	B<YtickWidth>

=item Switch:	B<-ytickwidth>

Set width of all y ticks.
 
 -ytickwidth => 10,

Default : B<5>

=item Name:	B<Ytickview>

=item Class:	B<YTickView>

=item Switch:	B<-ytickview>

View y ticks of graph.
 
 -ytickview => 0, # 0 or 1

Default : B<1>

=item Name:	B<Alltickview>

=item Class:	B<AllTickView>

=item Switch:	B<-alltickview>

View all ticks of graph. Combines xtickview and ytickview options;
 
 -alltickview => 0, # 0 or 1

Default : B<undef>

=item Name:	B<Linewidth>

=item Class:	B<LineWidth>

=item Switch:	B<-linewidth>

Set width of all lines graph of dataset.
 
 -linewidth => 10,

Default : B<1>

=item Name:	B<Colordata>

=item Class:	B<ColorData>

=item Switch:	B<-colordata>

This controls the colors of the lines. This should be a reference to an array of color names.
 
 -colordata => [ qw(green pink blue cyan) ],

Default : 

  [ 'red',     'green',   'blue',    'yellow',  'purple',  'cyan',
    '#996600', '#99A6CC', '#669933', '#929292', '#006600', '#FFE100',
    '#00A6FF', '#009060', '#B000E0', '#A08000', 'orange',  'brown',
    'black',   '#FFCCFF', '#99CCFF', '#FF00CC', '#FF8000', '#006090',
  ],

The default array contains 24 colors. If you have more than 24 samples, the next line 
will have the color of the first array case (red).

=back

=head1 WIDGET METHODS

The Canvas method creates a widget object. This object supports the 
configure and cget methods described in Tk::options which can be used 
to enquire and modify the options described above. 

=head2 add_data

=over 4

=item I<$GraphDummies>->B<add_data>(I<\@NewData, ?$legend>)

This method allows you to add data in your chart. If you have already plot data using plot method and 
if you want to add new data, you can use this method.
Your chart will be updade.

=back

=over 8

=item *

I<Data array reference>

Fill an array of arrays with the values of the datasets (I<\@data>). 
Make sure that every array has the same size, otherwise Tk::ForDummies::Graph::Areas 
will complain and refuse to compile the graph.

 my @NewData = (1,10,12,5,4);
 $GraphDummies>->(\@NewData);

If your last chart has a legend, you have to add a legend entry for the new dataset. Otherwise, 
the legend chart will not be display (see below).

=item *

I<$legend>

 my @NewData = (1,10,12,5,4);
 my $legend = "New data set";
 $GraphDummies>->(\@NewData, $legend);
  

=back

=head2 clearchart

=over 4

=item I<$GraphDummies>->B<clearchart>

This method allows you to clear the chart. The canvas 
will not be destroy. It's possible to I<redraw> your 
last chart using the I<redraw method>.

=back

=head2 delete_balloon

=over 4

=item I<$GraphDummies>->B<delete_balloon>

If you call this method, you disable help identification which has been enabled with set_balloon method.

=back

=head2 plot

=over 4

=item I<$GraphDummies>->B<plot>(I<\@data, ?arg>)

To display your chart the first time, plot the chart by using this method.

=back

=over 8

=item *

I<\@data>

Fill an array of arrays with the x values and the values of the datasets (I<\@data>). 
Make sure that every array have the same size, otherwise Tk::ForDummies::Graph::Areas 
will complain and refuse to compile the graph.

 my @data = (
     [ '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th' ],
     [ 1,     2,     5,     6,     3,     1.5,   1,     3,     4  ],
     [ 4,     2,     5,     2,     3,     5.5,   7,     9,     4  ],
     [ 1,     2,     52,    6,     3,     17.5,  1,     43,    10 ]
 );

@data have to contain a least two arrays, the x values and the values of the datasets.

If you don't have a value for a point in a dataset, you can use undef, 
and the point will be skipped.

 [ 1,     undef,     5,     6,     3,     1.5,   undef,     3,     4 ]


=item *

-substitutionvalue => I<real number>,

If you have a no real number value in a dataset, it will be replaced by a constant value.

Default : B<0>


 my @data = (
      [     '1st',   '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th' ],
      [         1,    "--",     5,     6,     3,   1.5,     1,     3,     4 ],
      [ "mistake",       2,     5,     2,     3,  "NA",     7,     9,     4 ],
      [         1,       2,    52,     6,     3,  17.5,     1,    43,     4 ],
 );
 $GraphDummies->plot( \@data,
   -substitutionvalue => '12',
 );
  # mistake, -- and NA will be replace by 12

-substitutionvalue have to be a real number (ex : 12, .25, 02.25, 5.2e+11, etc ...) 
  

=back

=head2 redraw

Redraw the chart. 

If you have used clearchart for any reason, it is possible to redraw the chart.
Tk::ForDummies::Graph::Areas supports the configure and cget methods described in the L<Tk::options> manpage.
If you use configure method to change a widget specific option, the modification will not be display. 
If the chart was already displayed and if you not resize the widget, call B<redraw> method to 
resolv the bug.

 ...
 $fenetre->Button(-text => "Change xlabel", -command => sub { 
   $GraphDummies->configure(-xlabel => "red"); 
   } 
 )->pack;
 ...
 # xlabel will be changed but not displayed if you not resize the widget.
  
 ...
 $fenetre->Button(-text => "Change xlabel", -command => sub { 
   $GraphDummies->configure(-xlabel => "red"); 
   $GraphDummies->redraw; 
   } 
 )->pack;
 ...
 # OK, xlabel will be changed and displayed without resize the widget.

=head2 set_balloon

=over 4

=item I<$GraphDummies>->B<set_balloon>(I<? %Options>)

If you call this method, you enable help identification.
When the mouse cursor passes over a plotted line or its entry in the legend, 
the line and its entry will be turn into a color (that you can change) to help the identification. 
B<set_legend> method must be set if you want to enabled identification.

=back

=over 8

=item *

-background => I<string>

Set a background color for the balloon.

 -background => "red",

Default : B<snow>

=item *

-colordatamouse => I<Array reference>

Specify an array reference wich contains 2 colors. The first color specifies 
the color of the line when mouse cursor passes over an entry in the legend. If the line 
has the same color, the second color will be used.

 -colordatamouse => ["blue", "green"],

Default : -colordatamouse => B<[ '#7F9010', '#CB89D3' ]>

=item *

-morepixelselected => I<integer>

When the mouse cursor passes over an entry in the legend, 
the line width increase. 

 -morepixelselected => 5,

Default : B<2>


=back

=head2 set_legend

=over 4

=item I<$GraphDummies>->B<set_legend>(I<? %Options>)

View a legend for the chart and allow to enabled identification help by using B<set_balloon> method.

=back

=over 8

=item *

-title => I<string>

Set a title legend.

 -title => "My title",

Default : B<undef>

=item *

-titlecolors => I<string>

Set a color to legend text.

 -titlecolors => "red",

Default : B<black>

=item *

-titlefont => I<string>

Set the font to legend title text.

 -titlefont => "{Arial} 8 {normal}",

Default : B<{Times} 8 {bold}>

=item *

-legendfont => I<string>

Set the font to legend text.

 -legendfont => "{Arial} 8 {normal}",

Default : B<{Times} 8 {normal}>

=item *

-box => I<boolean>

Set a box around all legend.

 -box => 0,

Default : B<1>

=item *

-legendmarkerheight => I<integer>

Change the heigth of marker for each legend entry. 

 -legendmarkerheight => 5,

Default : B<10>

=item *

-legendmarkerwidth => I<integer>

Change the width of marker for each legend entry. 

 -legendmarkerwidth => 5,

Default : B<10>

=item *

-heighttitle => I<integer>

Change the height title legend space. 

 -heighttitle => 75,

Default : B<30>

=back

=head2 zoom

zoom the chart. The x axis and y axis will be zoomed. If your graph has a 300*300 
size, after a zoom(200), the chart will have a 600*600 size.

$GraphDummies->zoom(I<$zoom>);

$zoom must be an integer great than 0.

 $GraphDummies->zoom(50); # size divide by 2 => 150*150
 ...
 $GraphDummies->zoom(200); # size multiplie by 2 => 600*600
 ...
 $GraphDummies->zoom(120); # 20% add in each axis => 360*360
 ...
 $GraphDummies->zoom(100); # original resize 300*300. 


=head2 zoomx

zoom the chart the x axis.

 # original canvas size 300*300
 $GraphDummies->zoomx(50); # new size : 150*300
 ...
 $GraphDummies->zoom(100); # new size : 300*300

=head2 zoomy

zoom the chart the y axis.

 # original canvas size 300*300
 $GraphDummies->zoomy(50); # new size : 300*150
 ...
 $GraphDummies->zoom(100); # new size : 300*300

=head1 AUTHOR

Djibril Ousmanou, C<< <djibel at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-Tk-ForDummies-Graph at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tk-ForDummies-Graph>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SEE ALSO

See L<Tk::Canvas> for details of the standard options.

See L<Tk::ForDummies::Graph>, L<Tk::ForDummies::Graph::FAQ>, L<GD::Graph>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tk::ForDummies::Graph::Areas


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tk-ForDummies-Graph>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tk-ForDummies-Graph>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tk-ForDummies-Graph>

=item * Search CPAN

L<http://search.cpan.org/dist/Tk-ForDummies-Graph/>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2009 Djibril Ousmanou, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
