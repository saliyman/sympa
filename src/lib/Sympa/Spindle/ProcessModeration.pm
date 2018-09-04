# -*- indent-tabs-mode: nil; -*-
# vim:ft=perl:et:sw=4
# $Id: Commands.pm 12548 2015-11-28 08:33:32Z sikeda $

# Sympa - SYsteme de Multi-Postage Automatique
#
# Copyright (c) 1997, 1998, 1999 Institut Pasteur & Christophe Wolfhugel
# Copyright (c) 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
# 2006, 2007, 2008, 2009, 2010, 2011 Comite Reseau des Universites
# Copyright (c) 2011, 2012, 2013, 2014, 2015, 2016, 2017 GIP RENATER
# Copyright 2017, 2018 The Sympa Community. See the AUTHORS.md file at the
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

package Sympa::Spindle::ProcessModeration;

use strict;
use warnings;

use Sympa;
use Conf;
use Sympa::Language;
use Sympa::Log;
use Sympa::Tools::Data;
use Sympa::Tools::Text;
use Sympa::Topic;

use base qw(Sympa::Spindle);

my $language = Sympa::Language->instance;
my $log      = Sympa::Log->instance;

use constant _distaff => 'Sympa::Spool::Moderation';

sub _init {
    my $self  = shift;
    my $state = shift;

    if ($state == 0) {
        die 'bug in logic. Ask developer'
            if ($self->{rejected_by} or $self->{validated_by})
            and not($self->{context} and $self->{authkey});
    }

    1;
}

sub _on_garbage {
    my $self   = shift;
    my $handle = shift;

    if ($self->{rejected_by} or $self->{validated_by}) {
        # Keep broken message and skip it.
        $handle->close;
    } else {
        $self->{distaff}->quarantine($handle);
    }
}

sub _on_failure {
    my $self    = shift;
    my $message = shift;
    my $handle  = shift;

    if ($self->{rejected_by} or $self->{validated_by}) {
        # Keep failed message and exit.
        $handle->close;
        # Terminate processing.
        $self->{finish} = 'failure';
    } else {
        $self->{distaff}->quarantine($handle);
    }
}

sub _on_success {
    my $self    = shift;
    my $message = shift;
    my $handle  = shift;

    if ($self->{rejected_by}) {
        # Remove succeeded message and exit.
        $self->{distaff}->remove($handle)
            and $self->{distaff}->html_remove($message);
        # Terminate processing.
        $self->{finish} = 'success';
    } elsif ($self->{validated_by}) {
        # Add extension to be distributed later.
        $self->{distaff}->remove(
            $handle,
            validated_by => $self->{validated_by},
            quiet        => $self->{quiet}
        );
        # Terminate processing.
        $self->{finish} = 'success';
    } else {
        # Remove succeeded message, and continue processing.
        $self->{distaff}->remove($handle)
            and $self->{distaff}->html_remove($message);
    }
}

sub _twist {
    my $self    = shift;
    my $message = shift;

    if ($self->{rejected_by}) {
        return _reject($self, $message);
    } elsif ($self->{validated_by}) {
        return _validate($self, $message);
    } else {
        return _distribute($self, $message);
    }
}

# Private subroutines.

sub _reject {
    my $self    = shift;
    my $message = shift;

    # Messages marked validated should not be rejected.
    return 0 if $message->{validated_by};

    # Assign distributing user as envelope sender to whom DSN will be sent.
    $message->{envelope_sender} = $self->{rejected_by};

    unless (ref $message->{context} eq 'Sympa::List') {
        $log->syslog('notice', 'Unknown list %s', $message->{localpart});
        Sympa::send_dsn($message->{context} || '*', $message, {}, '5.1.1');
        return undef;
    }
    my $list = $message->{context};

    $language->push_lang(
        $list->{'admin'}{'lang'},
        Conf::get_robot_conf($list->{'domain'}, 'lang'),
        $Conf::Conf{'lang'}, 'en'
    );

    if ($message->{sender}) {
        # Notify author of message.
        if (not $self->{quiet} or $self->{reject_blacklist}) {
            my $reject_template = $self->{reject_template}
                if $self->{reject_template}
                and $self->{reject_template} =~ /\A[-\w]+\z/;

            my $param = {
                subject       => $message->{decoded_subject},
                rejected_by   => $self->{rejected_by},
                template_used => $reject_template,
            };
            Sympa::send_file($list, ($reject_template || 'reject'),
                $message->{sender}, $param)
                or Sympa::send_dsn($list, $message, {}, '5.3.0');    #FIXME
        }

        # Add to blacklist if necessary.
        if ($self->{reject_blacklist}) {
            my $status = _add_in_blacklist($list, $message->{sender});
            #FIXME: add_stash() acording to $status
            if ($status) {
                $log->syslog('info', 'Added %s to %s blacklist',
                    $message->{sender}, $list);
            } elsif (defined $status) {                              # 0
                $log->syslog('info', '%s already in %s blacklist',
                    $message->{sender}, $list);
            } else {                                                 # undef
                $log->syslog('notice', 'Unable to add %s to %s blacklist',
                    $message->{sender}, $list);
            }
        }
    } else {
        $log->syslog(
            'err',
            'No sender found for message %s. Unable to use their address to add to blacklist or send notification',
            $message
        );
    }

    _signal_spam($self, $message) if $self->{reject_signal_spam};

    # Notify list moderator.
    # Ensure 1 second elapsed since last message.
    Sympa::send_file(
        $list,
        'message_report',
        $self->{rejected_by},
        {   type           => 'success',            # Compat. <=6.2.12.
            entry          => 'message_rejected',
            auto_submitted => 'auto-replied',
            key            => $message->{authkey}
        },
        date => time + 1
    );

    $log->add_stat(
        robot     => $list->{'domain'},
        list      => $list->{'name'},
        operation => 'reject',
        mail      => $self->{rejected_by},
        client    => $self->{scenario_context}->{remote_addr}
    );

    $language->pop_lang;

    1;
}

#FIXME:robot blacklist not yet availible.
# Old name: _add_in_blacklist() in wwsympa.fcgi.
sub _add_in_blacklist {
    $log->syslog('debug3', '(%s, %s)', @_);
    my $list  = shift;
    my $entry = shift;

    my $email = Sympa::Tools::Text::canonic_email($entry);
    unless ($email and Sympa::Tools::Text::valid_email($email)) {
        $log->syslog('err', 'Incorrect parameter %s', $entry);
        return undef;
    }

    my $dir = $list->{'dir'} . '/search_filters';
    unless (-d $dir or mkdir $dir, 0755) {
        $log->syslog('err', 'Unable to create dir %s: %m', $dir);
        return undef;
    }
    my $file = $dir . '/blacklist.txt';

    my $lock_fh = Sympa::LockedFile->new($file, 5, '+>>');
    unless ($lock_fh) {
        $log->syslog('err', 'Could not create new lock for %s', $file);
        return undef;
    }

    seek $lock_fh, 0, 0;
    my $nl = 0;
    while (<$lock_fh>) {
        $nl = /\n$/ ? 1 : 0;
        next if /\A\s*\z/ or /\A[#;]/;

        my $regexp = $_;
        chomp $regexp;
        $regexp =~ s/([^\s\w\x80-\xFF])/\\$1/g;
        $regexp =~ s/\\[*]/.*/g;
        if ($email =~ /\A$regexp\z/i) {
            $lock_fh->close;
            return 0;
        }
    }

    seek $lock_fh, 0, 2;
    print $lock_fh "\n" unless $nl;
    printf $lock_fh "%s\n", $email;

    close $lock_fh;

    1;
}

# Old name: (part of) do_reject() in wwsympa.fcgi.
sub _signal_spam {
    my $self    = shift;
    my $message = shift;

    my $list = $message->{context};
    my $script =
        Conf::get_robot_conf($list->{'domain'}, 'reporting_spam_script_path');
    return unless $self->{'reject_signal_spam'} and $script;

    my $pipeout;
    unless (-x $script) {
        $log->syslog(
            'err',
            'Ignoring parameter reporting_spam_script_path, value %s because not an executable script',
            $script
        );
    } elsif (open $pipeout, '|-', $script) {
        # Sending encrypted form in case a crypted message would be
        # sent by error.
        print $pipeout $message->as_string(original => 1);
        if (close $pipeout) {
            $log->syslog('info', 'Message %s reported as spam', $message);
        } else {
            $log->syslog('err', 'Could not report message %s as spam: %m',
                $message);
        }
    } else {
        $log->syslog('err', 'Could not execute %s: %m', $script);
    }
}

sub _validate {
    my $self    = shift;
    my $message = shift;

    # Messages marked validated should not be validated again.
    return 0 if $message->{validated_by};

    unless (ref $message->{context} eq 'Sympa::List') {
        $log->syslog('notice', 'Unknown list %s', $message->{localpart});
        #FIXME: use add_stash().
        Sympa::send_dsn($message->{context} || '*', $message, {}, '5.1.1');
        return undef;
    }

    # Register topics if specified.
    if ($self->{topics}) {
        Sympa::Topic->new(topic => $self->{topics}, method => 'editor')
            ->store($message);
    }

    1;    # See also _on_success().
}

sub _distribute {
    my $self    = shift;
    my $message = shift;

    # Messages _not_ marked validated should not be distributed.
    return 0 unless $message->{validated_by};

    my $distributed_by =
        Sympa::Tools::Text::canonic_email($message->{validated_by});
    # Compat. <= 6.2.36.
    $distributed_by = Sympa::get_address($message->{context}, 'editor')
        unless Sympa::Tools::Text::valid_email($distributed_by);
    # Overwrite attributes.
    $self->{distributed_by} = $distributed_by;
    $self->{quiet} ||= !!$message->{quiet};

    # Decrpyt message.
    # If encrypted, it will be re-encrypted by succeeding processes.
    $message->smime_decrypt;

    # Assign distributing user to envelope sender.
    $message->{envelope_sender} = $self->{distributed_by};

    unless (ref $message->{context} eq 'Sympa::List') {
        $log->syslog('notice', 'Unknown list %s', $message->{localpart});
        Sympa::send_dsn($message->{context} || '*', $message, {}, '5.1.1');
        return undef;
    }
    my $list = $message->{context};

    $language->set_lang(
        $list->{'admin'}{'lang'},
        Conf::get_robot_conf($list->{'domain'}, 'lang'),
        $Conf::Conf{'lang'}, 'en'
    );

    $message->add_header('X-Validation-by', $self->{distributed_by});

    $message->{shelved}{dkim_sign} = 1
        if Sympa::Tools::Data::is_in_array(
        $list->{'admin'}{'dkim_signature_apply_on'}, 'any')
        or Sympa::Tools::Data::is_in_array(
        $list->{'admin'}{'dkim_signature_apply_on'},
        'editor_validated_messages');

    # Notify author of message.
    unless ($self->{quiet}) {
        $message->{envelope_sender} = $message->{sender};
        Sympa::send_dsn($message->{context}, $message, {}, '2.1.5');
        $message->{envelope_sender} = $self->{distributed_by};
    }

    return ['Sympa::Spindle::DistributeMessage'];
}

1;
__END__

=encoding utf-8

=head1 NAME

Sympa::Spindle::ProcessModeration - Workflow of message moderation

=head1 SYNOPSIS

  use Sympa::Spindle::ProcessModeration;
  
  my $spindle = Sympa::Spindle::ProcessModeration->new(
      rejected_by => $email, context => $robot, authkey => $key);
  my $spindle = Sympa::Spindle::ProcessModeration->new(
      validated_by => $email, context => $robot, authkey => $key);
  $spindle->spin;
  
  my $spindle = Sympa::Spindle::ProcessModeration->new->spin;

=head1 DESCRIPTION

L<Sympa::Spindle::ProcessModeration> defines workflow for moderation of
messages.

When spin() method is invoked, it reads a message in moderation spool and
reject, validate or distribute it.

Either validation or rejection failed or not, spin() will terminate
processing.  In these cases
failed message will be kept in spool and wait for moderation again.

If distribution mode is specified, it reads messages in moderation spool
and distribute validated ones of them.

=head2 Public methods

See also L<Sympa::Spindle/"Public methods">.

=over

=item new ( rejected_by =E<gt> $email,
context =E<gt> $context, authkey =E<gt> $key,
[ reject_template =E<gt> $template ],
[ reject_blacklist =E<gt> 1 ], [ reject_signal_spam =E<gt> 1 ],
[ quiet =E<gt> 1 ] )

=item new ( validated_by =E<gt> $email,
context =E<gt> $context, authkey =E<gt> $key,
[ topics =E<gt> $string ],
[ quiet =E<gt> 1 ] )

=item new ( )

=item spin ( )

new() may take following options:

=over

=item rejected_by =E<gt> $email

=item validated_by =E<gt> $email

E-mail address of the user who distributed or rejected the message.
It is given by DISTRIBUTE or REJECT command.

Note:
C<distributed_by> parameter was deprecated on Sympa 6.2.37b.

=item context =E<gt> $context

=item authkey =E<gt> $key

Context (List or Robot) and authorization key to specify the message in
spool.

=item quiet =E<gt> 1

If this option is set, automatic replies reporting result of processing
to the user (see L</"validated_by"> and L</"rejected_by">) will not be sent.

=back

=back

=head2 Properties

See also L<Sympa::Spindle/"Properties">.

=over

=item {distaff}

Instance of L<Sympa::Spool::Moderation> class.

=item {finish}

C<'success'> is set if rejection or validation succeeded.
C<'failure'> is set if rejection or validation failed.

=back

=head1 SEE ALSO

L<Sympa::Message>,
L<Sympa::Spindle>, L<Sympa::Spindle::DistributeMessage>,
L<Sympa::Spool::Moderation>.

=head1 HISTORY

L<Sympa::Spindle::ProcessModeration> appeared on Sympa 6.2.13.
Validation mode was introduced on Sympa 6.2.37b.

=cut
