function analyzePump(command,hObject)

handles = guidata(hObject);
persistent counter backgroundTimer connected toolPath;

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
else
    return;
end

    function initdataStruct()
        % Initialize data struct
        %connected = false;
        toolPath = [];
    end


    function connectSerial
        ports = seriallist; % set ports to list of available serial ports
        handles.fid = serial(ports(get(handles.comSelector, 'Value'))); % create a serial object based on the index of the comSelector popupmenu
        handles.fid.BaudRate = 9600; % set baud rate
        fopen(handles.fid); % open serial communications
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
            backgroundTimer = timer('Period', 0.5, ...
                'ExecutionMode', 'fixedSpacing');
            backgroundTimer.TimerFcn = {@sendData, hObject};
            backgroundTimer.StopFcn = {@tmrstop};
            
            initializePlots(hObject);
            start(backgroundTimer);
        end
        
    end

    function readFile
        counter = 0;
        clearGraphs();
        
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
        angle_resolution = 1.5; %0.5 degrees / step
        
        % Modes
        Rapid_positioning = 0;
        Linear_interpolation = 1;
        CW_interpolation = 2;
        CCW_interpolation = 3;
        current_mode = NaN;
        % Initialize variables
        current_pos = [0,0,0];
        toolPath = [];
        arc_offsets = [0,0,0];
        interp_pos = [];
        feedrate = 0;
        while ~feof(raw_gcode_file)
            tline = fgetl(raw_gcode_file);
            if(~isempty(tline))
                if(tline(1) == 'G')
                    splitLine = strsplit(tline, ' ');
                    for i = 1:length(splitLine)
                        % Check what the command is
                        if strcmp(splitLine{i}, 'G00') || strcmp(splitLine{i}, 'G0')
                            %disp('Rapid positioning');
                            current_mode = Rapid_positioning;
                        elseif strcmp(splitLine{i}, 'G01') || strcmp(splitLine{i}, 'G1')
                            %disp('Linear positioning');
                            current_mode = Linear_interpolation;
                        elseif strcmp(splitLine{i}, 'G02')
                            %disp('Circular positioning, clockwise');
                            current_mode = CW_interpolation;
                        elseif strcmp(splitLine{i}, 'G03')
                            %disp('Circular positioning, counterclockwise');
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
                    
                    
%                     dist_res = dist_resolution * feedrate;
%                     angle_res = angle_resolution * feedrate;
                    dist_res = dist_resolution;
                    angle_res = angle_resolution;
                    % Check the current mode and calculate the next points along the
                    % path: linear modes
                    if current_mode == Linear_interpolation || current_mode == Rapid_positioning
                        if length(toolPath > 0)
                            interp_pos = [linspace(toolPath(end,1),current_pos(1),100)',linspace(toolPath(end,2),current_pos(2),100)',linspace(toolPath(end,3),current_pos(3),100)'];
                            dist = norm((current_pos - toolPath(end,:)));
                            if dist > 0
                                dire = (current_pos - toolPath(end,:))/dist;
                                interp_pos = toolPath(end,:) + dire.*(0:dist_res:dist)';
                                interp_pos = [interp_pos;current_pos];
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
                            interp_pos = [interp_pos;current_pos];
                        elseif angle_2 == angle_1
                            % this is a circle
                            % maybe try 4 quarter circles?? half circles gives wierd
                            % arches
                            interp = [current_pos];
                            for j = 1:4
                                angle_2 = angle_1 - 90;
                                interp_circ = [center_pos(1:2) + [cosd(angle_1:-angle_res:angle_2)',sind(angle_1:-angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:-angle_res:angle_2))'];
                                interp = [interp; interp_circ];
                                angle_1 = angle_1 - 90;
                            end
                            interp_pos = [interp;current_pos];
                        else
                            interp_pos = [center_pos(1:2) + [cosd(angle_1:-angle_res:angle_2)',sind(angle_1:-angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:-angle_res:angle_2))'];
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
                            interp_pos = [interp_pos; current_pos];
                        elseif angle_2 == angle_1
                            % this is a circle
                            % maybe try 4 quarter circles?? half circles gives wierd
                            % arches
                            interp = [current_pos];
                            for j = 1:4
                                angle_2 = angle_1 + 90;
                                interp_circ = [center_pos(1:2) + [cosd(angle_1:angle_res:angle_2)',sind(angle_1:angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:angle_res:angle_2))'];
                                interp = [interp; interp_circ];
                                angle_1 = angle_1 + 90;
                            end
                            interp_pos = [interp;current_pos];
                        else
                            interp_pos = [center_pos(1:2) + [cosd(angle_1:angle_res:angle_2)',sind(angle_1:angle_res:angle_2)']*r, linspace(center_pos(3),current_pos(3),length(angle_1:angle_res:angle_2))'];
                            interp_pos = [interp_pos; current_pos];
                        end
                        
                        interp_pos = [interp_pos;current_pos];
                    end
                    toolPath = [toolPath;interp_pos];
                    arc_offsets = [0, 0, 0];
                    %disp(interp_pos)
                end
            end
        end
        fclose(raw_gcode_file);
        startSerial();
    end

    function tmrstop(~, ~)
        fclose(handles.fid);
    end

    function stopData
        fprintf(handles.fid, 'F0'); % Send STOP gcode
        stop(backgroundTimer);
        fclose(handles.fid);
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
            
            fprintf(handles.fid, 'X%.4f Y%.4f Z%.4f', toolPath(counter,:));
            msg = fprintf('X%.4f Y%.4f Z%.4f', toolPath(counter,:));
            disp(msg)
        end
        %set(handles.figure1, 'CurrentAxes', handles.axes1);
        %         set(handles.figure1, 'CurrentAxes', handles.axes1);
        %         curve = animatedline();
        %         set(gca, 'XLim', [min(toolPath(:,1)) - 5,max(toolPath(:,1)) + 5], 'YLim', [min(toolPath(:,2)) - 5,max(toolPath(:,2)) + 5], 'ZLim', [min(toolPath(:,3)) - 1,max(toolPath(:,3)) + 1]);
        %         view(-40,40);
        %         addpoints(curve, toolPath(counter,1), toolPath(counter,2), toolPath(counter,3));
        %         drawnow
        %         for k = 1:length(toolPath)
        %
        %             pause(0.05);
        %         end
        
        
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
end
