function name = data(a)
     fileID = fopen('CARD_ID_Name.txt', 'r');
     formatSpec = '%s %s %s %s %s';
     N = 5;
     C_text = textscan(fileID,formatSpec);
     fclose(fileID);
     for i=1:N
            C(:,i) = string(C_text{i});
     end
     [C_row,C_column ]= size(C);
     flag = 0;
     A = string(a);
     for i=1:C_row
        if A(1)==C(i,2)&&A(2)==C(i,3)&&A(3)==C(i,4)&&A(4)==C(i,5)
            flag = 1;
            name = C(i,1)
            break;
        end
     end
     if flag==0
         name = "Noname"
     end
end
