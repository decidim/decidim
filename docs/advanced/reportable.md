# Reportable

## Resources can be reportable

`Reportable` is a feature that allows Decidim resources to be reported by users.
A resource can be reported by a user as 'spam', 'offensive' or 'does_not_belong'.

When a resource is reported, a `Report` is created. All `Report`s of a resource are grouped in a `Moderation` and can be moderated by the admins.

A `Reportable` is expected to implement:
 - `reported_content_url`: the URL for the reportable resource;
 - `reported_attributes`: a list of attributes that can be reported (e.g. `[:title, :body]`) - used to display the report content by the `ReportedContentCell`;
 - `reported_searchable_content_extras` (optional): a list of attributes other than `reported_attributes` the report can be search by (e.g. `[author.name]`) - used in the reports search bar of the admin panel.

## Public view

### The ReportedContentCell

The reccomended way to render the content of a `Reportable` is with a `decidim/reported_content` cell.

To render this button, `decidim-core` offers the `decidim/reported_content` cell. It is strongly recommended to use this cell to make new resources endorsable.

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