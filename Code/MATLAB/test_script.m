filepath = 'test_file.nc';
%gCodeReader  Function that takes a G-Code file and outputs the tool path
% for plotting/analysis. Not a complete analysis of the whole file, but
% more or less the basic motions.
% Inputs:
%        - path to G-Code file
%        - point spacing for linear motion (mm or inches, I guess)
%        - point spacing for arc motion (degrees)
%        - Plot the current path (1 or 0)
%        - Output raw G-Code to console
% Outputs:
%        - The interpolated tool path
% Notes:
%        - This is not at all complete, but should work well enough for
%        simple CNC G-Code. If you need anything more complex, I'd suggest
%        you implement it yourself, as this was more or less all I needed
%        at the time.
%        - I have also done zero optimization.
%        - This comes with no guarantees or warranties whatsoever, but I
%        hope it's useful for someone.
%
% Example usage:
%       toolpath = gCodeReader('simplePart.NC',0.5,0.5,1,0);
%
% Tom Williamson
% 18/06/2018
raw_gcode_file = fopen(filepath);

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
arc_offsets = [0,0,0];
interp_pos = [0, 0,0,0];
while ~feof(raw_gcode_file)
    tline = fgetl(raw_gcode_file);
    if(~isempty(tline))
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
            dist_res = dist_resolution * feedrate;
            angle_res = angle_resolution * feedrate;
            % Check the current mode and calculate the next points along the
            % path: linear modes
            if current_mode == Rapid_positioning
                if length(toolPath > 0)
                    interp_pos = [linspace(toolPath(end,1),current_pos(1),100)',linspace(toolPath(end,2),current_pos(2),100)',linspace(toolPath(end,3),current_pos(3),100)'];
                    dist = norm((current_pos - toolPath(end,:)));
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
                    interp_pos(:,end) = 0;
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
                interp_pos(:,end) = 0;
            end
            toolPath = [toolPath;interp_pos];
            arc_offsets = [0, 0, 0];
            disp(interp_pos);
        end
    end
end
fclose(raw_gcode_file);

curve = animatedline();
set(gca, 'XLim', [min(toolPath(:,1)) - 5,max(toolPath(:,1)) + 5], 'YLim', [min(toolPath(:,2)) - 5,max(toolPath(:,2)) + 5], 'ZLim', [min(toolPath(:,3)) - 1,max(toolPath(:,3)) + 1]);
view(-40,40);
for k = 1:length(toolPath)
    addpoints(curve, toolPath(k,1), toolPath(k,2), toolPath(k,3));
    disp(round(toolPath(k,:) * 25));
    drawnow
    pause(0.05);
end