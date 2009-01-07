package DBIx::Skinny::Iterator;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;

    my $self = bless \%args, $class;

    $self->reset;

    return wantarray ? $self->all : $self;
}

sub iterator {
    my $self = shift;

    my $potition = $self->{_potition} + 1;
    if ( my $row_cache = $self->{_rows_cache}->[$potition] ) {
        $self->{_potition} = $potition;
        return $row_cache;
    }

    my $row;
    if ($self->{sth}) {
        $row = $self->{sth}->fetchrow_hashref();
        unless ( $row ) {
            $self->{skinny}->_close_sth($self->{sth});
            return;
        }
    } elsif ($self->{data} && ref $self->{data} eq 'ARRAY') {
        $row = shift @{$self->{data}};
        unless ( $row ) {
            return;
        }
    } else {
        die 'invalid case.';
    }

    my $obj = $self->{row_class}->new(
        {
            row_data       => $row,
            skinny         => $self->{skinny},
            opt_table_info => $self->{opt_table_info},
        }
    );

    unless ($self->{_setup}) {
        $obj->setup;
        $self->{_setup}=1;
    }

    $self->{_rows_cache}->[$potition] = $obj;
    $self->{_potition} = $potition;

    return $obj;
}

sub first {
    my $self = shift;
    $self->reset;
    $self->next;
}

sub next { shift->iterator }

sub all {
    my $self = shift;
    my @result;
    while ( my $row = $self->next ) {
        push @result, $row;
    }
    return @result;
}

sub reset {
    my $self = shift;
    $self->{_potition} = 0;
    return $self;
}

sub count {
    my $self = shift;
    my @rows = $self->reset->all;
    $self->reset;
    scalar @rows;
}

1;

