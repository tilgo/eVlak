/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class prijavaUporabnikaControllerTest {
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        prijavaUporabnikaController controller = new prijavaUporabnikaController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}