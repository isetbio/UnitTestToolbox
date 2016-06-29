function roundedValue = roundBeforeHashingGivenTolerance(numericValue, tolerance)

    if (isempty(numericValue))
        roundedValue = numericValue;
        return;
    end
    
    truncator = tolerance;
    roundedValue = sign(numericValue) .* round(abs(numericValue/truncator)) * truncator;
    
end

