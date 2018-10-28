# How to add a new authorizable action?

## Proposals example

We're going to reproduce the steps to add an action (endorse) for a proposal step by step.

### Configuring a new 'endorse' action

1. Edit decidim-proposals/lib/decidim/proposals/component.rb
1. Add the new 'endorse' action into the `component.actions` array and save the file:

```ruby
component.actions = %w(endorse vote create)
```

1. Translate the action for the corresponding key: `en.decidim.components.proposals.actions.endorse = Endorse`
1. Edit `app/permissions/decidim/proposals/permissions.rb` and add the corresponding permission, using `authorized?` method to run the `authorization handler` logic.
1. In the endorse proposals controller, enforce that the user has permissions to perform the `endorse` action before actually doing it, using the `enforce_permission_to` method:

```ruby
enforce_permission_to :endorse, :proposal, proposal: proposal
```

1. In the proposals templates, change regular links and buttons to endorse a proposal with calls to `action_authorized_link_to` and `action_authorized_button_to` helpers.
1. Restart the server to pick up the changes.

### Using the new 'endorse' action

1. Now an admin user should be able to go to a participatory space with a `proposals` component panel and click on its `Permissions` link (the icon with a key). There, an `authorization handler` can be set for the `endorse` action.
1. Go to a Proposal detail in the front-end
1. Try to endorse the current proposal
  - If the user has not granted the selected permission, the 'endorse' button should block the action and allow the user to grant the permission with the selected `authorization handler` logic.
  - If the logger user has already granted the selected permission, the user should be able to perform the endorsement.

### Allow to configure the related permissions at resource level

Permissions settings could also be set for an specific resources appart from the full component. Actions should also be related to the resource.

1. Edit decidim-proposals/lib/decidim/proposals/component.rb
1. Add the 'endorse' action into the `resource.actions` array for the `proposal` resource definition and save the file:

```ruby
resource.actions = %w(endorse vote)
```

1. Only if this is the first resource action added, edit the proposals admin templates and use the `resource_permissions_link` helper to link the resource permissions page from each resource in the listing.

```erb
<%= resource_permissions_link(proposal) %>
```

1. In the proposals permission class, pass an extra `resource` named parameter to the calls to the `authorized?` method.

```ruby
authorized?(:endorse, resource: proposal)
```

1. In the proposals templates, also add the extra `resource` parameter to the `action_authorized_link_to` and `action_authorized_button_to` helpers.
1. Restart the server to pick up the changes.

### Using permissions at resource level

1. Now an admin user should be able to go to a participatory space with a `proposals` component panel and click on its `Permissions` link (the icon with a key). There, an `authorization handler` can be set for the `endorse` action.