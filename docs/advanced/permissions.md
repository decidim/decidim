# Permissions

Since Decidim has multiple roles, we needed a permissions system to discover what actions can a user perform, given their roles. The basis of the current permissions system were added on [\#3029](https://github.com/decidim/decidim/pull/3029), so be sure to check that PR (and the related ones) to read the discussion and the motivations behind the change.

## Overview

When checking for permission to perform an action, we check this chain:

1. The component permissions
1. The participatory space permissions
1. The core permissions

This way we're going from more specific to more general.

## Explanation

We wrap the permission and its context in a `PermissionsAction` object. It also holds the state of the permission (whether it's been allowed or not).

Each component and space must define a `Permissions` class, inheriting from `Decidim::DefaultPermissions`. The `Permissions` class must define a `permissions` instance method. this class will receive the permission action, and the `permissions` method must return the permission action. The `Permissions` class can set the action as allowed or disallowed.

There's a small limitation in the permission action state machine: once it's been disallowed it can't be reallowed. This is to avoid mischievous modules modifying permissions.

Permission actions have a scope. It's usually either `:public` or `:admin`, and the `Permissions` class usually handles the `:public` scope, while it delegates the `:admin` one to another specialized class.
