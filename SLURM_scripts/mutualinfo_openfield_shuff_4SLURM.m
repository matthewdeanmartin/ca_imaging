function mutualinfo_openfield_shuff_4SLURM

  maxNumCompThreads(str2num(getenv('SLURM_NPROCS')));

  % Refresh MATLAB's toolbox cache
  rehash toolboxcache;

  % Custom configuration for the cluster (if required)
  configCluster;

%{
  c = parcluster;
  c.AdditionalProperties.AccountName = 'p32072'; % Replace with your actual account name
  c.AdditionalProperties.WallTime = '24:00:00'; % Set to match the wall time in your SLURM script
  c.AdditionalProperties.QueueName = 'normal';
  c.AdditionalProperties.MemUsage = '64gb';


  % Set the number of computational threads to the number of allocated CPUs
  if ~isempty(getenv('SLURM_CPUS_PER_TASK'))
      maxNumCompThreads(str2num(getenv('SLURM_CPUS_PER_TASK')));
  end
%}

    addpath(pwd);
    addpath(genpath('/home/hsw967/Programming/ca_imaging'));
    addpath(genpath('/home/hsw967/Programming/data_analysis/hannah-in-use/matlab/'));


%  pool = c.parpool(8);

%file allvariables.mat should contain
  %all_traces
  %MI
  %MI_trace
  %peaks
  %pos

allvariables = load('allvariables.mat');
pos_structure = allvariables.pos;
spikes = allvariables.peaks;
ca_MI = allvariables.MI;

f = mutualinfo_openfield_shuff(spikes, pos_structure, 2, 2.5, 5, ca_MI)
MI_shuff = f;
% Save the output to a .mat file


try
    save('./mutualinfo_shuff_output.mat', 'MI_shuff');
catch e
    disp('Error occurred while saving the file:');
    disp(e.message);
end


end
