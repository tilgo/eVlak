public class nakupVozovniceController {

    public Boolean isError {get; set;}
    public String errorMsg {get; set;}

    public String relacijaId {get; set;}
    public Boolean smerProtiLj {get; set;}
    public Boolean povratna {get; set;}
    public Date izbranDate {get; set;}

    public String stringDate {get; set;}

    public Relacija__c relacija {get; set;}

    public Vozovnica__c vozovnica {get; set;}

    public Id postajaOdId {get; set;}
    public String postajaOdName {get; set;}
    public Id postajaDoId {get; set;}
    public String postajaDoName {get; set;}

    public String currentStatus {get; set;}

    public Decimal steviloVozovnic {get; set;}

    public String vozovnicaId;

    public wVozovnica vozovnicaW {get; set;}

	public nakupVozovniceController() {
		try {
			vozovnicaId = ApexPages.currentPage().getParameters().get('vid');
			currentStatus = 'urejanje';
			if(!String.isBlank(vozovnicaId)) {
				getVozovnica(vozovnicaId);
			} else {
				relacijaId = ApexPages.currentPage().getParameters().get('rid');
				smerProtiLj = Boolean.valueOf(ApexPages.currentPage().getParameters().get('s'));
				povratna = Boolean.valueOf(ApexPages.currentPage().getParameters().get('p'));
				stringDate = ApexPages.currentPage().getParameters().get('d');
				izbranDate = Date.parse(stringDate);
				if(izbranDate < Date.today()) {
					setError('Datum ne more biti manjši od današnjega!');
					return;
				}
				pridobiPodatkeRelacije();
			}
			
		} catch(Exception e) {
			setError('Nekaj je šlo narobe [dodaj preusmeritev nazaj na vozni red] + [' + e.getMessage() + ']');
			System.debug(e.getMessage());
		}
	}

	public void setStatus() {
		
		if(currentStatus == 'urejanje') {
			currentStatus = 'povzetek';
			insertVozovnica();
		} else if(currentStatus == 'povzetek') {
			currentStatus = 'placilo';
		} else if(currentStatus == 'placilo') {
			sleep(5000);
			currentStatus = 'konec';
			nastaviVozovnicoKotPlacano();
		} else if(currentStatus == 'pregled') {
			
		}
	}

	public void tiskVozovnice() {

	}

	public void setStatusBack() {
		if(currentStatus == 'urejanje') {
			
		} else if(currentStatus == 'povzetek') {
			currentStatus = 'urejanje';
			if(String.isBlank(vozovnicaId)) {
				deleteVozovnica();
			}
		} else if(currentStatus == 'placilo') {
			currentStatus = 'povzetek';
		} else if(currentStatus == 'pregled') {
			
		}
	}

	public void recalculateCena() {
		System.debug('recaculateCena');
		System.debug('Before cena: ' + vozovnicaW.cenaVozovnice);
		System.debug('St. vozovnic: ' + vozovnicaW.stVozovnic);
		Integer povratnaPribitek = vozovnicaW.povratna ? 2 : 1;
		vozovnicaW.cenaVozovnice = vozovnicaW.originalnaCenaVozovnice * vozovnicaW.stVozovnic * povratnaPribitek;
		System.debug('After cena: ' + vozovnicaW.cenaVozovnice);
	}

	public void sleep(Long milliSeconds) {
            Long timeDiff = 0;
            DateTime firstTime = System.now();
            do{
                timeDiff = System.now().getTime() - firstTime.getTime();
            } while(timeDiff <= milliSeconds);
    }

    public void setError(String errorLabel) {
        isError = true;
        errorMsg = errorLabel;
    }

    public void resetError() {
        isError = false;
        errorMsg = '';
    }

    public void insertVozovnica() {
    	System.debug('Podatki vozovnice');
    	System.debug(vozovnicaW);
    	if(vozovnica == null) {
    		vozovnica = new Vozovnica__c(Postaja_Do__c = vozovnicaW.postajaDoId, Postaja_Od__c = vozovnicaW.postajaOdId, Kupec__c = UserInfo.getUserId(), Datum_Veljave__c = vozovnicaW.datumVeljave, 
    												Povratna_Vozovnica__c = vozovnicaW.povratna, Relacija__c = vozovnicaW.relacija.Id, Stevilo_Vozovnic__c = vozovnicaW.stVozovnic, Cena_Vozovnice__c = vozovnicaW.cenaVozovnice);

    		vozovnica.Cena_Vozovnice__c = vozovnicaW.originalnaCenaVozovnice * (vozovnicaW.povratna ? 2 : 1) * (vozovnicaW.stVozovnic != null && vozovnicaW.stVozovnic != 0 ?vozovnicaW.stVozovnic : 1);
    		vozovnicaW.originalnaCenaVozovnice = vozovnica.Cena_Vozovnice__c;
			insert vozovnica;
    	} else if(!String.isBlank(vozovnicaId)) {
    		
    		vozovnica.Stevilo_Vozovnic__c = vozovnicaW.stVozovnic;
    		vozovnica.Povratna_Vozovnica__c = vozovnicaW.povratna;

    		//vozovnica.Cena_Vozovnice__c = vozovnicaW.cenaVozovnice;
    		vozovnica.Cena_Vozovnice__c = vozovnicaW.originalnaCenaVozovnice * (vozovnicaW.povratna ? 2 : 1) * (vozovnicaW.stVozovnic != null && vozovnicaW.stVozovnic != 0 ?vozovnicaW.stVozovnic : 1);
    		vozovnicaW.originalnaCenaVozovnice = vozovnica.Cena_Vozovnice__c;
    		update vozovnica;
    	}
    	

		//getVozovnica(vozovnica.Id);
    }

    public void nastaviVozovnicoKotPlacano() {
    	vozovnica.Placana__c = true;
    	update vozovnica;
    }

    public void deleteVozovnica() {

		delete vozovnica;
		vozovnica = null;

    }

    public void getVozovnica(String vozovnicaId) {
    	List<Vozovnica__c> vozovnice = new List<Vozovnica__c>([SELECT Id, Postaja_Do__c, Postaja_Do__r.Name, Postaja_Od__c, Postaja_Od__r.Name, Kupec__c, Datum_Veljave__c, Povratna_Vozovnica__c,
    														Relacija__c, Relacija__r.Razdalja__c, Relacija__r.Cena__c, Stevilo_Vozovnic__c, Cena_Vozovnice__c
    													  FROM Vozovnica__c WHERE Id = :vozovnicaId AND Placana__c = false LIMIT 1]);
    	if(vozovnice != null && vozovnice.size() > 0) {
    		vozovnica = vozovnice[0];

    		postajaOdId = vozovnica.Postaja_Od__c;
    		postajaDoId = vozovnica.Postaja_Do__c;

    		postajaOdName = vozovnica.Postaja_Od__r.Name;
    		postajaDoName = vozovnica.Postaja_Do__r.Name;

    		steviloVozovnic = vozovnica.Stevilo_Vozovnic__c;
    		povratna = vozovnica.Povratna_Vozovnica__c;
    		
			izbranDate = vozovnica.Datum_Veljave__c;
			stringDate = izbranDate.format();
			if(izbranDate < Date.today()) {
				setError('Datum ne more biti manjši od današnjega!');
				return;
			}

			

			vozovnicaW = new wVozovnica(postajaOdId, postajaDoId, postajaOdName, postajaDoName,	vozovnica.Relacija__r.Razdalja__c, vozovnica.Relacija__r.Cena__c, 
									izbranDate, stringDate, povratna, steviloVozovnic);
			System.debug('vozovnicaW');
			System.debug(vozovnicaW);
    	} else {
    		setError('Vozovnica ne obstaja ali pa je že bila plačana.');
    	}
    }

    public void pridobiPodatkeRelacije() {
    	List<Relacija__c> listOfRelacije = new List<Relacija__c>([SELECT Id, Cena__c, Razdalja__c, Postaja_1__c, Postaja_1__r.Name, Postaja_2__r.Name FROM relacija__c WHERE Id = :relacijaId]);

    	if(listOfRelacije != null && listOfRelacije.size() > 0) {
    		relacija = listOfRelacije[0];

    		postajaOdId = smerProtiLj ? relacija.Postaja_2__c : relacija.Postaja_1__c;
    		postajaDoId = !smerProtiLj ? relacija.Postaja_2__c : relacija.Postaja_1__c;

    		postajaOdName = smerProtiLj ? relacija.Postaja_2__r.Name : relacija.Postaja_1__r.Name;
    		postajaDoName = !smerProtiLj ? relacija.Postaja_2__r.Name : relacija.Postaja_1__r.Name;

    		steviloVozovnic = 1;

    		vozovnicaW = new wVozovnica(postajaOdId, postajaDoId, postajaOdName, postajaDoName,	relacija, izbranDate, stringDate, povratna, steviloVozovnic);

    		//Vozovnica__c voz = new Vozovnica__c(Do_Postanek__c = postajaDoId, Od_Postanek__c = postajaOdId, Kupec__c = UserInfo.getUserId(), Datum_Veljave__c = izbranDate, 
    		//										Povratna_Vozovnica__c = (povratna ? 'Da' : 'Ne'), Relacija__c = relacija.Id, Stevilo_Vozovnic__c = steviloVozovnic);
    		//Vozovnica__c voz = new Vozovnica__c(Do_Postanek__c = postajaDoId, Od_Postanek__c = postajaOdId, Kupec__c = UserInfo.getUserId());
    		//insert voz;

    		//getVozovnica(vozovnica.Id);
    		System.debug('vozovnicaW');
    		System.debug(vozovnicaW);
    	}
    }

    /* Wrappers */
    public class wVozovnica {
    	public Id postajaOdId {get; set;}
    	public Id postajaDoId {get; set;}
    	public String postajaOdName {get; set;}
    	public String postajaDoName {get; set;}
    	public Relacija__c relacija {get; set;}
    	public Decimal cenaVozovnice {get; set;}
    	public Decimal razdaljaRelacije {get; set;}
    	public Date datumVeljave {get; set;}
    	public String izbranDateString {get; set;}
    	public Boolean povratna {get; set;}
    	public Decimal stVozovnic {get; set;}
    	public Decimal originalnaCenaVozovnice {get; set;}

    	public wVozovnica(Id postajaOdId, Id postajaDoId, String postajaOdName, String postajaDoName, Relacija__c relacija, Date datumVeljave, String izbranDateString, Boolean povratna, Decimal stVozovnic) {
    		this.postajaOdId = postajaOdId;
    		this.postajaDoId = postajaDoId;
    		this.postajaOdName = postajaOdName;
    		this.postajaDoName = postajaDoName;
    		this.relacija = relacija;
    		this.cenaVozovnice = relacija.Cena__c * (povratna ? 2 : 1);
    		this.razdaljaRelacije = relacija.Razdalja__c;
    		this.datumVeljave = datumVeljave;
    		this.izbranDateString = izbranDateString;
    		this.povratna = povratna;
    		this.stVozovnic = stVozovnic;
    		this.originalnaCenaVozovnice = relacija.Cena__c;
    	}

    	public wVozovnica(Id postajaOdId, Id postajaDoId, String postajaOdName, String postajaDoName, Decimal razdalja, Decimal cena , Date datumVeljave, String izbranDateString, Boolean povratna, Decimal stVozovnic) {
    		this.postajaOdId = postajaOdId;
    		this.postajaDoId = postajaDoId;
    		this.postajaOdName = postajaOdName;
    		this.postajaDoName = postajaDoName;
    		this.cenaVozovnice = cena  * (povratna ? 2 : 1);
    		this.razdaljaRelacije = razdalja;
    		this.datumVeljave = datumVeljave;
    		this.izbranDateString = izbranDateString;
    		this.povratna = povratna;
    		this.stVozovnic = stVozovnic;
    		this.originalnaCenaVozovnice = cena;
    	}
    }
}