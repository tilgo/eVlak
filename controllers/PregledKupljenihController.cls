public class PregledKupljenihController {

	public String currUserId {get; set;}

	public List<Vozovnica__c> vozovnice {get; set;}

	public Boolean isError {get; set;}
	public String errorMsg {get; set;}

	public PregledKupljenihController() {
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
											FROM Vozovnica__c WHERE Kupec__c = :currUserId AND Placana__c = true ORDER BY Porabljena_Vozovnica_Final__c ASC, Datum_Veljave__c DESC]);
		System.debug('vozovnice');
		System.debug(vozovnice);
	}

	public void resetError() {
        isError = false;
        errorMsg = '';
    }


}