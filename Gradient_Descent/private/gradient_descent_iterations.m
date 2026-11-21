function [x, history, stopReason, stepSizes] = gradient_descent_iterations( ...
    objective, gradient, x0, fixedStep, maxIterations, tolerance)
% An empty fixedStep selects numerical exact line search.
positions = zeros(numel(x0), maxIterations + 1);
gradients = zeros(size(positions));
values = zeros(maxIterations + 1, 1);
gradientNorms = zeros(size(values));
stepSizes = nan(size(values));
candidate = x0;
x = x0;
count = 0;
stopReason = "nonfinite";
useLineSearch = isempty(fixedStep);

for iteration = 0:maxIterations
    if any(~isfinite(candidate))
        break
    end

    value = objective(candidate);
    slope = gradient(candidate);
    validateattributes(value, {'numeric'}, {'real','scalar'}, mfilename, 'F(x)');
    validateattributes(slope, {'numeric'}, {'real','size',size(x0)}, ...
        mfilename, 'G(x)');
    slope = double(slope);
    slopeNorm = norm(slope);
    if ~isfinite(value) || ~isfinite(slopeNorm)
        break
    end

    count = iteration + 1;
    x = candidate;
    positions(:, count) = x;
    gradients(:, count) = slope;
    values(count) = value;
    gradientNorms(count) = slopeNorm;

    if slopeNorm <= tolerance
        stopReason = "converged";
        break
    end
    if iteration == maxIterations
        stopReason = "iteration-limit";
        break
    end

    if useLineSearch
        direction = -slope/slopeNorm;
        distance = minimizeAlongRay(objective, x, direction, value, slopeNorm);
        step = distance/slopeNorm;
        if ~isfinite(step) || step <= 0
            stopReason = "line-search-failed";
            break
        end
        candidate = x + distance*direction;
    else
        step = fixedStep;
        candidate = x - step*slope;
    end
    stepSizes(count) = step;
end

history = struct('X', positions(:, 1:count), ...
    'F', values(1:count), ...
    'Gradient', gradients(:, 1:count), ...
    'GradientNorm', gradientNorms(1:count));
stepSizes = stepSizes(1:count);
if count > 0
    stepSizes(end) = NaN;
end
end

function distance = minimizeAlongRay(objective, x, direction, startValue, slopeNorm)
% Search in displacement units. Divide by the gradient norm to recover alpha.
lineObjective = @(t) rayValue(objective, x, direction, t);
maxBracketAttempts = 52;
middle = min(1, max(sqrt(eps), slopeNorm));
middleValue = lineObjective(middle);
distance = NaN;
for attempt = 1:maxBracketAttempts
    if middleValue < startValue
        break
    end
    middle = middle/2;
    middleValue = lineObjective(middle);
end
if middleValue >= startValue
    return
end

lower = 0;
for attempt = 1:maxBracketAttempts
    upper = 2*middle;
    upperValue = lineObjective(upper);
    if upperValue >= middleValue
        options = optimset('Display', 'off', 'TolX', 1e-12*max(1, norm(x, inf)));
        [trial, trialValue, exitFlag] = fminbnd(lineObjective, lower, upper, options);
        if exitFlag > 0
            distance = middle;
            if trialValue <= middleValue
                distance = trial;
            end
        end
        return
    end
    lower = middle;
    middle = upper;
    middleValue = upperValue;
end
end

function value = rayValue(objective, x, direction, distance)
point = x + distance*direction;
value = Inf;
if all(isfinite(point))
    trialValue = objective(point);
    if isreal(trialValue) && isfinite(trialValue)
        value = trialValue;
    end
end
end
