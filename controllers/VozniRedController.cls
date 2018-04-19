public class VozniRedController {
    public String postajeJSON {get;set;}
    public Boolean renderVR {get; set;}
    public String vstopnaValue {get; set;} 
    public String izstopnaValue {get; set;}
    public String startDate {get; set;}
    public Boolean povratnaVozovnicaCheckbox {get; set;}
    public List<Vlak__c> vsiVlaki {get; set;} // temporary, later on create wrapper that contains all data
    public wRelacija trenutnaRelacija {get; set;} // podatki o relaciji za prikaz na izbranem voznem redu
    public List<wIskaniVlaki> wVlakList {get; set;}
    public Relacija__c relacija {get; set;}

    public Boolean showLoginModal {get; set;}

    public String izstopnaApiPlaceId {get; set;}
    public String vstopnaApiPlaceId {get; set;}

    public Boolean isMember {get; set;}

    public Boolean showMap {get; set;}

    public Boolean isError {get; set;}
    public String errorMsg {get; set;}

    public Boolean searchPressed {get; set;}

    public String stringDate {get; set;}
    public Date tempDate {get; set;}

    public Boolean smerVoznjeProtiLj {get; set;}

    public VozniRedController() {
        resetError();
        searchPressed = false;
        showMap = false;
        isMember = false;
    	renderVR = false;
    	relacija = new Relacija__c();
        showLoginModal = false;
        getUserInfo();
    	getPostajeIzbira();
    }

    public void getUserInfo() {
        String userId = UserInfo.getUserId();
        
        System.debug('userId');
        System.debug(userId);

        if(userId != null && userId != '0050Y000002TdAsQAK') { //not default user id
            isMember = true;
        }
    }

    public void setSearchToFalse() {
        searchPressed = false;
    }

    public void toggleMap() {
        showMap =! showMap;
    }

    public void closeLoginModal() {
        showLoginModal = false;
    }

    public void openLoginModal() {
        //if(isMember)
        showLoginModal = true;
    }
    
    
    public void getPostajeIzbira() {

    	List<wLookup> postaje = new List<wLookup>();
        for(Postaja__c p : [SELECT Id, Name FROM Postaja__c]) {
            postaje.add(new wLookup(p.Id, p.Name));
            
        }
        System.debug('Postaje:');
        System.debug(postaje);
        postajeJSON = JSON.serialize(postaje);
        System.debug(postajeJSON);
    }

    public class wLookup {
    	public String id;
    	public String label;

    	public wLookup(String id, String label) {
    		this.id = id;
    		this.label = label;
    	}
    }

    public void vozniRedMock() {
    	renderVR =! renderVR;
    	
    }

    public void setError(String errorLabel) {
        isError = true;
        errorMsg = errorLabel;
    }

    public void resetError() {
        isError = false;
        errorMsg = '';
    }

    public void getResults() {
        searchPressed = true;
        resetError();
        sleep(250);

    	System.debug('vstopnaValue');
    	System.debug(vstopnaValue);
    	System.debug('izstopnaValue');
    	System.debug(izstopnaValue);
    	System.debug('startDate');
    	System.debug(startDate);
    	renderVR =! renderVR;

    	smerVoznjeProtiLj = null; // true -> proti lj, false -> iz lj

    	System.debug('smerVoznjeProtiLj');
		System.debug(smerVoznjeProtiLj);

		// error detection
		// check if entering and leaving station is not blank
    	if(String.isBlank(vstopnaValue)) {
    		// todo return page error -> izberite vstopno postajo
            setError('Izberite vstopno postajo!');
    		return;
    	}
    	if(String.isBlank(izstopnaValue)) {
    		// todo return page error -> izberite izstopno postajo
            setError('Izberite izstopno postajo!');
    		return;
    	}

    	// check if date is in right format
    	DateTime tempDt;
    	try {
    		tempDate = Date.parse(startDate);
    		tempDt = tempDate;
    	} catch(Exception e) { // error detection
    		// todo page error and return -> izbran je napačen datum
            setError('Izbran je napačen datum!');
    		return;
    		System.debug(e.getMessage());
    	}

        stringDate = tempDate.format();


        if(tempDate < Date.today()) {
            setError('Datuma, ki je manjši od današnjega, ni mogoče izbrati!');
            return;
        }

    	System.debug('tempDate');
    	System.debug(tempDate);
    	System.debug(tempDt.format('u'));

    	System.debug('povratnaVozovnicaCheckbox');
    	System.debug(povratnaVozovnicaCheckbox);


    	// get desired relation direction (v smeri ljubljani ali obratno)
    	List<Postaja__c> izstopnaPostajaList = [SELECT Id, Name, Order__c, Maps_Api_Place_Id__c FROM Postaja__c WHERE Id = :izstopnaValue LIMIT 1];
    	List<Postaja__c> vstopnaPostajaList = [SELECT Id, Name, Order__c, Maps_Api_Place_Id__c FROM Postaja__c WHERE Id = :vstopnaValue LIMIT 1];


    	if(izstopnaPostajaList != null && izstopnaPostajaList.size() > 0 && vstopnaPostajaList != null && vstopnaPostajaList.size() > 0) {
    		Postaja__c izstopnaPostaja = izstopnaPostajaList[0];
    		Postaja__c vstopnaPostaja = vstopnaPostajaList[0];

            izstopnaApiPlaceId = izstopnaPostaja.Maps_Api_Place_Id__c;
            vstopnaApiPlaceId = vstopnaPostaja.Maps_Api_Place_Id__c;

    		if(izstopnaPostaja.Order__c > vstopnaPostaja.Order__c) {
    			smerVoznjeProtiLj = false;
    			System.debug('Smer voznje je proti Sežani');
			} else if(izstopnaPostaja.Order__c < vstopnaPostaja.Order__c) {
				smerVoznjeProtiLj = true;
				System.debug('Smer voznje je proti Ljubljani');
			} else { // error detection
				// TODO error msg -> izbrana je ista vstopna in izstopna postaja
                setError('Izbrana je ista vstopna in izstopna postaja!');
				System.debug('Izbrana je ista vstopna in izstopna postaja');
				return;
			}

			System.debug('smerVoznjeProtiLj');
			System.debug(smerVoznjeProtiLj);

    	} else { // error detection
    		// todo return error msg -> prazn select za izstopno ali vstopno postajo -> za userje -> nekaj je slo narobe, poskusite ponovno
            setError('Nekaj je šlo narobe :( Poskusite ponovno!');
    		return;
    	}

    	// error detection
    	if(smerVoznjeProtiLj == null) {
    		// todo return error msg -> smer voznje ni dolocena -> za userje -> nekaj je slo narobe, poskusite ponvno
            setError('Nekaj je šlo narobe :( Poskusite ponovno!');
    		return;
    	}

    	// TODO !!!!
        // tempDate
    	// check for running days
    	// pridobi vse praznike -> potem preveri ali je datum 1,2,6,7,8
        // SELECT Id, Name, IsRecurrence, ActivityDate, RecurrenceStartDate FROM Holiday
    	List<Holiday> vsiPraznikiList = new List<Holiday>([SELECT Id, Name, IsRecurrence, ActivityDate, RecurrenceStartDate FROM Holiday ORDER BY Name]);

        Integer currDateMonth = tempDate.month();
        Integer currDateDay = tempDate.day();

        

        Integer holidayDateMonth;
        Integer holidayDateDay;

        Boolean praznik = false; // is current day on public holiday

        for(Holiday h : [SELECT Id, Name, IsRecurrence, ActivityDate, RecurrenceStartDate FROM Holiday ORDER BY Name]) {
            if(h.IsRecurrence) {
                holidayDateMonth = h.RecurrenceStartDate.month();
                holidayDateDay = h.RecurrenceStartDate.day();
                
                if(holidayDateDay == currDateDay && holidayDateMonth == currDateMonth) {
                    praznik = true;
                    break;
                }

            } else {
                if(h.ActivityDate == tempDate) {
                    praznik = true;
                    break;
                }
            }
        }

        System.debug('Praznik');
        System.debug(praznik);

        String dayOfWeek = tempDt.format('EEEE'); // get day of the week from current selected date ('Monday',...)

        Set<Integer> vsiTipi = new Set<Integer>{1, 2, 6, 7, 8};

        System.debug('vsiTipi');
        System.debug(vsiTipi);

        if(praznik) {
            vsiTipi.remove(1);
            vsiTipi.remove(2);
        }
        if(dayOfWeek == 'Sunday') {
            vsiTipi.remove(1);
        }
        if(dayOfWeek == 'Saturday') {
            vsiTipi.remove(1);
            vsiTipi.remove(2);
            vsiTipi.remove(7);
        }
        if(dayOfWeek == 'Saturday') { // če ni between 24.6 - 27.8
            vsiTipi.remove(1);
            vsiTipi.remove(2);
            vsiTipi.remove(7);
        }
        if( (currDateMonth == 12 && (currDateDay == 27 || currDateDay == 27)) || (currDateDay == 27 && currDateMonth == 2) || (currDateDay == 3 && currDateMonth == 3)) { // če ni between 24.6 - 27.8

            vsiTipi.remove(2);
        }

        System.debug('vsiTipi');
        System.debug(vsiTipi);


    	// TODO:
    	// Dnevi_Voznje__c	 	 Vlak__c
		//1 - Ne vozi ob sobote, nedelje in dela prostih dneh v RS 
		//2 - Ne vozi ob sobotah in dela prostih dneh v RS ter od 27.12.2016 do 30.12.2016, od 27.2.2017 do 3.3.2017, 28.4.2017, od 26.6.2017 do 31.8.2017, 30.10.2017, 2.11.2017 in 3.11.2017 
		//6 - Vozi od 24.6.2017 do 27.8.2017 
		//7 - Ne vozi ob sobotah
		//8 - Vozi vse dni
		// select from Holiday
		// smer voznje

    	// get all suitable trains
    	//vsiVlaki = [SELECT Id, Name, Smer_proti_Ljubljani__c, Dnevi_Voznje__c, (SELECT Id, Name, Cas__c, Postaja__c, Postaja__r.Id, Postaja__r.Name FROM Postanki__r) FROM Vlak__c WHERE Smer_proti_Ljubljani__c = :smerVoznjeProtiLj];

    	wVlakList = new List<wIskaniVlaki>();
    	wIskaniVlaki wVlakToAdd;

        Decimal trenutnaUra = DateTime.now().hour();
        Decimal trenutnaMinuta = DateTime.now().minute();

        Boolean isToday = tempDate == Date.today() ? true : false;

    	for(Vlak__c v : [SELECT Id, Name, Smer_proti_Ljubljani__c, Dnevi_Voznje__c, (SELECT Id, Name, Cas__c, Postaja__c, Postaja__r.Id, Postaja__r.Name FROM Vlaki__r  WHERE Postaja__c = :vstopnaValue OR Postaja__c =:izstopnaValue ORDER BY Postaja__r.Order__c ASC) FROM Vlak__c WHERE Smer_proti_Ljubljani__c = :smerVoznjeProtiLj AND Dnevi_Voznje__c IN :vsiTipi ORDER BY Name ASC]) {
    		System.debug('@@@@@@@@@@@@@@@@@@@@@ Vlak @@@@@@@@@@@@@@@@@@@@@@@@@');
    		System.debug(v);

    		wVlakToAdd = new wIskaniVlaki();

    		Boolean zacetniPostanek = false; // FLAG - ujemanje zacetne postaje s postankom trenutnega vlaka
    		Boolean koncniPostanek = false; // FLAG - ujemanje koncne postaje s postankom trenutnega vlaka

    		//get vlak__c info
    		wVlakToAdd.vlakName = v.Name;
    		wVlakToAdd.vlakId =  v.Id;

    		if(v.Vlaki__r != null && v.Vlaki__r.size() > 0) {

    			wVlakToAdd.vlakPostZacetna = new wPostanek();
    			wVlakToAdd.vlakPostKoncna = new wPostanek();

    			// get postanek__c info
    			for(Postanek__c p : v.Vlaki__r) {
    				System.debug('Current postanek:');
    				System.debug(p);

    				wPostaja postajaPostanka = new wPostaja();

                    Decimal uraPostankaTemp = p.Cas__c.hour();
                    Decimal minutaPostankaTemp = p.Cas__c.minute();

                    if(isToday && (uraPostankaTemp < trenutnaUra || (uraPostankaTemp == trenutnaUra && minutaPostankaTemp < trenutnaMinuta))) {
                        // ce je izbran vozni red za danasnji dan in je ura postanka ze v preteklosti, ne prikazi tega postanka
                        continue;
                    }

    				// preveri ce je postaja postanka zacetna iskana
    				if(p.Postaja__r.Id != null && p.Postaja__r.Id == vstopnaValue) {
    					System.debug('Zacetni postanek MATCH!! @@');

    					wVlakToAdd.vlakPostZacetna.postanekId = p.Id;
	    				wVlakToAdd.vlakPostZacetna.postanekName = p.Name;
	    				wVlakToAdd.vlakPostZacetna.postanekCasString = String.valueOf(p.Cas__c.hour()).leftPad(2, '0') + ':' + String.valueOf(p.Cas__c.minute()).leftPad(2, '0');
	    				wVlakToAdd.vlakPostZacetna.postanekCas = p.Cas__c;

	    				System.debug('@@@@@@@@');
	    				System.debug(p.Cas__c.hour());
	    				System.debug(p.Cas__c.minute());
	    				System.debug('@@@@@@@@');

	    				postajaPostanka.postajaId  = p.Postaja__r.Id;
	    				postajaPostanka.postajaName = p.Postaja__r.Name;

	    				wVlakToAdd.vlakPostZacetna.postanekPostaja = postajaPostanka;

	    				zacetniPostanek = true;

    				} else if (p.Postaja__r.Id != null && p.Postaja__r.Id == izstopnaValue) { // preveri ce je postaja postanka koncna iskana
    					System.debug('Koncni postanek MATCH!! @@');

    					wVlakToAdd.vlakPostKoncna.postanekId = p.Id;
	    				wVlakToAdd.vlakPostKoncna.postanekName = p.Name;
	    				wVlakToAdd.vlakPostKoncna.postanekCasString = String.valueOf(p.Cas__c.hour()).leftPad(2, '0') + ':' + String.valueOf(p.Cas__c.minute()).leftPad(2, '0');
	    				wVlakToAdd.vlakPostKoncna.postanekCas = p.Cas__c;

	    				System.debug('@@@@@@@@');
	    				System.debug(p.Cas__c.hour());
	    				System.debug(p.Cas__c.minute());
	    				System.debug('@@@@@@@@');

	    				postajaPostanka.postajaId  = p.Postaja__r.Id;
	    				postajaPostanka.postajaName = p.Postaja__r.Name;

	    				wVlakToAdd.vlakPostKoncna.postanekPostaja = postajaPostanka;

	    				koncniPostanek = true;
    				}
    			}

    			// check if starting and ending stop are in the trains path - if true - add train to vozni red list
    			if(koncniPostanek && zacetniPostanek) {
    				System.debug('Dodajam vlak na listo... @@');
    				//wVlakToAdd.vlakCasVoznje = wVlakToAdd.vlakPostZacetna.postanekCas - wVlakToAdd.vlakPostKoncna.postanekCas;

    				//Integer testTime = wVlakToAdd.vlakPostZacetna.postanekCas - wVlakToAdd.vlakPostKoncna.postanekCas;

    				//System.debug('testTime');
    				//System.debug(testTime);

    				wVlakList.add(wVlakToAdd);
    			}
    		}

    		System.debug(' ');
    	}

    	// sort wrapper by cas odhoda
    	wVlakList.sort();

    	// get relacija
    	List<Relacija__c> relacije = new List<Relacija__c>([SELECT Id, Cena__c, Razdalja__c, Cena_Povratne__c FROM Relacija__c WHERE (Postaja_1__c = :izstopnaValue AND Postaja_2__c = :vstopnaValue) OR 
    													(Postaja_1__c = :vstopnaValue AND Postaja_2__c = :izstopnaValue) ORDER BY Name DESC]);

    	if(relacije != null && relacije.size() > 0) {
    		relacija = relacije[0];
    	}

    	System.debug('relacije');
    	System.debug(relacije);

    	System.debug('wVlakList');
    	System.debug(wVlakList);

    	// soql query to get relacija__c info

    	// build wrapper
    }

    public void sleep(Long milliSeconds) {
            Long timeDiff = 0;
            DateTime firstTime = System.now();
            do{
                timeDiff = System.now().getTime() - firstTime.getTime();
            } while(timeDiff <= milliSeconds);
    }


    /** 
    *** Wrappers ***
	**/

    public class wIskaniVlaki implements Comparable {
    	public String vlakId {get; set;}
    	public String vlakName {get; set;}

    	public wPostanek vlakPostZacetna {get; set;}
    	public wPostanek vlakPostKoncna {get; set;}

    	public String vlakCasVoznje {get; set;}

    	public Integer compareTo(Object compareTo) {
    		wIskaniVlaki temp = (wIskaniVlaki) compareTo;
    		System.debug('@@@@@@@ Compare!');
    		if(this.vlakPostZacetna.postanekCas == temp.vlakPostZacetna.postanekCas) {
    			return 0;
    		}
    		else if(this.vlakPostZacetna.postanekCas > temp.vlakPostZacetna.postanekCas) {
    			return 1;
    		}
    		else {
    			return -1;
    		}
    	}
    }

    public class wPostanek {
    	public String postanekId {get; set;}
    	public String postanekName {get; set;}
    	public String postanekCasString {get; set;} // Time
    	public Time postanekCas {get; set;} // Time

    	public wPostaja postanekPostaja {get; set;}
    }

    public class wPostaja {
    	public String postajaId {get; set;}
    	public String postajaName {get; set;}
    	public Integer postajaOrder {get; set;} // int
    }

    public class wRelacija {
    	public String relacijaName {get; set;} 
    	public String relacijaCena {get; set;} // currency
    	public String relacijaRazdalja {get; set;} //int
    }
}