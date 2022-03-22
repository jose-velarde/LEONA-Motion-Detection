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

% if exist('arqposlight') 
%     poslight = load(arqposlight);                                               % load positive light data	


% posplot = poslight(find( poslight(:,1) > 0 ...              % split +cg from -cg
%           & poslight(:,11)>=tstart & poslight(:,11)<tend ...
%           & poslight(:,6)>=new_minlatplot & poslight(:,6)<=new_maxlatplot ...
%           & poslight(:,7)>=new_minlonplot & poslight(:,7)<=new_maxlonplot) ,:);

posplot = poslight(( poslight(:,1) > 0 ...              % split +cg from -cg
          & poslight(:,11)>=tstart & poslight(:,11)<tend ...
          & poslight(:,6)>=new_minlatplot & poslight(:,6)<=new_maxlatplot ...
          & poslight(:,7)>=new_minlonplot & poslight(:,7)<=new_maxlonplot) ,:);
      
%     posplot_all = poslight(find( poslight(:,11)>=tstart & poslight(:,11)<tend ...
%               & poslight(:,6)>=minlatplot & poslight(:,6)<=maxlatplot ...
%               & poslight(:,7)>=minlonplot & poslight(:,7)<=maxlonplot) ,:);
% end

set(pos_cg_plot, 'XData', posplot(:,7), 'YData',posplot(:,6));

%% Find and plot -CG

% if exist('arqneglight') 
%     neglight = load(arqneglight);                                               % load negative light data	

% negplot = neglight(find( neglight(:,1) < 0 ......
%           & neglight(:,11)>=tstart & neglight(:,11)<tend ...
%           & neglight(:,6)>=new_minlatplot & neglight(:,6)<=new_maxlatplot ...
%           & neglight(:,7)>=new_minlonplot & neglight(:,7)<=new_maxlonplot) ,:);

negplot = neglight((neglight(:,1) < 0 ......
          & neglight(:,11)>=tstart & neglight(:,11)<tend ...
          & neglight(:,6)>=new_minlatplot & neglight(:,6)<=new_maxlatplot ...
          & neglight(:,7)>=new_minlonplot & neglight(:,7)<=new_maxlonplot) ,:);

%     negplot_all = neglight(find( neglight(:,11)>=tstart & neglight(:,11)<tend ...
%               & neglight(:,6)>=minlatplot & neglight(:,6)<=maxlatplot ...
%               & neglight(:,7)>=minlonplot & neglight(:,7)<=maxlonplot) ,:);   
% end

set(neg_cg_plot, 'XData', negplot(:,7), 'YData',negplot(:,6));

%% Total Lightning
totpos = size(posplot,1);               % number of positives lightings
totneg = size(negplot,1);               % number of negatives lightings
tot = totpos + totneg;                  % positives + negatives lightings restricted to precedent constraint...

%% Get +CG current peak and temperature

pos_peak = [];
k = 1;
for k1=1:size(posplot,1)
    tr = find( abs(posplot(k1,6)-lts) == min(abs(posplot(k1,6)-lts)) );
    tc = find( abs(posplot(k1,7)-lns) == min(abs(posplot(k1,7)-lns)) );
%     change peak current to column 8
%     pos_peak(k) = posplot(k1,8);
    pos_peak(k) = posplot(k1,1);

    % temppos is the associated temperature of the CG
    if length(tr)==1 & length(tc)==1
       temppos(k)=couttemp(tr,tc);
    % get average if CG has 2 associated temperatures
    elseif length(tr)~=1 & length(tc)==1 
           temppos(k)=(couttemp(tr(1),tc) + couttemp(tr(2),tc))/2;
    elseif length(tr)==1 & length(tc)~=1
           temppos(k) = (couttemp(tr,tc(1)) + couttemp(tr,tc(2)))/2;
    % get average if CG has 4 associated temperatures
    else
        temppos(k)=(couttemp(tr(1),tc(1)) + couttemp(tr(2),tc(1))+...
        couttemp(tr(1),tc(2)) + couttemp(tr(2),tc(2)))/4;
    end
    k = k + 1;
end 
pos_peak = pos_peak(:);
temppos = temppos(:);      % ensure temppos is in column-wise

%% Get -CG current peak and temperature

neg_peak = [];
rows_neg = [];
cols_neg = [];
k = 1;
for k1=1:size(negplot,1)
    tr=find( abs(negplot(k1,6)-lts) == min(abs(negplot(k1,6)-lts)) );
    tc=find( abs(negplot(k1,7)-lns) == min(abs(negplot(k1,7)-lns)) );
    
    neg_peak(k) = negplot(k1,1);
    
    if length(tr)==1 & length(tc)==1
       tempneg(k)=couttemp(tr,tc);

    elseif length(tr)~=1 & length(tc)==1 
           tempneg(k)=(couttemp(tr(1),tc)+couttemp(tr(2),tc))/2;
    elseif length(tr)==1 & length(tc)~=1
           tempneg(k)=(couttemp(tr,tc(1))+couttemp(tr,tc(2)))/2;
    else
        tempneg(k)=(couttemp(tr(1),tc(1))+couttemp(tr(2),tc(1))+...
        couttemp(tr(1),tc(2))+couttemp(tr(2),tc(2)))/4;
    end
    k = k + 1;
end 
neg_peak = neg_peak(:);
tempneg = tempneg(:);


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

%% Create the histograms
% *************************************************************************

% Ts5 = -100:5:10;                        % edges vector (5 in 5)
Ts2 = -100:2:10;                        % edges vector (2 in 2)
% Ts1 = -100:1:10;                        % edges vector (1 in 1)
% Initialize the histograms vectors for deltaT = 2 C
ntspr2 = zeros(length(Ts2),1);

ntpos2 = ntspr2;
ntneg2 = ntspr2;


if ~isempty(posplot)
    ntpos2 = histc(temppos,Ts2);
    ntpos2 =  ntpos2(:);
end

if ~isempty(negplot)
    ntneg2 = histc(tempneg,Ts2);
    ntneg2 =  ntneg2(:);
end

nttot2 = ntpos2 + ntneg2;

xtick_histogram(ktt_aux) = str2double(hh{index}) + str2double(mm{index})/60; % current time
% xtick_histogram(ktt_aux) = str2double(UTC(1:2)) + str2double(UTC(3:4))/60; % current time

% Concatenate the current histogram vector into a matrix (used to create the spectrogram image)

temptimepos2(:,ktt_aux) = ntpos2;
temptimeneg2(:,ktt_aux) = ntneg2;
temptimetot2(:,ktt_aux) = nttot2;


uistack(neg_cg_plot,'top')
uistack(pos_cg_plot,'top')

