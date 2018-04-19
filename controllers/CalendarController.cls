public class CalendarController {
        public list<calEvent> events {get;set;}
     
    //Format datuma in ure
    String dtFormat = 'YYYY-MM-dd HH:mm';
     
    public PageReference pageLoad() {
        events = new list<calEvent>();
      
        for(Izpitni_rok__c izp: [select Id, Datum_in_ura__c, Name, Predmet__c, Trajanje_minute__c FROM Izpitni_rok__c]){
                //prestej stevilo prijavljenih za trenutno iteracijo izp
            Integer steviloPrijavljenih = [SELECT COUNT() FROM StudentRok__c WHERE Izpitni_rok__c = :izp.Id];
            Predmet__c pr = [SELECT Name FROM Predmet__c WHERE Id = :izp.Predmet__c];
            String nazivPredmeta = pr.Name;
            Integer min = (izp.Trajanje_minute__c).intValue();
            Datetime zacDat = izp.Datum_in_ura__c;
            Datetime konDat = zacDat.addMinutes(min);
            calEvent izpRok = new calEvent();
            
            izpRok.title = nazivPredmeta + ' (St. prijav: ' + steviloPrijavljenih + ')';
            izpRok.allDay = false;
            izpRok.startString = zacDat.format(dtFormat);
            izpRok.endString = konDat.format(dtFormat);
            //izpRok.url = '/' + izp.Id;
            izpRok.className = 'event-izpit';
            events.add(izpRok);
        }
        return null;
    }

     
    //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;set;}
        public String endString {get;set;}
        public String url {get;set;}
        public String className {get;set;}
    }
}