package Tk::ForDummies::Graph;

#==================================================================
# Author    : Djibril Ousmanou
# Copyright : 2009
# Update    : 30/03/2009
# AIM       : Private functions for Dummies Graph modules
#==================================================================
use strict;
use warnings;
use Carp;
use Tk::ForDummies::Graph::Utils qw (:DUMMIES);
use vars qw($VERSION);
$VERSION = '1.01';

use Exporter;

my @ModuleToExport = qw (
  _TreatParameters         _InitConfig _error
  _CheckSizeLengendAndData _ZoomCalcul
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
      Pie         => '_PieTag',          # id_PieTag
      Line        => '_LineTag',         # id_LineTag
      Bar         => '_BarTag',          # id_LineTag
      Legend      => '_LegendTag',       # id_LegendTag
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

  my $xvaluesregex  = $CompositeWidget->cget( -xvaluesregex );
  my $Colors        = $CompositeWidget->cget( -colordata );
  my @IntegerOption = qw /
    -xlabelheight -xlabelskip -xvaluespace
    -ylabelwidth -boxaxis -noaxis -zeroaxisonly -xtickheight -xtickview
    -yticknumber -ytickwidth -linewidth -alltickview
    -xvaluevertical -titleheight -gridview -ytickview
    -overwrite -cumulate -spacingbar -showvalues
    /;

  foreach my $OptionName (@IntegerOption) {
    my $data = $CompositeWidget->cget($OptionName);
    if ( defined $data and $data !~ m{^\d+$} ) {
      $CompositeWidget->_error(
        "'Can't set $OptionName to `$data', $data' isn't numeric", 1 );
      return;
    }
  }

  unless ( ref($xvaluesregex) =~ m{^Regexp$}i ) {
    $CompositeWidget->_error(
      "'Can't set -xvaluesregex to `$xvaluesregex', "
        . "$xvaluesregex' is not a regex expression\nEx : "
        . "-xvaluesregex => qr/My regex/;",
      1
    );
    return;
  }
  if ( defined $Colors and ref($Colors) ne 'ARRAY' ) {
    $CompositeWidget->_error(
      "'Can't set -colordata to `$Colors', "
        . "$Colors' is not an array reference\nEx : "
        . "-colordata => [\"blue\",\"#2400FF\",...]",
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

  my $SizeLegend = scalar @{$RefLegend};

  # Check legend size
  unless ( defined $RefData and defined $RefLegend ) {
    $CompositeWidget->_error("[WARNING] data or legend not defined");
    return;
  }

  # Check size between legend and data
  my $SizeData = scalar @{$RefData} - 1;
  unless ( $SizeLegend == $SizeData ) {
    $CompositeWidget->_error(
      "[WARNING] Legend and array size data are different");
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
  my $NewWidth  = ( $ZoomX / 100 ) * $CentPercentWidth  if ( defined $ZoomX );
  my $NewHeight = ( $ZoomY / 100 ) * $CentPercentHeight if ( defined $ZoomY );

  $CompositeWidget->{RefInfoDummies}->{Zoom}{CurrentX} = $ZoomX
    if ( defined $ZoomX );
  $CompositeWidget->{RefInfoDummies}->{Zoom}{CurrentY} = $ZoomY
    if ( defined $ZoomY );

  return ( $NewWidth, $NewHeight );
}

sub _error {
  my ( $CompositeWidget, $ErrorMessage, $Croak ) = @_;

  if ( defined $Croak and $Croak == 1 ) {
    croak $ErrorMessage, "\n";
  }
  else {
    warn $ErrorMessage, "\n";
  }

  return;
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

L<Tk::ForDummies::Graph::Lines>

    Extension of Canvas widget to create a line chart. 
    With this module it is possible to plot quantitative variables according to qualitative variables.

L<Tk::ForDummies::Graph::Bars>

    Extension of Canvas widget to create a bar chart with vertical bars.
    With this module it is possible to plot quantitative variables according to qualitative variables.

L<Tk::ForDummies::Graph::Pie>

    Extension of Canvas widget to create a pie chart. 

=head1 EXAMPLES

See the samples directory in the distribution, and read documentations for each modules Tk::ForDummies::Graph::ModuleName.

=head1 AUTHOR

Djibril Ousmanou, C<< <djibrilo at yahoo.fr> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tk-fordummies-graph at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tk-ForDummies-Graph>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tk::ForDummies::Graph


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


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Djibril Ousmanou, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
