function f = mutualinfo_openfield_trace(spike_structure, pos_structure, velthreshold, dim)
%finds mutual info for a bunch of cells
%idea modified from  HippoBellum: acute cerebellar modulation alters hippocampal dynamics and function
%The spatial information content of a cell's activity (in bits) was defined as: I= Σ୧(λ୧⁄λ) x logଶ(λ୧⁄λ) x p୧, where λ is the mean calcium activity ( Σ୧ p୧ x λ୧), λ୧  is the mean
%calcium activity in the i-th pixel, and p୧ is the probability of being in bin I (Skaggs et al., 1997;
%Rochefort et al., 2011; Shuman et al., 2020).

tic




fields_spikes = fieldnames(spike_structure);
fields_pos = fieldnames(pos_structure);

if numel(fields_spikes) ~= numel(fields_pos)
  error('your spike and US structures do not have the same number of values. you may need to pad your US structure for exploration days')
end


for i = 1:numel(fields_spikes)
      fieldName_spikes = fields_spikes{i};
      fieldValue_spikes = spike_structure.(fieldName_spikes);
      peaks_time = fieldValue_spikes;

      index = strfind(fieldName_spikes, '_');
      spikes_date = fieldName_spikes(index(2)+1:end)

      fieldName_pos = fields_pos{i};
      fieldValue_pos = pos_structure.(fieldName_pos);
      pos = fieldValue_pos;

      index = strfind(fieldName_spikes, '_');
      pos_date = fieldName_spikes(index(2)+1:end)

      mutinfo = NaN(size(peaks_time,1),1);

velthreshold = 2;
vel = ca_velocity(pos);
%vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30.0005); %originally had this at 30, trying with 15 now
goodvel = find(vel(1,:)>=velthreshold);
goodtime = pos(goodvel, 1);
goodpos = pos(goodvel,:);

mintime = vel(2,1);
maxtime = vel(2,end);

numunits = size(peaks_time,1);

if numunits<=1
  mutualinfo_struct.(sprintf('MI_%s', spikes_date)) = NaN;
  warning('you have no spikes')
else
for k=1:numunits
  highspeedspikes = [];

  [c indexmin] = (min(abs(peaks_time(k,:)-mintime))); %
  [c indexmax] = (min(abs(peaks_time(k,:)-maxtime))); %
  currspikes = peaks_time(k,indexmin:indexmax);

  for i=1:length(currspikes) %finding if in good vel
    [minValue,closestIndex] = min(abs(currspikes(i)-goodtime));

    if minValue <= 1 %if spike is within 1 second of moving. no idea if good time
      highspeedspikes(end+1) = currspikes(i);
    end;
  end

%want highspeedspikes



  set(0,'DefaultFigureVisible', 'off');
  if length(highspeedspikes)>0
  [trace_mean occprob] = CA_normalizePosData_trace(highspeedspikes, goodpos, dim, 1.000);
  mutinfo(k) = mutualinfo([trace_mean', occprob']);
  else
    mutinfo(k) = NaN;
  end

end

mutualinfo_struct.(sprintf('MI_%s', spikes_date)) = mutinfo';
end
end

f = mutualinfo_struct;