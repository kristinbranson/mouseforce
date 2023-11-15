

labels1 = load('label_file_modified_labels.mat');
labels2 = load('oldlabels.mat');


for i = 1:size(labels2.tblLbls, 1)
    row = labels2.tblLbls(i, :);

    idx = find(row.frm == labels1.tblLbls.frm);
    if isempty(idx) || strcmp(row.mov{1}, labels1.tblLbls.mov{idx, 1}) ~= 1
        labels1.tblLbls = [labels1.tblLbls; row];
    end
end

tblLbls = labels1.tblLbls;
save('merged.mat', 'tblLbls');
