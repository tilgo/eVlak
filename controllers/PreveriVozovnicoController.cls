public with sharing class PreveriVozovnicoController {
	public String vozovnicaId {get; set;}

	public Vozovnica__c vozovnica {get; set;}

	public PreveriVozovnicoController() {
		vozovnicaId = '';
		vozovnicaId = ApexPages.currentPage().getParameters().get('id');
		getVozovnicaInfo();
		System.debug(vozovnicaId);
	}

	public void getVozovnicaInfo() {
		List<Vozovnica__c> vozovnice = new List<Vozovnica__c>([SELECT Id, Name, Postaja_Do__c, Postaja_Do__r.Name, Postaja_Od__c, Postaja_Od__r.Name, Kupec__c, Datum_Veljave__c, Povratna_Vozovnica__c, Kupec__r.Name,
    														Relacija__c, Relacija__r.Razdalja__c, Relacija__r.Cena__c, Stevilo_Vozovnic__c, Cena_Vozovnice__c, Placana__c, Porabljena_Vozovnica_Final__c, QR_Koda_Link__c,
    														Porabljena_Vozovnica__c, Porabljena_Vozovnica_Povratna__c, Porabljena_Vozovnica_Timestamp__c,Porabljena_Vozovnica_Povratna_Timestamp__c 
    														FROM Vozovnica__c WHERE Id = :vozovnicaId]);
		System.debug(vozovnice);
		if(vozovnice != null && vozovnice.size() > 0) {
			vozovnica = vozovnice[0];
			System.debug(vozovnica);
		}
	}

	public void preveriVozovnico() {
		vozovnica.Porabljena_Vozovnica__c = true;
		vozovnica.Porabljena_Vozovnica_Timestamp__c = Datetime.now().addHours(1);
		vozovnica.Porabljena_Vozovnica_Kontrolor__c = UserInfo.getUserId();
		update vozovnica;
	}

	public void preveriPovratnoVozovnico() {
		vozovnica.Porabljena_Vozovnica_Povratna__c = true;
		vozovnica.Porabljena_Vozovnica_Povratna_Timestamp__c = Datetime.now().addHours(1);
		vozovnica.Porabljena_Vozovnica_Povratna_Kontrolor__c = UserInfo.getUserId();
		update vozovnica;
	}
}