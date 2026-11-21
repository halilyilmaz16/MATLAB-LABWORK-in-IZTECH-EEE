function fig = gradient_descent_gui()
%GRADIENT_DESCENT_GUI Explore fixed steps and numerical exact line search.
%   GRADIENT_DESCENT_GUI opens an interactive demo with an editable scalar
%   objective. Use x, real constants, +, -, *, /, ^, parentheses, and common
%   math functions such as sin, cos, exp, log, sqrt, and abs. For custom
%   objectives, the app estimates the derivative by finite differences.

minimum = 2;
defaultExpression = '(x-2)^2';
defaultObjective = @(x) (x - minimum).^2;
defaultGradient = @(x) 2*(x - minimum);
objective = defaultObjective;
gradient = defaultGradient;
isDefaultObjective = true;
useLineSearch = false;
appliedExpression = defaultExpression;
tolerance = 1e-8;
defaultAlpha = 0.2;
defaultStart = -3;
defaultMaxIterations = 50;
stepLimits = [0.001 1.5];
plotFloor = 1e-18;
blue = [0 0.447 0.741];
orange = [0.85 0.325 0.098];
green = [0.266 0.613 0.446];

fig = uifigure('Name', 'Gradient descent', ...
    'Position', [60 60 1080 740], 'Visible', 'off');
layout = uigridlayout(fig, [7 2], ...
    'RowHeight', {42, 52, 69, 26, '3x', '2x', 73}, ...
    'ColumnWidth', {'3x', '2x'}, 'Padding', [20 14 20 14], ...
    'RowSpacing', 10, 'ColumnSpacing', 18);

heading = uilabel(layout, 'Text', 'Gradient descent', ...
    'FontSize', 24, 'FontWeight', 'bold');
heading.Layout.Row = 1;
heading.Layout.Column = [1 2];

expressionControls = uigridlayout(layout, [2 2], 'RowHeight', {26, 20}, ...
    'ColumnWidth', {144, '1x'}, 'Padding', [0 0 0 0], 'RowSpacing', 3);
expressionControls.Layout.Row = 2;
expressionControls.Layout.Column = [1 2];
uilabel(expressionControls, 'Text', 'Amaç fonksiyonu f(x)', 'FontWeight', 'bold');
expressionField = uieditfield(expressionControls, 'text', 'Tag', 'ObjectiveExpression', ...
    'Value', defaultExpression, ...
    'Tooltip', 'x, pi, e, +, -, *, /, ^, sin, cos, tan, exp, log, log10, sqrt ve abs kullanılabilir.');
expressionNote = uilabel(expressionControls, 'Tag', 'ExpressionNote', ...
    'Text', 'Enter ile uygula  ·  Örnek: x^4 - 3*x^2 - 2');
expressionNote.Layout.Row = 2;
expressionNote.Layout.Column = 2;
expressionHint = expressionNote.Text;
expressionHintColor = expressionNote.FontColor;

controls = uigridlayout(layout, [2 6], 'RowHeight', {20, 26}, ...
    'ColumnWidth', {238, 88, '1x', 103, 112, 94}, ...
    'Padding', [0 0 0 0], 'ColumnSpacing', 14, 'RowSpacing', 4);
controls.Layout.Row = 3;
controls.Layout.Column = [1 2];
uilabel(controls, 'Text', 'Adım yöntemi', 'FontWeight', 'bold');
alphaLabel = uilabel(controls, 'Text', 'Adım boyu (α)', 'FontWeight', 'bold');
alphaLabel.Layout.Row = 1;
alphaLabel.Layout.Column = 2;
startLabel = uilabel(controls, 'Text', 'Başlangıç x₀');
startLabel.Layout.Row = 1;
startLabel.Layout.Column = 4;
limitLabel = uilabel(controls, 'Text', 'En çok iterasyon');
limitLabel.Layout.Row = 1;
limitLabel.Layout.Column = 5;

modeButtons = uigridlayout(controls, [1 2], ...
    'ColumnWidth', {93, '1x'}, 'Padding', [0 0 0 0], 'ColumnSpacing', 6);
modeButtons.Layout.Row = 2;
modeButtons.Layout.Column = 1;
fixedButton = uibutton(modeButtons, 'state', 'Text', 'Sabit adım', ...
    'Tag', 'FixedStepMode', 'Value', true);
exactButton = uibutton(modeButtons, 'state', 'Text', 'Exact line search', ...
    'Tag', 'ExactLineSearchMode', ...
    'Tooltip', 'Her iterasyonda iniş yönündeki amaç fonksiyonunu minimize eder.');

alphaField = uieditfield(controls, 'numeric', 'Tag', 'StepSizeField', ...
    'Limits', stepLimits, 'Value', defaultAlpha, ...
    'Tooltip', 'Seçilen α, koşunun tüm iterasyonlarında sabit kalır.');
alphaField.Layout.Row = 2;
alphaField.Layout.Column = 2;
alphaSlider = uislider(controls, 'Tag', 'StepSizeSlider', ...
    'Limits', stepLimits, 'Value', defaultAlpha, ...
    'MajorTicks', [0.001 0.25 0.5 0.75 1 1.25 1.5], ...
    'MajorTickLabels', {'0.001','0.25','0.5','0.75','1','1.25','1.5'}, 'MinorTicks', []);
alphaSlider.Layout.Row = 2;
alphaSlider.Layout.Column = 3;
startField = uieditfield(controls, 'numeric', 'Tag', 'InitialPoint', ...
    'Limits', [-15 15], 'Value', defaultStart);
startField.Layout.Row = 2;
startField.Layout.Column = 4;
limitField = uieditfield(controls, 'numeric', 'Tag', 'IterationLimit', ...
    'Limits', [1 100], 'RoundFractionalValues', 'on', 'Value', defaultMaxIterations);
limitField.Layout.Row = 2;
limitField.Layout.Column = 5;
resetButton = uibutton(controls, 'Text', 'Sıfırla', 'Tag', 'Reset');
resetButton.Layout.Row = 2;
resetButton.Layout.Column = 6;

behaviorLabel = uilabel(layout, 'Tag', 'StepBehavior', 'FontSize', 13, ...
    'FontWeight', 'bold');
behaviorLabel.Layout.Row = 4;
behaviorLabel.Layout.Column = 1;
statusLabel = uilabel(layout, 'Tag', 'RunStatus', ...
    'HorizontalAlignment', 'right', 'FontSize', 13);
statusLabel.Layout.Row = 4;
statusLabel.Layout.Column = 2;

objectiveAxes = uiaxes(layout, 'Box', 'on');
objectiveAxes.Layout.Row = 5;
objectiveAxes.Layout.Column = 1;
hold(objectiveAxes, 'on');
curve = plot(objectiveAxes, nan, nan, 'LineWidth', 1.8, 'Color', blue);
minimumPoint = plot(objectiveAxes, minimum, 0, 'd', ...
    'Color', green, 'MarkerFaceColor', green, 'MarkerSize', 8);
visitedPath = plot(objectiveAxes, nan, nan, 'o--', ...
    'Color', orange, 'LineWidth', 1.2, 'MarkerSize', 4);
currentPoint = plot(objectiveAxes, nan, nan, 'o', ...
    'Color', orange, 'MarkerFaceColor', orange, 'MarkerSize', 8);
title(objectiveAxes, 'Amaç fonksiyonu ve arama yolu');
xlabel(objectiveAxes, 'x');
ylabel(objectiveAxes, 'f(x)');
grid(objectiveAxes, 'on');

progressAxes = uiaxes(layout, 'Box', 'on');
progressAxes.Layout.Row = 6;
progressAxes.Layout.Column = 1;
hold(progressAxes, 'on');
fullProgress = plot(progressAxes, nan, nan, '.-', ...
    'Color', [0.58 0.62 0.67], 'LineWidth', 1);
visibleProgress = plot(progressAxes, nan, nan, '.-', ...
    'Color', blue, 'LineWidth', 1.6);
progressPoint = plot(progressAxes, nan, nan, 'o', ...
    'Color', orange, 'MarkerFaceColor', orange, 'MarkerSize', 6);
xlabel(progressAxes, 'İterasyon k');
grid(progressAxes, 'on');

trace = uigridlayout(layout, [3 1], 'RowHeight', {22, '1x', 20}, ...
    'Padding', [0 0 0 0], 'RowSpacing', 5);
trace.Layout.Row = [5 6];
trace.Layout.Column = 2;
uilabel(trace, 'Text', 'İterasyon tablosu', 'FontSize', 15, 'FontWeight', 'bold');
historyTable = uitable(trace, 'Tag', 'IterationTable', ...
    'ColumnName', {'k','xₖ','f(xₖ)','f′(xₖ)','αₖ'}, ...
    'ColumnWidth', {36,'1x','1x','1x','1x'}, 'RowName', {});
historyTable.Layout.Row = 2;
tableNote = uilabel(trace, 'Text', 'Satırı seçerek adımı incele. αₖ bir sonraki adımda kullanılır.');
tableNote.Layout.Row = 3;
selectedStyle = uistyle('BackgroundColor', [0.86 0.93 0.98], ...
    'FontColor', [0.10 0.16 0.23]);

navigation = uigridlayout(layout, [2 4], 'RowHeight', {28, 26}, ...
    'ColumnWidth', {86,'1x',86,86}, ...
    'Padding', [0 0 0 0], 'RowSpacing', 4, 'ColumnSpacing', 14);
navigation.Layout.Row = 7;
navigation.Layout.Column = [1 2];
stepLabel = uilabel(navigation, 'Tag', 'CurrentStep', ...
    'FontSize', 14, 'FontWeight', 'bold');
stepLabel.Layout.Row = 1;
stepLabel.Layout.Column = [1 4];
prevButton = uibutton(navigation, 'Text', '◀ Geri', 'Tag', 'PreviousStep');
prevButton.Layout.Row = 2;
prevButton.Layout.Column = 1;
iterationSlider = uislider(navigation, 'Tag', 'IterationSlider', ...
    'Limits', [0 1], 'Value', 0, 'MajorTicks', [], 'MinorTicks', []);
iterationSlider.Layout.Row = 2;
iterationSlider.Layout.Column = 2;
nextButton = uibutton(navigation, 'Text', 'İleri ▶', 'Tag', 'NextStep');
nextButton.Layout.Row = 2;
nextButton.Layout.Column = 3;
lastButton = uibutton(navigation, 'Text', 'Son adım', 'Tag', 'LastStep');
lastButton.Layout.Row = 2;
lastButton.Layout.Column = 4;

history = struct();
stepSizes = [];
progressValues = [];
lastStep = 0;
selectedStep = 1;
expressionField.ValueChangedFcn = @(~, ~) applyExpression();
fixedButton.ValueChangedFcn = @(~, ~) selectStepMode(false);
exactButton.ValueChangedFcn = @(~, ~) selectStepMode(true);
alphaField.ValueChangedFcn = @(source, ~) changeAlpha(source.Value);
alphaSlider.ValueChangedFcn = @(source, ~) changeAlpha(round(source.Value, 3));
startField.ValueChangedFcn = @(~, ~) recompute();
limitField.ValueChangedFcn = @(~, ~) recompute();
resetButton.ButtonPushedFcn = @reset;
prevButton.ButtonPushedFcn = @(~, ~) advance(-1);
nextButton.ButtonPushedFcn = @(~, ~) advance(1);
lastButton.ButtonPushedFcn = @goToLastStep;
iterationSlider.ValueChangedFcn = @(~, event) revealStep(event.Value);
iterationSlider.ValueChangingFcn = @(~, event) showStep(event.Value);
historyTable.CellSelectionCallback = @selectRow;

updateObjectiveDisplay();
recompute();
fig.Visible = 'on';

    function applyExpression()
        expression = strtrim(expressionField.Value);
        try
            updatedObjective = parseObjective(expression);
        catch exception
            if ~strcmp(exception.identifier, 'gradient_descent_gui:InvalidExpression')
                rethrow(exception);
            end
            expressionNote.Text = sprintf('%s  ·  Gösterilen f(x): %s', ...
                exception.message, appliedExpression);
            expressionNote.FontColor = [0.68 0.18 0.08];
            return
        end

        expressionNote.Text = expressionHint;
        expressionNote.FontColor = expressionHintColor;
        appliedExpression = expression;
        isDefaultObjective = strcmp(regexprep(expression, '\s|\.(?=[*/^])', ''), ...
            defaultExpression);
        if isDefaultObjective
            objective = defaultObjective;
            gradient = defaultGradient;
        else
            objective = updatedObjective;
            gradient = @(x) approximateSlope(updatedObjective, x);
        end
        updateObjectiveDisplay();
        selectedStep = 1;
        recompute();
    end

    function updateObjectiveDisplay()
        lines = [curve, visitedPath, currentPoint];
        labels = {'f(x)', 'İzlenen adımlar', 'Seçili adım'};
        minimumPoint.Visible = isDefaultObjective;
        if isDefaultObjective
            lines = [curve, minimumPoint, visitedPath, currentPoint];
            labels = {'f(x)', 'Minimum', 'İzlenen adımlar', 'Seçili adım'};
            title(progressAxes, 'Amaç değeri (log ölçek)');
            ylabel(progressAxes, 'max(f(x_k), 10^{-18})');
        else
            title(progressAxes, 'Amaç değeri');
            ylabel(progressAxes, 'f(x_k)');
            progressAxes.YScale = 'linear';
            ylim(objectiveAxes, 'auto');
        end
        legend(objectiveAxes, lines, labels, ...
            'Location', 'north', 'Orientation', 'horizontal', 'AutoUpdate', 'off');
    end

    function changeAlpha(alpha)
        alphaField.Value = alpha;
        alphaSlider.Value = alpha;
        recompute();
    end

    function selectStepMode(isExact)
        useLineSearch = isExact;
        selectedStep = 1;
        recompute();
    end

    function reset(~, ~)
        useLineSearch = false;
        alphaField.Value = defaultAlpha;
        alphaSlider.Value = defaultAlpha;
        startField.Value = defaultStart;
        limitField.Value = defaultMaxIterations;
        expressionField.Value = defaultExpression;
        applyExpression();
    end

    function recompute()
        alpha = alphaField.Value;
        fixedButton.Value = ~useLineSearch;
        exactButton.Value = useLineSearch;
        alphaField.Enable = ~useLineSearch;
        alphaSlider.Enable = ~useLineSearch;
        if useLineSearch
            [~, history, reason, stepSizes] = gradient_descent_iterations( ...
                objective, gradient, startField.Value, [], limitField.Value, tolerance);
        else
            [~, history, reason, stepSizes] = fixed_step_gradient_descent( ...
                objective, gradient, startField.Value, alpha, limitField.Value, tolerance);
        end
        lastStep = max(0, numel(history.F) - 1);
        iterations = (0:numel(history.F)-1).';
        rows = num2cell([iterations, history.X.', history.F, history.Gradient.', stepSizes]);
        if ~isempty(rows)
            rows{end, end} = '—';
        end
        historyTable.Data = rows;
        progressValues = history.F;
        if isDefaultObjective
            progressValues = max(progressValues, plotFloor);
        end
        set(fullProgress, 'XData', iterations, 'YData', progressValues);
        xlim(progressAxes, [-0.25, max(1, lastStep) + 0.25]);
        iterationSlider.Limits = [0, max(1, lastStep)];
        iterationSlider.Enable = lastStep > 0;

        if useLineSearch
            behaviorLabel.Text = 'αₖ = arg min f(xₖ − α f′(xₖ))   |   α ≥ 0';
        elseif isDefaultObjective
            behaviorLabel.Text = quadraticBehavior(alpha);
        else
            behaviorLabel.Text = 'f′(x) sonlu farkla hesaplanır';
        end
        switch reason
            case "converged"
                status = '|f′(x)| tolerans içinde';
            case "iteration-limit"
                status = 'İterasyon sınırına ulaşıldı';
            case "nonfinite"
                status = 'Sonlu olmayan değer';
            case "line-search-failed"
                status = 'Çizgi aramasında minimum bulunamadı';
        end
        if isempty(history.F)
            status = 'Başlangıç noktasında değer veya türev tanımsız';
        end
        statusLabel.Text = sprintf('%s  ·  %d adım', status, lastStep);
        goToStep(selectedStep);
        if isDefaultObjective
            progressAxes.YScale = 'log';
        end
    end

    function selectRow(~, event)
        if ~isempty(event.Indices)
            goToStep(event.Indices(1,1) - 1);
        end
    end

    function goToStep(step)
        showStep(step);
        iterationSlider.Value = selectedStep;
    end

    function revealStep(step)
        goToStep(step);
        scroll(historyTable, 'row', selectedStep + 1);
    end

    function advance(offset)
        revealStep(selectedStep + offset);
    end

    function goToLastStep(~, ~)
        revealStep(lastStep);
    end

    function showStep(step)
        selectedStep = min(max(round(step), 0), lastStep);
        index = min(selectedStep + 1, numel(history.F));
        visitedX = history.X(1:index);
        visitedValues = history.F(1:index);

        if isDefaultObjective
            radius = max(3, 1.18*max(abs(visitedX - minimum)));
            domain = minimum + [-radius radius];
            ylim(objectiveAxes, [-0.065 1.1]*radius^2);
        else
            domain = plotDomain([startField.Value visitedX]);
        end
        samples = linspace(domain(1), domain(2), 301);
        set(curve, 'XData', samples, 'YData', objective(samples));
        xlim(objectiveAxes, domain);
        set(visitedPath, 'XData', visitedX, 'YData', visitedValues);
        set(visibleProgress, 'XData', 0:index-1, 'YData', progressValues(1:index));

        removeStyle(historyTable);
        prevButton.Enable = selectedStep > 0;
        nextButton.Enable = selectedStep < lastStep;
        lastButton.Enable = selectedStep < lastStep;
        if index == 0
            set(currentPoint, 'XData', nan, 'YData', nan);
            set(progressPoint, 'XData', nan, 'YData', nan);
            stepLabel.Text = 'Fonksiyonun tanımlı olduğu bir başlangıç x₀ değeri gir.';
            return
        end

        x = history.X(index);
        value = history.F(index);
        slope = history.Gradient(index);
        set(currentPoint, 'XData', x, 'YData', value);
        set(progressPoint, 'XData', selectedStep, 'YData', progressValues(index));
        addStyle(historyTable, selectedStyle, 'row', index);

        if selectedStep < lastStep
            stepLabel.Text = sprintf(['k = %d / %d     |     ', ...
                'xₖ₊₁ = xₖ − αₖ f′(xₖ) = %.6g − (%.6g)·(%.6g) = %.6g'], ...
                selectedStep, lastStep, x, stepSizes(index), slope, history.X(index + 1));
        else
            stepLabel.Text = sprintf('k = %d / %d     |     xₖ = %.6g     |     f(xₖ) = %.6g', ...
                selectedStep, lastStep, x, value);
        end
    end
end

function objective = parseObjective(expression)
% Read a scalar math expression without evaluating user text as MATLAB code.
if isempty(expression) || numel(expression) > 160
    error('gradient_descent_gui:InvalidExpression', ...
        '1 ile 160 karakter uzunluğunda bir ifade gir.');
end
tokens = regexp(expression, ...
    '\s+|[a-zA-Z]\w*|(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?|\.[*/^]|[+*/^()-]', ...
    'match');
if ~strcmp([tokens{:}], expression)
    invalidExpression();
end
tokens = tokens(~cellfun(@(token) isempty(strtrim(token)), tokens));
tokens{end+1} = '';
position = 1;
mathFunctions = struct('sin', @sin, 'cos', @cos, 'tan', @tan, ...
    'exp', @exp, 'log', @log, 'log10', @log10, 'sqrt', @sqrt, 'abs', @abs);

node = readExpression(1);
if ~isempty(tokens{position})
    invalidExpression();
end
objective = @(x) realValue(node, x);

    function node = readExpression(minPrecedence)
        node = readPrefix();
        while true
            switch tokens{position}
                case '+'
                    precedence = 1;
                    operation = @plus;
                case '-'
                    precedence = 1;
                    operation = @minus;
                case {'*', '.*'}
                    precedence = 2;
                    operation = @times;
                case {'/', './'}
                    precedence = 2;
                    operation = @rdivide;
                case {'^', '.^'}
                    precedence = 4;
                    operation = @power;
                otherwise
                    return
            end
            if precedence < minPrecedence
                return
            end
            position = position + 1;
            right = readExpression(precedence + 1);
            node = @(x) operation(node(x), right(x));
        end
    end

    function node = readPrefix()
        token = tokens{position};
        if isempty(token)
            invalidExpression();
        end
        position = position + 1;
        switch token
            case '+'
                node = readExpression(3);
            case '-'
                operand = readExpression(3);
                node = @(x) -operand(x);
            case '('
                node = readExpression(1);
                consume(')');
            case 'x'
                node = @(x) x;
            case 'pi'
                node = @(~) pi;
            case 'e'
                node = @(~) exp(1);
            otherwise
                number = str2double(token);
                if isfinite(number) && isreal(number)
                    node = @(~) number;
                elseif isfield(mathFunctions, token)
                    mathFunction = mathFunctions.(token);
                    consume('(');
                    argument = readExpression(1);
                    consume(')');
                    node = @(x) mathFunction(argument(x));
                else
                    invalidExpression();
                end
        end
    end

    function consume(expected)
        if ~strcmp(tokens{position}, expected)
            invalidExpression();
        end
        position = position + 1;
    end
end

function invalidExpression()
error('gradient_descent_gui:InvalidExpression', ...
    'Geçersiz ifade. Örnek: (x-1)^2 + sin(x)');
end

function value = realValue(node, x)
rawValue = node(x) + zeros(size(x));
invalid = imag(rawValue) ~= 0 | ~isfinite(rawValue);
value = real(rawValue);
value(invalid) = NaN;
end

function slope = approximateSlope(objective, x)
% Central difference, with a one-sided difference at domain boundaries.
h = eps^(1/3)*max(1, abs(x));
left = objective(x-h);
right = objective(x+h);
slope = (right-left)/(2*h);
if ~isfinite(right)
    slope = (objective(x)-left)/h;
elseif ~isfinite(left)
    slope = (right-objective(x))/h;
end
end

function domain = plotDomain(positions)
lower = min(positions);
upper = max(positions);
center = lower/2 + upper/2;
radius = max(3, 1.18*(upper/2 - lower/2));
domain = max(-realmax, min(realmax, center + [-radius radius]));
end

function text = quadraticBehavior(alpha)
if alpha < 0.5
    behavior = 'Tek taraftan yakınsama';
elseif alpha == 0.5
    behavior = 'Minimuma tek adım';
elseif alpha < 1
    behavior = 'Salınımlı yakınsama';
elseif alpha == 1
    behavior = 'Sürekli salınım';
else
    behavior = 'Iraksama';
end
text = sprintf('%s   |   1 − 2α = %.9g', behavior, 1 - 2*alpha);
end
