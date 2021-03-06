# Copyright (C) 2018 SUSE LLC
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
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

package OpenQA::Schema::ResultSet::DeveloperSessions;
use strict;
use base 'DBIx::Class::ResultSet';
use OpenQA::Schema::Result::DeveloperSessions;

sub register {
    my ($self, $job_id, $user_id) = @_;

    return $self->result_source->schema->txn_do(
        sub {
            my $session = $self->find({job_id => $job_id});
            if ($session) {
                # allow only one session per job
                return unless ($session->user_id eq $user_id);
            }
            else {
                # create a new session if none existed before
                $session = $self->create(
                    {
                        job_id  => $job_id,
                        user_id => $user_id,
                    });
            }
            return $session;
        });
}

sub unregister {
    my ($self, $job_id) = @_;



    # to keep track of the responsible developer, don't delete the database entry here
    # (it is deleted when the associated job is delete anyways)

    # however, we should cancel the job now
    return $self->result_source->schema->txn_do(
        sub {
            my $session = $self->find({job_id => $job_id}) or return 0;
            my $job = $session->job or return 0;
            return $job->cancel();
        });
}

1;
