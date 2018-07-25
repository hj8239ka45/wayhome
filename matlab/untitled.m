function varargout = untitled(varargin)
% UNTITLED MATLAB code for untitled.fig
%      UNTITLED, by itself, creates a new UNTITLED or raises the existing
%      singleton*.
%
%      H = UNTITLED returns the handle to a new UNTITLED or the handle to
%      the existing singleton*.
%
%      UNTITLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED.M with the given input arguments.
%
%      UNTITLED('Property','Value',...) creates a new UNTITLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 04-Jun-2018 17:11:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;
x=randperm(10)-1;
x=x(1:4);
handles.value = x;
disp(x);
set(handles.result_text,'String',0);

%第二題先影藏
set(handles.player_text,'Visible','off');
set(handles.player_edit_1,'Visible','off');
set(handles.player_edit_2,'Visible','off');
set(handles.player_output,'Visible','off');
set(handles.text_a,'Visible','off');
set(handles.text_b,'Visible','off');
set(handles.computor_guess,'Visible','off');
set(handles.text10,'Visible','off');
set(handles.text11,'Visible','off');
set(handles.text13,'Visible','off');
set(handles.text14,'Visible','off');
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in start.


function computer_edit_Callback(hObject, eventdata, handles)

% hObject    handle to player_edit_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of player_edit_1 as text
%        str2double(get(hObject,'String')) returns contents of player_edit_1 as a double
end

% --- Executes during object creation, after setting all properties.
function computer_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to player_edit_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in player_output.


% --- Executes on button press in computer_output.
function computer_output_Callback(hObject, eventdata, handles)
% hObject    handle to computer_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_number = str2num(get(handles.computer_edit,'String'))%讀取輸入值
times = str2num(get(handles.result_text,'String'));
    times = 1 + times
    %fopeen('a.txt','a');
    x4 = rem(user_number,10);            %rem(x,y) 取x/y的餘數
    user_number = fix(user_number/10);   %fix(x,y) 取x/y的整數
    x3 = rem(user_number,10);
    user_number = fix(user_number/10);
    x2 = rem(user_number,10);
    user_number = fix(user_number/10);
    x1 = rem(user_number,10);
    n = [x1 x2 x3 x4];                   %排序
    a = 0;
    b = 0;
    for i = 1:4
        for j = 1:4
            if handles.value(i)==n(j)
                if i==j
                    a = a+1;
                else
                    b = b+1;
                end
            end
        end
    end
    set(handles.result_text,'String',times);
    msg2 = num2str(a);
    msg3 = num2str(b);
    msg4 = [msg2 'a' msg3 'b'];
    msg = mat2str(msg4);
    if a==4
        str1 = 'You are right,you takes  ';
        str2 = num2str(times);
        str3 = ' times.';
        msg5 = strcat(str1,str2,str3);
        msgbox(msg5);
        set(handles.player_text,'Visible','on');
        set(handles.player_edit_1,'Visible','on');
        set(handles.player_output,'Visible','on');
        set(handles.player_edit_2,'Visible','on');
        set(handles.text_a,'Visible','on');
        set(handles.text_b,'Visible','on');
        set(handles.computor_guess,'Visible','on');
        set(handles.text10,'Visible','on');
        set(handles.text11,'Visible','on');
        set(handles.text13,'Visible','on');
        set(handles.text14,'Visible','on');
        %prepare()
        remain=5040;
        set(handles.text14,'String',0);
        set(handles.text10,'String',remain);
        tmp=1;  %tmp只是一個拿來計數變數 
        isOver=0;  %判斷結束與否 
        handles.answerBase = AnswerBase(tmp);
        handles.randNum = randi([1 remain],1);
        guidata(hObject,handles)
        
        %first ask
        for i=1:4
        refer(i)=handles.answerBase(handles.randNum,i);
        end
        ans=mat2str(refer)
        set(handles.computor_guess,'String',ans);
        %prepare end
        
        %--%
        %x=randperm(10)-1;
        %x=x(1)*1000+x(2)*100+x(3)*10+x(4)
        %set(handles.computor_guess,'String',x);
        %handles.guess = x;
        %--%
    else
        msgbox(num2str(msg));
        fprintf('%da%db',a,b);
    end
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over player_edit_1.
function player_edit_1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to player_edit_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
% --- Executes during object creation, after setting all properties.

function start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
% --- Executes during object creation, after setting all properties.

function computer_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to computer_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end

% --- Executes during object creation, after setting all properties.
function player_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to player_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end


function player_edit_1_Callback(hObject, eventdata, handles)
% hObject    handle to player_edit_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of player_edit_1 as text
%        str2double(get(hObject,'String')) returns contents of player_edit_1 as a double
end

% --- Executes during object creation, after setting all properties.
function player_edit_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to player_edit_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in player_output.
function player_output_Callback(hObject, eventdata, handles)
% hObject    handle to player_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    remain =str2num(get(handles.text10,'String'));
    %%while ~isOver%%------------------
    %answer();
   
    a = str2num(get(handles.player_edit_1,'String'));
    b = str2num(get(handles.player_edit_2,'String'));
    right=1;
    %計次
    times = str2num(get(handles.text14,'String'));
    times = 1 + times;
    set(handles.text14,'String',times);
    %計次end
    if a==4&b==0
        isOver=1;
        str1 = 'That is right, computer takes  ';
        str2 = num2str(times);
        str3 = ' times.';
        msg5 = strcat(str1,str2,str3);
        msgbox(msg5);
    elseif remain==1  %如果答案庫只剩一個答案，但是這答案還是錯的，就是玩家作弊！
        msgbox('Cheater！= =+');
        isOver=1;
    end
    
    %answer() end;
    
    %think();
     for i=1:4
         refer(i)=handles.answerBase(handles.randNum,i);
     end
    %外部取remain、answerBase
    [remain  handles.answerBase] = test1(handles.answerBase,remain,refer,a,b);
    set(handles.text10,'String',remain);
    %think() end;
    
    %ask(void)
    handles.randNum = randi([1 remain],1);
    guidata(hObject, handles);
    for i=1:4
        refer(i)=handles.answerBase(handles.randNum,i);
    end
    ans=mat2str(refer);
    set(handles.computor_guess,'String',ans);
    %disp(handles.randNum);
    %ask(void) end
    
    %%end-------------
end


function player_edit_2_Callback(hObject, eventdata, handles)
% hObject    handle to player_edit_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of player_edit_2 as text
%        str2double(get(hObject,'String')) returns contents of player_edit_2 as a double
end

% --- Executes during object creation, after setting all properties.
function player_edit_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to player_edit_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function compare_Callback(hObject, eventdata, handles)
% hObject    handle to compare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=get(handles.result_text,'String');
b=get(handles.text14,'String');
a1=str2num(a);
b1=str2num(b);
result='';
if a1>b1
        result='Computer wins';
end
if b1>a1
        result='Hman wins';
end
if a1==b1
        result='Even';
end
msgbox(result);
end

% --------------------------------------------------------------------

% --------------------------------------------------------------------
function rule2_Callback(hObject, eventdata, handles)
% hObject    handle to rule2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    str4='           心電感應猜數字遊戲 ver2              ';
    str5='                                               ';
    str6='  遊戲規則：                                   ';
    str7='  1.每回合電腦會猜一個四位不重複數字                  ';
    str8='  2.A的次數代表電腦猜對了幾個數字且位置正確     ';
    str9='  3.B的次數代表電腦猜對了幾個數字但位置不對     ';
    str10='  4.你必須告訴電腦A和B的值                     ';
    str11='  5.七回合內必可猜出答案                       ';
    str12='  6.Enjoy！                                    ';
    str= strcat(str4,13,str5,13,str6,13,str7,13,str8,13,str9,13,str10,13,str11,13,str12)
    hs = msgbox({str4;str5;str6;str7;str8;str9;str10;str11;str12});
    
    ht = findobj(hs, 'Type', 'text');
    set(ht, 'FontSize', 13, 'Unit', 'normal');% 改變對話框大小
    set(hs, 'Resize', 'on'); % 手動改變，或者用
    set(hs,'position', [600 300 330 250]);
    
end


% --------------------------------------------------------------------
function rule1_Callback(hObject, eventdata, handles)
% hObject    handle to rule1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    str4='           心電感應猜數字遊戲 ver1              ';
    str5='                                               ';
    str6='  遊戲規則：                                   ';
    str7='  1.每回合玩家輸入一個四位不重複數字                  ';
    str8='  2.A的次數代表玩家猜對了幾個數字且位置正確     ';
    str9='  3.B的次數代表玩家猜對了幾個數字但位置不對     ';
    str10='  4.你換其他組四位不重複數字                     ';
    str11='  5.Enjoy！                                    ';
    
    str = strcat(str4,13,str5,13,str6,13,str7,13,str8,13,str9,13,str10,13,str11,13)
    hs  = msgbox({str4;str5;str6;str7;str8;str9;str10;str11});
    ht = findobj(hs, 'Type', 'text');
    set(ht, 'FontSize', 13, 'Unit', 'normal');% 改變對話框大小
    set(hs, 'Resize', 'on'); % 手動改變，或者用
    set(hs,'position', [600 300 330 230]);
    
    
end
