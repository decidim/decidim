# How to add a new authenticable action?

## Proposals example

We're going to reproduce the steps to add an action (adhere) for a proposal step by step.

### Configuring a new 'adhere' action

1. Edit decidim-proposals/lib/decidim/proposals/component.rb
1. Add the new 'adhere' action into the `component.actions` array and save the file:

```ruby
component.actions = %w(adhere vote create)
```

1. Translate the action for the corresponding key: `en.decidim.components.proposals.actions.adhere = Adhere`
1. Edit `app/permissions/decidim/proposals/permissions.rb` and add the corresponding permission.
1. Restart the server to pick up the changes.
1. Now the admin should be able to go to the Control Panel and edit `PROCESSES/Proposals/Permissions/Adhere` panel. There an `Authorization Handler` can be set.

### Using the new 'adhere' action

With a user which has the selected permission verified:

1. Go to a Proposal detail in the front-end
1. Adhere to the current proposal (see ProposalAdhesionsController): the user should be able to perform an adhesion.
    - If the user had the required permission unverified, the 'adhere' button should block the action. You can check it with an unverified user.
