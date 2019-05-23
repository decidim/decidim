# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

#### Participants metrics

After running the migrations, you can run the following code from the console to recalculate participants metrics (they should increase). It may take a while to complete.

```ruby
days = (Date.parse(2.months.ago.to_s)..Date.yesterday).uniq
Decidim::Organization.find_each do |org|
  old_metrics = Decidim::Metric.where(organization: org).where(metric_type: "participants")
  days.each do |day|
    new_metrics = Decidim::Metrics::ParticipantsMetricManage.new(day.to_s, org)
    ActiveRecord::Base.transaction do
      old_metrics.where(day: day).delete_all
      new_metrics.save
    end
  end
end
```

**Added**:

- **decidim-consultations**, Add buttons fot better Questions navigation. [#5112](https://github.com/decidim/decidim/pull/5112)
- **decidim-core**, Add rake task to recalculate all metrics since some specific date. [#5117](https://github.com/decidim/decidim/pull/5117)
- **decidim-core**, Add instructions to recalculate participants metrics. [#5110](https://github.com/decidim/decidim/pull/5110)
- **decidim-core**, **decidim-admin**, Add Selective Newsletter and allow Space admins to manage them. [#5039](https://github.com/decidim/decidim/pull/5039)
- **decidim-core** Persistence related documentation for Metrics. [\#5108](https://github.com/decidim/decidim/pull/5108)
- **decidim-core** Add optional parameter :col_sep to CSV exporter [\#5089](https://github.com/decidim/decidim/pull/5089)
- **decidim-meetings** Let user groups join meetings [\#5060](https://github.com/decidim/decidim/pull/5060)
- **decidim-assemblies**, **decidim-participatory_processes** Reorganize admin form [\#5068](https://github.com/decidim/decidim/pull/5068)
- **decidim-assemblies**, **decidim-participatory_processes** Table headers sortable links [\#5010](https://github.com/decidim/decidim/pull/5010)
- **decidim-assemblies**, **decidim-participatory_processes** Filter spaces by scope and area [\#5047](https://github.com/decidim/decidim/pull/5047)
- **decidim-admin**: Do not allow to delete areas when they have dependent spaces. [#5041](https://github.com/decidim/decidim/pull/5041)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory_processes** Space CTA button text changes when no components [\#5006](https://github.com/decidim/decidim/pull/5006)
- **decidim-participatory_processes**: Add a select field for assign an area to participatory processes [#5011](https://github.com/decidim/decidim/pull/5011)
- **decidim-accountability**: Also display the main scope as a filter for accountability results [#5022](https://github.com/decidim/decidim/pull/5022)
- **decidim-system**: Add custom SMTP settings for multitenant [#4698](https://github.com/decidim/decidim/pull/4698)
- **decidim-proposals**: Add proposal answers to the proposal export [#5139](https://github.com/decidim/decidim/pull/5139)

**Changed**:

- **decidim-core**: PermissionsRegistry introduced to enable reconfiguration of permission_class_chain. [#5069](https://github.com/decidim/decidim/pull/5069)
- **decidim-core**: Change attachment photo image alt texts to title instead of description. [#5043](https://github.com/decidim/decidim/pull/5043)
- **decidim-comments**: Allow cancelling a vote on a comment. [#5042](https://github.com/decidim/decidim/pull/5042)
- **decidim-initiatives**: Add styles inline in PDF document of signatures [#5103](https://github.com/decidim/decidim/pull/5103)

**Fixed**:

- **decidim-meetings**: Fix registration form in duplicated meeting [\#5136](https://github.com/decidim/decidim/pull/5136)
- **decidim-meetings**: Fix meeting minutes related information in public view [\#5137](https://github.com/decidim/decidim/pull/5137)
- **decidim-meetings**: Fix `deliver_now` call on `send_email_confirmation` [\#5111](https://github.com/decidim/decidim/pull/5111)
- **decidim-admin**: fix Decidim::Admin::NewsletterRecipient query [\#5109](https://github.com/decidim/decidim/pull/5109)
- **decidim-proposals**: Fix participatory text form. [#5094](https://github.com/decidim/decidim/pull/5094)
- **decidim-assemblies**: Add class `card--stack` to assemblies when have children assemblies. [#5093](https://github.com/decidim/decidim/pull/5093)
- **decidim-proposals**: Fix proposal participants metrics. [#5048](https://github.com/decidim/decidim/pull/5048)
- **decidim-comments**: Don't show a second reply button when comment is hidden. [#5045](https://github.com/decidim/decidim/pull/5045)
- **decidim-core**: Fix CSS transparencies using customized colors. [\#5071](https://github.com/decidim/decidim/pull/5071)
- **decidim-core**, **decidim-proposals**: Fix: show existing amendments when amendments feature is disabled [\#5070](https://github.com/decidim/decidim/pull/5070)
- **decidim-assemblies**: Fix admin assemblies form. [\#5054](https://github.com/decidim/decidim/pull/5054)
- **decidim-core**: Fix repeated amendments notifications. [\#5001](https://github.com/decidim/decidim/pull/5001)
- **decidim-core**: Fix amendments forms: show error messages and render hashtags. [#4951](https://github.com/decidim/decidim/pull/4951)
- **decidim-comments**: Fixes that as a normal user (no private user) I can comment on a private assembly where is available. [#4924](https://github.com/decidim/decidim/pull/4924)
- **decidim-accountability**: Handle special case when all children weight are nil on accountability. [#5026](https://github.com/decidim/decidim/pull/5026)
- **decidim-proposals**: Filter emendations by rendering only amendments. [#5025](https://github.com/decidim/decidim/pull/5025)
- **decidim-proposals**: Add documents folder in proposals manifest for precompile assets. [#5015](https://github.com/decidim/decidim/pull/5015)
- **decidim-core**: Fix user notification and interest settings on IE11. [#5044](https://github.com/decidim/decidim/pull/5044)
- **decidim-admin**, **decidim-forms**, **decidim-meetings**: Fix dynamic fields components on IE11. [#5052](https://github.com/decidim/decidim/pull/5052)
- **decidim-core**: Fix possible NoMethodErrors in the notification jobs filling logs. [#5083](https://github.com/decidim/decidim/pull/5083)
- **decidim-participatory_processes**: Fix step CTA URL when abse URL had params [#5082](https://github.com/decidim/decidim/pull/5082)
- **decidim-admin**: Ensure static pages slugs are relative paths [#5085](https://github.com/decidim/decidim/pull/5085)
- **decidim-accountability**: Remove useless button on the admin page for accountability statuses [#5099](https://github.com/decidim/decidim/pull/5099)
- **decidim-budgets**: Fix import of proposals to budget projects [#5097](https://github.com/decidim/decidim/pull/5097)

**Removed**:

## Previous versions

Please check [0.17-stable](https://github.com/decidim/decidim/blob/0.17-stable/CHANGELOG.md) for previous changes.
