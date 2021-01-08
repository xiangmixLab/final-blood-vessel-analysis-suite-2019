function varargout = Interactive_ROI_blood(varargin)
% INTERACTIVE_ROI_BLOOD MATLAB code for Interactive_ROI_blood.fig
%      INTERACTIVE_ROI_BLOOD, by itself, creates a new INTERACTIVE_ROI_BLOOD or raises the existing
%      singleton*.
%
%      H = INTERACTIVE_ROI_BLOOD returns the handle to a new INTERACTIVE_ROI_BLOOD or the handle to
%      the existing singleton*.
%
%      INTERACTIVE_ROI_BLOOD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERACTIVE_ROI_BLOOD.M with the given input arguments.
%
%      INTERACTIVE_ROI_BLOOD('Property','Value',...) creates a new INTERACTIVE_ROI_BLOOD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Interactive_ROI_blood_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Interactive_ROI_blood_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Interactive_ROI_blood

% Last Modified by GUIDE v2.5 25-Aug-2017 11:41:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Interactive_ROI_blood_OpeningFcn, ...
                   'gui_OutputFcn',  @Interactive_ROI_blood_OutputFcn, ...
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


% --- Executes just before Interactive_ROI_blood is made visible.
function Interactive_ROI_blood_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Interactive_ROI_blood (see VARARGIN)

% Choose default command line output for Interactive_ROI_blood
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
roiselected=0;
assignin('base','roiselected',roiselected);

% UIWAIT makes Interactive_ROI_blood wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Interactive_ROI_blood_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile('.mat','select blood data');
infostruct=load([PathName,FileName]);
assignin('base','infostruct',infostruct);

infostruct=evalin('base','infostruct');
[height,width]=size(infostruct.acontrast2);
anew=zeros(height,width,3);
anew(:,:,1)=infostruct.acontrast2;
anew(:,:,2)=infostruct.acontrast2;
anew(:,:,3)=infostruct.acontrast2;
anew=uint8(anew);
assignin('base','anew',anew);

showimage(hObject, eventdata, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roiselected=evalin('base','roiselected');
if roiselected==1
    roipos=evalin('base','roipos');
    anew=evalin('base','anew');
    anew=double(anew);
    anew(roipos(1,2):roipos(1,2)+roipos(1,4),roipos(1,1):roipos(1,1)+roipos(1,3),:)=0;
    
    infostruct=evalin('base','infostruct');
    averagevm=infostruct.averagevm;
    [rgb1,cmap] = rgbconvert(averagevm*14);
    anew(roipos(1,2):roipos(1,2)+roipos(1,4),roipos(1,1):roipos(1,1)+roipos(1,3),:)=anew(roipos(1,2):roipos(1,2)+roipos(1,4),roipos(1,1):roipos(1,1)+roipos(1,3),:)+rgb1(roipos(1,2):roipos(1,2)+roipos(1,4),roipos(1,1):roipos(1,1)+roipos(1,3),:);
    anew=uint8(anew);
    assignin('base', 'anew', anew);
    showimage(hObject, eventdata, handles);
end  
    

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roiselected=evalin('base','roiselected');
if roiselected==1
    roipos=evalin('base','roipos');
    
    infostruct=evalin('base','infostruct');
    averagevangle=infostruct.averagevangle;
    averagevm=infostruct.averagevm;
    [rgb1,cmap] = rgbconvert(averagevm*14);
    showimage(hObject, eventdata, handles);
    
    for i1=roipos(1,2):roipos(1,2)+roipos(1,4)
        for i2=roipos(1,1):roipos(1,1)+roipos(1,3)
            if averagevangle{i1,i2}~=[0,0]
                quiver(i2,i1,averagevangle{i1,i2}(1,2),averagevangle{i1,i2}(1,1),'color',[rgb1(i1,i2,1) rgb1(i1,i2,2) rgb1(i1,i2,3)]);
            end
        end
    end  
end  


% --- Executes during object deletion, before destroying properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over contrast image.
function roiselection(hObject, eventdata, handles)
if strcmp(get(gcf,'SelectionType'),'normal')
roi=imrect;
assignin('base', 'roi', roi);
roipos=getPosition(roi);
assignin('base', 'roipos', roipos);
roiselected=1;
assignin('base','roiselected',roiselected);
end

function showimage(hObject, eventdata, handles)

axes(handles.axes2);%

anew=evalin('base','anew');
himage=imshow(anew);
assignin('base', 'himage', himage);
set(himage,'buttondownFcn',@roiselection);
