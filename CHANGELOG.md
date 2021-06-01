# Change Log

## [v0.24.3](https://github.com/decidim/decidim/releases/tag/v0.24.3)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-participatory processes**: Fix attachment title migration generating possibly invalid values [\#8044](https://github.com/decidim/decidim/pull/8044)
- **decidim-comments**, **decidim-consultations**: Fix for commenting in consultation questions [\#8062](https://github.com/decidim/decidim/pull/8062)
- **decidim-core**: Fix boolean fields for .reported? and .hidden? which is nil if no report exists [\#8082](https://github.com/decidim/decidim/pull/8082)
- **decidim-core**: Fix redirects broken by Terms and Conditions redirect [\#8083](https://github.com/decidim/decidim/pull/8083)
- **decidim-core**: Use correct newsletter cell for web view [\#8081](https://github.com/decidim/decidim/pull/8081)
- **decidim-core**, **decidim-proposals**: Remove proposals filters cache [\#8038](https://github.com/decidim/decidim/pull/8038)
- **decidim-core**, **decidim-meetings**: Include resources on maps only when the geocoding got valid coords [\#8039](https://github.com/decidim/decidim/pull/8039)
- **decidim-core**: Fix editor when formatting starts with a linebreak [\#8024](https://github.com/decidim/decidim/pull/8024)
- **decidim-admin**: Use symbols for polymorphic route arguments [\#8060](https://github.com/decidim/decidim/pull/8060)

### Removed

Nothing.

### Developer improvements

- Bump gems versions to fix dependendabot alerts [\#8041](https://github.com/decidim/decidim/pull/8041)
- Bump bundle version for security reasons [\#8084](https://github.com/decidim/decidim/pull/8084)

## [v0.24.2](https://github.com/decidim/decidim/releases/tag/v0.24.2)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-core**: CSV exporter should take into account locales from all resources [\#7860](https://github.com/decidim/decidim/pull/7860)
- **decidim-comments**: Fix TypeError in newsletters [\#7876](https://github.com/decidim/decidim/pull/7876)
- **decidim-core**: Open attachments in new tab [\#7918](https://github.com/decidim/decidim/pull/7918)
- **decidim-core**: Validate nickname using correct regexp [\#7921](https://github.com/decidim/decidim/pull/7921)
- **decidim-proposals**: Cast proposal and collaborative drafts titles to text [\#7928](https://github.com/decidim/decidim/pull/7928)
- **decidim-core**: Fix editor: remove br tags from inside a tags [\#7957](https://github.com/decidim/decidim/pull/7957)
- **decidim-core**: Fix fragment caching with multiple locales [\#7960](https://github.com/decidim/decidim/pull/7960)

### Removed

Nothing.

### Developer improvements

- Do not change the global test app configs during specs [\#7816](https://github.com/decidim/decidim/pull/7816)
- Update to Rails 5.2.6 [\#7949](https://github.com/decidim/decidim/pull/7949)

## [v0.24.1](https://github.com/decidim/decidim/releases/tag/v0.24.1)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-admin**: Add admin missing translations (#7702) [\#7766](https://github.com/decidim/decidim/pull/7766)
- **decidim-initiatives**: Fix permission for initiative edit and update [\#7654](https://github.com/decidim/decidim/pull/7654)
- **decidim-conferences**:  Fix validations for registration related fields in Conference form [\#7734](https://github.com/decidim/decidim/pull/7734)
- **decidim-admin**, **decidim-conferences**: Add Conferences and Admin missing translations (#7653) [\#7765](https://github.com/decidim/decidim/pull/7765)

### Removed

Nothing.

### Developer improvements

- Do not modify the controller class in the controller tests that rende… [\#7775](https://github.com/decidim/decidim/pull/7775)
- Upgrade to Rails 5.2.5 [\#7806](https://github.com/decidim/decidim/pull/7806)

## [v0.24.0](https://github.com/decidim/decidim/releases/tag/v0.24.0)

### Upgrade Notes

#### Bump Ruby to v2.7

We've bumped the minimum Ruby version to 2.7.1, thanks to 2 PRs:

- [\#6320](https://github.com/decidim/decidim/pull/6320)
- [\#6522](https://github.com/decidim/decidim/pull/6522)

#### Comments no longer use react

As per [\#6498](https://github.com/decidim/decidim/pull/6498), the comments component is no longer implemented with the react component. In case you had customized the react component, it will still work as you would expect as the GraphQL API has not disappeared anywhere. You should, however, gradually migrate to the "new way" (Trailblazer cells) in order to ensure compatibility with future versions too.

#### Consultations module deprecation

As the new `Votings` module is being developed and will eventually replace the `Consultations` module, the latter enters the deprecation phase.

#### Authorization metadata is now encrypted in the database

As per [\#6947](https://github.com/decidim/decidim/pull/6947), the JSON values for the authorizations' `metadata` and `verification_metadata` columns in the `decidim_authorizations` database table are now automatically encrypted because they can contain identifiable or sensitive personal information connected to a user account. Storing this data in plain text in the database would be a security risk.

You need to do changes to your code if you have been querying these tables in the past through the `Decidim::Authorization` model as follows:

```ruby
Decidim::Authorization.where(
  name: "your_authorization_handler"
).where("metadata ->> 'gender' = ?", "f").find_each do |authorization|
  puts "#{authorization.user.name} is a #{authorization.metadata["gender"]}"
end
```

The problem with this code is that the data in the `metadata ->> 'gender'` column is now encrypted, so your search would not match any records in the database. Instead, you can do the following:

```ruby
Decidim::Authorization.where(
  name: "your_authorization_handler"
).find_each do |authorization|
  next unless authorization.metadata["gender"] == "f"

  puts "#{authorization.user.name} is a #{authorization.metadata["gender"]}"
end
```

As you notice, when you are accessing the `metadata` or `verification_metadata` columns through the Active Record object, you can utilize the data in plain text. This is because the accessor method for these columns will automatically decrypt the data in the hash object.

This is less performant but it is more secure. Security weighs more.

### Added

- **decidim-initiatives**: Show draft initiatives [\#6584](https://github.com/decidim/decidim/pull/6584)
- **decidim-budgets**: Add scope to proposals import in budgets [\#6525](https://github.com/decidim/decidim/pull/6525)
- Add new languages: Korean, Vietnamese and Chinese [\#6648](https://github.com/decidim/decidim/pull/6648)
- **decidim-core**, **decidim-meetings**: Add online meetings [\#6572](https://github.com/decidim/decidim/pull/6572)
- **decidim-core**: Allow customization of the upload help messages [\#6683](https://github.com/decidim/decidim/pull/6683)
- **decidim-admin**, **decidim-assemblies**, **decidim-elections**: Add elections trustees role [\#6535](https://github.com/decidim/decidim/pull/6535)
- **decidim-elections**: Add the trustee zone for users [\#6615](https://github.com/decidim/decidim/pull/6615)
- **decidim-elections**: Elections design improvements [\#6721](https://github.com/decidim/decidim/pull/6721)
- **decidim-elections**, **decidim-forms**: Election feedback form [\#6548](https://github.com/decidim/decidim/pull/6548)
- **decidim-meetings**: Missing i18n on closed debate notification [\#6746](https://github.com/decidim/decidim/pull/6746)
- **decidim-admin**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Improve moderation panel [\#6677](https://github.com/decidim/decidim/pull/6677)
- **decidim-budgets**: Budget voting projects rule (select min-max projects) [\#6753](https://github.com/decidim/decidim/pull/6753)
- **decidim-meetings**: Let users close meetings from public pages [\#6703](https://github.com/decidim/decidim/pull/6703)
- **decidim-elections**: Add preview of questions to an election [\#6749](https://github.com/decidim/decidim/pull/6749)
- **decidim-core**: feat: send notification to reported content authors [\#6747](https://github.com/decidim/decidim/pull/6747)
- **decidim-core**: Allow subhero content block to hold HTML tags [\#6810](https://github.com/decidim/decidim/pull/6810)
- **decidim-core**: Add info to report email for moderators [\#6725](https://github.com/decidim/decidim/pull/6725)
- **decidim-meetings**: Add registration system to meetings [\#6662](https://github.com/decidim/decidim/pull/6662)
- **decidim-initiatives**: Filter created initiatives only by author [\#6658](https://github.com/decidim/decidim/pull/6658)
- **decidim-proposals**: Add locales for cost report [\#6767](https://github.com/decidim/decidim/pull/6767)
- **decidim-admin**, **decidim-core**: Detect the use of spam-bots and ban non compliant users (part 1) [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-core**: Send report email when reported resource is translated to default org language [\#6726](https://github.com/decidim/decidim/pull/6726)
- **decidim-elections**: Setup election for bulletin board [\#6813](https://github.com/decidim/decidim/pull/6813)
- **decidim-initiatives**: Edit initiative as promoter [\#6790](https://github.com/decidim/decidim/pull/6790)
- **decidim-admin**, **decidim-core**: Send notification to resource's authors when it is hidden by a moderator [\#6885](https://github.com/decidim/decidim/pull/6885)
- **decidim-meetings**: Add a config flag to disable the registration code [\#6698](https://github.com/decidim/decidim/pull/6698)
- **decidim-elections**: Show election results [\#6768](https://github.com/decidim/decidim/pull/6768)
- **decidim-admin**: Add HTML titles in Admin panel  [\#6666](https://github.com/decidim/decidim/pull/6666)
- **decidim-core**, **decidim-elections**: Export election results [\#6846](https://github.com/decidim/decidim/pull/6846)
- **decidim-admin**, **decidim-participatory processes**: Implement ContentBlock for Process Groups (Admin UI) [\#6655](https://github.com/decidim/decidim/pull/6655)
- **decidim-meetings**: Automatically enable registrations when meeting is "on this platform" [\#6874](https://github.com/decidim/decidim/pull/6874)
- **decidim-core**, **decidim-proposals**: Allow user to drag address on proposal map [\#6291](https://github.com/decidim/decidim/pull/6291)
- **decidim-conferences**: Localize a string in conference speaker [\#6866](https://github.com/decidim/decidim/pull/6866)
- **decidim-participatory processes**: Add HTML Content Blocks in Process Groups  [\#6823](https://github.com/decidim/decidim/pull/6823)
- **decidim-core**: Adds spinner to block page while ajax petition is executed [\#6611](https://github.com/decidim/decidim/pull/6611)
- **decidim-participatory processes**: Add Metadata Content Block in Process Groups [\#6699](https://github.com/decidim/decidim/pull/6699)
- **decidim-participatory processes**: Add Participatory Processes Content Block in Process Groups [\#6826](https://github.com/decidim/decidim/pull/6826)
- **decidim-admin**: Add a general moderation panel [\#6955](https://github.com/decidim/decidim/pull/6955)
- **decidim-participatory processes**: Edit link in groups and show group in processes [\#6827](https://github.com/decidim/decidim/pull/6827)
- **decidim-participatory processes**: Improve highlights of Process Groups [\#6828](https://github.com/decidim/decidim/pull/6828)
- **decidim-participatory processes**: Improvements in Process Groups and processes block [\#6853](https://github.com/decidim/decidim/pull/6853)
- **decidim-debates**: Archive Debates [\#6940](https://github.com/decidim/decidim/pull/6940)
- **decidim-admin**, **decidim-core**: Let components define settings with type time [\#6948](https://github.com/decidim/decidim/pull/6948)
- **decidim-debates**: Export debate comments [\#6962](https://github.com/decidim/decidim/pull/6962)
- **decidim-elections**: Add and use decidim-bulletin_board gem [\#6997](https://github.com/decidim/decidim/pull/6997)
- **decidim-meetings**: Allow creation of hybrid meetings [\#6891](https://github.com/decidim/decidim/pull/6891)
- **decidim-core**, **decidim-verifications**: Encrypt authorization metadata [\#6947](https://github.com/decidim/decidim/pull/6947)
- **decidim-admin**, **decidim-core**, **decidim-system**: Make it possible to allow some pages to display publicly even when organization access is limited [\#6951](https://github.com/decidim/decidim/pull/6951)
- **decidim-surveys**: Start and end dates for survey [\#7016](https://github.com/decidim/decidim/pull/7016)
- **decidim-admin**, **decidim-core**, **decidim-verifications**: Improve management of managed user [\#6748](https://github.com/decidim/decidim/pull/6748)
- **decidim-participatory processes**: Let admins enter the Space Private Users section in admin [\#7067](https://github.com/decidim/decidim/pull/7067)
- **decidim-admin**, **decidim-core**: Detect the use of spam-bots and ban non compliant users (part 2) [\#6804](https://github.com/decidim/decidim/pull/6804)
- **decidim-meetings**: Add comments export to meetings [\#6946](https://github.com/decidim/decidim/pull/6946)
- **decidim-consultations**: See a deprecation callout in Consultations [\#7095](https://github.com/decidim/decidim/pull/7095)
- **decidim-debates**: Add scope to debates [\#6326](https://github.com/decidim/decidim/pull/6326)
- **decidim-budgets**: Sum Budgets finished and pending orders in admin panel [\#7010](https://github.com/decidim/decidim/pull/7010)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory processes**: Allow admin to be registered as a participatory space user [\#6890](https://github.com/decidim/decidim/pull/6890)
- **decidim-budgets**: Export budgets projects [\#7021](https://github.com/decidim/decidim/pull/7021)
- **decidim-initiatives**: Allow the admin to send an initiative to technical validation after it was discarded [\#6993](https://github.com/decidim/decidim/pull/6993)
- **decidim-debates**: Debates with no start and end time [\#6959](https://github.com/decidim/decidim/pull/6959)
- **decidim-accountability**: Add search, filter, order, and paginate capabilities to admin results view [\#7048](https://github.com/decidim/decidim/pull/7048)
- **decidim-core**: Allow customizing SMTP settings for seed data [\#7183](https://github.com/decidim/decidim/pull/7183)
- **decidim-elections**: Create Votings participatory space [\#7145](https://github.com/decidim/decidim/pull/7145)
- **decidim-elections**: Manage Votings [\#7160](https://github.com/decidim/decidim/pull/7160)
- **decidim-dev**, **decidim-elections**: Add the key ceremony [\#6967](https://github.com/decidim/decidim/pull/6967)
- **decidim-core**, **decidim-forms**: Create file uploads question type [\#7192](https://github.com/decidim/decidim/pull/7192)
- **decidim-debates**: Revert "Archive Debates (#6940)" [\#7214](https://github.com/decidim/decidim/pull/7214)
- **decidim-elections**: Add API types for votings [\#7222](https://github.com/decidim/decidim/pull/7222)
- **decidim-elections**: Open and close the Bulletin Board ballot box for elections [\#7035](https://github.com/decidim/decidim/pull/7035)
- **decidim-elections**: Add Vote verification client [\#7056](https://github.com/decidim/decidim/pull/7056)
- **decidim-elections**: Manage attachments in a voting [\#7175](https://github.com/decidim/decidim/pull/7175)
- **decidim-elections**: Add default help texts for votings [\#7174](https://github.com/decidim/decidim/pull/7174)
- **decidim-accountability**: Add attachments to accountability results [\#6851](https://github.com/decidim/decidim/pull/6851)
- **decidim-elections**: Prevent destroying an election component when elections are present [\#7235](https://github.com/decidim/decidim/pull/7235)
- **decidim-elections**: Ensure election data is sent to BB in the default locale [\#7069](https://github.com/decidim/decidim/pull/7069)
- **decidim-admin**: Add CTA buttons to Moderation report page [\#7227](https://github.com/decidim/decidim/pull/7227)
- **decidim-admin**: Display error message in case that justification length is less than specified characters [\#7173](https://github.com/decidim/decidim/pull/7173)
- **decidim-proposals**: Simplify collaborative drafts wizard [\#7239](https://github.com/decidim/decidim/pull/7239)
- **decidim-elections**: Add the votings content block in Homepage [\#7194](https://github.com/decidim/decidim/pull/7194)
- **decidim-core**: Add private message link to proposal author tooltip [\#7207](https://github.com/decidim/decidim/pull/7207)
- **decidim-elections**: Improve vote process [\#7229](https://github.com/decidim/decidim/pull/7229)
- **decidim-proposals**: Proposal preview with full text and attachments [\#7248](https://github.com/decidim/decidim/pull/7248)
- **decidim-elections**: Define voting type [\#7217](https://github.com/decidim/decidim/pull/7217)
- **decidim-elections**: Ensure Bulletin Board is configured for trustee zone [\#7074](https://github.com/decidim/decidim/pull/7074)
- **decidim-budgets**: Admin panel budgets count users with finished and pending votes [\#7195](https://github.com/decidim/decidim/pull/7195)
- **decidim-initiatives**: Include area in initiatives export [\#7242](https://github.com/decidim/decidim/pull/7242)
- **decidim-elections**: Add Polling Stations to Votings [\#7300](https://github.com/decidim/decidim/pull/7300)
- **decidim-initiatives**: Add optional order for initiative content block [\#7047](https://github.com/decidim/decidim/pull/7047)
- **decidim-initiatives**: Notification to initiative authors / promotor committee [\#7028](https://github.com/decidim/decidim/pull/7028)
- **decidim-admin**: Add sorting for “Number of reports” column on Reported users page [\#7279](https://github.com/decidim/decidim/pull/7279)
- **decidim-assemblies**: Add new statistics design to Assemblies [\#7275](https://github.com/decidim/decidim/pull/7275)
- **decidim-elections**: Add the tally process [\#7268](https://github.com/decidim/decidim/pull/7268)
- **decidim-forms**: Max characters for questionnaire answers [\#7314](https://github.com/decidim/decidim/pull/7314)
- **decidim-comments**: Notify users when their comments are voted [\#7055](https://github.com/decidim/decidim/pull/7055)
- **decidim-elections**: Let user change their vote in an Election [\#7262](https://github.com/decidim/decidim/pull/7262)
- **decidim-core**: Add notification setting: emails on moderations [\#7328](https://github.com/decidim/decidim/pull/7328)
- **decidim-admin**, **decidim-proposals**: Import proposals from a spreadsheet [\#7084](https://github.com/decidim/decidim/pull/7084)
- **decidim-meetings**: Add "my activity" filter section on meeting index [\#7261](https://github.com/decidim/decidim/pull/7261)
- **decidim-core**, **decidim-proposals**: Allow multiple lines in announcement block [\#7341](https://github.com/decidim/decidim/pull/7341)
- **decidim-admin**, **decidim-core**: Show session timeout warning and limit sessions to 30min of inactivity [\#7282](https://github.com/decidim/decidim/pull/7282)
- **decidim-admin**, **decidim-core**: Detect the use of spam-bots and ban non compliant users (part 4) [\#6941](https://github.com/decidim/decidim/pull/6941)
- **decidim-elections**: Add Polling Officers to Voting [\#7315](https://github.com/decidim/decidim/pull/7315)
- **decidim-meetings**: Add filter help in all the meetings navigation page [\#7355](https://github.com/decidim/decidim/pull/7355)
- **decidim-elections**: Votings public index [\#7284](https://github.com/decidim/decidim/pull/7284)
- **decidim-elections**: Add admin users query for voting [\#7391](https://github.com/decidim/decidim/pull/7391)
- **decidim-elections**: Add election statistics [\#7258](https://github.com/decidim/decidim/pull/7258)
- **decidim-admin**, **decidim-elections**: Manage voting landing page with content blocks [\#7331](https://github.com/decidim/decidim/pull/7331)
- **decidim-proposals**: Let admins delete proposal attachments [\#7259](https://github.com/decidim/decidim/pull/7259)
- **decidim-assemblies**, **decidim-participatory processes**: Add assemblies & processes weight field [\#7283](https://github.com/decidim/decidim/pull/7283)
- **decidim-elections**: Assign Polling Officers to Polling Stations [\#7344](https://github.com/decidim/decidim/pull/7344)
- **decidim-elections**: Add Monitoring Committee to Voting [\#7396](https://github.com/decidim/decidim/pull/7396)
- **decidim-initiatives**: Raise an alert when there's an error signing an initiative [\#7412](https://github.com/decidim/decidim/pull/7412)
- **decidim-elections**: Filter Polling Stations by Polling Officers assigned/not assigned [\#7415](https://github.com/decidim/decidim/pull/7415)
- **decidim-elections**: Filter and search polling officers [\#7411](https://github.com/decidim/decidim/pull/7411)
- **decidim-api**: Add default order by ID to API list queries [\#7424](https://github.com/decidim/decidim/pull/7424)
- **decidim-api**: Further default orders for the API [\#7436](https://github.com/decidim/decidim/pull/7436)
- **decidim-elections**: Voting: show callout when Polling Stations miss Polling Officers [\#7417](https://github.com/decidim/decidim/pull/7417)
- **decidim-elections**: Add Polling Officer Zone [\#7439](https://github.com/decidim/decidim/pull/7439)
- **decidim-assemblies**: Add order in not highlighted assemblies by weight [\#7444](https://github.com/decidim/decidim/pull/7444)
- **decidim-elections**: Add Votings to Open Data export [\#7388](https://github.com/decidim/decidim/pull/7388)
- **decidim-proposals**: Feature proposal infinite edit time [\#7406](https://github.com/decidim/decidim/pull/7406)
- **decidim-meetings**: Display map and link for hybrid meetings [\#7065](https://github.com/decidim/decidim/pull/7065)

### Changed

- **decidim-api**: Make cors more strict [\#6642](https://github.com/decidim/decidim/pull/6642)
- **decidim-initiatives**: Use a more neutral vocabulary on initiatives [\#6590](https://github.com/decidim/decidim/pull/6590)
- **decidim-conferences**: Fix default help section and page for Conferences and consultations [\#6618](https://github.com/decidim/decidim/pull/6618)
- **decidim-core**: Let the file validator humanizer work with static numeric values [\#6682](https://github.com/decidim/decidim/pull/6682)
- **decidim-verifications**: Show pending authorizations as a list [\#6680](https://github.com/decidim/decidim/pull/6680)
- **decidim-core**: Update social media icons [\#6660](https://github.com/decidim/decidim/pull/6660)
- **decidim-admin**, **decidim-core**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-verifications**: Fix i18n capitalizations [\#6784](https://github.com/decidim/decidim/pull/6784)
- **decidim-budgets**: Add translation for "selected" projects [\#6770](https://github.com/decidim/decidim/pull/6770)
- **decidim-assemblies**, **decidim-participatory processes**, **decidim-proposals**: Fix missing translation keys for mime types [\#6766](https://github.com/decidim/decidim/pull/6766)
- **decidim-blogs**, **decidim-budgets**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**: Add margin between back link and title [\#6854](https://github.com/decidim/decidim/pull/6854)
- **decidim-admin**, **decidim-assemblies**, **decidim-debates**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**: Align actions on Admin panel [\#6805](https://github.com/decidim/decidim/pull/6805)
- **decidim-admin**, **decidim-core**, **decidim-participatory processes**: Fix some strings [\#6958](https://github.com/decidim/decidim/pull/6958)
- **decidim-core**: Improve layout for standalone T&C page [\#6944](https://github.com/decidim/decidim/pull/6944)
- **decidim-admin**: Limit moderation tooltips and tables to 250 chars [\#6976](https://github.com/decidim/decidim/pull/6976)
- **decidim-meetings**: Order meetings by start date instead of creation date [\#6975](https://github.com/decidim/decidim/pull/6975)
- **decidim-core**: Improve help tip on CSV imports [\#6936](https://github.com/decidim/decidim/pull/6936)
- **decidim-core**: Change the personal URL links to profile path links [\#7004](https://github.com/decidim/decidim/pull/7004)
- **decidim-admin**, **decidim-assemblies**, **decidim-core**: Add some missing i18n keys [\#7039](https://github.com/decidim/decidim/pull/7039)
- **decidim-core**: Remove question from blocked user email subject [\#7094](https://github.com/decidim/decidim/pull/7094)
- **decidim-initiatives**: Update initiative answer strings [\#7167](https://github.com/decidim/decidim/pull/7167)
- **decidim-initiatives**: Update button texts on initiative finish page [\#7169](https://github.com/decidim/decidim/pull/7169)
- **decidim-initiatives**: Update initiative child scopes help [\#7168](https://github.com/decidim/decidim/pull/7168)
- **decidim-admin**: Fix word new reused in different contexts [\#7185](https://github.com/decidim/decidim/pull/7185)
- **decidim-core**: Update "Delete my account" text in User Account page [\#7228](https://github.com/decidim/decidim/pull/7228)
- **decidim-core**, **decidim-generators**, **decidim-verifications**: Clarify authorization message with participant scope/postal code [\#7225](https://github.com/decidim/decidim/pull/7225)
- **decidim-assemblies**: Show created_at in assemblies admin index [\#7307](https://github.com/decidim/decidim/pull/7307)
- **decidim-admin**, **decidim-assemblies**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-verifications**: Improve some static strings [\#7329](https://github.com/decidim/decidim/pull/7329)
- **decidim-core**: Clarify the texts to download user data in "My account" [\#7281](https://github.com/decidim/decidim/pull/7281)
- **decidim-admin**: Add some missing words in locales file [\#7346](https://github.com/decidim/decidim/pull/7346)
- **decidim-core**: Clarify the texts to download user data in "My account" (part 2) [\#7342](https://github.com/decidim/decidim/pull/7342)
- **decidim-meetings**: Improve seeds dates in meetings [\#7339](https://github.com/decidim/decidim/pull/7339)
- **decidim-admin**: Migrate Admin menus to Menu Registry [\#7368](https://github.com/decidim/decidim/pull/7368)
- **decidim-core**: Align Data Picker selected values styles [\#7448](https://github.com/decidim/decidim/pull/7448)
- **decidim-comments**: Make API commentable mutation translation attributes optional [\#7694](https://github.com/decidim/decidim/pull/7694)

### Fixed

- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Ensure translatable resources save their fields as JSON objects [\#6587](https://github.com/decidim/decidim/pull/6587)
- **decidim-debates**, **decidim-meetings**: Fix meeting and debate presenters with machine translations [\#6643](https://github.com/decidim/decidim/pull/6643)
- **decidim-core**, **decidim-proposals**: Fix admin logs proposal presenter [\#6637](https://github.com/decidim/decidim/pull/6637)
- **decidim-conferences**, **decidim-core**: Escape conferences user input [\#6641](https://github.com/decidim/decidim/pull/6641)
- **decidim-meetings**: Fix deprecated js loadMap on meetings index [\#6654](https://github.com/decidim/decidim/pull/6654)
- **decidim-elections**: Fix order for elections [\#6616](https://github.com/decidim/decidim/pull/6616)
- **decidim-core**: Fix error when exporting user data [\#6612](https://github.com/decidim/decidim/pull/6612)
- **decidim-core**: Fix nickname prefix wraps on certain view widths [\#6649](https://github.com/decidim/decidim/pull/6649)
- **decidim-initiatives**: Fix error when saving an Initiative title and description from Admin [\#6581](https://github.com/decidim/decidim/pull/6581)
- **decidim-generators**: Avoid rendering values on the secrets.yml when creating a new app [\#6653](https://github.com/decidim/decidim/pull/6653)
- **decidim-core**: Add missing margin between username and title in cards [\#6674](https://github.com/decidim/decidim/pull/6674)
- **decidim-elections**: Fix elections count in Homepage statistics [\#6684](https://github.com/decidim/decidim/pull/6684)
- **decidim-core**: Ensure `resource_text` is a string in NotificationMailer [\#6685](https://github.com/decidim/decidim/pull/6685)
- **decidim-meetings**: Show only visible meetings in highglighted meetings section [\#6707](https://github.com/decidim/decidim/pull/6707)
- **decidim-meetings**: Fix meetings creation [\#6695](https://github.com/decidim/decidim/pull/6695)
- **decidim-admin**, **decidim-core**: Fix content block image updates [\#6681](https://github.com/decidim/decidim/pull/6681)
- **decidim-meetings**: Fix accept invitation to private meetings [\#6727](https://github.com/decidim/decidim/pull/6727)
- **decidim-budgets**: Fix a mistake in a string [\#6750](https://github.com/decidim/decidim/pull/6750)
- **decidim-core**: Fix conference speakers js-bio display [\#6712](https://github.com/decidim/decidim/pull/6712)
- **decidim-core**: Security: hide uploader's internal tool details to users [\#6754](https://github.com/decidim/decidim/pull/6754)
- **decidim-comments**: Fix non-XHR requests for comments (e.g. for search engines) [\#6740](https://github.com/decidim/decidim/pull/6740)
- **decidim-consultations**: Fix Question for Consultation can not be rendered without image [\#6731](https://github.com/decidim/decidim/pull/6731)
- **decidim-meetings**: Fixes meeting card date and address alignment [\#6700](https://github.com/decidim/decidim/pull/6700)
- **decidim-admin**: Fix newsletter create and update actions [\#6755](https://github.com/decidim/decidim/pull/6755)
- **decidim-budgets**: Fix budgeting projects ordered ids [\#6761](https://github.com/decidim/decidim/pull/6761)
- **decidim-core**: Fix ToS agreement display [\#6716](https://github.com/decidim/decidim/pull/6716)
- **decidim-consultations**: Fix aria-label attribute in the vote modal confirm close button [\#6756](https://github.com/decidim/decidim/pull/6756)
- **decidim-meetings**: Only show visible meetings on Upcoming Meetings content block [\#6778](https://github.com/decidim/decidim/pull/6778)
- **decidim-assemblies**: Fix images URL in assemblies presenter on cloud storage [\#6758](https://github.com/decidim/decidim/pull/6758)
- **decidim-meetings**: Do not html_escape meetings title twice in cells [\#6763](https://github.com/decidim/decidim/pull/6763)
- **decidim-core**: Require the necessary "zip" gem in the open data exporter [\#6464](https://github.com/decidim/decidim/pull/6464)
- **decidim-core**: Bubble jQuery events with the custom confirm dialog [\#6610](https://github.com/decidim/decidim/pull/6610)
- **decidim-admin**: Only show header snippets input if feature is enabled [\#6793](https://github.com/decidim/decidim/pull/6793)
- **decidim-consultations**: Fix question#show view when question has no hero_image [\#6797](https://github.com/decidim/decidim/pull/6797)
- **decidim-participatory processes**: Fix highlighted participatory processes title [\#6798](https://github.com/decidim/decidim/pull/6798)
- **decidim-budgets**, **decidim-comments**, **decidim-core**: Fix broken notifications page due to multi-budget changes [\#6815](https://github.com/decidim/decidim/pull/6815)
- **decidim-system**: Fix SMTP settings update [\#6664](https://github.com/decidim/decidim/pull/6664)
- **decidim-forms**: Fix display conditions validations with choices [\#6837](https://github.com/decidim/decidim/pull/6837)
- **decidim-proposals**: Fix issues with move proposal fields to i18n [\#6838](https://github.com/decidim/decidim/pull/6838)
- **decidim-meetings**:  Fix String to Array comparison in meetings type filter [\#6831](https://github.com/decidim/decidim/pull/6831)
- **decidim-core**: Fix broken profile link in plain text emails [\#6833](https://github.com/decidim/decidim/pull/6833)
- **decidim-meetings**: Fix proposals selection when closing a meeting [\#6803](https://github.com/decidim/decidim/pull/6803)
- **decidim-core**: Fix show generic error on minimagick processing error  [\#6818](https://github.com/decidim/decidim/pull/6818)
- **decidim-core**: Fix searchable issues with resources with unexisting organization [\#6839](https://github.com/decidim/decidim/pull/6839)
- **decidim-admin**: Fix color text for unpublish button [\#6845](https://github.com/decidim/decidim/pull/6845)
- **decidim-budgets**, **decidim-comments**: Fix broken comments index redirect for non-XHR requests [\#6817](https://github.com/decidim/decidim/pull/6817)
- **decidim-admin**: Disable select inputs with the subform toggler as well [\#6769](https://github.com/decidim/decidim/pull/6769)
- **decidim-admin**, **decidim-core**: Fix inconsistent styles in links. [\#6751](https://github.com/decidim/decidim/pull/6751)
- **decidim-core**, **decidim-forms**, **decidim-meetings**: Fix security token generation in anonymous surveys and pads [\#6850](https://github.com/decidim/decidim/pull/6850)
- **decidim-core**: Fix to suppress error when "forms.length_validator.minimum.one" is missing [\#6865](https://github.com/decidim/decidim/pull/6865)
- **decidim-core**: Fix send report notification asynchronously [\#6868](https://github.com/decidim/decidim/pull/6868)
- **decidim-core**: Fix to use `tail_before_final_tag: false` option [\#6886](https://github.com/decidim/decidim/pull/6886)
- **decidim-budgets**: Fix incorrect order of minimum/maximum in the locales [\#6882](https://github.com/decidim/decidim/pull/6882)
- **decidim-admin**: Fix newsletter delivery issue to all recipients with no scopes [\#6875](https://github.com/decidim/decidim/pull/6875)
- **decidim-forms**, **decidim-surveys**:  Fix mixing answers exports and admin management in questionnaires [\#6902](https://github.com/decidim/decidim/pull/6902)
- **decidim-system**: Fix smtp_settings keys type [\#6908](https://github.com/decidim/decidim/pull/6908)
- **decidim-assemblies**, **decidim-core**: Fix traceability logs with invalid record [\#6879](https://github.com/decidim/decidim/pull/6879)
- **decidim-admin**: Fix broken dashboard action logs under certain conditions [\#6857](https://github.com/decidim/decidim/pull/6857)
- **decidim-core**: Fix newsletter html containing style tag content [\#6876](https://github.com/decidim/decidim/pull/6876)
- **decidim-blogs**: Add logic in view to prevent visual error in blog post [\#6942](https://github.com/decidim/decidim/pull/6942)
- **decidim-meetings**: Hide moderated meetings in the meetings index page  [\#6927](https://github.com/decidim/decidim/pull/6927)
- **decidim-core**: Fix the data portability exporter when zip is not in the gemfile [\#6969](https://github.com/decidim/decidim/pull/6969)
- **decidim-meetings**: Use URL instead of path in meeting registration invitation emails [\#6965](https://github.com/decidim/decidim/pull/6965)
- **decidim-core**: Fix email CTA alignment on Outlook and Windows Mail [\#6895](https://github.com/decidim/decidim/pull/6895)
- **decidim-participatory processes**: Fix ParticipatoryProcess metrics ajax call in show [\#6971](https://github.com/decidim/decidim/pull/6971)
- **decidim-admin**, **decidim-core**: Fix editor image alt tag [\#6920](https://github.com/decidim/decidim/pull/6920)
- **decidim-core**, **decidim-dev**, **decidim-initiatives**: Fix initiatives notifications by email for followers [\#6889](https://github.com/decidim/decidim/pull/6889)
- **decidim-admin**, **decidim-core**: Fix private participants pagination crash [\#6986](https://github.com/decidim/decidim/pull/6986)
- **decidim-core**, **decidim-meetings**: Fix visible_meeting_for to increase cases where an user can see meetings [\#6925](https://github.com/decidim/decidim/pull/6925)
- **decidim-core**: Uploaders enforce organizations, but not always available [\#6924](https://github.com/decidim/decidim/pull/6924)
- **decidim-meetings**: Fix meeting closing issues [\#6974](https://github.com/decidim/decidim/pull/6974)
- **decidim-core**: Remove duplicated error message in datetime_fields [\#7008](https://github.com/decidim/decidim/pull/7008)
- **decidim-sortitions**: Fix CandidateProposals attribute type on SortitionType on the API [\#6992](https://github.com/decidim/decidim/pull/6992)
- **decidim-core**: Fix avoid removing tag style on custom sanitize [\#7018](https://github.com/decidim/decidim/pull/7018)
- **decidim-admin**, **decidim-core**: Fix linebreaks in WYSWYG editor [\#6996](https://github.com/decidim/decidim/pull/6996)
- **decidim-proposals**: Fix proposals admin form when editing [\#7042](https://github.com/decidim/decidim/pull/7042)
- **decidim-admin**: Allow selecting multiple files on gallery forms [\#7052](https://github.com/decidim/decidim/pull/7052)
- **decidim-proposals**: Fix filter proposals by state in the admin [\#6883](https://github.com/decidim/decidim/pull/6883)
- **decidim-conferences**: Fix error adding partner to conference [\#7026](https://github.com/decidim/decidim/pull/7026)
- **decidim-admin**: Remove HTML from tooltips on "Visit URL" link [\#7032](https://github.com/decidim/decidim/pull/7032)
- **decidim-core**: Fix the TOS page acceptance form not displaying with layout customizations [\#7096](https://github.com/decidim/decidim/pull/7096)
- **decidim-blogs**, **decidim-budgets**, **decidim-comments**, **decidim-core**, **decidim-meetings**, **decidim-proposals**: Don't show unpublished content in search engine [\#6863](https://github.com/decidim/decidim/pull/6863)
- **decidim-admin**: Ensure only installed content blocks are loaded in admin [\#7141](https://github.com/decidim/decidim/pull/7141)
- **decidim-admin**, **decidim-core**: Fix editor linebreak module [\#7070](https://github.com/decidim/decidim/pull/7070)
- **decidim-admin**: Fix comments newsletter participant ids [\#7046](https://github.com/decidim/decidim/pull/7046)
- **decidim-core**: Fix possible infinite redirection loop with internal server error on the TOS acceptance page [\#7149](https://github.com/decidim/decidim/pull/7149)
- **decidim-meetings**: Leaving meeting without questionnaire will render error [\#7150](https://github.com/decidim/decidim/pull/7150)
- **decidim-proposals**: Fix the proposal body validation error messages [\#7156](https://github.com/decidim/decidim/pull/7156)
- **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-proposals**: Fix form string length validation with carriage returns [\#7157](https://github.com/decidim/decidim/pull/7157)
- **decidim-initiatives**: Fix initiative type scope form HTML [\#7166](https://github.com/decidim/decidim/pull/7166)
- **decidim-conferences**: Fix error when updating a Conference speaker with an invalid image [\#7189](https://github.com/decidim/decidim/pull/7189)
- **decidim-conferences**: Fix error when creating a Conference speaker with an attachment [\#7191](https://github.com/decidim/decidim/pull/7191)
- **decidim-core**: Fix issue trying to add references to unexisting records [\#7205](https://github.com/decidim/decidim/pull/7205)
- **decidim-core**: Remove negative margin from registration field [\#7198](https://github.com/decidim/decidim/pull/7198)
- **decidim-consultations**: Restore consultation's description rich text format [\#7218](https://github.com/decidim/decidim/pull/7218)
- **decidim-conferences**: Fix error when updating the Conference partner with an invalid image [\#7210](https://github.com/decidim/decidim/pull/7210)
- **decidim-admin**, **decidim-core**: Fix: hide help section when it has no content [\#7224](https://github.com/decidim/decidim/pull/7224)
- **decidim-conferences**:  Fix error when creating the Conference partner with an invalid image [\#7211](https://github.com/decidim/decidim/pull/7211)
- **decidim-admin**, **decidim-core**: Fix editor paste [\#7241](https://github.com/decidim/decidim/pull/7241)
- **decidim-proposals**: Ignore the `state_published_at` field when importing proposals [\#7231](https://github.com/decidim/decidim/pull/7231)
- **decidim-forms**: Don't render separators when exporting questionnaires [\#7243](https://github.com/decidim/decidim/pull/7243)
- **decidim-assemblies**: Hide Assemblies menu if none are visible [\#7254](https://github.com/decidim/decidim/pull/7254)
- **decidim-meetings**: Fix meetings filters to show the right count  [\#7255](https://github.com/decidim/decidim/pull/7255)
- **decidim-accountability**, **decidim-admin**, **decidim-core**: Fix custom colors to apply everywhere [\#7172](https://github.com/decidim/decidim/pull/7172)
- **decidim-elections**: Fix elections announcement [\#7270](https://github.com/decidim/decidim/pull/7270)
- **decidim-core**: Fix line breaks in external links [\#7280](https://github.com/decidim/decidim/pull/7280)
- **decidim-initiatives**: Fix unclosed div [\#7302](https://github.com/decidim/decidim/pull/7302)
- **decidim-core**: Avoid CarrierWave::IntegrityError [\#7324](https://github.com/decidim/decidim/pull/7324)
- **decidim-admin**: fix css caret from dropdown-menu in admin [\#7332](https://github.com/decidim/decidim/pull/7332)
- **decidim-initiatives**: Fix initiative edit [\#7054](https://github.com/decidim/decidim/pull/7054)
- **decidim-meetings**: Truncate description in meetings map popup [\#7335](https://github.com/decidim/decidim/pull/7335)
- **decidim-budgets**, **decidim-core**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-proposals**: Fix broken attachments with form validation errors [\#7336](https://github.com/decidim/decidim/pull/7336)
- **decidim-initiatives**: Fix initiatives type permissions page [\#7356](https://github.com/decidim/decidim/pull/7356)
- **decidim-core**, **decidim-proposals**: Fix removal of the address from proposals [\#7343](https://github.com/decidim/decidim/pull/7343)
- **decidim-core**: Fix long redirect URL storing in cookies [\#7362](https://github.com/decidim/decidim/pull/7362)
- **decidim-core**: Fix infinite redirect loops due to no permissions for the page and referer pointing to the same path [\#7381](https://github.com/decidim/decidim/pull/7381)
- **decidim-proposals**: Fix proposal title minimum length validation of 15 characters [\#7379](https://github.com/decidim/decidim/pull/7379)
- **decidim-core**: Don't include JS file manually [\#7383](https://github.com/decidim/decidim/pull/7383)
- **decidim-forms**, **decidim-meetings**: Fix ehterpad compatibility for old meetings [\#7384](https://github.com/decidim/decidim/pull/7384)
- **decidim-admin**: Fix require session timeouter javascript in admin application.js [\#7389](https://github.com/decidim/decidim/pull/7389)
- **decidim-core**: Fix random order inconsistencies [\#7437](https://github.com/decidim/decidim/pull/7437)
- **decidim-admin**: Fix to avoid registered users being invited again [\#7392](https://github.com/decidim/decidim/pull/7392)
- **decidim-debates**: Fix display of debates with multiple dates [\#7393](https://github.com/decidim/decidim/pull/7393)
- **decidim-core**: Fix session timeout when using multiple windows or tabs [\#7459](https://github.com/decidim/decidim/pull/7459)
- **decidim-core**: Fix invalid signature on message decryption [\#7490](https://github.com/decidim/decidim/pull/7490)
- **decidim-assemblies**, **decidim-participatory processes**: Fix NULL error with weight field in assemblies & processes [\#7491](https://github.com/decidim/decidim/pull/7491)
- **decidim-core**: Fix record encryptor hash values JSON parsing for legacy unencrypted hash values [\#7496](https://github.com/decidim/decidim/pull/7496)
- **decidim-admin**: Only share tokens if component exists [\#7504](https://github.com/decidim/decidim/pull/7504)
- **decidim-core**: Invalidate all user sessions when destroying the account [\#7511](https://github.com/decidim/decidim/pull/7511)
- **decidim-proposals**: Fix non-unique IDs element in filter hash cash [\#7533](https://github.com/decidim/decidim/pull/7533)
- **decidim-core**: Fix record encryptor trying to decrypt or decode non-String values [\#7538](https://github.com/decidim/decidim/pull/7538)
- **decidim-core**: Fix record encryptor trying to decrypt empty strings [\#7547](https://github.com/decidim/decidim/pull/7547)
- **decidim-admin**, **decidim-budgets**:  New Admin users cannot accept Terms and conditions [\#7520](https://github.com/decidim/decidim/pull/7520)
- **decidim-core**, **decidim-proposals**: Fix cells caching by using cache_key_with_version instead of cache version [\#7556](https://github.com/decidim/decidim/pull/7556)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Fix user profile timeline activity cards texts showing "New resource" on updates [\#7558](https://github.com/decidim/decidim/pull/7558)
- **decidim-core**: Sanitize address inputs [\#7576](https://github.com/decidim/decidim/pull/7576)
- **decidim-participatory processes**: Fix process serializer to consider nil images [\#7614](https://github.com/decidim/decidim/pull/7614)
- **decidim-core**: Make category in the API non-mandatory [\#7626](https://github.com/decidim/decidim/pull/7626)
- **decidim-proposals**: Improve proposals listing performance after cache implementation [\#7630](https://github.com/decidim/decidim/pull/7630)
- **decidim-meetings**: Do not crash if mandatory fields are blank and registrations are enabled [\#7636](https://github.com/decidim/decidim/pull/7636)
- **decidim-participatory processes**: Show processes finishing today [\#7637](https://github.com/decidim/decidim/pull/7637)
- **decidim-proposals**: Fix rendering of proposals in map [\#7645](https://github.com/decidim/decidim/pull/7645)
- **decidim-proposals**: Don't copy counters when copying proposals [\#7639](https://github.com/decidim/decidim/pull/7639)
- **decidim-proposals**: Show all proposals in map (#7660) [\#7678](https://github.com/decidim/decidim/pull/7678)
- **decidim-core**: Fit the map properly on mobile screens with multiple markers [\#7651](https://github.com/decidim/decidim/pull/7651)
- **decidim-initiatives**: Fix initiative-m card hashtags [\#7679](https://github.com/decidim/decidim/pull/7679)
- **decidim-core**: Ensure pagination elements per page is a valid option [\#7680](https://github.com/decidim/decidim/pull/7680)
- **decidim-core**: Don't show deleted users on user group members page [\#7681](https://github.com/decidim/decidim/pull/7681)
- **decidim-core**: Fix report mailers when author is a meeting [\#7683](https://github.com/decidim/decidim/pull/7683)
- **decidim-admin**: Don't render a moderation when its reportable is deleted [\#7684](https://github.com/decidim/decidim/pull/7684)
- **decidim-meetings**: Show newer meetings first [\#7685](https://github.com/decidim/decidim/pull/7685)
- **decidim-admin**: Only show moderations from current organization in Global Moderation panel [\#7686](https://github.com/decidim/decidim/pull/7686)
- **decidim-core**: Don't send emails to deleted users [\#7688](https://github.com/decidim/decidim/pull/7688)
- **decidim-proposals**: Fix a series of issues with proposal attachments in the public area [\#7699](https://github.com/decidim/decidim/pull/7699)
- **decidim-proposals**: Fix map preview when there is no address [\#7673](https://github.com/decidim/decidim/pull/7673)
- **decidim-core**, **decidim-proposals**: Fix announcements when sending an empty translations hash [\#7568](https://github.com/decidim/decidim/pull/7568)

### Removed

- **decidim-admin**, **decidim-core**: Remove show_statistics checkbox in Appearance [\#6575](https://github.com/decidim/decidim/pull/6575)

### Developer improvements

- Update documentation for `decidim` OAuth social provider [\#6607](https://github.com/decidim/decidim/pull/6607)
- Delete decidim-participatory_processes/A file [\#6668](https://github.com/decidim/decidim/pull/6668)
- Remove unused /organization_users route [\#6673](https://github.com/decidim/decidim/pull/6673)
- Homepage content blocks cache [\#6235](https://github.com/decidim/decidim/pull/6235)
- Remove unused Initiative author i18n block [\#6667](https://github.com/decidim/decidim/pull/6667)
- Display the time Rails spends rendering a cell [\#6515](https://github.com/decidim/decidim/pull/6515)
- Refactor comments: get rid of react [\#6498](https://github.com/decidim/decidim/pull/6498)
- Add machine translations on factories [\#6665](https://github.com/decidim/decidim/pull/6665)
- Refactor meetings test to be resilient to flakys [\#6694](https://github.com/decidim/decidim/pull/6694)
- Upgrade to Ruby 2.7.1 and update sprockets related gems [\#6551](https://github.com/decidim/decidim/pull/6551)
- Fix rubocop lint due to an upgraded ruby 2.7 [\#6715](https://github.com/decidim/decidim/pull/6715)
- Fix dependencies for decidim-templates within decidim-forms [\#6652](https://github.com/decidim/decidim/pull/6652)
- Add information for a correct etherpad integration [\#6704](https://github.com/decidim/decidim/pull/6704)
- Adjust Faker syntax to remove deprecation warnings in sortitions [\#6738](https://github.com/decidim/decidim/pull/6738)
- Adjust Faker syntax to remove deprecation warnings in core [\#6737](https://github.com/decidim/decidim/pull/6737)
-  Adjust Faker syntax to remove deprecation warnings in all other modules [\#6764](https://github.com/decidim/decidim/pull/6764)
- Fix failing spec for Decidim::System::MenuHelper [\#6765](https://github.com/decidim/decidim/pull/6765)
- Add Visual Code Remote Containers support [\#6638](https://github.com/decidim/decidim/pull/6638)
- Fix devise deprecations [\#6736](https://github.com/decidim/decidim/pull/6736)
- Generate changelog entries [\#6794](https://github.com/decidim/decidim/pull/6794)
- Remove httparty gem [\#6888](https://github.com/decidim/decidim/pull/6888)
- Fix decidim-templates gem definition to include templates migrations [\#6899](https://github.com/decidim/decidim/pull/6899)
- Add Decidim::Faker::Internet.slug; slug should be ASCII [\#6742](https://github.com/decidim/decidim/pull/6742)
- Update release notes documentation [\#6809](https://github.com/decidim/decidim/pull/6809)
- chore: move rubocop ruby config to own file [\#6952](https://github.com/decidim/decidim/pull/6952)
- Convert technical docs to Antora [\#6526](https://github.com/decidim/decidim/pull/6526)
- Fix name error when no elections [\#6903](https://github.com/decidim/decidim/pull/6903)
- Fix README adoc [\#6979](https://github.com/decidim/decidim/pull/6979)
- Docs: Undo 'main' branch renaming [\#6999](https://github.com/decidim/decidim/pull/6999)
- Update link to CONTRIBUTING.adoc in PULL_REQUEST_TEMPLATE.md [\#6995](https://github.com/decidim/decidim/pull/6995)
- Docs: add SSL recommmendations [\#7003](https://github.com/decidim/decidim/pull/7003)
- GraphQL syntax upgrade (Part 1) [\#6950](https://github.com/decidim/decidim/pull/6950)
- Fix cell specs assuming within statements [\#7022](https://github.com/decidim/decidim/pull/7022)
- GitHub Action workflow on release triggering decidim/docker build [\#6931](https://github.com/decidim/decidim/pull/6931)
- Fix initiatives GraphQL type [\#7038](https://github.com/decidim/decidim/pull/7038)
- GraphQL syntax upgrade (Part 2) - increase test coverage [\#7023](https://github.com/decidim/decidim/pull/7023)
- Increase codecov/project change failure threshold [\#7088](https://github.com/decidim/decidim/pull/7088)
- GraphQL syntax upgrade (Part 3) [\#7049](https://github.com/decidim/decidim/pull/7049)
- GraphQL syntax upgrade (Part 4) [\#7071](https://github.com/decidim/decidim/pull/7071)
- GraphQL syntax upgrade (Part 5) [\#7072](https://github.com/decidim/decidim/pull/7072)
- GraphQL syntax upgrade (Part 6) [\#7093](https://github.com/decidim/decidim/pull/7093)
- Add caching to proposals [\#6808](https://github.com/decidim/decidim/pull/6808)
- GraphQL syntax upgrade (Part 7) [\#7050](https://github.com/decidim/decidim/pull/7050)
- GraphQL syntax upgrade (Part 8) [\#7144](https://github.com/decidim/decidim/pull/7144)
- Upgrade GraphQL syntax [\#6914](https://github.com/decidim/decidim/pull/6914)
- Fix foundation deprecations [\#7158](https://github.com/decidim/decidim/pull/7158)
- Update nokogiri [\#7151](https://github.com/decidim/decidim/pull/7151)
- Fix conditions to autocancel CI builds [\#7159](https://github.com/decidim/decidim/pull/7159)
- Upgrade GraphQL syntax - cleanup [\#7155](https://github.com/decidim/decidim/pull/7155)
- Fix syntax error in docs of c4model diagrams [\#7164](https://github.com/decidim/decidim/pull/7164)
- Bump axios version [\#7182](https://github.com/decidim/decidim/pull/7182)
- Split core, meetings and proposals system public CI suites into multiple workflows [\#7179](https://github.com/decidim/decidim/pull/7179)
- Bump minimum version for redcarpet [\#7181](https://github.com/decidim/decidim/pull/7181)
- API paths refactor [\#7199](https://github.com/decidim/decidim/pull/7199)
- Fix autoloading paths on GraphQL on more libraries. [\#7203](https://github.com/decidim/decidim/pull/7203)
- Add local development build instructions with Antora [\#7193](https://github.com/decidim/decidim/pull/7193)
- Add timeouts for workflow [\#7209](https://github.com/decidim/decidim/pull/7209)
-  Fix autoloading paths on GraphQL on more libraries (wrap up).   [\#7204](https://github.com/decidim/decidim/pull/7204)
- Upgrade graphql to 1.12.0  [\#7201](https://github.com/decidim/decidim/pull/7201)
- Use correct command in CI [\#7220](https://github.com/decidim/decidim/pull/7220)
- Add docs on how to customize seed data [\#7187](https://github.com/decidim/decidim/pull/7187)
- Make the API return a JSON-formatted message on error in development mode [\#7177](https://github.com/decidim/decidim/pull/7177)
- Document command to list unused i18n keys [\#7232](https://github.com/decidim/decidim/pull/7232)
- Document automated docker release builds [\#7230](https://github.com/decidim/decidim/pull/7230)
- Add missing tests for conference speakers [\#7216](https://github.com/decidim/decidim/pull/7216)
- Fix minimum versions of dependencies [\#7237](https://github.com/decidim/decidim/pull/7237)
- Update Dockerfile.design to not depend on decidim/docker [\#7077](https://github.com/decidim/decidim/pull/7077)
- Refactor API path for votings [\#7245](https://github.com/decidim/decidim/pull/7245)
- Upgrade carrierwave to version 2.1 [\#7213](https://github.com/decidim/decidim/pull/7213)
- Upgrade decidim-bulletin_board to 0.8.0 [\#7236](https://github.com/decidim/decidim/pull/7236)
- Fix datepicker tests to not match upcoming month's days [\#7256](https://github.com/decidim/decidim/pull/7256)
- Fix typos on docs [\#7257](https://github.com/decidim/decidim/pull/7257)
- Add documentation for running localhost in SSL [\#7263](https://github.com/decidim/decidim/pull/7263)
- Fix HTML closing tag [\#7266](https://github.com/decidim/decidim/pull/7266)
- Replace partials with the cells they render [\#7251](https://github.com/decidim/decidim/pull/7251)
- Change all `master` references to `develop` [\#7267](https://github.com/decidim/decidim/pull/7267)
- Fix `--edge` generators to use the default branch [\#7271](https://github.com/decidim/decidim/pull/7271)
- Remove real address from tests [\#7301](https://github.com/decidim/decidim/pull/7301)
- Delete docker-compose.yml and d/* stubs [\#7312](https://github.com/decidim/decidim/pull/7312)
- Bump carrierwave version [\#7320](https://github.com/decidim/decidim/pull/7320)
- Update docker documentation [\#7311](https://github.com/decidim/decidim/pull/7311)
- Fix C4 PlantUML references in docs  [\#7325](https://github.com/decidim/decidim/pull/7325)
- Add Bulletin Board docs [\#7326](https://github.com/decidim/decidim/pull/7326)
- Fix the failing consultations system spec [\#7348](https://github.com/decidim/decidim/pull/7348)
- Fix the failing initiatives system spec [\#7347](https://github.com/decidim/decidim/pull/7347)
- Fix admin spec issue regarding tooltip ID selectors starting with numbers [\#7349](https://github.com/decidim/decidim/pull/7349)
- Update on_release CI workflow [\#7350](https://github.com/decidim/decidim/pull/7350)
- CI: Suppress deprecation warnings [\#7352](https://github.com/decidim/decidim/pull/7352)
- Fix open-ended dependency warning [\#7353](https://github.com/decidim/decidim/pull/7353)
- Additional fix of GitHub Actions config [\#7373](https://github.com/decidim/decidim/pull/7373)
- Fix warnings of `have_content nil` [\#7372](https://github.com/decidim/decidim/pull/7372)
- Fix warnings of `not_to raise_error` in specs [\#7370](https://github.com/decidim/decidim/pull/7370)
- Configure capybara puma maximum threads to 1 [\#7366](https://github.com/decidim/decidim/pull/7366)
- Fix issue in initiatives spec with clashing IDs and user nicknames [\#7365](https://github.com/decidim/decidim/pull/7365)
- Fix forms specs for manage display conditions random question order [\#7367](https://github.com/decidim/decidim/pull/7367)
- Fixing foundation deprecations [\#7374](https://github.com/decidim/decidim/pull/7374)
- Fix the integration schema spec expectation's published at date [\#7375](https://github.com/decidim/decidim/pull/7375)
- Fix questionnaire spec factory random question order [\#7378](https://github.com/decidim/decidim/pull/7378)
- Fix an issue with puffing-billy event machine not running [\#7364](https://github.com/decidim/decidim/pull/7364)
- Merge and organize elections examples [\#7385](https://github.com/decidim/decidim/pull/7385)
- Remove Codecov annotations [\#7394](https://github.com/decidim/decidim/pull/7394)
- Use real resource controller for filterable concern in system tests [\#7402](https://github.com/decidim/decidim/pull/7402)
- Refactor participatory process groups landing page in Admin Dashboard [\#7361](https://github.com/decidim/decidim/pull/7361)
- Rename proposalscreator to proposalcreator [\#7405](https://github.com/decidim/decidim/pull/7405)
- Remove unused class [\#7340](https://github.com/decidim/decidim/pull/7340)
- Ignore warning on CI when no artifacts to upload [\#7420](https://github.com/decidim/decidim/pull/7420)
- Update dependencies [\#7422](https://github.com/decidim/decidim/pull/7422)
- Ensure Rails is locked to 5.2.4.x series [\#7430](https://github.com/decidim/decidim/pull/7430)
- Bump to carrierwave 2.2.0 [\#7441](https://github.com/decidim/decidim/pull/7441)
- Split Election tests suite into 3 workflows [\#7451](https://github.com/decidim/decidim/pull/7451)
- Improve menus sorting [\#7460](https://github.com/decidim/decidim/pull/7460)
- Add changelog generator based on PR data [\#7461](https://github.com/decidim/decidim/pull/7461)
- Trigger docs build on folder changes [\#7360](https://github.com/decidim/decidim/pull/7360)
- Remove duplicated migration [\#7521](https://github.com/decidim/decidim/pull/7521)
- Bump mimemagic to 0.3.6 [\#7701](https://github.com/decidim/decidim/pull/7701)

## Previous versions

Please check [release/0.23-stable](https://github.com/decidim/decidim/blob/release/0.23-stable/CHANGELOG.md) for previous changes.
