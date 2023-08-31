function f = plotPCAscores(scores, envCSUSmatrix, princcopnumber)
  %plots principle component scores for all eyeblink trials
  %CS/US matrix should come from movingtimetraining or equivalent. will be a matrix where first row is either 1 or 2 to indicate env A or B, second row is 10 or 20 or 0 to indicate CS/US/neither

k=1;
cstimes = find(envCSUSmatrix(2,:)==10);
cs_start = [];
while k<=length(envCSUSmatrix)
  overtime = (find(cstimes>k));
  overtime = min(overtime);
  if length(overtime>0);
  overtime = overtime(1);
  overtime = cstimes(overtime);
  cs_start(end+1) = overtime;
  end

  k=overtime+15;
end



scorematrixA = NaN(19, length(cs_start));
scorematrixB = NaN(19, length(cs_start));
env = NaN(1, length(cs_start));
for i=1:length(cstimes)
  curstart = cstimes(i);
  curend = curstart+18;
  wantedscore = scores(curstart:curend, princcopnumber);
  if envCSUSmatrix(1,curstart) == 1
  scorematrixA(:,i) = wantedscore;
  else

  scorematrixB(:,i) = wantedscore;
  end
end

f = [scorematrixA,scorematrixB];


figure
plot(scorematrixA, 'Color', [0.3010 0.7450 0.9330], 'LineWidth', .2);
hold on
plot(scorematrixB, 'Color', [.9 .7 .7], 'LineWidth', .2);
plot(nanmean(scorematrixA'), 'Color', [0 0.4470 0.7410], 'LineWidth', 4)
plot(nanmean(scorematrixB'), 'Color', 'red', 'LineWidth', 4)
