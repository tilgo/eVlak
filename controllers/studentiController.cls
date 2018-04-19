public class studentiController {
    
    public List<Student__c> studenti {get; set;}
    public Student__c student { get; set;}
    public String idS {get; set;}

    public studentiController() {
        studenti = [select Id, Name, priimek__c, datum_rojstva__c, letnik__c, naslov__c, naziv_fakultete__c, studijski_program__c, tip_studija__c, samoplacnik__c from Student__c ORDER BY Name, priimek__c];
        student = new Student__c();
    }
    
    //za izbiro studija
    public List<SelectOption> getTipStudija() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Student__c.tip_studija__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('', ''));
        
        for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    //za izbiro fakultete
    public List<SelectOption> getNazivFakultete() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Student__c.naziv_fakultete__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('', ''));
            
        for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    //za izbiro stud. programa
    public List<SelectOption> getStudijskiProgram() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Student__c.studijski_program__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('', ''));
            
        for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }

    public PageReference save() {
        //try {
            upsert(student);
        //} catch(System.DMLException e) {
          //  ApexPages.addMessages(e);
            return null;
        //}
        // nazaj na trenutno stran 
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference del() {
        System.debug('idS: '+idS);
        //delete [SELECT id from Student__c WHERE Id = :idS];
        delete new Student__C(Id=ids);
        //PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        //pageRef.setRedirect(true);
        //return pageRef;
        
        return null;
    }  
}