%manual vessel region move
function velo_manual_region_move(orilocation,destination_folder,condition)
for i=1:length(orilocation)
    cd(orilocation{i})
    slash_pos=findstr(orilocation{i},'\');
    fname=orilocation{i}(slash_pos(3)+1:end);
    fname(findstr(fname,'\'))='_';
    copyfile('Result\datas_conclusion_quick.mat',[destination_folder,'\',condition,'_',fname,'.mat']);
end
    
