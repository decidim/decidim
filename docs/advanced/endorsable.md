# Endorsable

## Things can be endorsable

`Endorsable` is a feature to allow participants to promote (reivindicate, etc.) resources in the platform to their followers.

When endorsing an element the endorsements counter for this element is increased and a notification to all the followers of the participant is sent.

Participants can endorse with their own identity or with the identify of the `user_groups` they belong to. Each endorsing identity on its own will increment the endorsements counter by one.

## Data model

A `decidim_endorsements` table registers each endorsement that each identity gives to each element. This is, one endorsable has many endorsements, and each endorsement belongs to one endorsable.
For performance, an endorsable has a counter cache of endorsements.

```ascii
+----------------------+
|  Decidim::Endorsable |
|   ((Proposal,...))   |                                   +-------------+
+----------------------+  0..N +--------------------+   +--+Decidim::User|
|-has_many endorsements|-------+Decidim::Endorsement|   |  +-------------+
|#counter cahce column |       +--------------------+   |
|-endorsements_counter |       |-author: may be a   |<--+
+----------------------+       |         user or a  |   |
                               |         user_group |   |  +------------------+
                               +--------------------+   +--+Decidim::UserGroup|
                                                           +------------------+
```

Thus, each endorsable must have the endorsements counter cache column.
This is an example migration to add the endorsements counter cache column to a resource:

```ruby
class AddEndorsementsCounterCacheToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :endorsements_count, :integer, null: false, default: 0
  end
end

```

## Administration Panel

It is a good practice to give the opportunity to the admin to switch Endorsements on and off.

There are two switches that are normally defined in the manifest of the element in the following way (usually this would be at component.rb in a Decidim engine):

```ruby
    settings.attribute :endorsements_enabled, type: :boolean, default: true
    settings.attribute :endorsements_blocked, type: :boolean
```

- `endorsements_enabled`: when enabled endorsement functionality appears in the public views, when disabled, this functionality is hidden.
- `endorsements_blocked`: when blocked, the counter of endorsements is visible but no more endorsements can be added or withdrawn, the button is hidden.

## Permissions

In some cases, it may be interesting to require the user to be verified in order to be able to endorse. To do so, add the endorse action to the component manifest:

```ruby
  component.actions = %w(endorse vote create withdraw amend)
```

Given that some settings have been defined in the Administration Panel, for the user to have permissions to endorse endorsements should be enabled and not blocked.

## Public view

### The "Endorse" buttons cell

It normally appears in the resource detail view (show). At the action card, in right-side of the view.
It allows users to endorse with any of their identities, the personal one, and/or their user_groups', if any.
It also shows the current number of endorsements for this resource.

To render this button, `decidim-core` offers the `decidim/endorsement_buttons` cell. It is strongly recommended to use this cell to make new resources endorsable.

```ruby
cell("decidim/endorsement_buttons", resource)
```

This cell, renders the endorsements counter and the endorsement button by default. But it has the possibility to be invoked to render elements sepparately.

```ruby
# By default the `show` method is invoked as usual
# Renders `render_endorsements_count` and `render_endorsements_button` in a block.
cell("decidim/endorsement_buttons", resource)
# It is recommended to use the `endorsement_buttons_cell` helper method
endorsement_buttons_cell(resource)

# Renders the "Endorse" button
# It takes into account:
# - if endorsements are enabled
# - if users are logged in
# - if users can endorse with many identities (of their user_groups)
# - if users require verification
endorsement_buttons_cell(resource).render_endorsements_button

# Renders the counter of endorsements that appears in card.
endorsement_buttons_cell(resource).render_endorsements_count

# Renders a button to perform the endorse action, but only with the personal identity of the user. It does not take into account if the user belongs to any user group.
endorsement_buttons_cell(resource).render_user_identity_endorse_button
```

### The list of endorsers

The `Decidim::EndorsersListCell` renders the list of endorsers of a resource. It is usually rendered in the show of the resource, just upside the comments.

```ruby
# to render the list of endorsers, the cell requires the endorsable resource, and the current user
cell "decidim/endorsers_list", resource
# or using the helper
endorsers_list_cell(resource)
```