function roundedValue = roundBeforeHashingGivenTolerance(numericValue, tolerance)

    if (isempty(numericValue))
        roundedValue = numericValue;
        return;
    end
    
    truncator = abs(tolerance);
    
    if (~isreal(numericValue))
        realValue = real(numericValue);
        imagValue = imag(numericValue);
        realRoundedValue = sign(realValue) .* round(abs(realValue/truncator)) * truncator;
        imagRoundedValue = sign(imagValue) .* round(abs(imagValue/truncator)) * truncator;
        roundedValue = realRoundedValue + 1i * imagRoundedValue;
    else
        roundedValue = sign(numericValue) .* round(abs(numericValue/truncator)) * truncator;
    end
    
end

