function func = ft_getuserfun(func, prefix)

% FT_GETUSERFUN will search the Matlab path for a function with the
% appropriate name, and return a function handle to the function.
% Considered are, in this order:
%  - the name itself, i.e. you get exactly the same func back as you put in;
%  - the name with the specified prefix;
%  - the name with 'ft_' and the specified prefix.
%
% For example, calling FT_GETUSERFUN('general', 'trialfun') might return a
% function named 'general', 'trialfun_general', or 'ft_trialfun_general',
% whichever of those is found first and is not a compatibility wrapper.
%
% If func is a function handle, it is returned as-is.
%
% If no appropriate function is found, a warning is issued and the empty
% array [] will be returned.

% Copyright (C) 2012, Eelke Spaak
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if isa(func, 'function_handle')
  % treat function handle as-is
elseif isfunction(func) && ~iscompatwrapper(func) && ~strncmp(which(func), matlabroot, length(matlabroot))
  % return custom user function, do not return MATLAB function (yet)
  func = str2func(func);
elseif isfunction([prefix '_' func]) && ~iscompatwrapper([prefix '_' func])
  func = str2func([prefix '_' func]);
elseif isfunction(['ft_' prefix '_' func])
  func = str2func(['ft_' prefix '_' func]);
elseif isfunction(func) && ~iscompatwrapper(func)
  % return custom user function, it might also be MATLAB function
  func = str2func(func);
else
  warning(['no function by the name ''' func ''', ''' prefix '_' func...
    ''', or ''ft_' prefix '_' func ''' could not be found']);
  func = [];
end