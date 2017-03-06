# Decidim::System

This engine adds an administration dashboard so admin can manage a Decidim deploy
and its organizations when working in a multi-tenant environment.

## Usage

`decidim-system` is already included in the `decidim` gem, but you can also include it separately:

Add this line to your application's Gemfile:

```ruby
gem 'decidim-system'
```

And then execute:
```bash
$ bundle
```

## Multi-tenancy in Decidim

A single Decidim deploy can be used by multiple organizations (tenants) at the same time. All resources and entities are always scoped to an organization.

When using Decidim as multi-tenant, you should keep these in mind:

* All organizations share the same database.
* Each organization must have a different hostname.
* Users aren't shared between each organization (the same email can be registered in different organizations and it will be considered as different users).
* All configuration related to Decidim (`Decidim.config`) is shared between the organizations.
* Stylesheets aren't customizable per-tenant so UI styles (colors and other variables) are shared.

## Glossary

* **Organization**: Each of the tenants using a Decidim deploy.
* **System admin**: Users that can manage organizations in a Decidim deploy.
* **Admins**: Users that can manage a **single** organization in a Decidim deploy.
* **Participatory process admins**: Users that can manage a **single participatory process** in an organization in a Decidim deploy.

## Managing System admins

Currently Decidim doesn't provide a way to create the first System Admin in a new deployment. To do it, you should open a Rails console in your application and
create it:

```ruby
Decidim::System::Admin.create!(
  email: "your-email@example.org",
  password: "your-safe-password",
  password_confirmation: "your-safe-password"
)
```

Once you have created your first admin you can access the system dashboard at `https://your-decidim-deployment-host/system` and login with your newly created user.
From the system dashboard you can add new admins.

## Managing organizations

Once you have your system admin setup you can also start managing the organizations in your deploy. To do it, login at the system dashboard and create a new organization
following the form instructions. After creating it, a new admin user will be created and invited to start managing it.

Remember that System admins and regular Admins are completely different users (they don't even share the same database table), so you can't use your
system user to login in as an organization admin.

## License
The gem is available as open source under the terms of the [AGPLv3 License](https://opensource.org/licenses/AGPL-3.0).
