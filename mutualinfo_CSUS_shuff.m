function mutualinfo_struct = mutualinfo_CSUS_shuff(spike_structure, CSUS_structure, do_you_want_CSUS_or_CSUSnone, how_many_divisions, num_times_to_run, MI_CSUS)
%finds 'mutual info' for CS/US/ non CS/US
%CSUS_structure should come from BULKconverttoframe.m
%do_you_want_CSUS_or_CSUSnone: 1 for only cs us, 0 for cs us none
%how many divisions you wanted-- for ex,
    % do_you_want_CSUS_or_CSUSnone = 1
    % how_many_divisions = 2 will just split between cs and us
                        %= 10 will split CS and US each into 5
%right now because im lazy how_many_divisions must be a factor of 10

divisions = how_many_divisions;
fields_spikes = fieldnames(spike_structure);
fields_CSUS = fieldnames(CSUS_structure);
fields_MI = fieldnames(MI_CSUS);

if numel(fields_spikes) ~= numel(fields_CSUS)
  error('your spike and US structures do not have the same number of values. you may need to pad your US structure for exploration days')
end


for i = 1:numel(fields_spikes)
      fieldName_spikes = fields_spikes{i};
      fieldValue_spikes = spike_structure.(fieldName_spikes);
      peaks_time = fieldValue_spikes;

      index = strfind(fieldName_spikes, '_');
      spikes_date = fieldName_spikes(index(2)+1:end);

      fieldName_CSUS = fields_CSUS{i};
      fieldValue_CSUS = CSUS_structure.(fieldName_CSUS);
      CSUS = fieldValue_CSUS;

      fieldName_MI = fields_MI{i};
      fieldValue_MI = MI_CSUS.(fieldName_MI);
      MI = fieldValue_MI;

      index = strfind(fieldName_spikes, '_');
      CSUS_date = fieldName_spikes(index(2)+1:end)

      numunits = size(peaks_time,1);

      time = CSUS(2,:);
      CSUS = CSUS(1,:);

      occ_in_CS_US = zeros(1,10);
      occ_intertrial = zeros(1,1);
      if do_you_want_CSUS_or_CSUSnone==1
        numbering = 10./divisions;
        previousz = 0;
        for z=0:numbering:10 %%%%%%fix

            if z==0
              occ_intertrial = length(find(CSUS ==0));
            else
              wanted1 = find(CSUS > previousz);
              wanted2 = find(CSUS <= z);
              wanted = intersect(wanted1,wanted2);
              occ_in_CS_US(z) = length(wanted);
              CSUS(wanted) = z;
              previousz = z;
            end
          end

      elseif do_you_want_CSUS_or_CSUSnone==0
          error(' have not written this code yet') %%%%%%%%%%%%%%%%%%%%%%%%
          %should be easy to impliment, already tagging all those times with 0s and counting them
          %just need to decide if i want all the times or just a little before cs/us
          %probably want the latter so need to tag them, prob want to do that outside this code
      end

      mutinfo = NaN(3,numunits);
      if numunits<=1 | length(unique(CSUS))<3
          mutualinfo_struct.(sprintf('MI_%s', spikes_date)) = NaN;
          warning('you have no cells or no spikes or no CS/US')
      else
          for k=1:size(peaks_time,1)
              currspikes = peaks_time(k,:);
              if isnan(MI(k))==1
                  mutinfo(1, k) = NaN;
                  mutinfo(2, k) = NaN;
                  mutinfo(3, k) = NaN;
                  continue
              end


              set(0,'DefaultFigureVisible', 'off');
              shuf = NaN(num_times_to_run,1);
              if length(currspikes)>0  %finding how many spikes in each time bin
                parfor l = 1:num_times_to_run
                  spikes_in_CS_US = zeros(1,10);
                  spikes_intertrial = zeros(1,1);
                    wanted = find(CSUS > 0);
                    shuffCSUS = CSUS;
                    shufff = wanted(randperm(length(wanted)));
                    shuffCSUS(wanted) = CSUS(shufff);
                                for q =1:length(currspikes)
                                [c index] = (min(abs(currspikes(q)-time))); %
                                spikebin = shuffCSUS(index);
                                                  if spikebin == 0
                                                    spikes_intertrial = spikes_intertrial+1;
                                                  else
                                                    spikes_in_CS_US(spikebin) = spikes_in_CS_US(spikebin)+1;
                                                  end
                                  end
                          occprob = occ_in_CS_US.*(1/7.5);
                          spikeprob =  spikes_in_CS_US;
                          shuf(l) = mutualinfo([spikeprob', occprob']); %is this oriented the right way
                      end

                      topMI5 = floor(num_times_to_run*.95);
                      topMI1 = floor(num_times_to_run*.99);
                      shuf = sort(shuf);
                      if isnan(topMI5)==0
                        mutinfo(1, k) = shuf(topMI5);
                      else
                        mutinfo(1, k) = NaN;
                      end
                      if isnan(topMI1)==0
                        mutinfo(2, k) = shuf(topMI1);
                      else
                        mutinfo(2, k) = NaN;
                      end

                      [c index] = (min(abs(MI(k)-shuf)));
                      if isnan(index)==0
                        rank = index./length(shuf);
                        mutinfo(3, k) = rank;
                      else
                        mutinfo(3,k) = NaN;
                      end

                  else
                          mutinfo(1,k) = NaN;
                          mutinfo(2,k) = NaN;
                          mutinfo(3,k) = NaN;
                  end




            end %for k=1:size(peaks_time,1)
        end %if numunits<=1

            mutualinfo_struct.(sprintf('MI_%s', spikes_date)) = mutinfo';
    end


      MI_CSUS_shuff = mutualinfo_struct;

      % Get the current date and time as a string
      currentDateTime = datestr(now, 'yyyymmdd_HHMMSS');
      % Create a filename with the timestamp
      filename = ['mutualinfo_CSUS_shuff_', currentDateTime, '.mat'];
      % Save the output to the .mat file with the timestamped filename
      save(filename, 'MI_CSUS_shuff');

      f = MI_CSUS_shuff;