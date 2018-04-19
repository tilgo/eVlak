public with sharing class pregledNekupljenihController {
	public String currUserId {get; set;}

	public List<Vozovnica__c> vozovnice {get; set;}

	public Boolean isError {get; set;}
	public String errorMsg {get; set;}

	public String vozovnicaToDeleteId {get; set;}

	public pregledNekupljenihController() {
		getUserInfo();
		getUsersTickets();
		isError = false;
		errorMsg = '';

	}

	public void getUserInfo() {
		currUserId = UserInfo.getUserId();
		System.debug('currUserId');
		System.debug(currUserId);
	}

	public void getUsersTickets() {
		vozovnice = new List<Vozovnica__c>([SELECT Id, Name, Kupec__c, Placana__c, Relacija__c, Preklicana__c, Stevilo_Vozovnic__c, Datum_Veljave__c, Porabljena_Vozovnica__c, Postaja_Od__r.Name, 
											Postaja_Do__r.Name, Povratna_Vozovnica__c, Cena_Vozovnice__c, Porabljena_Vozovnica_Timestamp__c, Porabljena_Vozovnica_Final__c
											FROM Vozovnica__c WHERE Kupec__c = :currUserId AND Placana__c = false AND Datum_Veljave__c >= TODAY ORDER BY Datum_Veljave__c DESC]);
		System.debug('vozovnice');
		System.debug(vozovnice);
	}

	public void resetError() {
        isError = false;
        errorMsg = '';
    }

    public void deleteVozovnica() {
    	System.debug('vozovnicaToDeleteId');
    	System.debug(vozovnicaToDeleteId);
    	List<Vozovnica__c> vozovniceList = new List<Vozovnica__c>([SELECT Id FROM Vozovnica__c WHERE Id = :vozovnicaToDeleteId LIMIT 1]);
    	if(vozovniceList != null && vozovniceList.size() > 0) {
    		delete vozovniceList[0];
    	}
    	vozovnice = new List<Vozovnica__c>([SELECT Id, Name, Kupec__c, Placana__c, Relacija__c, Preklicana__c, Stevilo_Vozovnic__c, Datum_Veljave__c, Porabljena_Vozovnica__c, Postaja_Od__r.Name, 
											Postaja_Do__r.Name, Povratna_Vozovnica__c, Cena_Vozovnice__c, Porabljena_Vozovnica_Timestamp__c, Porabljena_Vozovnica_Final__c
											FROM Vozovnica__c WHERE Kupec__c = :currUserId AND Placana__c = false AND Datum_Veljave__c >= TODAY ORDER BY Datum_Veljave__c DESC]);
    }
}