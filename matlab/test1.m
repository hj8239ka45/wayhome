function [x y] =test1(answerBase,remaind,refer,a,b)
    temp=1;  %temp只是一個拿來計數變數 
    remain=0;
     for i=1:remaind
         %填裝a值和b值，但要區別於之前的人類輸入的a值b值 
         aa = 0;
         bb = 0;
         %以下兩個for用來比對第i個答案和亂數取的答案的是幾a幾b 
         for j=1:4  
             for k=1:4
                 if answerBase(i,j)==refer(k)
                     if j==k
                         aa=aa+1;
                     else
                         bb=bb+1;
                     end
                 end
             end
         end
         %比對 end
         if ((aa==a)&&(bb==b))
			for k=1:4
                answerbase(temp,k)=answerBase(i,k);
            end
			remain=remain+1;
            temp=temp+1;
         end
     end
     if remain ==0
         msgbox('Cheater！= =+');
         pause(3);
         close all;
     end
     disp(refer);
     x = remain;
     y = answerbase;
end
