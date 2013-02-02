use 5.008001;
use strict;
use warnings;

package Dancer::SessionFactory::PSGI;
# ABSTRACT: Dancer 2 session storage with Plack middleware
# VERSION

use Moo;

with 'Dancer::Core::Role::SessionFactory';

#--------------------------------------------------------------------------#
# Required methods
#--------------------------------------------------------------------------#

# We just grab the middleware session hash
sub _retrieve {
    my ($self, $id) = @_;
    return $self->context->env->{'psgix.session'};
}

# Put the data back to the env hash
sub _flush {
    my ($self, $id, $data) = @_;
    $self->context->env->{'psgix.session'} = $data;
    return;
}

# Handled by Plack::Middleware if cookie is expired
sub _destroy { return }

# There is no way to know about existing sessions when cookies
# are used as the store, so we lie and return an empty list.
sub _sessions { return [] }

#--------------------------------------------------------------------------#
# Overridden methods
#--------------------------------------------------------------------------#

# We don't set the header, the middleware does that; but we need to
# notify about expiration
sub set_cookie_header {
    my ($self, %params) = @_;
    my $session = $params{session};
    if ( $session->expires < time ) {
        $self->context->env->{'psgix.session.options'}{expire} = 1;
    }
    return;
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  # In Dancer 2 config.yml file

  session: PSGI
  engines:
    session:
      PSGI:
        store: File

=head1 DESCRIPTION

This module implements a session factory for Dancer 2 that usee
L<Plack::Middleware::Session>.

=cut

# vim: ts=4 sts=4 sw=4 et:
