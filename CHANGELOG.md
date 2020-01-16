# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Endorsements**

This new version of Decidim has extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements should be copied into the new `Decidim::Endorsable` tables and counter cache columns. This must be done after executing the migrations.

```ruby
# copy endorsements from `decidim_proposals_proposal_endorsements` into `decidim_endorsements`
class ProposalEndorsement < ApplicationRecord
  self.table_name = :decidim_proposals_proposal_endorsements
end
non_duplicated_group_endorsements = ProposalEndorsement.select(
     "MIN(id) as id, decidim_user_group_id"
).group(:decidim_user_group_id).where.not(decidim_user_group_id: nil)

ProposalEndorsement.where("id IN (?) OR decidim_user_group_id IS NULL", non_duplicated_group_endorsements.map(&:id)).find_each do |prop_endorsement|
  ::Decidim::Endorsement.create!(
    resource_type: Decidim::Proposals::Proposal.class.name,
    resource_id: prop_endorsement.decidim_proposal_id,
    decidim_author_type: prop_endorsement.decidim_author_type,
    decidim_author_id: prop_endorsement.decidim_author_id,
    decidim_user_group_id: prop_endorsement.decidim_user_group_id)
end
# update new `decidim_proposals_proposal.endorsements_count` counter cache
Decidim::Proposals::Proposal.all.pluck(:id).find_each do |id|
  Decidim::Proposals::Proposal.reset_counters(id, :endorsements)
end
```

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` can be removed.

```sql
-- remove legacy `decidim_proposals_proposal_endorsements` table
DROP TABLE IF EXISTS decidim_proposals_proposal_endorsements RESTRICT;
-- remove legacy column `decidim_proposals_proposal.proposal_endorsements_count`
ALTER TABLE decidim_proposals_proposal DROP COLUMN proposal_endorsements;
```

- **Assembly types**

In order to prevent errors while upgrading multi-servers envirnoments, the fields `assembly_type` and `assembly_type_other` are maintained. Future releases will take care of this.

- **Organization Time Zones**

Now is its possible to configure every organization (tenant) with a different time zone by any admin in the global configuration. We recommend to not define any specific `config.time_zone` in Rails so it uses UTC internally. In any case Rails configuration will be ignored in the context of the controller (users will be using always organization's configured time zone).

To upgrade it is recommended to configured the proper time zone in the admin for the organization and remove any `config.time_zone` personalization in Rails (unless you know what you are doing).

For those who have not changed the Rails `config.time_zone` (thus using UTC globally) but using dates as if they were non-UTC zones might notice that changing the organization time zone will shift all presented dates accordingly. This might require to re-edit any scheduled date in meetings or debates in order be properly displayed.

- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

**Added**:

- **decidim-admin** Add terms of use for admin. [#5507](https://github.com/decidim/decidim/pull/5507)
- **decidim-assemblies**: Added configurable assembly types. [\#5616](https://github.com/decidim/decidim/pull/5616)
- **decidim-core**: Added configurable time zones for every tenant (organization). [\#5607](https://github.com/decidim/decidim/pull/5607)
- **decidim-admin**: Display the number of participants subscribed to a newsletter. [\#5555](https://github.com/decidim/decidim/pull/5555)
- **decidim-accountability**, **decidim-admin**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-generators**, **decidim-meetings**, **decidim-proposals**, **decidim_app-design**: Change: Extend the capabilities of the Quill text editor. [\#5488](https://github.com/decidim/decidim/pull/5488)
- **decidim-core**: Add docs in how to fix metrics problems. [\#5587](https://github.com/decidim/decidim/pull/5587)
- **decidim-core**: Data portability now supports AWS S3 storage. [\#5342](https://github.com/decidim/decidim/pull/5342)

**Changed**:

- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Extract proposa'ls endorsements into a polymorphic concern that can now be applied no any resource. It has been aplied to blog posts. [#5542](https://github.com/decidim/decidim/pull/5542)
- **decidim-participatory_processes**, **decidim-conferences**, **decidim-assemblies**, **decidim-initiatives**: Use cardM cell in space embed [#5589](https://github.com/decidim/decidim/pull/5589)

**Fixed**:

- **decidim-verifications**: Fix: Missing method email_regexp [#5560](https://github.com/decidim/decidim/pull/5560)
- **decidim-core**: Fix: use incrementing date when rebuilding since one date. [\#5541](https://github.com/decidim/decidim/pull/5541)

**Removed**:

## Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.20-stable/CHANGELOG.md) for previous changes.
