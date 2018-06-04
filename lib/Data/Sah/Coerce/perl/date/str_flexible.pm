package Data::Sah::Coerce::perl::date::str_flexible;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 3,
        enable_by_default => 0,
        might_fail => 1,
        prio => 60, # a bit lower than normal
        precludes => [qr/\A(str_alami(_.+)?|str_natural)\z/],
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};
    my $coerce_to = $args{coerce_to} // 'float(epoch)';

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"DateTime::Format::Flexible"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my \$datetime; eval { \$datetime = DateTime::Format::Flexible->parse_datetime($dt) }; ",
        ($coerce_to eq 'float(epoch)' ? "if (\$@) { ['Invalid date format'] } else { [undef, \$datetime->epoch] } " :
             $coerce_to eq 'Time::Moment' ? "if (\$@) { ['Invalid date format'] } else { \$datetime->set_time_zone('UTC'); [undef, Time::Moment->from_object(\$datetime) ] } " :
             $coerce_to eq 'DateTime' ? "if (\$@) { ['Invalid date format'] } else { [undef, \$datetime] } " :
             (die "BUG: Unknown coerce_to '$coerce_to'")),
        "}",
    );

    $res;
}

1;
# ABSTRACT: Coerce date from string parsed by DateTime::Format::Flexible

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["date", "x.perl.coerce_rules"=>["str_flexible"]]
