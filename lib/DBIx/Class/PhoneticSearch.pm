package DBIx::Class::PhoneticSearch;

use warnings;
use strict;

use Class::Load qw();

use constant PHONETIC_ALGORITHMS =>
  qw(DaitchMokotoff DoubleMetaphone Koeln Metaphone Phonem Phonix Soundex SoundexNara);

sub register_column {
    my ( $self, $column, $info, @rest ) = @_;

    $self->next::method( $column, $info, @rest );

    if ( my $config = $info->{phonetic_search} ) {
        $info->{phonetic_search} = $config = { algorithm => $config }
          unless ( ref $config eq "HASH" );
        $config->{algorithm} = 'Phonix'
          unless ( grep { $config->{algorithm} eq $_ } PHONETIC_ALGORITHMS );
        $self->add_column( $column
              . '_phonetic_'
              . lc( $config->{algorithm} ) =>
              { data_type => 'character varying', is_nullable => 1 } );
    }

    return undef;
}

sub store_column {
    my ( $self, $name, $value, @rest ) = @_;

    my $info = $self->column_info($name);

    if ( my $config = $info->{phonetic_search} ) {
        my $class  = 'Text::Phonetic::' . $config->{algorithm};
        my $column = $name . '_phonetic_' . lc( $config->{algorithm} );
        Class::Load::load_class($class);
        $self->set_column( $column, $class->new->encode($value) );
    }

    return $self->next::method( $name, $value, @rest );
}

sub sqlt_deploy_hook {
    my ($self, $table, @rest) = @_;
    $self->maybe::next::method($table, @rest);
    foreach my $column($self->columns) {
        next unless(my $config = $self->column_info($column)->{phonetic_search});
        next if($config->{no_indices});
        my $phonetic_column = $column.'_phonetic_' . lc( $config->{algorithm} );
        $table->add_index(name => 'idx_'.$phonetic_column, fields => [$phonetic_column]);
        $table->add_index(name => 'idx_'.$column, fields => [$column]);
        
    }
    
}

1;

__END__

=head1 NAME

DBIx::Class::PhoneticSearch - The great new DBIx::Class::PhoneticSearch!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use DBIx::Class::PhoneticSearch;

    my $foo = DBIx::Class::PhoneticSearch->new();
    ...
    
=head1 ADVANCED CONFIGURATION

=head2 algorithm

Choose one of C<DaitchMokotoff DoubleMetaphone Koeln Metaphone Phonem Phonix Soundex SoundexNara>.

See L<Text::Phonetic> for more details.

Defaults to C<Phonix>.

=head2 no_indices

By default this module will create indices on both the source column and the phonetic column. Set this attribute to a true value to disable this behaviour.

=head1 AUTHOR

Moritz Onken, C<< <onken at netcubed.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-class-phoneticsearch at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-Class-PhoneticSearch>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::Class::PhoneticSearch


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-Class-PhoneticSearch>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-Class-PhoneticSearch>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-Class-PhoneticSearch>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-Class-PhoneticSearch/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

