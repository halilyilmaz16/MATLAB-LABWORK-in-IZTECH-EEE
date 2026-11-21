function [x, history, stopReason, stepSizes] = fixed_step_gradient_descent( ...
    objective, gradient, x0, stepSize, maxIterations, tolerance)
%FIXED_STEP_GRADIENT_DESCENT Minimize an objective with a constant step size.
%   [X,HISTORY,STOPREASON] = FIXED_STEP_GRADIENT_DESCENT(F,G,X0,ALPHA)
%   applies x(k+1) = x(k) - ALPHA*G(x(k)). F returns a real scalar and G
%   returns a real column vector of the same size as X0.
%
%   Specify MAXITERATIONS and TOLERANCE to override the defaults (100 and
%   1e-8). Convergence is checked using norm(G(x),2) <= TOLERANCE.
%   HISTORY stores valid iterates by column in X and Gradient, with F and
%   GradientNorm as column vectors. Its first entry is iteration zero.
%   STOPREASON is "converged", "iteration-limit", or "nonfinite".
%   X is the last valid iterate, or X0 if the initial evaluation is nonfinite.
%   The optional fourth output STEPSIZES lists the step from each iterate
%   to the next one. Its final row is NaN when the history is nonempty.
%
%   Example:
%       [x,h] = fixed_step_gradient_descent(@(x)(x-2).^2, ...
%           @(x)2*(x-2), -3, 0.2);

arguments
    objective (1,1) function_handle
    gradient (1,1) function_handle
    x0 (:,1) double {mustBeNonempty,mustBeReal,mustBeFinite}
    stepSize (1,1) double {mustBeReal,mustBeFinite,mustBePositive}
    maxIterations (1,1) double {mustBeReal,mustBeFinite, ...
        mustBeInteger,mustBeNonnegative} = 100
    tolerance (1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 1e-8
end

[x, history, stopReason, stepSizes] = gradient_descent_iterations( ...
    objective, gradient, x0, stepSize, maxIterations, tolerance);
end
