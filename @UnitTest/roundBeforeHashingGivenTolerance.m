function roundedValue = roundBeforeHashingGivenTolerance(numericValue, tolerance)

    if (isempty(numericValue))
        roundedValue = numericValue;
        return;
    end
    
    truncator = abs(tolerance);
    
    if (~isreal(numericValue))
        %warndlg(sprintf('Complex %d-dim Variable! Will compare ABS value.', ndims(numericValue)), sprintf('TOL:%g', tolerance));
        roundedValue = round(abs(numericValue)/truncator) * truncator;
    else
        roundedValue = sign(numericValue) .* round(abs(numericValue/truncator)) * truncator;
    end
    
end

