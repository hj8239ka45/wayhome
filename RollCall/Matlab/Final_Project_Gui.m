function varargout = Final_Project_Gui(varargin)
% FINAL_PROJECT_GUI MATLAB code for Final_Project_Gui.fig
%      FINAL_PROJECT_GUI, by itself, creates a new FINAL_PROJECT_GUI or raises the existing
%      singleton*.
%
%      H = FINAL_PROJECT_GUI returns the handle to a new FINAL_PROJECT_GUI or the handle to
%      the existing singleton*.
%
%      FINAL_PROJECT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINAL_PROJECT_GUI.M with the given input arguments.
%
%      FINAL_PROJECT_GUI('Property','Value',...) creates a new FINAL_PROJECT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Final_Project_Gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Final_Project_Gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Final_Project_Gui

% Last Modified by GUIDE v2.5 22-Dec-2018 15:10:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Final_Project_Gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Final_Project_Gui_OutputFcn, ...
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

% --- Executes just before Final_Project_Gui is made visible.
function Final_Project_Gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Final_Project_Gui (see VARARGIN)
% Choose default command line output for Final_Project_Gui
handles.output = hObject;

prompt = {'Enter your com:'};
title = 'Input';
dims = [1 35];
port_num = string(inputdlg(prompt,title,dims));

if port_num == ""
    port_num = 5;
    handles.port = remo_open(port_num);
else
    handles.port = remo_open(str2double(port_num));
end

handles.close = 1;
set(handles.text7,'Visible','off');
DATAName_1 = ["Noname" "CARD_ID" "CARD_ID_Name"];
    for i=1:3
        DATAName = [char(DATAName_1(i)) '.txt'];
        fid = fopen(DATAName,'r');
        if fid==-1
            fid = fopen(DATAName,'a+');
            if i~=3
                fprintf(fid,' 姓名\t\t卡號\t\t\t\t日期\t\t\t\t\t\t進出 ');
                fprintf(fid,'\r\n');
            end
            fclose(fid);
            fid=0;
        elseif fid==3
                fclose(fid);
        end
    end
    handles.name = dataname;
    [handles.row , handles.column] = size(handles.name);
    for i=1:handles.row
        DATAName = [char(handles.name(i)) '.txt'];
        fid = fopen(DATAName,'r');
        if fid==-1
            fid = fopen(DATAName,'a+');
            fprintf(fid,' 姓名\t\t卡號\t\t\t\t日期\t\t\t\t\t\t進出 ');
            fprintf(fid,'\r\n');       
            fclose(fid);
            fid=0;
        elseif fid==3
            fclose(fid);
        end
    end
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes Final_Project_Gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = Final_Project_Gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

function close_app_Callback(hObject, eventdata, handles)
% hObject    handle to close_app (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.close = 2;
set(handles.text7,'Visible','off');
set(handles.text7,'String','非點名狀態');
pause(0.1);
end

% --- Executes on button press in start_butt.
function start_butt_Callback(hObject, eventdata, handles)
% hObject    handle to start_butt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    pause(0.5);
    set(handles.text7,'Visible','on');
    set(handles.text7,'String','點名中');
    set(handles.exist_result,'String','是否還在');
    pause(0.1);
    handles.name = dataname;
    [handles.row , handles.column] = size(handles.name);
    while 1
        pause(2);
        [Card_ID,error] = remo_get(handles.port);
        pause(0.5);
        closee = get(handles.text7, 'String')
        if closee == string('點名中')
            closee;
            Card_ID = string(dec2hex(Card_ID));
            format short g;
            cloc = clock;
            DATA(1) = data(Card_ID);
            for i=1:10
                if(i<5)
                    DATA(i+1) = Card_ID(i);
                else
                    DATA(i+1) = round(cloc(i-4));
                end
            end

            %紀錄個人資料
            DATAName = [char(DATA(1)) '.txt'];
            fid = fopen(DATAName,'r');
            formatSpec = '%s %s %s %s %s %s %s %s %s %s %s %s';
            N = 12;
            C_text = textscan(fid,formatSpec);
            fclose(fid);

            [row_chara,column_chara] = size(C_text{1});

            if rem(row_chara,2)==1
                DATA(12) = 'on';
            else
                DATA(12) = 'off';
            end
            fid = fopen(DATAName,'a+');
            fprintf(fid,' %s ',DATA);
            fprintf(fid,'\r\n');
            fclose(fid);
            set(handles.name_result,'String',char(DATA(1)));
            set(handles.card_result,'String',char(DATA(2:5)));
            set(handles.exist_result,'String',char(DATA(12)));

            %紀錄全部資料
            name = dataname;
            DATA_total(:,1) = name;
            for i = 1:handles.row
                [time(i,:),exist(i)] = CumulativeTime(name(i));
            end

            DATA_total(:,2:7) = time;
            DATA_total(:,8) = exist;
            fid = fopen('CARD_ID.txt','wt');
            fprintf(fid,' 姓名\t\t時間\t\t\t\t\t\t是否還在 ');
            fprintf(fid,'\n');
            for i = 1:handles.row
                fprintf(fid,'%s\t',DATA_total(i,:));
                fprintf(fid,'\n');
            end
            fclose(fid);
        else
            closee;
            break;
        end
    end
    close all;
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
end

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in add_member_butt.
function add_member_butt_Callback(hObject, eventdata, handles)
% hObject    handle to add_member_butt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end


% --------------------------------------------------------------------
function search_Callback(hObject, eventdata, handles)
% hObject    handle to search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.txt*','*txt');
cd (pathname);
winopen (filename)
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text7,'Visible','on');
set(handles.text7,'String','新增資料中');
pause(1);
set(handles.exist_result,'String','');
[Card_ID,error] = remo_get(handles.port);
card = (dec2hex(Card_ID));
name = data(card);
card_id = card';
set(handles.name_result,'String',name);
set(handles.card_result,'String',card_id(1:8));
if name == "Noname"
    prompt = {'Enter this member`s name:'};
    title = 'Input';
    dims = [1 35];
    addname = string(inputdlg(prompt,title,dims));
    if addname~=""
        add_data(1) = addname;
        add_data(2:5) = string(card);

        DATAName = ['CARD_ID_Name' '.txt'];
        fid = fopen(DATAName,'a+');
        fprintf(fid,'%s\t',add_data);
        fprintf(fid,'\r\n');
        fclose(fid);
        fid=0;
        set(handles.name_result,'String','');
        set(handles.card_result,'String','');
        DATAName = [char(addname) '.txt'];
        fid = fopen(DATAName,'a+');
        fprintf(fid,' 姓名\t\t卡號\t\t\t\t日期\t\t\t\t\t\t進出 ');
        fprintf(fid,'\r\n');
        fclose(fid);
        fid=0;
    end
end
set(handles.text7,'String','');
set(handles.text7,'Visible','off');
pause(0.1);
end
