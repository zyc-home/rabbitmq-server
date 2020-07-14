%% This Source Code Form is subject to the terms of the Mozilla Public
%% License, v. 2.0. If a copy of the MPL was not distributed with this
%% file, You can obtain one at https://mozilla.org/MPL/2.0/.
%%
%% Copyright (c) 2011-2020 VMware, Inc. or its affiliates.  All rights reserved.
%%

-module(peer_discovery_dns_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("amqp_client/include/amqp_client.hrl").
-include_lib("eunit/include/eunit.hrl").

-compile(export_all).

all() ->
    [
     {group, non_parallel}
    ].

groups() ->
    [
      {non_parallel, [], [
                          hostname_discovery_with_long_node_names,
                          hostname_discovery_with_short_node_names,
                          node_discovery_with_long_node_names,
                          node_discovery_with_short_node_names,
                          test_aaaa_record_hostname_discovery
                         ]}
    ].

suite() ->
    [
      %% If a test hangs, no need to wait for 30 minutes.
      {timetrap, {minutes, 1}}
    ].


%% -------------------------------------------------------------------
%% Testsuite setup/teardown.
%% -------------------------------------------------------------------

-define(DISCOVERY_ENDPOINT_RECORD_A, "peer_discovery.tests.ipv4.rabbitmq.com").

-define(DISCOVERY_ENDPOINT_RECORD_AAAA, "www.v6.facebook.com").

init_per_suite(Config) ->
    rabbit_ct_helpers:log_environment(),
    rabbit_ct_helpers:run_setup_steps(Config).

end_per_suite(Config) ->
    rabbit_ct_helpers:run_teardown_steps(Config).


init_per_testcase(test_aaaa_record, Config) ->
    case inet_res:lookup(?DISCOVERY_ENDPOINT_RECORD_AAAA, in, aaaa) of
        []      ->
            {skip, "pre-configured AAAA record does not resolve, skipping"};
        [_ | _] ->
            Config
    end;

init_per_testcase(_Testcase, Config) ->
    case inet_res:lookup(?DISCOVERY_ENDPOINT_RECORD_A, in, a) of
        []      ->
            {skip, "pre-configured *.rabbitmq.com record does not resolve, skipping"};
        [_ | _] ->
            Config
    end.


end_per_testcase(_Testcase, Config) ->
    case inet_res:lookup(?DISCOVERY_ENDPOINT_RECORD_A, in, a) of
        []      ->
            {skip, "pre-configured *.rabbitmq.com record does not resolve, skipping"};
        [_ | _] ->
            Config
    end.


%% -------------------------------------------------------------------
%% Test cases
%% -------------------------------------------------------------------

test_aaaa_record_hostname_discovery(_) ->
    Result = rabbit_peer_discovery_dns:discover_hostnames(?DISCOVERY_ENDPOINT_RECORD_AAAA, true),
    ?assert(string:str(lists:flatten(Result), "facebook.com") > 0).

hostname_discovery_with_long_node_names(_) ->
    Result = rabbit_peer_discovery_dns:discover_hostnames(?DISCOVERY_ENDPOINT_RECORD_A, true),
    ?assert(lists:member("www.rabbitmq.com", Result)).

hostname_discovery_with_short_node_names(_) ->
    Result = rabbit_peer_discovery_dns:discover_hostnames(?DISCOVERY_ENDPOINT_RECORD_A, false),
    ?assert(lists:member("www", Result)).

node_discovery_with_long_node_names(_) ->
    Result = rabbit_peer_discovery_dns:discover_nodes(?DISCOVERY_ENDPOINT_RECORD_A, true),
    ?assert(lists:member('ct_rabbit@www.rabbitmq.com', Result)).

node_discovery_with_short_node_names(_) ->
    Result = rabbit_peer_discovery_dns:discover_nodes(?DISCOVERY_ENDPOINT_RECORD_A, false),
    ?assert(lists:member(ct_rabbit@www, Result)).
