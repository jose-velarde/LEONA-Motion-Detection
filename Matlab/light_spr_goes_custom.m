%% Boilerplate
if ktt_aux == 1
    current_day = 'force_initial_load';
    new_minlatplot = minlatplot;
    new_minlonplot = minlonplot; 
    new_maxlatplot = maxlatplot;
    new_maxlonplot = maxlonplot;

    neg_cg_plot = plot(-65, -30, '.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',9);
    pos_cg_plot = plot(-65, -30, '+','MarkerEdgeColor','m','MarkerFaceColor','m','MarkerSize',6);
% CPTEC Style
%     neg_cg_plot = plot(-65, -30, 'dk', 'Color', 'black', 'MarkerFaceColor', 'green' );
%     pos_cg_plot = plot(-65, -30, 'pk', 'Color', 'black', 'MarkerFaceColor', 'red' , 'MarkerSize', 12 );
end
%% Load/read data on each new day, NOTE: won't load if midnight scan is missing
if ~strcmp(current_day, DD{index})
    if strcmp(load_cg_data, 'Yes')
        load(strcat('./data_mat/', image_name, '_cg', '.mat'));
        neglight = poslight;
        delete(neg_cg_plot)
%         neg_cg_plot = plot(-65, -30, 'dk', 'Color', 'black', 'MarkerFaceColor', 'green' );
        neg_cg_plot = plot(-65, -30, '.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',9);
        delete(pos_cg_plot)
%         pos_cg_plot = plot(-65, -30, 'pk', 'Color', 'black', 'MarkerFaceColor', 'red' , 'MarkerSize', 12);
        pos_cg_plot = plot(-65, -30, '+','MarkerEdgeColor','m','MarkerFaceColor','m','MarkerSize',6);
        fprintf('Finished loading cg data \n')
    else
        lightning_file = strcat('C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\BrasilDAT_data\days_cg\',...
            YYYY{index}, '-',...
            MM{index}, '-',...
            DD{index}, '_cg.csv');
        poslight = csvread(lightning_file, 1, 0);
        neglight = poslight; % temporary
        save(strcat('./data_mat/', image_name, '_cg', '.mat'), 'poslight');
        delete(neg_cg_plot)
%         neg_cg_plot = plot(-65, -30, 'dk', 'Color', 'black', 'MarkerFaceColor', 'green' );
        neg_cg_plot = plot(-65, -30, '.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',9);

        delete(pos_cg_plot)
%         pos_cg_plot = plot(-65, -30, 'pk', 'Color', 'black', 'MarkerFaceColor', 'red' , 'MarkerSize', 12 );
        pos_cg_plot = plot(-65, -30, '+','MarkerEdgeColor','m','MarkerFaceColor','m','MarkerSize',6);

        fprintf('Finished saving cg data \n')
    end
    current_day = DD{index};
    postlight = poslight(:,2)+ poslight(:,3)/60.0 + poslight(:,4)/3600.0;       % calculate decimal time
    poslight(:,11) = postlight;	
    
    
%     negtlight = neglight(:,2)+ neglight(:,3)/60.0 + neglight(:,4)/3600.0;       % calculate decimal time
    negtlight = postlight; % temporary
    neglight(:,11) = negtlight;	
end
himg = str2double(hh{index});
minimg = str2double(mm{index});
% tstart = (himg + minimg/60.0) - 0.08333;                % 5 minutes before
% tend = tstart + 0.16666;                                 % 5 minutes after
tstart = (himg + minimg/60.0) - 0.125;                % 7.5 minutes before
tend = tstart + 0.25;                                 % 7.5 minutes after

%% Find and plot +CG

posplot = poslight(( poslight(:,1) > 0 ...              % split +cg from -cg
          & poslight(:,11)>=tstart & poslight(:,11)<tend ...
          & poslight(:,6)>=new_minlatplot & poslight(:,6)<=new_maxlatplot ...
          & poslight(:,7)>=new_minlonplot & poslight(:,7)<=new_maxlonplot) ,:);
      
set(pos_cg_plot, 'XData', posplot(:,7), 'YData',posplot(:,6));

%% Find and plot -CG

negplot = neglight((neglight(:,1) < 0 ......
          & neglight(:,11)>=tstart & neglight(:,11)<tend ...
          & neglight(:,6)>=new_minlatplot & neglight(:,6)<=new_maxlatplot ...
          & neglight(:,7)>=new_minlonplot & neglight(:,7)<=new_maxlonplot) ,:);

set(neg_cg_plot, 'XData', negplot(:,7), 'YData',negplot(:,6));

%% Total Lightning
totpos = size(posplot,1);               % number of positives lightings
totneg = size(negplot,1);               % number of negatives lightings
tot = totpos + totneg;                  % positives + negatives lightings restricted to precedent constraint...

%% Get +CG current peak, temperature and row/col

pos_lightning = zeros(20000,4);
k = 1;
for k1=1:size(posplot,1)
    tr = find( abs(posplot(k1,6)-lts) == min(abs(posplot(k1,6)-lts)) );
    tc = find( abs(posplot(k1,7)-lns) == min(abs(posplot(k1,7)-lns)) );

    pos_lightning(k,1:2) = [tr tc];
    pos_lightning(k,3) = couttemp(tr,tc);
    pos_lightning(k,4) = posplot(k1,1);

    k = k + 1;
end 

%% Get -CG current peak and temperature

neg_lightning = zeros(20000,4);

k = 1;
for k1=1:size(negplot,1)
    tr=find( abs(negplot(k1,6)-lts) == min(abs(negplot(k1,6)-lts)) );
    tc=find( abs(negplot(k1,7)-lns) == min(abs(negplot(k1,7)-lns)) );
    
    neg_lightning(k,1:2) = [tr tc];
    neg_lightning(k,3)=couttemp(tr,tc);
    neg_lightning(k,4) = negplot(k1,1);

    k = k + 1;
end 

neg_lightning = setdiff(neg_lightning, zeros(20000,4),'rows');
pos_lightning = setdiff(pos_lightning, zeros(20000,4),'rows');
tot_lightning = [neg_lightning; pos_lightning];

%% Create the histograms
% *************************************************************************

% Ts5 = -100:5:10;                        % edges vector (5 in 5)
Ts2 = -100:2:10;                        % edges vector (2 in 2)
% Ts1 = -100:1:10;                        % edges vector (1 in 1)
% Initialize the histograms vectors for deltaT = 2 C
% ntspr2 = zeros(length(Ts2),1);
% 
% ntpos2 = ntspr2;
% ntneg2 = ntspr2;


if ~isempty(posplot)
    ntpos2 = histc(pos_lightning(:,3),Ts2);
    ntpos2 =  ntpos2(:);
end

if ~isempty(negplot)
    ntneg2 = histc(neg_lightning(:,3),Ts2);
    ntneg2 =  ntneg2(:);
end

nttot2 = ntpos2 + ntneg2;

xtick_histogram(ktt_aux) = str2double(hh{index}) + str2double(mm{index})/60; % current time

% Concatenate the current histogram vector into a matrix (used to create the spectrogram image)

temptimepos2(:,ktt_aux) = ntpos2;
temptimeneg2(:,ktt_aux) = ntneg2;
temptimetot2(:,ktt_aux) = nttot2;

%% Associate Lightning to Regions -52C
pos_lightning_core = pos_lightning;
neg_lightning_core = neg_lightning;

for current_region = current_labels(~cellfun(@isempty, {current_labels.label}))
    current_label = str2double(current_region.label);

    current_labels(current_label).pos_light = pos_lightning_core(ismember(pos_lightning_core(:,1:2),current_labels(current_label).pixels,'rows'),:);
    pos_lightning_core = setdiff(pos_lightning_core, current_labels(current_label).pos_light,'rows');
    
    current_labels(current_label).neg_light = neg_lightning_core(ismember(neg_lightning_core(:,1:2),current_labels(current_label).pixels,'rows'),:);
    neg_lightning_core = setdiff(neg_lightning_core, current_labels(current_label).neg_light,'rows');
end

%% Associate Lightning to Regions -72C
pos_lightning_most = pos_lightning;
neg_lightning_most = neg_lightning;

for current_region = current_labels3(~cellfun(@isempty, {current_labels3.label}))
    current_label = str2double(current_region.label);

    current_labels3(current_label).pos_light = pos_lightning_most(ismember(pos_lightning_most(:,1:2),current_labels3(current_label).pixels,'rows'),:);
    pos_lightning_most = setdiff(pos_lightning_most, current_labels3(current_label).pos_light,'rows');
    
    current_labels3(current_label).neg_light = neg_lightning_most(ismember(neg_lightning_most(:,1:2),current_labels3(current_label).pixels,'rows'),:);
    neg_lightning_most = setdiff(neg_lightning_most, current_labels3(current_label).neg_light,'rows');
end
%% Associate Lightning to Regions -32C
neg_lightning_cover = neg_lightning;
pos_lightning_cover = pos_lightning;

for current_region = current_labels2(~cellfun(@isempty, {current_labels2.label}))
    current_label = str2double(current_region.label);

    current_labels2(current_label).pos_light = pos_lightning_cover(ismember(pos_lightning_cover(:,1:2),current_labels2(current_label).pixels,'rows'),:);
    pos_lightning_cover = setdiff(pos_lightning_cover, current_labels2(current_label).pos_light,'rows');
    
    current_labels2(current_label).neg_light = neg_lightning_cover(ismember(neg_lightning_cover(:,1:2),current_labels2(current_label).pixels,'rows'),:);
    neg_lightning_cover = setdiff(neg_lightning_cover, current_labels2(current_label).neg_light,'rows');
end

%%
% % Loop 4 -  % positive light associated with sprite 
% if ~isempty(possprplot)                                        
% k = 1;
% for k1=1:size(possprplot,1)
%     tr=find( abs(possprplot(k1,6)-lts) == min(abs(possprplot(k1,6)-lts)) );
%     tc=find( abs(possprplot(k1,7)-lns) == min(abs(possprplot(k1,7)-lns)) );
%     if length(tr)==1 & length(tc)==1
%         tempposspr(k)=couttemp(tr,tc);
%     elseif length(tr)~=1 & length(tc)==1 
%         tempposspr(k)=(couttemp(tr(1),tc)+couttemp(tr(2),tc))/2;
%     elseif length(tr)==1 & length(tc)~=1
%         tempposspr(k)=(couttemp(tr,tc(1))+couttemp(tr,tc(2)))/2;
%     else
%         tempposspr(k)=(couttemp(tr(1),tc(1))+couttemp(tr(2),tc(1))+...
%             couttemp(tr(1),tc(2))+couttemp(tr(2),tc(2)))/4;
%     end
%     k=k+1;
% end  
% if size(tempposspr,2)>size(tempposspr,1)
%     tempposspr=tempposspr';
% end
% end

% Loop 5 -  % negative light associated with sprite 
% if ~isempty(negsprplot)
% k = 1;
% for k1=1:size(negsprplot,1)
%     tr = find( abs(negsprplot(k1,6)-lts) == min(abs(negsprplot(k1,6)-lts)) );
%     tc = find( abs(negsprplot(k1,7)-lns) == min(abs(negsprplot(k1,7)-lns)) );
%     if length(tr)==1 & length(tc)==1
%        tempnegspr(k)=couttemp(tr,tc);
%     elseif length(tr)~=1 & length(tc)==1 
%            tempnegspr(k) = (couttemp(tr(1),tc)+couttemp(tr(2),tc))/2;
%     elseif length(tr)==1 & length(tc)~=1
%            tempnegspr(k) = (couttemp(tr,tc(1))+couttemp(tr,tc(2)))/2;
%     else
%         tempnegspr(k) = (couttemp(tr(1),tc(1))+couttemp(tr(2),tc(1))+...
%         couttemp(tr(1),tc(2))+couttemp(tr(2),tc(2)))/4;
%     end
%     k=k+1;
% end  
% if size(tempnegspr,2)>size(tempnegspr,1)
%     tempnegspr=tempnegspr';
% end
 %end
% waitforbuttonpress
% pause(0.01)




uistack(neg_cg_plot,'top')
uistack(pos_cg_plot,'top')
