function result = iterate_2R_ik(q0, target, method, alpha, tolerance, maxIter)
%ITERATE_2R_IK Solve planar, unit-link IK. History column k+1 is iterate k.
arguments
    q0 (2,1) double {mustBeFinite, mustBeReal}
    target (2,1) double {mustBeFinite, mustBeReal}
    method (1,1) string {mustBeMember(method, ["Newton","Gradient"])}
    alpha (1,1) double {mustBePositive, mustBeFinite} = 0.2
    tolerance (1,1) double {mustBePositive, mustBeFinite} = 1e-6
    maxIter (1,1) double {mustBeInteger, mustBeNonnegative, mustBeFinite} = 500
end
q = zeros(2, maxIter+1);
tip = zeros(2, maxIter+1);
errorNorm = zeros(1, maxIter+1);
q(:,1) = q0;
status = "No - Max Iter";
diagnostic = "";

for n = 1:maxIter+1
    [tip(:,n), J] = kinematics(q(:,n));
    e = target - tip(:,n);
    errorNorm(n) = norm(e, 2);
    if errorNorm(n) < tolerance
        status = "Yes";
        break
    end
    if n == maxIter+1
        break
    end
    if method == "Newton"
        conditioning = rcond(J);
        if conditioning <= sqrt(eps)
            status = "Singular/Diverged";
            diagnostic = compose("Stopped before solve at k=%d (rcond=%.2e).", ...
                n-1, conditioning);
            break
        end
        delta = J \ e;
    else
        delta = alpha * (J.' * e);
    end
    candidate = q(:,n) + delta;
    if any(~isfinite(candidate)) || ~isfinite(sum(candidate))
        status = "Singular/Diverged";
        diagnostic = compose("Nonfinite update rejected at k=%d.", n-1);
        break
    end
    q(:,n+1) = candidate;
end
result.q = q(:,1:n);                 % unwrapped radians for both algorithms
result.tip = tip(:,1:n);
result.error = errorNorm(1:n);
result.iterations = n-1;              % counts updates, excluding the start
result.status = status;
result.finalWrapped = atan2(sin(q(:,n)), cos(q(:,n)));
result.minAbsSinQ2 = min(abs(sin(result.q(2,:))));
if diagnostic == "" && any(diff(result.error) > 0)
    diagnostic = "Residual increased on " + nnz(diff(result.error) > 0) + " update(s).";
end
result.diagnostic = diagnostic;
end

function [tip, J] = kinematics(q)
% The two unit vectors point along the first and second links.
a = [cos(q(1)); sin(q(1))];
b = [cos(sum(q)); sin(sum(q))];
tip = a + b;
J = [-tip(2), -b(2); tip(1), b(1)];
end
