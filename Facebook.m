clear all
smoothing = 10; % days

%% open text file for reading
% format: "26.10.2011 06:57:35"
fid = fopen('dates.txt', 'r');
% scan file
input = textscan(fid, '%2d.%2d.%4d %2d:%2d:%2d', 'CollectOutput', 1);
% newest one is on to -> flip data
input = flipud(input{1});
% there are remaining other posts from profile pic, title pic etc. (5 pcs)
input = input(6:end,:);

%% parse date and time
% convert date/time to serial date number
input = double(input);
dt = datenum(input(:,3), input(:,2), input(:,1), input(:,4), input(:,5),...
    input(:,6));
% convert date to serial date number
d = datenum(input(:,3), input(:,2), input(:,1));
first_date = d(1);
last_date = d(end);

%% prepare linear axis and count number of posts / day
x = datenum((first_date-10*smoothing:1:last_date+5*smoothing)');
y = zeros(length(x),1);

for i = 1:length(x)
        y(i) = length(find(d==x(i)));
end

%% filter the y values
windowWidth = 150;  % <<<===== CHANGE SMOOTHING VALUE HERE!!!!
halfWindow = windowWidth/2;
gaussFilter = gausswin(windowWidth);
gaussFilter = gaussFilter / sum(gaussFilter);   % Normalize
smoothY = conv(y, gaussFilter);
y2 = smoothY(ceil(halfWindow):end-floor(halfWindow));

% plot semester end / begin
hold all;
sem1 = [datenum('19-sep-2011') datenum('20-jan-2012')];
sem2 = [datenum('15-feb-2012') datenum('15-jun-2012')];
sem3 = [datenum('19-sep-2012') datenum('20-jan-2013')];
sem4 = [datenum('15-feb-2013') datenum('15-jun-2013')];
sem5 = [datenum('10-sep-2013') datenum('20-jan-2014')];
sem6 = [datenum('15-feb-2014') datenum('15-jun-2014')];
alpha(0.5);
semester = fill([sem1(1) sem1(2) sem1(2) sem1(1)], [0 0 10 10], 'r');
fill([sem2(1) sem2(2) sem2(2) sem2(1)], [0 0 10 10], 'r');
fill([sem3(1) sem3(2) sem3(2) sem3(1)], [0 0 10 10], 'r');
fill([sem4(1) sem4(2) sem4(2) sem4(1)], [0 0 10 10], 'r');
fill([sem5(1) sem5(2) sem5(2) sem5(1)], [0 0 10 10], 'r');
fill([sem6(1) sem6(2) sem6(2) sem6(1)], [0 0 10 10], 'r');

% plot da shit
posts = plot(x, y2, 'LineWidth', 2, 'linesmoothing', 'on');

% cosmetics
xlim([datenum('01-aug-2011') datenum('01-apr-2014')]);
ylim([0 max(y2)*1.01]);
tick_locations = datenum(2011,8:1:40,1);
set(gca,'XTick',tick_locations);
ylabel('posts / day'); grid;
datetick('x', 'mmm yyyy', 'keeplimits', 'keepticks');
xticklabel_rotate;
legend([posts, semester], {'posts / day', 'semester period'});

% save as png
%filename = ['Plots/gauss_' int2str(windowWidth) '.png'];
%disp(['Saving as "' filename '"']);
%print('-dpng', filename);