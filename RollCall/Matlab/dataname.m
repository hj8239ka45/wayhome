function name = dataname()
    fileID = fopen('CARD_ID_Name.txt', 'r');
    formatSpec = '%s %s %s %s %s';
    N = 5;
    C_text = textscan(fileID,formatSpec);
    fclose(fileID);
    for i=1:N
        C(:,i) = string(C_text{i});
    end
    name = C(:,1);
end