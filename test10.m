function varargout = test10(varargin)
% TEST10 MATLAB code for test10.fig
%      TEST10, by itself, creates a new TEST10 or raises the existing
%      singleton*.
%
%      H = TEST10 returns the handle to a new TEST10 or the handle to
%      the existing singleton*.
%
%      TEST10('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST10.M with the given input arguments.
%
%      TEST10('Property','Value',...) creates a new TEST10 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test10_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test10_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test10

% Last Modified by GUIDE v2.5 29-May-2018 23:32:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test10_OpeningFcn, ...
                   'gui_OutputFcn',  @test10_OutputFcn, ...
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


% --- Executes just before test10 is made visible.
function test10_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test10 (see VARARGIN)

% Choose default command line output for test10
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test10 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test10_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[filename, pathname]=uigetfile('*.txt*','*txt')
[filename, pathname]=uigetfile('*.*','All Files');
    path_origin = cd;
    if string(filename) == "0" & string(pathname) == "0"
        warning('no file');
    else
        cd(pathname);
        a=dir(filename);
        bytes=num2str(a.bytes);
        Byte=strcat(bytes,'bytes');
        set(handles.text4,'String',filename);
        set(handles.text6,'String',Byte);
        date=a.date;
        set(handles.text7,'String',date);
        cd(path_origin);
    end