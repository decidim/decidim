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
