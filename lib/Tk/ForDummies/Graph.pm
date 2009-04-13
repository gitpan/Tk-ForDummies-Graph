package Tk::ForDummies::Graph;

#==================================================================
# Author    : Djibril Ousmanou
# Copyright : 2009
# Update    : 13/04/2009 13:34:12
# AIM       : Private functions for Dummies Graph modules
#==================================================================
use strict;
use warnings;
use Carp;
use Tk::ForDummies::Graph::Utils qw (:DUMMIES);
use vars qw($VERSION);
$VERSION = '1.06';

use Exporter;

my @ModuleToExport = qw (
  _TreatParameters         _InitConfig    _error
  _CheckSizeLengendAndData _ZoomCalcul    _DestroyBalloonAndBind
  _CreateType              _GetMarkerType
);

our @ISA         = qw(Exporter);
our @EXPORT_OK   = @ModuleToExport;
our %EXPORT_TAGS = ( DUMMIES => \@ModuleToExport );

sub _InitConfig {
  my $CompositeWidget = shift;
  my %Configuration   = (
    'Axis' => {
      Cx0   => undef,
      Cx0   => undef,
      CxMin => undef,
      CxMax => undef,
      CyMin => undef,
      CyMax => undef,
      Xaxis => {
        Width             => undef,
        Height            => undef,
        xlabelHeight      => 30,
        ScaleValuesHeight => 30,
        TickHeight        => 5,
        CxlabelX          => undef,
        CxlabelY          => undef,
        Idxlabel          => undef,
        IdxTick          => undef,
        TagAxis0          => 'Axe00',
      },
      Yaxis => {
        ylabelWidth      => 5,
        ScaleValuesWidth => 60,
        TickWidth        => 5,
        TickNumber       => 4,
        Width            => undef,
        Height           => undef,
        CylabelX         => undef,
        CylabelY         => undef,
        Idylabel         => undef,
      },
    },
    'Balloon' => {
      Obj               => undef,
      Message           => {},
      State             => 0,
      ColorData         => [ '#000000', '#CB89D3' ],
      MorePixelSelected => 2,
      Background        => 'snow',
      BalloonMsg        => undef,
      IdLegData         => undef,
    },
    'Canvas' => {
      Height           => 400,
      Width            => 500,
      HeightEmptySpace => 20,
      WidthEmptySpace  => 20,
      YTickWidth       => 2,
    },
    'Data' => {
      RefXLegend        => undef,
      RefAllData        => undef,
      PlotDefined       => undef,
      MaxYValue         => undef,
      MinYValue         => undef,
      GetIdData         => {},
      SubstitutionValue => 0,
      NumberRealData    => undef,

    },
    'Font' => {
      Default            => '{Times} 10 {normal}',
      DefaultTitle       => '{Times} 12 {bold}',
      DefaultLabel       => '{Times} 10 {bold}',
      DefaultLegend      => '{Times} 8 {normal}',
      DefaultLegendTitle => '{Times} 8 {bold}',
      DefaultBarValues   => '{Times} 8 {normal}',
    },
    'Legend' => {
      HeightTitle     => 30,
      HLine           => 20,
      WCube           => 10,
      HCube           => 10,
      SpaceBeforeCube => 5,
      SpaceAfterCube  => 5,
      WidthText       => 250,
      NbrLegPerLine   => undef,
      '-width'        => undef,
      Height          => 0,
      Width           => undef,
      LengthOneLegend => undef,
      DataLegend      => undef,
      LengthTextMax   => undef,
      GetIdLeg        => {},
      title           => undef,
      titlefont       => '{Times} 12 {bold}',
      titlecolors     => 'black',
      Colors          => [
        'red',     'green',   'blue',    'yellow',  'purple',  'cyan',
        '#996600', '#99A6CC', '#669933', '#929292', '#006600', '#FFE100',
        '#00A6FF', '#009060', '#B000E0', '#A08000', 'orange',  'brown',
        'black',   '#FFCCFF', '#99CCFF', '#FF00CC', '#FF8000', '#006090',
      ],
      NbrLegend => 0,
      box       => 0,
    },
    'TAGS' => {
      AllAXIS     => 'AllAXISTag',
      yAxis       => 'yAxisTag',
      xAxis       => 'xAxisTag',
      'xAxis0'    => '0AxisTag',
      BoxAxis     => 'BoxAxisTag',
      xTick       => 'xTickTag',
      yTick       => 'yTickTag',
      AllTick     => 'AllTickTag',
      'xValue0'   => 'xValue0Tag',
      xValues     => 'xValuesTag',
      yValues     => 'yValuesTag',
      AllValues   => 'AllValuesTag',
      TitleLegend => 'TitleLegendTag',
      BoxLegend   => 'BoxLegendTag',
      AllData     => 'AllDataTag',
      AllPie      => 'AllPieTag',
      Pie         => '_PieTag',
      Line        => '_LineTag',
      Bar         => '_BarTag',
      Legend      => '_LegendTag',
      DashLines   => '_DashLineTag',
      BarValues   => '_BarValuesTag',
      Boxplot     => '_BoxplotTag',
    },
    'Title' => {
      Ctitrex  => undef,
      Ctitrey  => undef,
      IdTitre  => undef,
      '-width' => undef,
      Width    => undef,
      Height   => 40,
    },
    'Zoom' => {
      CurrentX => 100,
      CurrentY => 100,
    },
  );

  return \%Configuration;
}

sub _TreatParameters {
  my ($CompositeWidget) = @_;

  my @IntegerOption = qw /
    -xlabelheight -xlabelskip     -xvaluespace  -ylabelwidth
    -boxaxis      -noaxis         -zeroaxisonly -xtickheight
    -xtickview    -yticknumber    -ytickwidth   -linewidth
    -alltickview  -xvaluevertical -titleheight  -gridview
    -ytickview    -overwrite      -cumulate     -spacingbar
    -showvalues   -startangle     -viewsection  -zeroaxis
    -longticks    -smoothline     -pointline    -markersize
    /;

  foreach my $OptionName (@IntegerOption) {
    my $data = $CompositeWidget->cget($OptionName);
    if ( defined $data and $data !~ m{^\d+$} ) {
      $CompositeWidget->_error(
        "'Can't set $OptionName to `$data', $data' isn't numeric", 1 );
      return;
    }
  }

  my $xvaluesregex = $CompositeWidget->cget( -xvaluesregex );
  unless ( ref($xvaluesregex) =~ m{^Regexp$}i ) {
    $CompositeWidget->_error(
      "'Can't set -xvaluesregex to `$xvaluesregex', "
        . "$xvaluesregex' is not a regex expression\nEx : "
        . "-xvaluesregex => qr/My regex/;",
      1
    );
    return;
  }

  my $Colors = $CompositeWidget->cget( -colordata );
  if ( defined $Colors and ref($Colors) ne 'ARRAY' ) {
    $CompositeWidget->_error(
      "'Can't set -colordata to `$Colors', "
        . "$Colors' is not an array reference\nEx : "
        . "-colordata => [\"blue\",\"#2400FF\",...]",
      1
    );
    return;
  }
  my $Markers = $CompositeWidget->cget( -markers );
  if ( defined $Markers and ref($Markers) ne 'ARRAY' ) {
    $CompositeWidget->_error(
      "'Can't set -markers to `$Markers', "
        . "$Markers' is not an array reference\nEx : "
        . "-markers => [5,8,2]",
      1
    );

    return;
  }

  if ( my $xtickheight = $CompositeWidget->cget( -xtickheight ) ) {
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight}
      = $xtickheight;
  }

  if ( my $xvaluespace = $CompositeWidget->cget( -xvaluespace ) ) {
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight}
      = $xvaluespace;
  }

  if ( $CompositeWidget->cget( -noaxis ) == 1 ) {
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{ScaleValuesHeight} = 0;
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ScaleValuesWidth}  = 0;
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth}         = 0;
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{TickHeight}        = 0;
  }

  if ( my $title = $CompositeWidget->cget( -title ) ) {
    if ( my $titleheight = $CompositeWidget->cget( -titleheight ) ) {
      $CompositeWidget->{RefInfoDummies}->{Title}{Height} = $titleheight;
    }
  }
  else {
    $CompositeWidget->{RefInfoDummies}->{Title}{Height} = 0;
  }

  if ( my $xlabel = $CompositeWidget->cget( -xlabel ) ) {
    if ( my $xlabelheight = $CompositeWidget->cget( -xlabelheight ) ) {
      $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight}
        = $xlabelheight;
    }
  }
  else {
    $CompositeWidget->{RefInfoDummies}->{Axis}{Xaxis}{xlabelHeight} = 0;
  }

  if ( my $ylabel = $CompositeWidget->cget( -ylabel ) ) {
    if ( my $ylabelWidth = $CompositeWidget->cget( -ylabelWidth ) ) {
      $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth}
        = $ylabelWidth;
    }
  }
  else {
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{ylabelWidth} = 0;
  }

  if ( my $ytickwidth = $CompositeWidget->cget( -ytickwidth ) ) {
    $CompositeWidget->{RefInfoDummies}->{Axis}{Yaxis}{TickWidth} = $ytickwidth;
  }

  if ( my $valuescolor = $CompositeWidget->cget( -valuescolor ) ) {
    $CompositeWidget->configure( -xvaluecolor => $valuescolor );
    $CompositeWidget->configure( -yvaluecolor => $valuescolor );
  }

  if ( my $textcolor = $CompositeWidget->cget( -textcolor ) ) {
    $CompositeWidget->configure( -titlecolor  => $textcolor );
    $CompositeWidget->configure( -xlabelcolor => $textcolor );
    $CompositeWidget->configure( -ylabelcolor => $textcolor );
  }
  elsif ( my $labelscolor = $CompositeWidget->cget( -labelscolor ) ) {
    $CompositeWidget->configure( -xlabelcolor => $labelscolor );
    $CompositeWidget->configure( -ylabelcolor => $labelscolor );
  }

  if ( my $textfont = $CompositeWidget->cget( -textfont ) ) {
    $CompositeWidget->configure( -titlefont  => $textfont );
    $CompositeWidget->configure( -xlabelfont => $textfont );
    $CompositeWidget->configure( -ylabelfont => $textfont );
  }
  if ( my $startangle = $CompositeWidget->cget( -startangle ) ) {
    if ( $startangle < 0 or $startangle > 360 ) {
      $CompositeWidget->configure( -startangle => 0 );
    }
  }
  if ( my $longticks = $CompositeWidget->cget( -longticks ) ) {
    if ( $longticks == 1 ) {
      $CompositeWidget->configure( -boxaxis => 1 );
    }
  }

=for borderwidth:
  If user call -borderwidth option, the chart will be trunc.
  Then we will add HeightEmptySpace and WidthEmptySpace.

=cut

  if ( my $borderwidth = $CompositeWidget->cget( -borderwidth ) ) {
    $CompositeWidget->{RefInfoDummies}->{Canvas}{HeightEmptySpace}
      = $borderwidth + 15;
    $CompositeWidget->{RefInfoDummies}->{Canvas}{WidthEmptySpace}
      = $borderwidth + 15;
  }

  return 1;
}

sub _CheckSizeLengendAndData {
  my ( $CompositeWidget, $RefData, $RefLegend ) = @_;

  # Check legend size
  unless ( defined $RefLegend ) {
    $CompositeWidget->_error("legend not defined");
    return;
  }
  my $SizeLegend = scalar @{$RefLegend};

  # Check size between legend and data
  my $SizeData = scalar @{$RefData} - 1;
  unless ( $SizeLegend == $SizeData ) {
    $CompositeWidget->_error("Legend and array size data are different");
    return;
  }

  return 1;
}

sub _ZoomCalcul {
  my ( $CompositeWidget, $ZoomX, $ZoomY ) = @_;

  if ( ( defined $ZoomX and !( _isANumber($ZoomX) or $ZoomX > 0 ) )
    or ( defined $ZoomY and !( _isANumber($ZoomY) or $ZoomY > 0 ) )
    or ( not defined $ZoomX and not defined $ZoomY ) )
  {
    $CompositeWidget->_error(
      "zoom value must be defined, numeric and great than 0", 1 );
    return;
  }

  my $CurrentWidth  = $CompositeWidget->{RefInfoDummies}->{Canvas}{Width};
  my $CurrentHeight = $CompositeWidget->{RefInfoDummies}->{Canvas}{Height};

  my $CentPercentWidth
    = ( 100 / $CompositeWidget->{RefInfoDummies}->{Zoom}{CurrentX} )
    * $CurrentWidth;
  my $CentPercentHeight
    = ( 100 / $CompositeWidget->{RefInfoDummies}->{Zoom}{CurrentY} )
    * $CurrentHeight;
  my $NewWidth = ( $ZoomX / 100 ) * $CentPercentWidth
    if ( defined $ZoomX );
  my $NewHeight = ( $ZoomY / 100 ) * $CentPercentHeight
    if ( defined $ZoomY );

  $CompositeWidget->{RefInfoDummies}->{Zoom}{CurrentX} = $ZoomX
    if ( defined $ZoomX );
  $CompositeWidget->{RefInfoDummies}->{Zoom}{CurrentY} = $ZoomY
    if ( defined $ZoomY );

  return ( $NewWidth, $NewHeight );
}

sub _DestroyBalloonAndBind {
  my ($CompositeWidget) = @_;

  # balloon defined and user want to stop it
  if ( $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}
    and Tk::Exists $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj} )
  {
    $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}
      ->configure( -state => 'none' );
    $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}
      ->detach($CompositeWidget);

    #$CompositeWidget->{RefInfoDummies}->{Balloon}{Obj}->destroy;

    undef $CompositeWidget->{RefInfoDummies}->{Balloon}{Obj};
  }

  return;
}

sub _error {
  my ( $CompositeWidget, $ErrorMessage, $Croak ) = @_;

  if ( defined $Croak and $Croak == 1 ) {
    croak "[BE CARREFUL] : $ErrorMessage\n";
  }
  else {
    warn "[WARNING] : $ErrorMessage\n";
  }

  return;
}

sub _GetMarkerType {
  my ( $CompositeWidget, $Number ) = @_;
  my %MarkerType = (

    # N°      Type                Filled
    1  => [ "square",           1 ],
    2  => [ "square",           0 ],
    3  => [ "horizontal cross", 1 ],
    4  => [ "diagonal cross",   1 ],
    5  => [ "diamond",          1 ],
    6  => [ "diamond",          0 ],
    7  => [ "circle",           1 ],
    8  => [ "circle",           0 ],
    9  => [ "horizontal line",  1 ],
    10 => [ "vertical line",    1 ],
  );

  return unless ( defined $MarkerType{$Number} );

  return $MarkerType{$Number};
}

=for _CreateType
  Calculate different points coord to create a rectangle, circle, 
  verticale or horizontal line, a cross, a plus and a diamond 
  from a point coord.
  Arg : Reference of hash
  {
    x      => value,
    y      => value,
    pixel  => value,
    type   => string, (circle, cross, plus, diamond, rectangle, Vline, Hline )
    option => Hash reference ( {-fill => xxx, -outline => yy, ...} )
  }

=cut

sub _CreateType {
  my ( $CompositeWidget, %Refcoord ) = @_;

  if ( $Refcoord{type} eq "circle" or $Refcoord{type} eq "square" ) {
    my $x1 = $Refcoord{x} - ( $Refcoord{pixel} / 2 );
    my $y1 = $Refcoord{y} + ( $Refcoord{pixel} / 2 );
    my $x2 = $Refcoord{x} + ( $Refcoord{pixel} / 2 );
    my $y2 = $Refcoord{y} - ( $Refcoord{pixel} / 2 );

    if ( $Refcoord{type} eq "circle" ) {
      $CompositeWidget->createOval( $x1, $y1, $x2, $y2,
        %{ $Refcoord{option} } );
    }
    else {
      $CompositeWidget->createRectangle( $x1, $y1, $x2, $y2,
        %{ $Refcoord{option} } );
    }
  }
  elsif ( $Refcoord{type} eq "horizontal cross" ) {
    my $x1 = $Refcoord{x};
    my $y1 = $Refcoord{y} - ( $Refcoord{pixel} / 2 );
    my $x2 = $x1;
    my $y2 = $Refcoord{y} + ( $Refcoord{pixel} / 2 );
    my $x3 = $Refcoord{x} - ( $Refcoord{pixel} / 2 );
    my $y3 = $Refcoord{y};
    my $x4 = $Refcoord{x} + ( $Refcoord{pixel} / 2 );
    my $y4 = $y3;
    $CompositeWidget->createLine( $x1, $y1, $x2, $y2, %{ $Refcoord{option} } );
    $CompositeWidget->createLine( $x3, $y3, $x4, $y4, %{ $Refcoord{option} } );
  }
  elsif ( $Refcoord{type} eq "diagonal cross" ) {
    my $x1 = $Refcoord{x} - ( $Refcoord{pixel} / 2 );
    my $y1 = $Refcoord{y} + ( $Refcoord{pixel} / 2 );
    my $x2 = $Refcoord{x} + ( $Refcoord{pixel} / 2 );
    my $y2 = $Refcoord{y} - ( $Refcoord{pixel} / 2 );
    my $x3 = $x1;
    my $y3 = $y2;
    my $x4 = $x2;
    my $y4 = $y1;
    $CompositeWidget->createLine( $x1, $y1, $x2, $y2, %{ $Refcoord{option} } );
    $CompositeWidget->createLine( $x3, $y3, $x4, $y4, %{ $Refcoord{option} } );
  }
  elsif ( $Refcoord{type} eq "diamond" ) {
    my $x1 = $Refcoord{x} - ( $Refcoord{pixel} / 2 );
    my $y1 = $Refcoord{y};
    my $x2 = $Refcoord{x};
    my $y2 = $Refcoord{y} + ( $Refcoord{pixel} / 2 );
    my $x3 = $Refcoord{x} + ( $Refcoord{pixel} / 2 );
    my $y3 = $Refcoord{y};
    my $x4 = $Refcoord{x};
    my $y4 = $Refcoord{y} - ( $Refcoord{pixel} / 2 );
    $CompositeWidget->createPolygon( $x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4,
      %{ $Refcoord{option} } );
  }
  elsif ( $Refcoord{type} eq "vertical line" ) {
    my $x1 = $Refcoord{x};
    my $y1 = $Refcoord{y} - ( $Refcoord{pixel} / 2 );
    my $x2 = $Refcoord{x};
    my $y2 = $Refcoord{y} + ( $Refcoord{pixel} / 2 );
    $CompositeWidget->createLine( $x1, $y1, $x2, $y2, %{ $Refcoord{option} } );
  }
  elsif ( $Refcoord{type} eq "horizontal line" ) {
    my $x1 = $Refcoord{x} - ( $Refcoord{pixel} / 2 );
    my $y1 = $Refcoord{y};
    my $x2 = $Refcoord{x} + ( $Refcoord{pixel} / 2 );
    my $y2 = $Refcoord{y};
    $CompositeWidget->createLine( $x1, $y1, $x2, $y2, %{ $Refcoord{option} } );
  }
  else {
    return;
  }

  return 1;
}
1;

__END__

=head1 NAME

Tk::ForDummies::Graph - Extension of Canvas widget to create a graph like GDGraph. 

=head1 SYNOPSIS

use Tk::ForDummies::Graph::ModuleName;

=head1 DESCRIPTION

B<Tk::ForDummies::Graph> is a module to create and display charts on a Tk widget. 
The module is written entirely in Perl/Tk.

You can change the color, font of title, labels (x and y) of charts.
You can set an interactive legend. The axes can be automatically scaled or set by the code.

When the mouse cursor passes over a plotted line, bars ou pie or its entry in the legend, 
its entry will be turn to a color to help identify it. 

You can use 3 methods to zoom (vertically, horizontally or both).

L<Tk::ForDummies::Graph::Lines>

    Extension of Canvas widget to create lines chart. 
    With this module it is possible to plot quantitative variables according to qualitative variables.

L<Tk::ForDummies::Graph::Splines>

    To create lines chart as B<Bézier curve>. 

L<Tk::ForDummies::Graph::Areas>

    Extension of Canvas widget to create an area lines chart. 

L<Tk::ForDummies::Graph::Bars>

    Extension of Canvas widget to create bars chart with vertical bars.

L<Tk::ForDummies::Graph::Pie>

    Extension of Canvas widget to create a pie chart. 


=head1 EXAMPLES

See the samples directory in the distribution, and read documentations for each modules Tk::ForDummies::Graph::ModuleName.

=head1 SEE ALSO

See L<Tk::ForDummies::Graph::FAQ>, L<GD::Graph>, L<Tk::Graph>, L<Tk::LineGraph>, L<Tk::PlotDataset>, L<Chart::Plot::Canvas>.

=head1 AUTHOR

Djibril Ousmanou, C<< <djibel at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tk-fordummies-graph at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tk-ForDummies-Graph>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tk::ForDummies::Graph
    perldoc Tk::ForDummies::Graph::Lines
    perldoc Tk::ForDummies::Graph::Splines
    perldoc Tk::ForDummies::Graph::Points
    perldoc Tk::ForDummies::Graph::Bars
    perldoc Tk::ForDummies::Graph::Areas
    perldoc Tk::ForDummies::Graph::Pie
    perldoc Tk::ForDummies::Graph::FAQ
    perldoc Tk::ForDummies::Graph::Boxplots


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
