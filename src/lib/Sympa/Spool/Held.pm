# -*- indent-tabs-mode: nil; -*-
# vim:ft=perl:et:sw=4
# $Id$

# Sympa - SYsteme de Multi-Postage Automatique
#
# Copyright (c) 1997, 1998, 1999 Institut Pasteur & Christophe Wolfhugel
# Copyright (c) 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
# 2006, 2007, 2008, 2009, 2010, 2011 Comite Reseau des Universites
# Copyright (c) 2011, 2012, 2013, 2014, 2015, 2016, 2017 GIP RENATER
# Copyright 2018 The Sympa Community. See the AUTHORS.md file at the
# top-level directory of this distribution and at
# <https://github.com/sympa-community/sympa.git>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package Sympa::Spool::Held;

use strict;
use warnings;

use Conf;
use Sympa::Tools::Text;

use base qw(Sympa::Spool);

sub _directories {
    return {
        directory     => $Conf::Conf{'queueauth'},
        bad_directory => $Conf::Conf{'queueauth'} . '/bad',
    };
}

sub _filter {
    my $self     = shift;
    my $metadata = shift;

    return 1 unless $metadata;

    if ($metadata->{validated_by}) {
        $metadata->{validated_by} =~ s/\A,//;
        $metadata->{validated_by} =
            Sympa::Tools::Text::decode_filesystem_safe(
            $metadata->{validated_by});
    }

    if ($metadata->{auth_method}) {
        $metadata->{auth_method} =~ s/\A,//;
    }

    1;
}

sub _filter_pre {
    my $self     = shift;
    my $metadata = shift;

    return 1 unless $metadata;

    if ($metadata->{validated_by}) {
        # Encode e-mail.
        $metadata->{validated_by} = sprintf ',%s',
            Sympa::Tools::Text::encode_filesystem_safe(
            $metadata->{validated_by});
    } else {
        $metadata->{validated_by} = '';
    }

    if ($metadata->{auth_method}) {
        $metadata->{auth_method} = sprintf ',%s', $metadata->{auth_method};
    } else {
        $metadata->{auth_method} = '';
    }

    if ($metadata->{quiet}) {
        # Normalize.
        $metadata->{quiet} = ',quiet';
    } else {
        $metadata->{quiet} = '';
    }

    1;
}

use constant _generator => 'Sympa::Message';

use constant _marshal_format => '%s@%s_%s%s%s%s';
use constant _marshal_keys   => [
    qw(localpart domainpart AUTHKEY
        validated_by auth_method quiet)
];
use constant _marshal_regexp => qr{\A
    ([^\s\@]+) \@ ([-.\w]+) _ ([\da-f]+)
    (,[^,]+)? (,(?:smtp|dkim|md5|smime))? (,quiet)?
\z}x;
use constant _store_key => 'authkey';

sub remove {
    my $self    = shift;
    my $handle  = shift;
    my %options = @_;

    if ($options{validated_by}) {
        return 1 if $handle->basename =~ /,\S+\z/;

        my $enc_validated_by = sprintf ',%s',
            Sympa::Tools::Text::encode_filesystem_safe(
            $options{validated_by});
        my $enc_auth_method = sprintf ',%s',
            ($options{auth_method} || 'smtp');
        my $enc_quiet = $options{quiet} ? ',quiet' : '';
        return $handle->rename(
            sprintf '%s/%s%s%s%s', $self->{directory},
            $handle->basename,     $enc_validated_by,
            $enc_auth_method,      $enc_quiet
        );
    } else {
        return $self->SUPER::remove($handle);
    }
}

sub size {
    scalar grep { !/,\S+\z/ } @{shift->_load || []};
}

1;
__END__

=encoding utf-8

=head1 NAME

Sympa::Spool::Held - Spool for held messages waiting for confirmation

=head1 SYNOPSIS

  use Sympa::Spool::Held;

  my $spool = Sympa::Spool::Held->new;
  my $authkey = $spool->store($message);

  my $spool =
      Sympa::Spool::Held->new(context => $list, authkey => $authkey);
  my ($message, $handle) = $spool->next;

  $spool->remove($handle, validated_by => $validator, quiet => 1);
  $spool->remove($handle);

=head1 DESCRIPTION

L<Sympa::Spool::Held> implements the spool for held messages waiting for
confirmation.

=head2 Methods

See also L<Sympa::Spool/"Public methods">.

=over

=item new ( [ context =E<gt> $list ], [ authkey =E<gt> $authkey ] )

=item next ( [ no_lock =E<gt> 1 ] )

If the pairs describing metadatas are specified,
contents returned by next() are filtered by them.

=item remove ( $handle, [ validated_by =E<gt> $email, [ quiet =E<gt> 1 ] ] )

If email is specified, rename message file to add it as extension, instead of
removing message file.
Otherwise, removes message file.

=item size ( )

Returns number of messages in the spool except which have extension.

=item store ( $message, [ original =E<gt> $original ] )

If storing succeeded, returns authentication key.

=back

=head2 Context and metadata

See also L<Sympa::Spool/"Marshaling and unmarshaling metadata">.

This class particularly gives following metadata:

=over

=item {authkey}

Authentication (confirmation or moderation) key generated automatically
when the message is stored into spool.

=item {validated_by}

Keeps an e-mail address of validator, if message has been renamed using
remove() with option.

=item {auth_method}

TBD.

=item {quiet}

TBD.

=back

=head1 CONFIGURATION PARAMETERS

Following site configuration parameters in sympa.conf will be referred.

=over

=item queueauth

Directory path of held message spool.

Note:
Named such by historical reason (don't confuse with L<Sympa::Spool::Auth>).

=back

=head1 SEE ALSO

L<sympa_msg(8)>, L<wwsympa(8)>,
L<Sympa::Message>, L<Sympa::Spool>.

=head1 HISTORY

L<Sympa::Spool::Held> appeared on Sympa 6.2.8.

=cut
