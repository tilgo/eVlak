public with sharing class globalNavigationComponentController {
	public Id userId {get; set;}
	public String userName {get; set;}
	public Boolean isMember {get; set;}

	public globalNavigationComponentController() {
		isMember = false;
		userName = null;
		getUserInfo();

	}

	public void getUserInfo() {
		userId = UserInfo.getUserId();
		
		System.debug('userId');
		System.debug(userId);

		if(userId != null && userId != '0050Y000002TdAsQAK') {
			isMember = true;
			userName = UserInfo.getFirstName();
			System.debug('userName');
			System.debug(userName);
		}
	}
}