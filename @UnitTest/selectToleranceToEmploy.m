% Method to select which tolerance to employ by checking if the fieldName exists in customTolerances
function toleranceEmployed = selectToleranceToEmploy(globalTolerance, customTolerances, fieldName)
    toleranceEmployed = globalTolerance;
    
    fieldName = strrep(fieldName, 'validationData.', '');
    drilledDownToleranceStuct = customTolerances;
    drilledFieldName = fieldName;
    
    fieldPath = strsplit(drilledFieldName, '.');
    for k = 1:numel(fieldPath)
        if (isfield(drilledDownToleranceStuct, fieldPath{k}))
            drilledDownToleranceStuct = drilledDownToleranceStuct.(fieldPath{k});
            drilledFieldName = strrep(drilledFieldName, sprintf('%s.', fieldPath{k}), '');
            if (k ==numel(fieldPath))
                toleranceEmployed = drilledDownToleranceStuct;
            end
        end
    end

    %fprintf('Tolerance for field %s: %g\n', fieldName, toleranceEmployed);
end