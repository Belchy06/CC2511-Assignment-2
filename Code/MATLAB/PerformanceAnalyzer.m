function varargout = PerformanceAnalyzer(varargin)
% PerformanceAnalyzer MATLAB code for PerformanceAnalyzer.fig
%      PerformanceAnalyzer, by itself, creates a new PerformanceAnalyzer or raises the existing
%      singleton*.
%
%      H = PerformanceAnalyzer returns the handle to a new PerformanceAnalyzer or the handle to
%      the existing singleton*.
%
%      PerformanceAnalyzer('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PerformanceAnalyzer.M with the given input arguments.
%
%      PerformanceAnalyzer('Property','Value',...) creates a new PerformanceAnalyzer or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PerformanceAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PerformanceAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PerformanceAnalyzer

% Last Modified by GUIDE v2.5 21-Sep-2020 08:42:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PerformanceAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @PerformanceAnalyzer_OutputFcn, ...
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


% --- Executes just before PerformanceAnalyzer is made visible.
function PerformanceAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PerformanceAnalyzer (see VARARGIN)

% Choose default command line output for PerformanceAnalyzer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global serialRefresh
serialRefresh = timer('TimerFcn', {@Update_Com_Ports, gcf}, 'Period', 10, 'ExecutionMode', 'fixedSpacing');
start(serialRefresh);
% UIWAIT makes PerformanceAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PerformanceAnalyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connectBtn.
function connectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to connectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Supplied_Data_Test(handles)
controlCNC('serial',hObject)


% --- Executes on button press in stopLiveBtn.
function stopLiveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stopLiveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in exportBtn.
function exportBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exportBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

controlCNC('save',hObject)


% --- Executes on button press in prerecordedBtn.
function prerecordedBtn_Callback(hObject, eventdata, handles)
% hObject    handle to prerecordedBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_File_Path(handles);
controlCNC('prerecorded',hObject)


% --- Executes on button press in clearBtn.
function clearBtn_Callback(hObject, eventdata, handles)
% hObject    handle to clearBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
controlCNC('clear',hObject)


% --- Executes during object creation, after setting all properties.
function comSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', seriallist);


    
function Update_Com_Ports(hObject, eventdata, fignum)
    handles = guidata(fignum);
    handles.comSelector.String = seriallist;
 
    
function Update_File_Path(handles)
    [filename, path] = uigetfile({'*.nc'; '*.gcode'}, 'File Selector');
    if filename ~= 0
        fullpath = fullfile(path, filename);
        handles.pathTxt.String = fullpath;
    else
        handles.pathTxt.String = "";
    end
    
% --- Executes on selection change in comSelector.
function comSelector_Callback(hObject, eventdata, handles)
% hObject    handle to comSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comSelector



% --- Executes on selection change in dataSelector.
function dataSelector_Callback(hObject, eventdata, handles)
% hObject    handle to dataSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dataSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dataSelector
updateGui(handles, handles.dataSelector.Value);


% --- Executes during object creation, after setting all properties.
function dataSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateGui(handles, value)
    switch value
        case 1
            handles.manualUI.Visible = 'on';
            handles.fileUI.Visible = 'off';
        case 2
            handles.manualUI.Visible = 'off';
            handles.fileUI.Visible = 'on';       
    end
    
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    global serialRefresh
    selection = questdlg(['Close ' get(handles.figure1, 'Name') '?'], ...
                    ['Close ' get(handles.figure1, 'Name') '...'],...
                    'Yes','No','Yes');
    if strcmp(selection, 'No')
        return;
    else
        fclose all;
        stop(serialRefresh);
        if ~isempty(instrfind)
            fclose(instrfind);
            delete(instrfind);
        end
        delete(hObject);
    end
    
    


% --- Executes on button press in stopBtn.
function stopBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stopBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
controlCNC('stop',hObject)
