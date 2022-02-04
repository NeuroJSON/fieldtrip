function inspect_pull1970

% WALLTIME 00:10:00
% MEM 2gb
% DEPENDENCY ft_databrowser

cfg = [];
cfg.dataset = dccnpath('/home/common/matlab/fieldtrip/data/Subject01.ds');
cfg = ft_definetrial(cfg);
cfg.trl = cfg.trl(1:20,:);
cfg.trl(:,3) = cfg.trl(:,1)-1;
cfg.demean = 'yes';
cfg.channel = 'MEG';
data = ft_preprocessing(cfg);

%%
% all viewmodes can work with component data

cfg = [];
cfg.method = 'pca';
comp = ft_componentanalysis(cfg, data);

%%

cfg = [];
cfg.plotevents = 'no';
cfg.viewmode = 'vertical';
ft_databrowser(cfg, comp)

%%

cfg = [];
cfg.plotevents = 'no';
cfg.viewmode = 'butterfly';
ft_databrowser(cfg, comp)

%%

cfg = [];
cfg.plotevents = 'no';
cfg.viewmode = 'component';
ft_databrowser(cfg, comp)

%%

cfg = [];
cfg.plotevents = 'no';
cfg.viewmode = 'multiplot';
cfg.layout = 'CTF151_helmet.mat';
ft_databrowser(cfg, data)
