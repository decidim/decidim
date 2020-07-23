# How to use initiatives advanced configs

The initiatives participatory space has evolved to include many configuration options. This doc file describes how to use them so admins can fully understand how to use them.

When creating an intiative type a section displays with configuration options (**OPTIONS**)
![type creation form](https://imgur.com/aQLHmFP)
_Initiative type creation form_

We'll describe how the most complex ones work.

## Collect participant personal data on signature

If ticked, it enables a form (see <<personal-data-form-enabled>>) that users will have to fill in order to sign the initiative. The info gathered in that form will be exported along the signatures in the pdf export.

![personal data form](https://imgur.com/MnZFEQJ)
_Default personal data collection form_


## Enable promoting committee
If ticked and if the minimum number of committee members is set above 1 then the initiative author will need to find at least 1 promoting committee member (as author they are automatically part of it) to be able to send its initiative to technical validation.

## Enable child scope signatures
If ticked, it enables **sub-jauges**
![sub-jauges](https://imgur.com/Yyq7U85)
_Sub-jauges display on initiative page_

These sub-jauges need additional configuration in order to work :
- **SCOPES FOR THE INITIATIVE TYPE** need to be configured in hierarchical way  : 1 Parent - N Children
![child-scope-config](https://imgur.com/MO3qBfO)
_Example of scope configuration for "Enable child scope signatures"_
- `Only allow global scope initiative creation` needs to be ticked in the **OPTIONS** section when the parent scope is the Global scope. (see how to configure that bellow)
- It works with an authorization handler that associates a scope to the user, make sure you select the right authorization handler in the **AUTHORIZATION SETTINGS** section. (You can test it with the "Example authorization" aka `Dummy Authorization Handler`)
![authorization-handler-settings](https://imgur.com/63Bq0Mv)
_Example of an authorization handler selection"_
- /!\ this config option doesn't support offline votes yet, so make sure you selected **Online** as a `signature type` in the **OPTION** section.


## Only allow global scope initiatives creation
you want to tick this flag if you ticked enable `Child scope signatures` and configured the global scope as your parent scope and children scope as 1st level scopes. By enabling this, the scope selection will be automatically made to Global scope in the initiative creation wizard and won't be displayed to the user.

![global-parent-config](https://imgur.com/w8BrNdY)
_Example of scope configuration for "Only allow global scope initiatives creation"_
