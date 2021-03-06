% Method to round numeric values to N decimal digits
function roundedValue = roundToNdigits(numericValue, decimalDigits)
    
    if (isempty(numericValue))
        roundedValue = numericValue;
        return;
    end
    
    truncator = 10^(-decimalDigits);
    roundedValue = sign(numericValue) .* round(abs(numericValue/truncator)) * truncator;
end


