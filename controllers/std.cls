public class std {

    public Student__c student { get; private set; }

    public std() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        student = (id == null) ? new Student__c() : 
            [SELECT Name FROM Student__c WHERE Id = :id];
    }

    public PageReference save() {
        try {
            upsert(student);
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        //  After successful Save, navigate to the default view page
        PageReference newocp= new PageReference('/apex/sv');
        newocp.setRedirect(true);
        return newocp;
    }
}