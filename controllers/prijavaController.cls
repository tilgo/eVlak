public class prijavaController {

    public String datumUra;
    public String danS;
    public String danB;
    public Student__c student {get;set;}
    public Predmet__c predmet {get;set;}
    public Izpitni_rok__c rok {get;set;}
    public StudentRok__c sr {get;set;}
    
    public prijavaController() {
        student = new Student__c();
        predmet = new Predmet__c();
        rok = new Izpitni_rok__c();
        sr = new StudentRok__c();
    }
    
    public List<SelectOption> getVsiStudenti() {
        List<SelectOption> options = new List<SelectOption>();

        List<Student__c> studenti = [SELECT Id, Name, priimek__c FROM Student__c];
                
        options.add(new SelectOption('', '"izberite študenta"'));
            
        for( Student__c f : studenti) {
          options.add(new SelectOption(f.Id, f.Name + ' ' + f.priimek__c));
        }       
        return options;
    }
    
    public List<SelectOption> getVsiPredmeti() {
        List<SelectOption> options = new List<SelectOption>();
        
        List<Predmet__c> predmeti = [SELECT Id, Name, Naziv__c FROM Predmet__c WHERE Id IN (SELECT Predmet__c FROM StudentPredmet__c WHERE Student__r.Id = :student.Id)];
        
        options.add(new SelectOption('', '"izberite predmet"'));
            
        for( Predmet__c f : predmeti) {
          options.add(new SelectOption(f.Id, f.Naziv__c));
        }       
        return options;
    }
    
    public List<SelectOption> getVsiRoki() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('', '"izberite rok"'));
        
        if(predmet != null) {
            List<Izpitni_rok__c> roki= [SELECT Id, Name, Datum_in_ura__c, Trajanje_minute__c FROM Izpitni_rok__c WHERE Predmet__r.Id = :predmet.Id];
            
            for( Izpitni_rok__c f : roki) {
                //datumUra = f.Datum_in_ura__c.format('EEEE, dd. MM. YYYY, HH:mm'); -> izpis z angl. dnevi
                datumUra = f.Datum_in_ura__c.format(', dd. MM. YYYY, HH:mm');
                danS = f.Datum_in_ura__c.format('u');
                
                if (danS.equals('1')) {
                    danB = 'ponedeljek';
                }else if (danS.equals('2')){
                    danB = 'torek';
                }else if (danS.equals('3')){
                    danB = 'sreda';
                }else if (danS.equals('4')){
                    danB = 'četrtek';    
                }else if (danS.equals('5')){
                    danB = 'petek';
                }else if (danS.equals('6')){
                    danB = 'sobota';
                }else if (danS.equals('7')){
                    danB = 'nedelja';
                }
                //izpis z trajanjem izpita
                //options.add(new SelectOption(f.Id, danB + datumUra + ' (' + String.valueOf(f.Trajanje_minute__c) + ' min)'));
                options.add(new SelectOption(f.Id, danB + datumUra));
            }  
        }
             
        return options;
    }
    
    public PageReference save() {
        try {
            //nastavi oba atributa objektu StudentRok
            sr.Student__c = student.Id;
            sr.Izpitni_rok__c = rok.Id;
            upsert(sr);
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        // nazaj na trenutno stran 
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }
}