function f = plotchar(cellcenters, characteristic)
%plots cell centers in a color corresponding to a (numerical) characteristic such as field location

bicenter = NaN(size(cellcenters,2),1);
for k=1:size(cellcenters,2)
  f1f = characteristic(k, 1); %field center forward
  f1b = characteristic(k, 2); %field center backward
  if isnan(f1f)==1 && isnan(f1b)==1
    bicenter(k) = NaN;
  elseif isnan(f1f)==1
    bicenter(k) = f1b;
  elseif isnan(f1b)==1
    bicenter(k) = f1f;
  elseif abs(f1f-f1b) <= 15 %same field
    bicenter(k) = mean(f1f, f1b)
  elseif abs(f1f-f1b) > 15
    bicenter(k) = NaN;
  end
end
f1f = characteristic(:, 1);
f1b = characteristic(:, 2)

%{
figure
subplot(1,3,1)
colors = ((f1f) - min(f1f))./max(f1f); %normalize to 0:1
colors = colors*100;
%colors = colors(indexes3,:);
c = colorbar;
%set(gca, 'clim', [min(indexes2),100]);
sizes = 100;
size(cellcenters)
size(colors)
scatter(cellcenters(3,:), cellcenters(4,:), sizes, colors, 'filled')
colorbar
title('Forward Direction')


subplot(1,3,2)
colors = (f1b - min(f1b))./max(f1b); %normalize to 0:1
colors = colors*100;
%colors = colors(indexes3,:);
c = colorbar;
%set(gca, 'clim', [min(indexes2),100]);
sizes = 100;
scatter(cellcenters(3,:), cellcenters(4,:), sizes, colors, 'filled')
colorbar
title('Backward Direction')

subplot(1,3,3)
%}
figure
colors = (bicenter - min(bicenter))./max(bicenter); %normalize to 0:1
colors = colors*100;
%colors = colors(indexes3,:);
c = colorbar;
%set(gca, 'clim', [min(indexes2),100]);
sizes = 100;
scatter(cellcenters(3,:), cellcenters(4,:), sizes, colors, 'filled')
colorbar
title('Both Directions')
