% Ask whether passed expression is within tolerance of zero.
function assertIsZero(diffExpression,exprString,tolerance)
    
    %% Do the comparison
    if (max(abs(diffExpression(:)) > tolerance))
        message = sprintf('%s differs from zero by more than tolerance (%0.1g). [Diff: %g]', exprString, tolerance, max(abs(diffExpression(:))));
        UnitTest.validationRecord('FAILED', message);
    else
        message = sprintf('%s is within the specified tolerance (%0.1g) of zero.', exprString, tolerance);
        UnitTest.validationRecord('PASSED', message);
    end
         
end

