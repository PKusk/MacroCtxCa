function score_trace = PK_time_idx_to_score_trace(time_idx_file,window,range,total_length)
% Input
%time_idx_file = dvnt_stims;
%window = [10 20];
%range = [-1 1];
%total_length = 12000;

template_trace = ones(1,total_length);

for ii = 1:length(time_idx_file)
template_trace(time_idx_file(ii)-window(1):time_idx_file(ii)+window(2))=2;
end

score_trace = rescale(template_trace,range(1),range(2));
end