%% This Source Code Form is subject to the terms of the Mozilla Public
%% License, v. 2.0. If a copy of the MPL was not distributed with this
%% file, You can obtain one at https://mozilla.org/MPL/2.0/.
%%
%% Copyright (c) 2007-2020 VMware, Inc. or its affiliates.  All rights reserved.
%%

-module(rabbit_queue_location_client_local).
-behaviour(rabbit_queue_master_locator).

-include_lib("rabbit_common/include/rabbit.hrl").
-include("amqqueue.hrl").

-export([description/0, queue_master_location/1]).

-rabbit_boot_step({?MODULE,
                   [{description, "locate queue master client local"},
                    {mfa,         {rabbit_registry, register,
                                   [queue_master_locator,
                                    <<"client-local">>, ?MODULE]}},
                    {requires,    rabbit_registry},
                    {enables,     kernel_ready}]}).


%%---------------------------------------------------------------------------
%% Queue Master Location Callbacks
%%---------------------------------------------------------------------------

description() ->
    [{description, <<"Locate queue master node as the client local node">>}].

queue_master_location(Q) when ?is_amqqueue(Q) ->
    {ok, node()}.
