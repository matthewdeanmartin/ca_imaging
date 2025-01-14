function f = ca_maxrate(spike_times, pos, dim)
  %finds max rate for a cell

  tic
  maxrate = NaN(2, size(spike_times,1));

  velthreshold = 8;
  vel = ca_velocity(pos);
  vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
  goodvel = find(vel(1,:)>=velthreshold);
  goodtime = pos(goodvel, 1);
  goodpos = pos(goodvel,:);

  numunits = size(spike_times,1);

  for k=1:numunits
    highspeedspikes = [];
    for i=1:length(spike_times(k,:)) %finding if in good vel
      [minValue,closestIndex] = min(abs(spike_times(k,i)-goodtime));

      if minValue <= 1 %if spike is within 1 second of moving. no idea if good time
        highspeedspikes(end+1) = spike_times(k,i);
      end;
    end

    %gets direction
    fwd = [];
    bwd = [];
    for z = 1:length(highspeedspikes)
      [minValue,closestIndex] = min(abs(pos(:,1)-highspeedspikes(z)));
      if pos(max(closestIndex-15, 1),2)-pos(min(closestIndex+15,length(pos)),2)>0
        fwd(end+1) = highspeedspikes(z);
      else
        bwd(end+1) = highspeedspikes(z);
      end
    end


    %subplot(ceil(sqrt(numunits)),ceil(sqrt(numunits)), k)


    set(0,'DefaultFigureVisible', 'off');

    if length(fwd)./length(goodtime)*30 >.01
    goodpos(:,3) = 1;
    [rate totspikes totstime colorbar spikeprob occprob] = normalizePosData(fwd,goodpos,dim, 2.5);

    maxrate(1, k) = max(rate);
    meanrate(1,k) = nanmean(rate);

    else
      maxrate(1, k) = NaN;
      meanrate(1,k) = NaN;
    end


    if length(bwd)./length(goodtime)*30 >.01
    goodpos(:,3) = 1;
    [rate totspikes totstime colorbar spikeprob occprob] = normalizePosData(bwd,goodpos,dim, 2.5);
    maxrate(2, k) = max(rate);
    meanrate(2,k) = nanmean(rate);

    else
      maxrate(2, k) = NaN;
      meanrate(2,k) = NaN;

    end


  end

  f = [maxrate'*dim, meanrate'*dim];
