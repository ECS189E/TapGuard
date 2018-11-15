# Meeting 14.11.2018
## Agenda
1. What we have done
2. Discussion
3. What to do

## What We Have Done
1. LoginViewController
2. PhoneNumberViewController
3. VerificationViewController
4. HomeViewController

## Discussion
## Phone number verification
**Problem:** Should we do email verification or phone verification because phone verification has some limitations for firebase implementation in that we cannot save accesstoken unlike for google authentication

**Suggestion:** Save userID and do future authentication via firebase database, or use a dummy user

**Problem:** What happens if the user changes phone number. Does he/she have to create a brand new account and update settings?

**Suggestion/Decision:** Use google/email login as the main userid, and then verification of phone number can be for a dummy userid. 

## Things to research
1. How to implement touch/facial id
2. How to implement double authentication

## Things to do
1. Charles: Finish up google authentication + touch/facial id by Friday
2. Saksham: SettingsViewController (Phone Number, Emergency Phone Number)
3. 