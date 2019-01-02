# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:


**Added**:

- **decidim-assemblies**: Add feature filter assemblies by type [\#4659](https://github.com/decidim/decidim/pull/4659/)
- **decidim-meetings**: Add notification to conferences and meetings registrations [\#4636](https://github.com/decidim/decidim/pull/4636/)
- **decidim-proposals**: Add amend button and amendments counter to participatory text proposals [\#4598](https://github.com/decidim/decidim/pull/4598/)
- **decidim-proposals**: Add filter by type functionality to Amendments on proposals. [\#4567](https://github.com/decidim/decidim/pull/4567/)
- **decidim-proposals**: Add version control functionality to Amendments on proposals. [\#4567](https://github.com/decidim/decidim/pull/4567/)
- **decidim-core**: Add reject/promote amendments functionalities to the Amendment feature. [\#3986](https://github.com/decidim/decidim/pull/3986/)
- **decidim-proposals**: Automatic and suggested hashtags. [\#4585](https://github.com/decidim/decidim/pull/4585/)
- **decidim-core**: Add version control functionality into Amendment feature. [\#4567](https://github.com/decidim/decidim/pull/4567/)
- **decidim-core**: Add reject/promote amendments functionalities into Amendment feature. [\#3986](https://github.com/decidim/decidim/pull/3986/)
- **decidim-core**: Add polymorphic Amendment feature that can be activated in the proposal component with these working functionalities: create/withdraw/accept amendments. [\#3985](https://github.com/decidim/decidim/pull/3985/)
- **decidim-meetings**: Add registration form answers when exporting meeting registrations.[\#4589](https://github.com/decidim/decidim/pull/4589)
- **decidim-core**: Trigger an ActiveSupport::Notification after registering via OmniAuth. [\#4565](https://github.com/decidim/decidim/pull/4565)
- **decidim-proposals**: Specific public view rendering of participatory texts. [\#4316](https://github.com/decidim/decidim/pull/4316)
- **decidim-proposals**: Admin can create proposals from the admin panel, with a meeting as an author.[\#4382](https://github.com/decidim/decidim/pull/4382)
- **decidim-conferences**: Add diplomas functionallity in an automated way for those users that has their registration confirmed. [\#4443](https://github.com/decidim/decidim/pull/4443)
- **decidim-proposals**: Add support to import .odt participatory text files. [\#4386](https://github.com/decidim/decidim/pull/4386)
- **decidim-conferences**: Add conference registration types. [\#4408](https://github.com/decidim/decidim/pull/4408)
- **decidim-core**: Added `users_registration_mode` to allow disable users registration or login [\#4428](https://github.com/decidim/decidim/pull/4428)
- **decidim-forms**: Create a new gem to hold reusable surveys logic [\#3877](https://github.com/decidim/decidim/pull/3877)
- **decidim-meetings**: Allow admins to activate a registration form to be answered by the user when they joins for the meeting [\#4419](https://github.com/decidim/decidim/pull/4419)
- **decidim-verifications**: Add SMS verification workflow [\#4429](https://github.com/decidim/decidim/pull/4429)
- **decidim-proposals**: Split & merge proposals to the same component [\#4415](https://github.com/decidim/decidim/pull/4415)
- **decidim-core**: Adds the ability to send a welcome notification to new users [#4432](https://github.com/decidim/decidim/pull/4432)
- **decidim-core**: Shows the first unread message in a conversation in the notification email [#4463](https://github.com/decidim/decidim/pull/4463)
- **decidim-meetings**: Add a meetings calendar at organization and component levels [\#4376](https://github.com/decidim/decidim/pull/4376)
- **decidim-proposals**: Add user groups and meetings options on Origin filters [\#4462](https://github.com/decidim/decidim/pull/4462)
- **decidim-accountability**: Notify followers of the proposals linked in a result that the result progress has been updated [\#4466](https://github.com/decidim/decidim/pull/4466)
- **decidim-admin**: Adds the ability to specify contextual help to participatory spaces [\#4470](https://github.com/decidim/decidim/pull/4470)
- **decidim-core**: Show minicard with a little bit of profile data when hovering on user and user group names [\#4472](https://github.com/decidim/decidim/pull/4472)
- **decidim-core**: Added more metric calculations. It involves several adding in related modules: proposals, participatory_processes, debates, etc... [\#4372](https://github.com/decidim/decidim/pull/4372)
- **decidim-core**: Let users find search results by writing prefixes of a word instead of whole words [\#4492](https://github.com/decidim/decidim/pull/4492)
- **decidim-core**: Add Etherpad integration [\#4493](https://github.com/decidim/decidim/pull/4493)
- **decidim-meetings**: Add Etherpad integration [\#4493](https://github.com/decidim/decidim/pull/4493)
- **decidim-core**: Adds default pages and contextual help when creating organizations [\#4541](https://github.com/decidim/decidim/pull/4541)
- **decidim-core**: Adds a user activity tab on the public profile. [\#4570](https://github.com/decidim/decidim/pull/4570)
- **decidim-core**: Adds a user timeline tab on the public profile. [\#4574](https://github.com/decidim/decidim/pull/4574)
- **decidim-core**: Open Data export [\#4578](https://github.com/decidim/decidim/pull/4578)
- **decidim-meetings**: Export meetings [\#4597](https://github.com/decidim/decidim/pull/4597)
- **decidim-core**: User groups can now confirm their email [\#4603](https://github.com/decidim/decidim/pull/4603)
- **decidim-core**: Admins can verify batches of user groups that have the email confirmed by uploading a CSV file [\#4613](https://github.com/decidim/decidim/pull/4613)
- **decidim-core**: Let users select their interests (scopes/areas). They will see relevant activity in the Timeline tab in their profile [\#4621](https://github.com/decidim/decidim/pull/4621)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to restrict online signatures [\#4668](https://github.com/decidim/decidim/pull/4668)
- **decidim-initiatives**: Add `Decidim::HasReference` concern to initiatives model, display reference in front and id in admin [\#4665](https://github.com/decidim/decidim/pull/4665)
- **decidim-core**: Let users choose what kind of notifications they want to erceive [\#4663](https://github.com/decidim/decidim/pull/4663)

**Changed**:


**Fixed**:


**Removed**:


## Previous versions

Please check [0.16-stable](https://github.com/decidim/decidim/blob/0.16-stable/CHANGELOG.md) for previous changes.
