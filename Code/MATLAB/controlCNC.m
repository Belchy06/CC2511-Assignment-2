function analyzePump(command,hObject)

handles = guidata(hObject);
persistent counter backgroundTimer connected toolPath;
deadZone = 0.15;

initdataStruct();
% Compares input command to determine which script to execute
if strcmp(command, 'serial')
    connectSerial();
elseif strcmp(command, 'prerecorded')
    readFile();
elseif strcmp(command, 'stop')
    stopData();
elseif strcmp(command, 'save')
    exportData();
elseif strcmp(command, 'clear')
    clearGraphs();
elseif strcmp(command, 'manual')
    startManual();
elseif strcmp(command, 'calibrate')
    sendCalibration();
elseif strcmp(command, 'home')
    sendSetHome();
else
    return;
end

    function initdataStruct()
        % Initialize data struct
        %connected = false;
        toolPath = [0, 0, 0, 0];
    end


    function connectSerial
        ports = seriallist; % set ports to list of available serial ports
        %handles.fid = serial(ports(get(handles.comSelector, 'Value'))); % create a serial object based on the index of the comSelector popupmenu
        %handles.fid.BaudRate = 9600; % set baud rate
        %fopen(handles.fid); % open serial communications
        handles.device = serialport(ports(get(handles.comSelector, 'Value')), 9600);
        configureTerminator(handles.device,"CR");
        disp("Connected!");
        connected = true;
        guidata(hObject, handles); % update guidata with new fid object
    end

    function startSerial
        if(connected == true)
            counter = 0;
            
            % Create backgroundTimer object and specify conditions, main
            % function and stop function
            %%%%%
            % this period should be based on feed rate
            %%%%
            backgroundTimer = timer('Period', 0.1, ...
                'ExecutionMode', 'fixedSpacing');
            backgroundTimer.TimerFcn = {@sendData, hObject};
            backgroundTimer.StopFcn = {@tmrstop};
            
            initializePlots(hObject);
            start(backgroundTimer);
        end
    end

    function startManual
        if(connected == true)
            counter = 0;
            initdataStruct();
            % Create backgroundTimer object and specify conditions, main
            % function and stop function
            %%%%%
            % this period should be based on feed rate
            %%%%
            backgroundTimer = timer('Period', 0.1, ...
                'ExecutionMode', 'fixedSpacing');
            backgroundTimer.TimerFcn = {@sendManual, hObject};
            backgroundTimer.StopFcn = {@tmrstop};
            
            initializePlots(hObject);
            start(backgroundTimer);
        end
    end

    function readFile
        counter = 0;
        clearGraphs();
        toolPath = [0, 0, 0, 0];
        % Check to see if user opened file or cancelled the getui method
        if handles.pathTxt.String == ""
            % If user just closed getui then don't try and analyze data
            return;
        end
        
        %handles.fid = fopen(handles.pathTxt.String); % Open the file specified by user
        
        
        initializePlots(hObject);
        
        
        raw_gcode_file = fopen(handles.pathTxt.String);
        
        % Resolution
        dist_resolution = 0.5; %0.5mm / step
        angle_resolution = 0.5; %0.5 degrees / step
        
        % Modes
        Rapid_positioning = 0;
        Linear_interpolation = 1;
        CW_interpolation = 2;
        CCW_interpolation = 3;
        current_mode = NaN;
        % Initialize variables
        current_pos = [0,0,0,0];
        toolPath = [];
        arc_offsets = [0,0,0,0];
        interp_pos = [0, 0,0,0];
        feedrate = 25;
        while ~feof(raw_gcode_file)
            tline = fgetl(raw_gcode_file);
            if(~isempty(tline))
                if((tline(1) == ";")) 
                    continue; 
                end
                if(tline(1) == 'G')
                    splitLine = strsplit(tline, ' ');
                    for i = 1:length(splitLine)
                        % Check what the command is
                        if strcmp(splitLine{i}, 'G00') || strcmp(splitLine{i}, 'G0')
                            disp('Rapid positioning');
                            current_mode = Rapid_positioning;
                        elseif strcmp(splitLine{i}, 'G01') || strcmp(splitLine{i}, 'G1')
                            disp('Linear positioning');
                            current_mode = Linear_interpolation;
                        elseif strcmp(splitLine{i}, 'G02')
                            disp('Circular positioning, clockwise');
                            current_mode = CW_interpolation;
                        elseif strcmp(splitLine{i}, 'G03')
                            disp('Circular positioning, counterclockwise');
                            current_mode = CCW_interpolation;
                        else
                            if splitLine{i}(1) == 'X'
                                current_pos(1) = str2num(splitLine{i}(2:end));
                            elseif splitLine{i}(1) == 'Y'
                                current_pos(2) = str2num(splitLine{i}(2:end));
                            elseif splitLine{i}(1) == 'Z'
                                current_pos(3) = str2num(splitLine{i}(2:end));
                            elseif splitLine{i}(1) == 'I'
                                arc_offsets(1) = str2num(splitLine{i}(2:end));
                            elseif splitLine{i}(1) == 'J'
                                arc_offsets(2) = str2num(splitLine{i}(2:end));
                            elseif splitLine{i}(1) == 'F'
                                feedrate = str2num(splitLine{i}(2:end));
                            end
                            %disp(current_pos);
                        end
                    end
                    %dist_res = dist_resolution * feedrate;
                    %angle_res = angle_resolution * feedrate;
                    dist_res = dist_resolution * (feedrate / 2);
                    angle_res = angle_resolution;
                    
                    % Check the current mode and calculate the next points along the
                    % path: linear modes
                    if current_mode == Rapid_positioning
                        if length(toolPath > 0)
                            interp_pos = [linspace(toolPath(end,1),current_pos(1),100)',linspace(toolPath(end,2),current_pos(2),100)',linspace(toolPath(end,3),current_pos(3),100)'];
                            dist = norm((current_pos - toolPath(end,:)));
                            interp_pos(:,4) = 0;
                            if dist > 0
                                dire = (current_pos - toolPath(end,:))/dist;
                                interp_pos = toolPath(end,:) + dire.*(0:dist_res:dist)';
                                interp_pos = [interp_pos;current_pos];
                                interp_pos(:,end) = 255;
                            end
                        else
                            interp_pos = current_pos;
                        end
                    elseif current_mode == Linear_interpolation
                        if length(toolPath > 0)
                            interp_pos = [linspace(toolPath(end,1),current_pos(1),100)',linspace(toolPath(end,2),current_pos(2),100)',linspace(toolPath(end,3),current_pos(3),100)'];       
                            dist = norm((current_pos - toolPath(end,:)));
                            interp_pos(:,4) = 0;
                            if dist > 0
                                dire = (current_pos - toolPath(end,:))/dist;
                                interp_pos = toolPath(end,:) + dire.*(0:dist_res:dist)';
                                interp_pos = [interp_pos;current_pos];
                                interp_pos(:,end) = 0;
                            end
                        else
                            interp_pos = current_pos;
                        end
                        % Check the current mode and calculate the next points along the
                        % path: arc modes, note that this assumes the arc is in the X-Y
                        % axis only
                    elseif current_mode == CW_interpolation
                        center_pos = toolPath(end,:) + arc_offsets;
                        v1 = (toolPath(end,1:2)-center_pos(1:2));
                        v2 = (current_pos(1:2)-center_pos(1:2));
                        
                        r = norm(current_pos(1:2)-center_pos(1:2));
                        angle_1 = atan2d(v1(2),v1(1));
                        angle_2 = atan2d(v2(2),v2(1));
                        
                        if angle_2 > angle_1
                            % Normal Arc
                            angle_2 = angle_2-360;
                            interp_pos = [center_pos(1:2) + [cosd(angle_1:-angle_res:angle_2)',sind(angle_1:-angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:-angle_res:angle_2))'];
                            interp_pos(:,4) = 0;
                            interp_pos = [interp_pos;current_pos];
                        elseif angle_2 == angle_1
                            % this is a circle
                            % maybe try 4 quarter circles?? half circles gives wierd
                            % arches
                            interp = [current_pos];
                            for j = 1:4
                                angle_2 = angle_1 - 90;
                                interp_circ = [center_pos(1:2) + [cosd(angle_1:-angle_res:angle_2)',sind(angle_1:-angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:-angle_res:angle_2))'];
                                interp_circ(:,4) = 0;
                                interp = [interp; interp_circ];
                                angle_1 = angle_1 - 90;
                            end
                            interp_pos = [interp;current_pos];
                        else
                            interp_pos = [center_pos(1:2) + [cosd(angle_1:-angle_res:angle_2)',sind(angle_1:-angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:-angle_res:angle_2))'];
                            interp_pos(:,4) = 0;
                            interp_pos = [interp_pos;current_pos];
                        end
                        
                    elseif current_mode == CCW_interpolation
                        center_pos = toolPath(end,:) + arc_offsets;
                        v1 = (toolPath(end,1:2)-center_pos(1:2));
                        v2 = (current_pos(1:2)-center_pos(1:2));
                        r = norm(current_pos(1:2)-center_pos(1:2));
                        angle_1 = atan2d(v1(2),v1(1));
                        angle_2 = atan2d(v2(2),v2(1));
                        if norm(v1) <0.1
                            angle_1 = 0;
                        end
                        if norm(v2) <0.1
                            angle_2 = 0;
                        end
                        
                        if angle_2 < angle_1
                            angle_2 = angle_2+360;
                            interp_pos = [center_pos(1:2) + [cosd(angle_1:angle_res:angle_2)',sind(angle_1:angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:angle_res:angle_2))'];
                            interp_pos(:,4) = 0;
                            interp_pos = [interp_pos; current_pos];
                        elseif angle_2 == angle_1
                            % this is a circle
                            % maybe try 4 quarter circles?? half circles gives wierd
                            % arches
                            interp = [current_pos];
                            for j = 1:4
                                angle_2 = angle_1 + 90;
                                interp_circ = [center_pos(1:2) + [cosd(angle_1:angle_res:angle_2)',sind(angle_1:angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:angle_res:angle_2))'];
                                interp_circ(:,4) = 0;
                                interp = [interp; interp_circ];
                                angle_1 = angle_1 + 90;
                            end
                            interp_pos = [interp;current_pos];
                        else
                            interp_pos = [center_pos(1:2) + [cosd(angle_1:angle_res:angle_2)',sind(angle_1:angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:angle_res:angle_2))'];
                            interp_pos(:,4) = 0;
                            interp_pos = [interp_pos; current_pos];
                        end
                        
                        interp_pos = [interp_pos;current_pos];
                        interp_pos(:,end) = 0;
                    end
                    toolPath = [toolPath;interp_pos];
                    arc_offsets = [0, 0, 0, 0];
                    %disp(interp_pos);
                end
            end
        end
        toolPath = [toolPath; [0, 0, 0, 255]];
        fclose(raw_gcode_file);
        startSerial();
    end

    function tmrstop(~, ~)
        clear handles.device;
    end

    function stopData
        clear handles.device;
        disp("Device disconnected!");
    end


    function sendData(~, ~, hObject)
        handles = guidata(hObject);
        counter = counter + 1;
        
        
        if(counter < length(toolPath))
            fprintf('Sending Packet %d \r\n', counter);
            %disp(toolPath(counter,:));
            
            set(gca, 'XLim', [min(toolPath(:,1)) - 5,max(toolPath(:,1)) + 5], 'YLim', [min(toolPath(:,2)) - 5,max(toolPath(:,2)) + 5], 'ZLim', [min(toolPath(:,3)) - 1,max(toolPath(:,3)) + 1]);
            
            addpoints(handles.curve, toolPath(counter,1), toolPath(counter,2), toolPath(counter,3));
            drawnow
            % multiply the toolPath by the handles.steps (the number of
            % steps per mm)
            controlstring = sprintf('X%d Y%d Z%d S%d', [round(toolPath(counter,1:3) * handles.steps) toolPath(counter,4)]);
            %controlstring = sprintf('X%.4f Y%.4f Z%.4f', round(toolPath(counter,:) * handles.steps));
            writeline(handles.device, controlstring);
            disp(controlstring);
        end
    end

    function sendManual(~, ~, hObject)
        handles = guidata(hObject);
        counter = counter + 1;
        sPWM = 255;
        
        
        %% Read current joystick pos
        [pos, but] = mat_joy(0);
        %% Make sure the x axis doesn't accumulate error
        if(abs(pos(1)) < deadZone)
            pos(1) = 0;
        end
        %% Make sure the y axis doesn't accumulate error
        if(abs(pos(2)) < deadZone)
            pos(2) = 0;
        end
        %% If the trigger is pressed, then enable the 'throttle' to control the z height
        if(~but(1))
            pos(3) = 0;
        end
        if(but(2))
            sPWM = 0;
        end
        interpPos = [toolPath(end,1) + pos(1), toolPath(end,2) - pos(2), toolPath(end,3) - (pos(3)), sPWM];
        toolPath = [toolPath; interpPos];
        
        
        
        
        if(counter > 1)
            if(~isequal(toolPath(end-1,:),toolPath(end,:)))
                fprintf('Sending Packet %d \r\n', counter);
                %disp(toolPath(counter,:));
                
                set(gca, 'XLim', [min(toolPath(:,1)) - 5,max(toolPath(:,1)) + 5], 'YLim', [min(toolPath(:,2)) - 5,max(toolPath(:,2)) + 5], 'ZLim', [min(toolPath(:,3)) - 1,max(toolPath(:,3)) + 1]);
                
                addpoints(handles.curve, toolPath(counter,1), toolPath(counter,2), toolPath(counter,3));
                drawnow
                
                controlstring = sprintf('X%d Y%d Z%d S%d', [round(toolPath(counter,1:3) * handles.steps) toolPath(counter,4)]);
                writeline(handles.device, controlstring);
                disp(controlstring);
            end
        else
            fprintf('Sending Packet %d \r\n', counter);
            %disp(toolPath(counter,:));
            
            set(gca, 'XLim', [min(toolPath(:,1)) - 5,max(toolPath(:,1)) + 5], 'YLim', [min(toolPath(:,2)) - 5,max(toolPath(:,2)) + 5], 'ZLim', [min(toolPath(:,3)) - 1,max(toolPath(:,3)) + 1]);
            
            addpoints(handles.curve, toolPath(counter,1), toolPath(counter,2), toolPath(counter,3));
            drawnow
            
            controlstring = sprintf('X%d Y%d Z%d S%d', [round(toolPath(counter,1:3) * handles.steps) toolPath(counter:4)]);
            writeline(handles.device, controlstring);
            disp(controlstring);
        end
        
        %disp(msg)
    end

    function clearGraphs
        %sets new axes if user wants to clear recently plotted data
        handles = guidata(hObject);
        axes(handles.axes1);
        cla reset;
        view(-40,40);
        guidata(hObject, handles);
        
    end



    function initializePlots(hObject)
        %Update handles object and create new axes with correct
        %specifications. eg, plot, lineStyle
        handles = guidata(hObject);
        handles.toolPathPlot = plot(handles.axes1,0,0);
        axes(handles.axes1);
        view(-40,40);
        handles.curve = animatedline();
        
        guidata(hObject, handles);
    end



    function sendCalibration()
        handles = guidata(hObject);
        device = handles.device;
        if(connected)
            controlstring = sprintf('X%.4f Y%.4f Z%.4f', [handles.pos.x, handles.pos.y, handles.pos.z]);
            writeline(device, controlstring);
        else
            disp("Connect to the device first!");
        end
        
    end

    function sendSetHome()
        handles = guidata(hObject);
        if(connected)
            writeline(handles.device, "H");
            disp("HOME");
        else
            disp("Connect to the device first!");
        end
    end
end
