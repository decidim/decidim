# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

- **Actions on omniauth registrations**: Due to [#4895](https://github.com/decidim/decidim/pull/4895), if there are [actions registered to be performed when a user registers throught OAuth](https://github.com/decidim/decidim/blob/master/docs/customization/oauth.md#performing-more-actions-on-omniauth-registration), the name of the event must be changed to keep them working. The subscription to the notification should be changed from:

```ruby
ActiveSupport::Notifications.subscribe "decidim.events.user.omniauth_registration" do |name, started, finished, unique_id, data|
```

to

```ruby
ActiveSupport::Notifications.subscribe "decidim.user.omniauth_registration" do |name, started, finished, unique_id, data|
```


- **Bump Ruby version**: As per [\#4927](https://github.com/decidim/decidim/pull/4927) we've bumped the minimum Ruby version to 2.5.x. Check you're running a suitable Ruby version.

**Added**:

- **decidim-proposals**: Added a button to reset all participatory text drafts. [\#4814](https://github.com/decidim/decidim/pull/4814)
- **decidim-proposals** Add text formatting capabilities to MarkdownToProposals. [\#4837](https://github.com/decidim/decidim/pull/4837)
- **decidim-docs** Update dependencies and ruby version. [\#4812](https://github.com/decidim/decidim/pull/4812)
- **decidim-proposals** Lists are imported as a single proposal. [\#4780](https://github.com/decidim/decidim/pull/4780)
- **decidim-proposals**: Allow to persist participatory text drafts before publishing. [\#4808](https://github.com/decidim/decidim/pull/4808)
- **decidim-docs**: Some components.md corrections and a little more info related with modules and engines.. [\#4752](https://github.com/decidim/decidim/pull/4752)
- **decidim-proposals**: Add Participatory Text support for images in Markdown. [\#4791](https://github.com/decidim/decidim/pull/4791)
- **decidim-proposals**: In participatory texts it is better to render Article cards open by default. [\#4806](https://github.com/decidim/decidim/pull/4806)
- **decidim-proposals**: Add Participatory Text support for links in Markdown. [\#4790](https://github.com/decidim/decidim/pull/4790)
- **decidim-core**: User groups can now be disabled per organization. [\#4681](https://github.com/decidim/decidim/pull/4681/)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to restrict online signatures [\#4668](https://github.com/decidim/decidim/pull/4668)
- **decidim-verifications**: Add multitenant csv census verifications [\#4719](https://github.com/decidim/decidim/pull/4719)
- **decidim-initiatives**: Extend authorizations to resources not related with components and define initiatives vote authorizations on initiatives types [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to set minimum commitee members before sending initiative to technical evaluation [\#4688](https://github.com/decidim/decidim/pull/4688)
- **decidim-initiatives**: Add option to initiative types to collect personal data on signature and make related changes in front [\#4690](https://github.com/decidim/decidim/pull/4690)
- **decidim-initiatives**: Implement a mechanism to store encrytped personal data of users on votes and decrypt it exporting to PDF [\#4716](https://github.com/decidim/decidim/pull/4716)
- **decidim-initiatives**: Add setting to initiatives types to enable a step to allow initiative signature after passing SMS verification mechanism [\#4792](https://github.com/decidim/decidim/pull/4792)
- **decidim-initiatives**: Allow integration of services to add timestamps and sign PDFs, define example services and use in application generator [\#4805](https://github.com/decidim/decidim/pull/4805)
- **decidim-initiatives**: Add setting to initiatives types to verify document number provided on votes and avoid duplicated votes with the same document [\#4794](https://github.com/decidim/decidim/pull/4794)
- **decidim-initiatives**: Add validation using metadata of authorization for handler defined to validate document mumber [\#4838](https://github.com/decidim/decidim/pull/4838)
- **decidim-initiatives**: Better admin initiative search [\#4845](https://github.com/decidim/decidim/pull/4845)
- **decidim-meetings**: Order meetings at admin [\#4844](https://github.com/decidim/decidim/pull/4844)
- **decidim-proposals** Add admin edit link for proposals [\#4843](https://github.com/decidim/decidim/pull/4843)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to enable users to undo their initiatives signatures. [\#4841](https://github.com/decidim/decidim/pull/4841)
- **decidim-initiatives**: Add author of initiative to committee members on creation. [\#4861](https://github.com/decidim/decidim/pull/4861)
- **decidim-initiatives**: Display state of initiative on edition form inside a disabled select. [\#4861](https://github.com/decidim/decidim/pull/4861)
- **decidim-initiatives**: Allow users report comments on initiatives and admins moderate reports from initiative admin panel. [\#4878](https://github.com/decidim/decidim/pull/4878)
- **decidim-admin**: Add css variables for multitenant custom colors. [\#4882](https://github.com/decidim/decidim/pull/4882)
- **decidim-verifications**: Allow definition of attributes in settings manifest to be required always on authorizations. [\#4911](https://github.com/decidim/decidim/pull/4911)
- **decidim-verifications**: Allow resending SMS code. [\#4928](https://github.com/decidim/decidim/pull/4928)

**Changed**:

- **decidim-proposals** Allow to change participatory texts title without uploading file. [\#4761](https://github.com/decidim/decidim/pull/4761)
- **decidim-proposals** Change collaborative draft contributors permissions [\#4712](https://github.com/decidim/decidim/pull/4712)
- **decidim-admin**: Change admin moderations manager [\#4717](https://github.com/decidim/decidim/pull/4717)
- **decidim-core**: Change action_authorization and modals to manage multiple authorization handlers instead of one [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-admin**: Change interface to manage multiple authorizations for components and resources [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-initiatives**: Change logic of online sign initiative buttons. [\#4841](https://github.com/decidim/decidim/pull/4841)
- **decidim-initiatives**: Add a last step on signature initiatives wizard and use it instead of redirect to initiative after signing. [\#4841](https://github.com/decidim/decidim/pull/4841)
- **decidim-initiatives**: Change permissions of sign_initiative action. [\#4841](https://github.com/decidim/decidim/pull/4841)
- **decidim-initiatives**: Allow edition of type, scope and signature type of initiatives depending on state and user. [\#4861](https://github.com/decidim/decidim/pull/4861)
- **decidim-initiatives**: Move edition of initiatives answer to a separated form in admin panel and shows answer in front if present for any state. [\#4881](https://github.com/decidim/decidim/pull/4881)
- **decidim-initiatives**: Change initiative type selection step view to display options using tabs. [\#4884](https://github.com/decidim/decidim/pull/4884)
- **decidim-initiatives**: Change design of column containing signatures progress and actions buttons in initiative show. [\#4887](https://github.com/decidim/decidim/pull/4887)
- **decidim-initiatives**: Change initiative creation wizard layout. [\#4888](https://github.com/decidim/decidim/pull/4888)
- **decidim-initiatives**: Make changes related with initiatives signature and permissions ux. [\#4906](https://github.com/decidim/decidim/pull/4906)
- **decidim-admin**: Fix inputs of translated attributes in resource permissions options form. [\#4911](https://github.com/decidim/decidim/pull/4911)
- **decidim**: Bump required Ruby minimum version to 2.5.x [\#4927](https://github.com/decidim/decidim/pull/4927)
- **decidim-initiatives**: Validate vote_form metadata considering initiative scope and also children scopes. [\#4933](https://github.com/decidim/decidim/pull/4933)

**Fixed**:

- **decidim-core**: Fix wrong check of avatar_url in `/oauth/me` controller  [#4917](https://github.com/decidim/decidim/pull/4917)
- **decidim-core**: Don't mix omniauth notifications with `Decidim::EventManager` events [#4895](https://github.com/decidim/decidim/pull/4895)
- **decidim-core**: Hide comments on cards when deactivated on a component. [\#4904](https://github.com/decidim/decidim/pull/4904)
- **decidim-debates**: Fix stats display for debates when a debate has been moderated. [\#4903](https://github.com/decidim/decidim/pull/4903)
- **decidim-core**: Fix comments count when a comment has been moderated [\#4901](https://github.com/decidim/decidim/pull/4901)
- **decidim-core**: Fix AttachmentCreatedEvent email resource_url [#4880](https://github.com/decidim/decidim/pull/4880)
- **decidim-proposals**: Add participatory texts file format support in admin. [#4819](https://github.com/decidim/decidim/pull/4819)
- **decidim-proposals**: Fix collaborative draft attachment when attachments are enabled after collaborative draft creation [\#4877](https://github.com/decidim/decidim/pull/4877)
- **decidim-assemblies**: Fix parent assemblies children_count counter (add migration) [\#4852](https://github.com/decidim/decidim/pull/4852/)
- **decidim-proposals**: Fix Proposals Last Activity feed [\#4828](https://github.com/decidim/decidim/pull/4828)
- **decidim-proposals**: Fix attachments not being inherited from collaborative draft when published as proposal. [\#4811](https://github.com/decidim/decidim/pull/4811)
- **decidim-core**: Add set_locale method to prevent users be redirected to unexpected locale[#4809](https://github.com/decidim/decidim/pull/4809)
- **decidim-core**: Fix inconsistent dataviz [\#4787](https://github.com/decidim/decidim/pull/4787)
- **decidim-proposals**: Fix participatory texts error uploading files with accents and special characters. [\#4788](https://github.com/decidim/decidim/pull/4788)
- **decidim-meetings**: Fix form when duplicating meetings [\#4750](https://github.com/decidim/decidim/pull/4750)
- **decidim-proposals**: Fix admin proposals manager: show proposal state [\#4789](https://github.com/decidim/decidim/pull/4789/)
- **decidim-core**: Fix DataPortabilityExportJob: private method 'file' called when Carrierwave Storage fog enable [#4337](https://github.com/decidim/decidim/pull/4337)
- **decidim-proposals** Public view of Participatory Text is now preserving new lines. [\#4782](https://github.com/decidim/decidim/pull/4782)
- **decidim-assemblies**: Fix assemblies filter by type [\#4778](https://github.com/decidim/decidim/pull/4778)
- **decidim-conferences**: Fix error when visiting a Conference event[\#4776](https://github.com/decidim/decidim/pull/4776)
- **decidim-proposals** Fix unhideable reported collaborative drafts and mail jobs [\#4706](https://github.com/decidim/decidim/pull/4706)
- **decidim-assemblies**: Fix parent assemblies children_count counter [\#4718](https://github.com/decidim/decidim/pull/4718/)
- **decidim-core**: Place `CurrentOrganization` middleware before `WardenManager`. [\#4708](https://github.com/decidim/decidim/pull/4708)
- **decidim-core**: Fix form builder upload field multiple errors display [\#4715](https://github.com/decidim/decidim/pull/4715)
- **decidim-core**: MetricResolver filtering corrected comparison between symbol and string [\#4733](https://github.com/decidim/decidim/pull/4733)
- **decidim-core**: Ignore blank permission options in action authorizer [\#4744](https://github.com/decidim/decidim/pull/4744)
- **decidim-core**: Date field form inputs failing to highlight errors on some edge cases. [\#3515](https://github.com/decidim/decidim/pull/3515)
- **decidim-core**: Datetime field form inputs failing to highlight errors on some edge cases. [\#3515](https://github.com/decidim/decidim/pull/3515)
- **decidim-proposals** Lock proposals on voting to avoid race conditions to vote over the limit [\#4763](https://github.com/decidim/decidim/pull/4763)
- **decidim-initiatives** Add missing dependency for wicked_pdf to initiatives module [\#4813](https://github.com/decidim/decidim/pull/4813)
- **decidim-participatory_processes**: Shows the short description on processes when displaying a single one on the homepage. [\#4824](https://github.com/decidim/decidim/pull/4824)
- **decidim-core** Fix redirect to static map view after login. [\#4830](https://github.com/decidim/decidim/pull/4830)
- **decidim-proposals**: Add missing translation key for "Address". [\#4835](https://github.com/decidim/decidim/pull/4835)
- **decidim-proposals**: Fix proposal activity cell rendering. [\#4848](https://github.com/decidim/decidim/pull/4848)
- **decidim-meetings**: Fix accepting/declining meeting invitations [\#4839](https://github.com/decidim/decidim/pull/4839)
- **decidim-budgets**: Allow only to attach published proposals to budgeting projects [\#4840](https://github.com/decidim/decidim/pull/4840)
- **decidim-core**: Prevent empty selection in the data picker [\#4842](https://github.com/decidim/decidim/pull/4842)
- **decidim-forms**: Fix free text fields exporting. [\#4846](https://github.com/decidim/decidim/pull/4846)
- **decidim-initiatives** Fix admin layout of some subsections of initiatives participatory spaces. [\#4849](https://github.com/decidim/decidim/pull/4849)
- **decidim-proposals** Fix recent proposals order [\#4854](https://github.com/decidim/decidim/pull/4854)
- **decidim-core**: Fix user activities list [\#4853](https://github.com/decidim/decidim/pull/4853)
- **decidim-comments** Fix author display in comments [\#4851](https://github.com/decidim/decidim/pull/4851)
- **decidim-debates** Allow HTML content at debates page [\#4850](https://github.com/decidim/decidim/pull/4850)
- **decidim-proposals** Fix proposals search indexes [\#4857](https://github.com/decidim/decidim/pull/4857)
- **decidim-proposals** Remove etiquette validation from proposals admin [\#4856](https://github.com/decidim/decidim/pull/4856)
- **decidim-core**: Fix process filters [\#4872](https://github.com/decidim/decidim/pull/4872)
- **decidim-debates** Fix debates card and ordering [\#4879](https://github.com/decidim/decidim/pull/4879)
- **decidim-proposals** Don't count withdrawn proposals when publishing one [\#4875](https://github.com/decidim/decidim/pull/4875)
- **decidim-initiatives** Fix author duplicated appearance in some initiatives authors lists. [\#4885](https://github.com/decidim/decidim/pull/4885)
- **decidim-meetings**, **decidim-forms**: Fix form to_param methods printing out empty IDs and causing an HTTP 400 exception [\#4896](https://github.com/decidim/decidim/pull/4896)
- **decidim-core** Fix elements with non-unique ID on filtering pages [\#4897](https://github.com/decidim/decidim/pull/4897)
- **decidim-debates** Correctly set the category in the admin debate form [\#4894](https://github.com/decidim/decidim/pull/4894)
- **decidim-proposals**: Let admins keep orirignal authors when importing proposals from another component [\#4902](https://github.com/decidim/decidim/pull/4902)
- **decidim-proposals**: Don't let users vote/follow withdrawn proposals [\#4909](https://github.com/decidim/decidim/pull/4909)
- **decidim-participatory_processes**: Fix collaborator permissions so they can't `:read` anything [\#4899](https://github.com/decidim/decidim/pull/4899)
- **decidim-initiatives** Add some small fixes in admin panel of initiatives [\#4912](https://github.com/decidim/decidim/pull/4912)
- **decidim-core**: Ensure email is downcased when authenticating a user [\#4926](https://github.com/decidim/decidim/pull/4926)
- **decidim-proposals**: Allow reporting official proposals [\#4930](https://github.com/decidim/decidim/pull/4930)
- **decidim-participatory_processes**: Fix past processes filter [\#4932](https://github.com/decidim/decidim/pull/4932)
- **decidim-verifications**: Redirect to previous url after verifying your mobile number via SMS. [\#4929](https://github.com/decidim/decidim/pull/4929)

**Removed**:

## Previous versions

Please check [0.16-stable](https://github.com/decidim/decidim/blob/0.16-stable/CHANGELOG.md) for previous changes.
