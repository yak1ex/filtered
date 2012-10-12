use strict;
use warnings;

package filtered::hook; ## no critic (RequireFilenameMatchesPackage)

# VERSION

sub new
{
	my ($self, %arg)  = @_;
	my $class = ref($self) || $self;
	return bless  {
		_FILTER => $arg{FILTER},
	}, $class;
}

# NOTE: To store data in object is probably not good idea because this prohibits re-entrance.
sub init
{
	my ($self, $target, $as) = @_;

	$self->{_TARGET} = $target;
	$self->{_AS} = $as;
	return $self;
}

sub filtered::hook::INC
{
	my ($self, $filename) = @_;
	$self->{_FILENAME} = $filename;
	shift @INC; # TODO: Gain robustness # NOTE: Just one time application

#print "SELF: $self / FILTER: $self->{_FILTER} / AS: $self->{_AS} / FILENAME: $filename\n";

# NOTE: The following part is based on perldoc -f require
	if (exists $INC{$self}{$filename}) {
		# return 1 in original require
		return (sub {
			if($_[1]) {
				delete $INC{$filename};
				$_ = "1;\n";
				$_[1] = 0;
				return 1;
			} else {
				return 0;
			}
		}, 1) if $INC{$self}{$filename};
		die "Compilation failed in require";
	}
	my ($realfilename,$result);
	ITER: {
		foreach my $prefix (@INC) {
			$realfilename = "$prefix/$filename";
			if (-f $realfilename) {
				$INC{$self}{$filename} = $realfilename;
				last ITER;
			}
		}
		die "Can't find $filename in \@INC";
	}

	open my $fh, '<', $realfilename;
	my $qr1 = qr/\b(package\s+)$self->{_TARGET}\b/;
	my $qr2 = qr/\b$self->{_TARGET}::\b/;
	return (sub {
		my ($sub, $state) = @_;
		if($state == 1) { # Inject filter at the beginning
			delete $INC{$filename};
			$_ = 'use '.$self->{_FILTER}.";\n";
			$_[1] = 0;
		} elsif(eof($fh)) {
			close $fh;
			return 0;
		} elsif(defined $self->{_AS}) {
			$_ = <$fh>;
			s {$qr1} {${1}$self->{_AS}};
			s {$qr2} {$self->{_AS}::};
		} else {
			$_ = <$fh>;
		}
		return 1;
	}, 1);
}

package filtered;

# VERSION

use Carp;

my %hook;

sub import
{
	my ($class, @args) = @_;
	my ($filter, $target, $as);
	while(1) {
		if($args[0] eq 'by') {
			shift @args;
			$filter = shift @args;
		} elsif($args[0] eq 'as') {
			shift @args;
			$as = shift @args;
		} elsif($args[0] eq 'on') {
			shift @args;
			$target = shift @args;
			last;
		} else {
			$target = shift @args;
			last;
		}
	}

	croak '`by\' must be specified' if ! defined($filter);
	croak '`on\' or target name must be specified' if ! defined($target);
	$hook{$filter} = filtered::hook->new(FILTER => $filter) if ! exists $hook{$filter};
	unshift @INC, 	$hook{$filter}->init($target, $as);
	if(!defined eval "require $target") {
		delete $INC{$hook{$filter}{_FILENAME}}; # For error in internal require
		croak "Can't load $target by $@";
	}
	if(defined $as) {
		@_ = ($as, @args);
	} else {
		@_ = ($target, @args);
	}
	{
		no strict 'refs'; ## no critic (ProhibitNoStrict)
		no warnings 'once';
		my $import = *{$_[0].'::import'}{CODE};
		if(defined $import) {
			goto &$import;
		} elsif ($_[0]->isa('Exporter')) {
			$_[0]->export_to_level(1, @_);
		}
	}
}

1;
__END__
=pod

=head1 NAME

filtered - Apply source filter on external module

=head1 SYNOPSIS

  # Apply source filter YourFilter.pm on Target.pm, then result can be used as FilteredTarget
  use filtered by => 'YourFilter', as => 'FilteredTarget', on => 'Target', qw(func);
  my $obj = FilteredTarget->new;

  # You can omit `as' option and `on' key
  use filtered by => 'YourFilter', 'Target', qw(func);
  my $obj = Target->new; # Target is filtered

  # You can use differnt module with the same filter
  use filtered by => 'YourFilter', as => 'FilteredTarget1', on => 'Target1', qw(func);
  use filtered by => 'YourFilter', as => 'FilteredTarget2', on => 'Target2', qw(func);

  # or, you can also use differnt filters on the same module
  use filtered by => 'YourFilter1', as => 'FilteredTarget1', on => 'Target', qw(func);
  use filtered by => 'YourFilter2', as => 'FilteredTarget2', on => 'Target', qw(func);

=head1 DESCRIPTION

Source filter has unlimited power to enhance Perl.
However, source filter is usually applied on your own sources.
This module enables you to apply source filter on external module.

=head1 OPTIONS

Rest of the options are passed to C<import> of filtered module.

=over 4

=item C<by>

Specify a source filter module you want to apply on an external module.

=item C<as>

Specify the package name for the resultant filtered module.
This option can be omitted. If omitted, original names are used.

=item C<on>

Specify a target module. C<on> keyword can be ommited. 

=back

=head1 CAVEATS

=over 4

=item This module uses @INC hook.

For @INC hook, please consult C<perldoc -f require>. Hook itself is enabled in short period but it may affect other modules.

=item Replacement by C<as> is applied in limited context.

If you specified C<as =E<gt> FilteredTarget, on =E<gt> Target>, the following codes:

  package Target::work;
  package Target;
  Target::work::call();

are transformed into as follows:

  package FilteredTarget::work;
  package FilteredTarget;
  FilteredTarget::work::call();

Actually, only C<'\bpackage\s+Target\b'> and C<'\bTarget::\b'> are replaced.

=back

=head1 SEE ALSO

=over 4

=item *

L<http://github.com/yak1ex/filtered> - Github repository

=item *

L<Filter::Simple> - Helper module to implement source filter

=back

=head1 AUTHOR

Yasutaka ATARASHI <yakex@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
