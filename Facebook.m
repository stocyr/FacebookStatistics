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
x = (first_date-smoothing:1:last_date+smoothing)';
y = zeros(length(x),1);

for i = 1:length(x)
        y(i) = length(find(d==x(i)));
end

%% filter the y values
windowWidth = 1;  % <<<===== CHANGE SMOOTHING VALUE HERE!!!!
halfWindow = windowWidth/2;
gaussFilter = gausswin(windowWidth);
gaussFilter = gaussFilter / sum(gaussFilter);   % Normalize
smoothY = conv(y, gaussFilter);
y2 = smoothY(ceil(halfWindow):end-floor(halfWindow));

% plot da shit
plot(x, y2, 'LineWidth', 2, 'LineSmoothing', 'on');
ylabel('posts / day'); grid;
datetick('x', 'dd. mmmm yyyy', 'keepticks');

% save as png
%filename = ['Plots/gauss_' int2str(windowWidth) '.png'];
%disp(['Saving as "' filename '"']);
%print('-dpng', filename);