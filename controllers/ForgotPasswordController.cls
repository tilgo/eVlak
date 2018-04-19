/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}

    public Boolean error {get; set;} 
       
    public ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
      error = false;
      List<User> matchingUsers = new List<User>([SELECT Id FROM User WHERE isActive = true AND Username = :username LIMIT 1]);
      
      if(matchingUsers == null || matchingUsers.size() == 0) {
        error = true;
        return null;
      }
      
      System.debug('Forget password function');
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
      System.debug('Success?');
      System.debug(success);
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
      error = true;
  		return null;
  	}
}