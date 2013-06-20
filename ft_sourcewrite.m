function ft_sourcewrite(cfg, source)

% FT_SOURCEWRITE exports source analysis results to gifti or nifti format
% file, depending on whether the source locations are described by on a
% cortically constrained sheet (gifti) or by a regular 3D lattice (nifti).
%
% Use as
%  ft_sourcewrite(cfg, source)
% where source is a source structure obtained from FT_SOURCEANALYSIS and
% cfg is a structure that should contain
%
%  cfg.filename  = string, name of the file
%  cfg.parameter = string, functional parameter to be written to file
%
% To facilitate data-handling and distributed computing with the peer-to-peer
% module, this function has the following options:
%   cfg.inputfile   =  ...
% If you specify this the input data will be read from a *.mat
% file on disk. This mat file should contain only a single variable,
% corresponding with the input data structure.
%
% See also FT_SOURCEANALYSIS FT_SOURCEDESCRIPTIVES FT_VOLUMEWRITE

% Copyright (C) 2011, Jan-Mathijs Schoffelen
% Copyright (C) 2011-2013, Jan-Mathijs Schoffelen, Robert Oostenveld
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

revision = '$Id$';

ft_defaults
ft_preamble init
ft_preamble provenance
ft_preamble trackconfig
ft_preamble debug
ft_preamble loadvar source

source = ft_checkdata(source, 'datatype', 'source', 'feedback', 'yes');

% ensure that the required options are present
cfg = ft_checkconfig(cfg, 'required', {'parameter', 'filename'});

% get the options
cfg.parameter    = ft_getopt(cfg, 'parameter');
cfg.filename     = ft_getopt(cfg, 'filename');
cfg.filetype     = ft_getopt(cfg, 'filetype'); % the default is determined further down
cfg.parcellation = ft_getopt(cfg, 'parcellation'); % can be used for cifti

if isempty(cfg.filetype)
  if isfield(source, 'dim')
    % source positions are on a regular 3D lattice, save as nifti
    cfg.filetype = 'nifti';
  elseif isfield(source, 'tri')
    % there is a specification of a 2D cortical sheet, save as gifti
    cfg.filetype = 'gifti';
  else
    error('the input data does not look like a 2D sheet, nor as a 3D regular volume');
  end
end

switch (cfg.filetype)
  case 'nifti'
    if numel(cfg.filename)<=4 || ~strcmp(cfg.filename(end-3:end), '.nii');
      cfg.filename = cat(2, cfg.filename, '.nii');
    end
    
    % convert functional data into 4D
    dat = getsubfield(source, cfg.parameter);
    dat = reshape(dat, source.dim(1), source.dim(2), source.dim(3), []);
    
    if ~isfield(source, 'transform')
      source.transform = pos2transform(source.pos);
    end
    
    % this is a bit of a kludge, but ft_write_mri can write 3D and 4D nifti
    ft_write_mri(cfg.filename, dat, 'dataformat', 'nifti', 'transform', source.transform);
    
  case 'gifti'
    if numel(cfg.filename)<=4 || ~strcmp(cfg.filename(end-3:end), '.gii');
      cfg.filename = cat(2, cfg.filename, '.gii');
    end
    
    % this is a bit of a kludge, but ft_write_headshape can write gifti including data
    ft_write_headshape(cfg.filename, source, 'data', getsubfield(source, cfg.parameter), 'format', 'gifti');
    
  case 'cifti'
    if numel(cfg.filename)<=4 || ~strcmp(cfg.filename(end-3:end), '.nii');
      cfg.filename = cat(2, cfg.filename, '.nii');
    end
    
    % this is a bit of a kludge, but ft_write_headshape can write cifti including data and the parcellation
    % note that the low-level function requires quite some details
    ft_write_headshape(cfg.filename, source, 'parameter', cfg.parameter, 'parcellation', cfg.parcellation, 'format', 'cifti');
    
  otherwise
    error('unsupported output format (%s)', cfg.filetype);
end % switch filetype

ft_postamble debug
ft_postamble trackconfig
ft_postamble provenance
