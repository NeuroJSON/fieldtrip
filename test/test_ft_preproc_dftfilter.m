function test_ft_preproc_dftfilter

% WALLTIME 00:10:00
% MEM 2gb
% DEPENDENCY ft_preproc_dftfilter

% this is an issue related to numerical precision which is too strictly
% checked in ft_preproc_dftfilter (with spectral interpolation)

inspect_results = false; %true if visual inspection required
run_additional_tests = false; %true if particular tests needed

fs = 500;
lineFreq = 50;
nharmonics = 2;
start_time = -1; %s
end_time = 2.498; %s
nsamples = (end_time - start_time) * fs;
data = [];
data.time{1} = linspace(start_time, end_time, nsamples);

lnoise = zeros(nharmonics,nsamples);
for i = 1:nharmonics
    lnoise(i,:) = (1+hanning(nsamples))'.*sin((2.*pi.*data.time{1}).*(lineFreq*i));
end

data.trial{1} = randn(nharmonics,nsamples)+lnoise;
alphabet = ('a':'z').';
data.label = num2cell(alphabet(1:nharmonics));
data.fsample = fs;

cfg              = [];
cfg.dftfilter    = 'yes'; %apply line noise filter with spectrum interpolation
cfg.dftfreq      = linspace(lineFreq,lineFreq*nharmonics,nharmonics); %line noise and harmonic
cfg.dftreplace   = 'neighbour'; %spectral interpolation
cfg.dftbandwidth = 1:nharmonics; %width of window to be interpolated
cfg.dftneighbourwidth = repmat(2,nharmonics,1); %width of window from which to interpolate
datafilt1 = ft_preprocessing(cfg, data);

try
    cfg.dftreplace   = 'neighbour_fft';
    datafilt2 = ft_preprocessing(cfg, data); % this should now work thanks to some eps leniency
    ft_error('if the code ends up here, then something suddenly started working');
catch
    datafilt2 = data; %bypass the neighbour_fft method
end

cfg           = [];
cfg.dftfilter = 'yes';
cfg.dftfreq      = linspace(lineFreq,lineFreq*nharmonics,nharmonics);
datafilt3     = ft_preprocessing(cfg, data);

if inspect_results
    figure;
    subplot(2,2,1);plot(datafilt1.time{1}, data.trial{1}-datafilt1.trial{1}); ylim([-2.1 2.1]);xlabel('estimated linenoise neighbour');
    subplot(2,2,2);plot(datafilt2.time{1}, data.trial{1}-datafilt2.trial{1}); ylim([-2.1 2.1]);xlabel('estimated linenoise neighbour_fft','interpreter','none');
    subplot(2,2,3);plot(datafilt2.time{1}, data.trial{1}-datafilt3.trial{1}); ylim([-2.1 2.1]);xlabel('estimated linenoise static dft');
    subplot(2,2,4);plot(data.time{1}, lnoise); ylim([-2.1 2.1]);xlabel('simulated linenoise');

    figure; plot(data.time{1}, datafilt1.trial{1}-datafilt2.trial{1});
    title('difference between filtered signals obtained by "zero" and "neighbour" methods')
    % the difference here can be explained by the fact that neighbour_fft takes
    % an asymmetric band around 50/100 Hz, due to rounding in nearest I guess
end

if ~run_additional_tests
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% some other instances, testing ft_preproc_dftfilter directly
tim = (0:1999)./1000;
dat = randn(1, 2000) + (1+hanning(2000))'.*sin(2.*pi.*(tim).*50);
filt  = ft_preproc_dftfilter(dat, 1000, 50, 'dftreplace', 'neighbour');
filt2 = ft_preproc_dftfilter(dat, 1000, 50, 'dftreplace', 'neighbour_fft');

figure;plot(tim, dat-filt); hold on;plot(tim, (1+hanning(2000))'.*sin(2.*pi.*(tim).*50));
figure;plot(tim, dat-filt2); hold on;plot(tim, (1+hanning(2000))'.*sin(2.*pi.*(tim).*50));
figure;plot(filt, filt2, 'o');

tim = (0:2000)./1000;
dat = randn(1, 2001) + (1+hanning(2001))'.*sin(2.*pi.*(tim).*50);
filt = ft_preproc_dftfilter(dat, 1000, 50, 'dftreplace', 'neighbour');
try
 filt2 = ft_preproc_dftfilter(dat, 1000, 50, 'dftreplace', 'neighbour_fft');
 ft_error('if the code ends up here, then something suddenly started working');
catch
 % this is supposed to happen
end
  
figure;plot(tim, dat-filt); hold on;plot(tim, (1+hanning(2001))'.*sin(2.*pi.*(tim).*50));


dat = randn(3, 2001) + [(1+hanning(2001))'.*sin(2.*pi.*(tim).*53) ; (1+hanning(2001))'.*sin(2.*pi.*(tim).*79 - 0.025) ; (1+hanning(2001))'.*sin(2.*pi.*(tim).*127 + 0.002)];
filt = ft_preproc_dftfilter(dat, 1000, [53, 79, 127], 'dftreplace', 'neighbour', 'dftneighbourwidth', [1 1 1]);
figure; 
subplot(2,2,1); plot(tim, dat(1,:)-filt(1,:)); hold on;plot(tim, (1+hanning(2001))'.*sin(2.*pi.*(tim).*53));
subplot(2,2,2); plot(tim, dat(2,:)-filt(2,:)); hold on;plot(tim, (1+hanning(2001))'.*sin(2.*pi.*(tim).*79 - 0.025));
subplot(2,2,3); plot(tim, dat(3,:)-filt(3,:)); hold on;plot(tim, (1+hanning(2001))'.*sin(2.*pi.*(tim).*127 + 0.002));

tim = (0:5000)./678.253;
krn = (1+hanning(5000)')./2;
dat = randn(1, 5001) + ([krn(1:2500) ones(1,2501)]).*sin(2.*pi.*(tim).*50);
filt = ft_preproc_dftfilter(dat, 678.253, 50, 'dftreplace', 'neighbour', 'dftneighbourwidth', 2, 'dftbandwidth', 2);
figure;hold on;plot(tim, ([krn(1:2500) ones(1,2501)]).*sin(2.*pi.*(tim).*50));plot(tim, dat-filt)

tim = (0:4999)./1000;
krn = (1+hanning(5000)')./2;
dat = randn(1, 5000) + ([krn(1:2500) ones(1,2500)]).*sin(2.*pi.*(tim).*50);
filt = ft_preproc_dftfilter(dat, 1000, 50, 'dftreplace', 'neighbour', 'dftneighbourwidth', 2, 'dftbandwidth', 2);
figure;hold on;plot(tim, ([krn(1:2500) ones(1,2500)]).*sin(2.*pi.*(tim).*50));plot(tim, dat-filt)

%%%%%%%%%
% Code chunk from Sabine
samples_off = 2; % samples to add, so a full 50 Hz cycle doesn't fit

lengthsec= 4;  % data length in seconds
fs = 1000; % sampling rate
acfreq = 50; % set the powerline frequency, e.g., 50 or 60 Hz    

datlength = (lengthsec*fs);
dat = gausswin(datlength, round(datlength/100) )'; 
t= (0:(length(dat)-1))/fs;
noise = cos( 2 * pi * acfreq * t );

% spectrum interpolation 
filt_spec = ft_preproc_dftfilter(dat + noise, fs, acfreq, 'dftreplace', 'neighbour', ... 
'dftbandwidth', 2, 'dftneighbourwidth', 2 );

% add samples to the data to introduce leakage
datlength2 = (lengthsec*fs) + samples_off;  % LEAK, add samples, so a full cycle doesn't fit
dat2 = gausswin(datlength2, round(datlength2/100) )'; 
t2 = (0:(length(dat2)-1))/fs;
noise2 = cos( 2 * pi * acfreq * t2 );

% comment out error message in the dftfilter function, before running this
filt_spec_leak = ft_preproc_dftfilter(dat2 + noise2, fs, acfreq, 'dftreplace', 'neighbour', ... 
'dftbandwidth', 2, 'dftneighbourwidth', 2 );

figure;
hold all
plot( t , dat + noise,'k')
ylabel('Amplitude (a.u.)')
xlabel('Time (s)')
ylim( [ -1.25 2.05 ] )
xlim( [ 0 4.005 ] )
legend('Gaussian with 50 Hz line noise')
title('Gaussian with added 50 Hz sinusoid of constant amplitude - 4.003 s')

figure;
hold all
plot( t , filt_spec, 'b')
plot( t2 , filt_spec_leak,'r')
plot(t, dat,'k')
xlabel('Time (s)')
ylabel('Amplitude (a.u.)')
legend('Spectrum Interpolation Full Cycle', 'Spectrum Interpolation Not Full Cycle', ... 
'Original Clean Gaussian')

ylim( [ -0.5 1.5] )
xlim( [ 0 4 ] )
title(['DFT neighbour function used for mixed signal (gaussian + line noise)  - Data length = ' ... 
num2str(datlength/fs) ' s and ' num2str(datlength2/fs) ' s']);



