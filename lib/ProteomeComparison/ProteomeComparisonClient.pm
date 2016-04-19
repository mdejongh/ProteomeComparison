package ProteomeComparison::ProteomeComparisonClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

ProteomeComparison::ProteomeComparisonClient

=head1 DESCRIPTION


A KBase module: ProteomeComparison


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => ProteomeComparison::ProteomeComparisonClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 compare_proteomes

  $return = $obj->compare_proteomes($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a ProteomeComparison.ProteomeComparisonParams
$return is a ProteomeComparison.ProteomeComparisonResult
ProteomeComparisonParams is a reference to a hash where the following keys are defined:
	genome1ws has a value which is a string
	genome1id has a value which is a string
	genome2ws has a value which is a string
	genome2id has a value which is a string
	sub_bbh_percent has a value which is a float
	max_evalue has a value which is a string
	output_ws has a value which is a string
	output_id has a value which is a string
ProteomeComparisonResult is a reference to a hash where the following keys are defined:
	report_name has a value which is a string
	report_ref has a value which is a string
	pc_ref has a value which is a string

</pre>

=end html

=begin text

$input is a ProteomeComparison.ProteomeComparisonParams
$return is a ProteomeComparison.ProteomeComparisonResult
ProteomeComparisonParams is a reference to a hash where the following keys are defined:
	genome1ws has a value which is a string
	genome1id has a value which is a string
	genome2ws has a value which is a string
	genome2id has a value which is a string
	sub_bbh_percent has a value which is a float
	max_evalue has a value which is a string
	output_ws has a value which is a string
	output_id has a value which is a string
ProteomeComparisonResult is a reference to a hash where the following keys are defined:
	report_name has a value which is a string
	report_ref has a value which is a string
	pc_ref has a value which is a string


=end text

=item Description



=back

=cut

 sub compare_proteomes
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_proteomes (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_proteomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_proteomes');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProteomeComparison.compare_proteomes",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_proteomes',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_proteomes",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_proteomes',
				       );
    }
}
 
  

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "ProteomeComparison.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'compare_proteomes',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method compare_proteomes",
            status_line => $self->{client}->status_line,
            method_name => 'compare_proteomes',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for ProteomeComparison::ProteomeComparisonClient\n";
    }
    if ($sMajor == 0) {
        warn "ProteomeComparison::ProteomeComparisonClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 ws_genome_id

=over 4



=item Description

A workspace ID that references a Genome data object.
@id ws KBaseGenomes.Genome


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 hit

=over 4



=item Description

int inner_pos - position of gene name in inner genome (see dataN field in ProteomeComparison
int score - bit score of blast alignment multiplied by 100
int percent_of_best_score - best bit score of all hits connected to either of two genes from this hit


=item Definition

=begin html

<pre>
a reference to a list containing 3 items:
0: (inner_pos) an int
1: (score) an int
2: (percent_of_best_score) an int

</pre>

=end html

=begin text

a reference to a list containing 3 items:
0: (inner_pos) an int
1: (score) an int
2: (percent_of_best_score) an int


=end text

=back



=head2 ProteomeComparison

=over 4



=item Description

string genome1ws - workspace of genome1 (depricated, use genome1ref instead)
string genome1id - id of genome1 (depricated, use genome1ref instead)
ws_genome_id genome1ref - reference to genome1
string genome2ws - workspace of genome2 (depricated, use genome2ref instead)
string genome2id - id of genome2 (depricated, use genome2ref instead)
ws_genome_id genome2ref - reference to genome2
float sub_bbh_percent - optional parameter, minimum percent of bit score compared to best bit score, default is 90
string max_evalue -  optional parameter, maximum evalue, default is 1e-10
list<string> proteome1names - names of genes of genome1
mapping<string, int> proteome1map - map from genes of genome1 to their positions
list<string> proteome2names - names of genes of genome2
mapping<string, int> proteome2map - map from genes of genome2 to their positions
list<list<hit>> data1 - outer list iterates over positions of genome1 gene names, inner list iterates over hits from given gene1 to genome2
list<list<hit>> data2 - outer list iterates over positions of genome2 gene names, inner list iterates over hits from given gene2 to genome1
@optional genome1ws
@optional genome1id
@optional genome1ref
@optional genome2ws
@optional genome2id
@optional genome2ref


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome1ws has a value which is a string
genome1id has a value which is a string
genome1ref has a value which is a ProteomeComparison.ws_genome_id
genome2ws has a value which is a string
genome2id has a value which is a string
genome2ref has a value which is a ProteomeComparison.ws_genome_id
sub_bbh_percent has a value which is a float
max_evalue has a value which is a string
proteome1names has a value which is a reference to a list where each element is a string
proteome1map has a value which is a reference to a hash where the key is a string and the value is an int
proteome2names has a value which is a reference to a list where each element is a string
proteome2map has a value which is a reference to a hash where the key is a string and the value is an int
data1 has a value which is a reference to a list where each element is a reference to a list where each element is a ProteomeComparison.hit
data2 has a value which is a reference to a list where each element is a reference to a list where each element is a ProteomeComparison.hit

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome1ws has a value which is a string
genome1id has a value which is a string
genome1ref has a value which is a ProteomeComparison.ws_genome_id
genome2ws has a value which is a string
genome2id has a value which is a string
genome2ref has a value which is a ProteomeComparison.ws_genome_id
sub_bbh_percent has a value which is a float
max_evalue has a value which is a string
proteome1names has a value which is a reference to a list where each element is a string
proteome1map has a value which is a reference to a hash where the key is a string and the value is an int
proteome2names has a value which is a reference to a list where each element is a string
proteome2map has a value which is a reference to a hash where the key is a string and the value is an int
data1 has a value which is a reference to a list where each element is a reference to a list where each element is a ProteomeComparison.hit
data2 has a value which is a reference to a list where each element is a reference to a list where each element is a ProteomeComparison.hit


=end text

=back



=head2 ProteomeComparisonParams

=over 4



=item Description

string genome1ws - workspace of genome1
string genome1id - id of genome1
string genome2ws - workspace of genome2
string genome2id - id of genome2
float sub_bbh_percent - optional parameter, minimum percent of bit score compared to best bit score, default is 90
string max_evalue -  optional parameter, maximum evalue, default is 1e-10
string output_ws - workspace of output object
string output_id - future id of output object


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome1ws has a value which is a string
genome1id has a value which is a string
genome2ws has a value which is a string
genome2id has a value which is a string
sub_bbh_percent has a value which is a float
max_evalue has a value which is a string
output_ws has a value which is a string
output_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome1ws has a value which is a string
genome1id has a value which is a string
genome2ws has a value which is a string
genome2id has a value which is a string
sub_bbh_percent has a value which is a float
max_evalue has a value which is a string
output_ws has a value which is a string
output_id has a value which is a string


=end text

=back



=head2 ProteomeComparisonResult

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a string
report_ref has a value which is a string
pc_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a string
report_ref has a value which is a string
pc_ref has a value which is a string


=end text

=back



=cut

package ProteomeComparison::ProteomeComparisonClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
