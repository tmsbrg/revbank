package RevBank::Global;
use strict;
use POSIX qw(strftime);

sub import {
    require RevBank::Plugins;
    require RevBank::Users;
    no strict 'refs';
    my $caller = caller;
    *{"$caller\::ACCEPT"} = sub () { \1 };
    *{"$caller\::ABORT"}  = sub () { \2 };
    *{"$caller\::REJECT"} = sub () { \3 };
    *{"$caller\::NEXT"}   = sub () { \4 };
    *{"$caller\::DONE"}   = sub () { \5 };
    *{"$caller\::parse_user"} = \&RevBank::Users::parse_user;
    *{"$caller\::parse_amount"} = sub {
        my ($amount) = @_;
        defined $amount or return undef;
        length  $amount or return undef;
        $amount =~ /^(-)?[0-9]*(?:[,.][0-9]{1,2})?$/ or return undef;
        if ($1) {
            die "For our sanity, no negative amounts, please :).\n";
        }
        $amount =~ s/,/./g;
        if ($amount > 999) {
            die "That's way too much money, or an unknown barcode.\n";
        }
        return 0 + $amount;
    };
    *{"$caller\::call_hooks"} = \&RevBank::Plugins::call_hooks;
    *{"$caller\::say"} = sub {
        print @_, "\n";
    };
    *{"$caller\::now"} = sub {
        return strftime '%Y-%m-%d_%H:%M:%S', localtime;
    };

}

1;
__END__

=head1 NAME

RevBank::Global - Constants and utility functions

=head1 SYNOPSIS

    use RevBank::Global;

=head1 DESCRIPTION

This module unconditionally exports the following symbols into the calling
namespace:

=head2 ACCEPT, ABORT, REJECT, NEXT, DONE

Return codes for plugins. See L<RevBank::Plugins>.

=head2 say

Print with newline, in case your Perl version doesn't already have a C<say>.

=head2 call_hooks($hook, @arguments)

See C<call_hooks> in L<RevBank::Plugins>.

=head2 parse_amount($amount)

Returns the amount given if it is well formed, undef if it was not. Dies if
the given amount exceeds certain boundaries.

Commas are changed to periods so C<3,50> and C<3.50> both result in C<3.5>.

=head2 parse_user($username)

See C<parse_user> in L<RevBank::Users>.

Returns the canonical username, or undef if the account does not exist.

=head1 AUTHOR

Juerd Waalboer <#####@juerd.nl>

=head1 LICENSE

Pick your favourite OSI license.
