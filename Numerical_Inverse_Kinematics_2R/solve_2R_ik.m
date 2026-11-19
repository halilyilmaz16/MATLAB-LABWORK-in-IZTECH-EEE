%% Numerical inverse kinematics of a planar 2R robot
% Run this script to print both tables and export the figures beside it.
ikTarget = [1; 1];
ikStarts = [0.1, -0.1, -1.0, 2.2; 1.45, 1.70, 0.8, 0.8];
ikAlphas = [0.05, 0.2, 0.5, 0.8];
ikTolerance = 1e-6;
ikMaxIter = 500;
ikFolder = fileparts(mfilename('fullpath'));

%% Tasks 1-3. Compare Newton and gradient from identical starts.
ikBaseline = runCases(ikStarts, ikTarget, ["Newton","Gradient"], ...
    [0.2, 0.2], ikTolerance, ikMaxIter);
ikSummary = metrics(ikBaseline, ["Newton","Gradient"], [NaN, 0.2]);
fprintf('\nTasks 1-3 | Newton and gradient | target [1, 1] | angles in radians\n');
disp(ikSummary(:,["Start","Method","InitialError","FinalError","Updates", ...
    "Status","FinalQ1","FinalQ2","MinAbsSinQ2","Diagnostic"]));
plotErrors(ikBaseline, ikStarts, ["Newton","Gradient (\alpha = 0.2)"], ...
    ikTolerance, "Effect of the initial configuration", ...
    fullfile(ikFolder,"task2_initial_conditions.png"));
plotArms(ikBaseline, ikStarts, ikTarget, fullfile(ikFolder,"task3_arm_trajectories.png"));

%% Task 4. Repeat the gradient experiment across step sizes.
ikGradientMethods = repmat("Gradient",size(ikAlphas));
ikSweep = runCases(ikStarts, ikTarget, ikGradientMethods, ikAlphas, ikTolerance, ikMaxIter);
ikStepSummary = metrics(ikSweep, ikGradientMethods, ikAlphas);
fprintf('\nTask 4 | Gradient step size | tolerance %.0e | update limit %d\n', ...
    ikTolerance, ikMaxIter);
disp(ikStepSummary(:,["Start","Alpha","FinalError","Updates","Status"]));
plotErrors(ikSweep, ikStarts, compose("\\alpha = %.2g",ikAlphas), ...
    ikTolerance, "Gradient convergence by step size", fullfile(ikFolder,"task4_step_size.png"));

function runs = runCases(starts,target,methods,alphas,tol,limit)
runs = cell(size(starts,2),numel(methods));
for i = 1:size(runs,1)
    for j = 1:size(runs,2)
        runs{i,j} = iterate_2R_ik(starts(:,i),target,methods(j),alphas(j),tol,limit);
    end
end
end

function summary = metrics(runs,methods,alphas)
% Transpose before flattening so rows for each initial pose stay together.
ordered = runs.';
r = [ordered{:}];
q = [r.finalWrapped].';
start = repelem((1:size(runs,1)).',size(runs,2));
summary = table(start,repmat(methods(:),size(runs,1),1), ...
    repmat(alphas(:),size(runs,1),1),arrayfun(@(s)s.error(1),r).', ...
    arrayfun(@(s)s.error(end),r).',[r.iterations].',[r.status].', ...
    q(:,1),q(:,2),[r.minAbsSinQ2].',[r.diagnostic].', ...
    'VariableNames',{'Start','Method','Alpha','InitialError','FinalError', ...
    'Updates','Status','FinalQ1','FinalQ2','MinAbsSinQ2','Diagnostic'});
end

function [fig,layout] = figureGrid(name,rows,cols,width,height)
fig = figure('Name',name,'NumberTitle','off','Color','white', ...
    'Units','pixels','Position',[50 60 width height],'Theme','light');
layout = tiledlayout(fig,rows,cols,'TileSpacing','compact','Padding','compact');
title(layout,name,'FontWeight','bold','FontSize',16);
end

function label = startLabel(i,starts)
label = sprintf('Start %d   [%.2f, %.2f] rad',i,starts(1,i),starts(2,i));
end

function plotErrors(runs,starts,labels,tol,name,path)
[fig,layout] = figureGrid(name,2,2,1040,720);
colors = [0.07 0.32 0.57; 0.72 0.28 0.07; 0.04 0.47 0.35; 0.51 0.25 0.59];
styles = ["-","--","-.",":"];
for i = 1:size(runs,1)
    ax = nexttile(layout);
    hold(ax,'on');
    for j = 1:size(runs,2)
        r = runs{i,j};
        h = semilogy(ax,0:r.iterations,r.error,styles(j),'Color',colors(j,:), ...
            'DisplayName',labels(j),'LineWidth',1.7);
        if labels(j) == "Newton"
            h.Marker = 'o';
            h.MarkerSize = 4;
        end
    end
    ax.YScale = 'log';
    yline(ax,tol,'--','Color',[0.32 0.32 0.32],'DisplayName','Tolerance');
    grid(ax,'on');
    xlabel(ax,'Iteration k');
    ylabel(ax,'||e(q_k)||_2');
    title(ax,startLabel(i,starts));
end
lg = legend(ax,'Orientation','horizontal','NumColumns',numel(labels)+1);
lg.Layout.Tile = 'south';
exportgraphics(fig,path,'Resolution',180);
end

function plotArms(runs,starts,target,path)
[fig,layout] = figureGrid("Arm poses and end-effector iterates",2,4,1280,730);
methods = ["Newton","Gradient"];
blue = [0.08 0.33 0.57];
orange = [0.73 0.29 0.07];
for j = 1:2
    for i = 1:size(runs,1)
        ax = nexttile(layout);
        hold(ax,'on');
        r = runs{i,j};
        plot(ax,r.tip(1,:),r.tip(2,:),'.-','Color',[0.17 0.55 0.47], ...
            'MarkerSize',7,'DisplayName','End-effector iterates');
        drawArm(ax,r.q(:,1),r.tip(:,1),'--o',orange,'Initial arm');
        drawArm(ax,r.q(:,end),r.tip(:,end),'-o',blue,'Final arm');
        plot(ax,target(1),target(2),'kp','MarkerFaceColor',[1 0.85 0.27], ...
            'MarkerSize',11,'DisplayName','Target');
        axis(ax,'equal');
        xlim(ax,[-2.1 2.1]); ylim(ax,[-2.1 2.1]);
        grid(ax,'on'); xlabel(ax,'x'); ylabel(ax,'y');
        title(ax,{startLabel(i,starts),sprintf('%s  |  %d updates',methods(j),r.iterations)});
    end
end
lg = legend(ax,'Orientation','horizontal','NumColumns',4);
lg.Layout.Tile = 'south';
exportgraphics(fig,path,'Resolution',180);
end

function drawArm(ax,q,tip,style,color,label)
elbow = [cos(q(1)); sin(q(1))];
plot(ax,[0 elbow(1) tip(1)],[0 elbow(2) tip(2)],style,'Color',color, ...
    'MarkerSize',4,'LineWidth',1.7,'DisplayName',label);
end
