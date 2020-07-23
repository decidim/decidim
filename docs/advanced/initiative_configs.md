# How to use initiative advanced configs

The initiatives participatory space has evolved to include many configuration options. This doc file describes how to use them so admins can fully understand how to use them.

`Collect participant personal data on signature` if ticked, it enables a form (see <<personal-data-form-enabled>>) that users will have to fill in order to sign the initiative. The info gathered in that form will be exported along the signatures in the pdf export.

[#personal-data-form-enabled]
._Default personal data collection form_.
image::image80.png[image]

`Enable promoting committee` if ticked and if the minimum number of committee members is set above 1 then the initiative author will need to find at least 1 promoting committee member (as author they are automatically part of it) to be able to send its initiative to technical validation.

`Enable child scope signatures` if ticked, it enables *sub-jauges* (see <<sub-jauges>>) which need special configuration in order to work :
- *SCOPES FOR THE INITIATIVE TYPE* need to be configured in hierarchical way (see <<child-scope-config>>) : 1 Parent - N Children
- `Only allow global scope initiative creation` needs to be ticked in the *OPTIONS* section when the parent scope is the Global scope.
- It works with an authorization handler that associates a scope to the user, make sure you select the right authorization handler in the *AUTHORIZATION SETTINGS* section (See <<authorization-handler-settings>>). (You can test it with the "Example authorization" aka `Dummy Authorization Handler`)
- /!\ this config option doesn't support offline votes yet, so make sure you selected *Online* as a `signature type` in the *OPTION* section.

[#sub-jauges]
._Sub-jauges display on initiative page_.
image::image81.png[image]

[#child-scope-config]
._Example of scope configuration for "Enable child scope signatures"_.
image::image78.png[image]

[#authorization-handler-settings]
._Example of an authorization handler selection"_.
image::image82.png[image]

`Only allow global scope initiatives creation`: you want to tick this flag if you ticked enable `Child scope signatures` and configured the global scope as your parent scope and children scope as 1st level scopes (see <<global-parent-config>>). By enabling this, the scope selection will be automatically made to Global scope in the initiative creation wizard and won't be displayed to the user.

[#global-parent-config]
._Example of scope configuration for "Only allow global scope initiatives creation"_.
image::image79.png[image]
