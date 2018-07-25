function x = AnswerBase(tmp)
for i=123:9876  %這個for產生答案庫 
        unit_1 = rem(i,10);  %以下四行把四位數拆成四個各位數分別存到四個變數 
        unit_10 = rem(fix(i/10),10);
        unit_100 = rem(fix(i/100),10);
        unit_1000 = rem(fix(i/1000),10);
        if unit_1~=unit_10 && unit_1~=unit_100 && unit_1~=unit_1000 && unit_10~=unit_100 && unit_10~=unit_1000 && unit_100~=unit_1000
            answerBase(tmp,1) = unit_1000;
            answerBase(tmp,2) = unit_100;
            answerBase(tmp,3) = unit_10;
            answerBase(tmp,4) = unit_1;
            tmp=tmp+1;
        end
end
    x=answerBase;
end