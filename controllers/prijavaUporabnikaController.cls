/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class prijavaUporabnikaController {
    global String username {get; set;}
    global String password {get; set;}

    public Boolean error {get; set;}

    global PageReference login() {
        System.debug('@@@@ Login!!');
        error = false;
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        PageReference pageRef;
        try {
            pageRef = Site.login(username, password, '/evlak');
            System.debug(pageRef);
            System.debug('@@@@ Before success!!');
            
        } catch(Exception e) {
            System.debug(e.getMessage());
            error = true;
            System.debug('@@@@ After fail!!');
        }
        if(pageRef != null) {
            System.debug('@@@@ success!!');
            return pageRef;
        } else {
            System.debug('@@@@ FAIL!!!!!');
            error = true;
            return null;
        }
        
        //return Site.login(username, password, '/evlak');
    }
    
    global prijavaUporabnikaController () {}
}