function [time,exist] = CumulativeTime(name)
    DATAName=[char(name) '.txt'];
    fileID = fopen(DATAName, 'r');
    formatSpec = '%s %s %s %s %s %s %s %s %s %s %s %s';
    N = 12;
    C_text = textscan(fileID,formatSpec);
    fclose(fileID);
    
    for i=1:N
        C(:,i) = string(C_text{i});
    end
    [C_row,C_column ]= size(C);
    
    time = 0;
    for i = 1:fix((C_row-1)/2)
        for j = 1:6
            time_2(j) = str2num(char(C(i*2+1,j+5)));
            time_1(j) = str2num(char(C(i*2,j+5)));
        end
        time = datenum(time_2)-datenum(time_1) + datenum(time);
    end
    time = string(datevec(time));
    exist =  string(C(C_row,12));
    if exist == ''
        exist = string('off');
    end
end
