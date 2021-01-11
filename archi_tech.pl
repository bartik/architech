#!/usr/bin/perl
use strict;
use warnings;
use Switch;
use Data::Dumper qw(Dumper);

my %model;
my @wrow;
my $rg_id;
my $vnode_id;
my $filename;
my $fh;

# cluster configuration
$filename = 'ugssc4n1_clshowres.txt';
open($fh, '<', $filename)
  or die "Could not open file '$filename' $!";
while (my $row = <$fh>) {
  chomp $row;
  $row =~ s/ +/ /g;
  @wrow = split / /,$row;
  switch($row) {
        case /^Resource/ {
                # create cluster resource group
                $rg_id = $wrow[-1];
                $model{elements}{TechnologyCollaboration}{$rg_id} = 0;
        }
        case /^Service/ {
                # create virtual sap node
                $vnode_id = $wrow[-1];
                $model{elements}{Node}{$vnode_id} = 0;
                # connect virtual sap node to cluster resource group
                push (@{$model{relations}{RealizationRelationship}}, { source => ["TechnologyCollaboration", $rg_id], target => ["Node",$vnode_id]});
        }
        case /^Participating/ {
                for ( my $node_idx = 3; $node_idx < scalar @wrow; $node_idx++ ) {
                        # create physical nodes and connect
                        $model{elements}{Node}{$wrow[$node_idx]} = 0;
                        # connect resource group to physical node
                        push (@{$model{relations}{AggregationRelationship}}, { source => ["TechnologyCollaboration", $rg_id], target => ["Node",$wrow[$node_idx]]});
                }
        }
        else {
        }
  }
}
close ($fh);

# application configuration
$filename = 'SP2_components.txt';
open($fh, '<', $filename)
  or die "Could not open file '$filename' $!";
$model{elements}{ApplicationCollaboration}{"SAP SP2"} = 0;
push (@{$model{relations}{RealizationRelationship}}, { source => ["Node", "sapsp2ci"], target => ["ApplicationCollaboration","SAP SP2"]});
while (my $row = <$fh>) {
  chomp $row;
  $row =~ s/ +/ /g;
  $model{elements}{ApplicationComponent}{$row} = 0;
  push (@{$model{relations}{AggregationRelationship}}, { source => ["ApplicationCollaboration", "SAP SP2"], target => ["ApplicationComponent",$row]});
}
close ($fh);

print Dumper(\%model);
