 % Method to query the user whether he really wants to push ground truth data to the remote repository
function queryUserWhetherToPushGroundTruthDataToRepoteRepository(obj)

    obj.userOKwithPushingGroundTruthDataToRemoteRepository = false;
    
    updateString = upper('Yes, I know what I am doing!');
    donotUpdateString = upper('Ooops... No, please do not update the ground truth data.');
    
    % Construct a questdlg with three options
    choice = questdlg(upper('Really update the ground truth data on the remote repository ?'), ...
                      'ABOUT TO UPDATE GROUND TRUTH DATA IN REMOTE REPOSITORY', ...
                      updateString, donotUpdateString, donotUpdateString);
                  
    % Handle response
    switch choice
        case updateString
        obj.userOKwithPushingGroundTruthDataToRemoteRepository = true;
        
        case donotUpdateString
        obj.userOKwithPushingGroundTruthDataToRemoteRepository = false;
    end
end