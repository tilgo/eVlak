/**
 * An apex class that creates a portal user
 */
public with sharing class registracijaUporabnikaController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    private static Id PORTAL_ACCOUNT_ID = '0010Y000015y2Yd';

    public Boolean isError {get; set;}
    public String errorMsg {get; set;}
    
    public registracijaUporabnikaController () {
        isError = false;
        errorMsg = '';
        System.debug('Registracija Uporabnika');
    }

    public String username {get; set;}
    public String ime {get; set;}
    public String priimek {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
      
    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    public PageReference registerUser() {
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            System.debug('pass ni valid!');
            isError = true;
            System.debug('isError!');
            System.debug(isError);
            errorMsg = 'Gesli se ne ujemata!';
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            //ApexPages.addMessage(msg);
            return null;
        }

        System.debug('Password is valid!');

        User u = new User();
        u.Username = email;
        u.Email = email;
        u.CommunityNickname = ime;
        u.FirstName = ime;
        u.LastName = priimek;
        
        String accountId = PORTAL_ACCOUNT_ID;

        System.debug('user@');
        System.debug(u);

        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        String userId = Site.createPortalUser(u, accountId, password, true);

        System.debug('userId@');
        System.debug(userId);

        if (userId != null) { 
            if (password != null && password.length() > 1) {
                System.debug('password not null@');
                System.debug(password);
                return Site.login(email, password, '/evlak');
            }
            else {
                PageReference page = System.Page.SiteRegisterConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}