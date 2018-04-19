public with sharing class UrejanjePodatkovController {
	public String currUserId {get; set;}
	public User currUser {get; set;}

	public Boolean isError {get; set;}
	public String errorMsg {get; set;}

	public UrejanjePodatkovController() {
		getUserInfo();
		resetError();
		getCurrentUser();
	}

	public void getUserInfo() {
		currUserId = UserInfo.getUserId();
		System.debug('currUserId');
		System.debug(currUserId);
	}

	public void resetError() {
        isError = false;
        errorMsg = '';
    }

    public void getCurrentUser() {
    	currUser = [SELECT Id, Name, FirstName, LastName  FROM User WHERE Id = :currUserId];
    }

    public void shraniPodatke() {
    	update currUser;
    }
}