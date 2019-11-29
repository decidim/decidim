# Endorsable

## Things can be endorsable

`Endorsable` is a feature to allow participants to promote elements in the platform.

When endorsing an element the endorsements counter for this element is increased and a notification to all the followers of the participant is sent.

A participant can endorse with her own identity or with the identify of the `user_groups` she belongs to. Each endorsing identity will increment the endorsements counter by its own.

## Data model

A `decidim_endorsements` table that registers each endorsement that each identity gives to each element. This is, one endorsable has many endorsements, and each endorsement belongs to on endorsable.
For performance, an endorsable has a counter cache of endorsements.

## Administration Panel

It is a good practice to give the opportunity to the admin to switch on and off Endorsements.

There are two switches that are normally defined in the manifest of the element in the following way:

```
    settings.attribute :endorsements_enabled, type: :boolean, default: true
    settings.attribute :endorsements_blocked, type: :boolean
```

- `endorsements_enabled`: when enabled endorsement functionality appears in the public views, when disabled, this functionality is hidden.
- `endorsements_blocked`: when blocked, the counter of endorsements is visible but no more endorsements can be added or withdrawn, the button is hidden.


## Permissions

In some cases, it may be interesting to require the user to be verified in order to be able to endorse. To do so, add the endorse action to the component manifest:
```
  component.actions = %w(endorse vote create withdraw amend)
```


Given that some settings have been defined in the Administration Panel, the most common will be to define some permissions to check if the user can or can not endorse.


```
    def can_endorse?(resource)
      is_allowed = resource &&
                   authorized?(:endorse, resource: resource) &&
                   current_settings&.endorsements_enabled? &&
                   !current_settings&.endorsements_blocked?

      toggle_allow(is_allowed)
    end

    def can_unendorse?(resource)
      is_allowed = proposal &&
                   authorized?(:endorse, resource: proposal) &&
                   current_settings&.endorsements_enabled?

      toggle_allow(is_allowed)
    end
```

There is already a concern with this two methods: `Decidim::WithEndorsablePermissions`.



## Public view

### The "Endorse" button in the right-side action card
### The endorsements count cell
### The list of endorsers
