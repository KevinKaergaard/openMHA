% This function tests that when two TCP clients connect to the MHA,
% it is not possible for one connection to block the other by flooding
% the MHA with commands.
%
% This file is part of the HörTech Open Master Hearing Aid (openMHA)
% Copyright © 2018 HörTech gGmbH

% openMHA is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published by
% the Free Software Foundation, version 3 of the License.
%
% openMHA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License, version 3 for more details.
%
% You should have received a copy of the GNU Affero General Public License, 
% version 3 along with openMHA.  If not, see <http://www.gnu.org/licenses/>.

function test_multiple_tcp_connections_no_starvation
  % create an MHA for this test
  mha = mha_start();
  unittest_teardown(@mha_set, mha, 'cmd', 'quit');

  % Make sure conn 1 is connected
  mha_set(mha, 'instance', 'test_multiple_tcp_connections_no_starvation');
  
  % flood the MHA with 2 commands that take 1 second each to process over conn 2
  system(sprintf('(echo sleep=1;echo sleep=1) | nc -w 1 %s %d &', ...
                 mha.host, mha.port));

  % let half a second pass
  pause(0.5);
  
  % While the MHA is still flooded in connection 2 for about 1.5 seconds,
  % change a setting over conn 1.   Measure how long this 
  start_time = tic;
  mha_set(mha, 'nchannels_in', 2);
  duration = toc(start_time)

  % Instead of 1.5 seconds, this should have only taken about 0.5 seconds,
  % because the MHA serves 1 command from each connection round-robin
  assert_difference_below(0, duration, 0.6);
end

% Local Variables:
% mode: octave
% coding: utf-8-unix
% indent-tabs-mode: nil
% End:
