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
bundle
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

For logging in to this dashboard, you'll need to create a system admin account from your terminal:

```bash
bin/rails decidim_system:create_admin
```

You'll be asked for an email and a password. For security, the password will not get displayed back at you and you'll need to confirm it.

Once you have created your first admin you can access the system dashboard at `/system`. For instance, if you have Decidim running at `https://example.org`, this URL would be `https://example.org/system`.
You'll be able to login with your newly created user.

From the system dashboard you can add new admins.

⚠️ If you need to reset your administrator password you'll need to do it by entering the Rails console and changing it manually. ⚠️

. Open the rails console:

```bash
bin/rails console
```

. Run the following instructions, changing them accordingly:

```ruby
system_admin = Decidim::System::Admin.order(:id).first                        # for the first system admin
system_admin = Decidim::System::Admin.find_by_email "system@example.org"      # if you already know the email
system_admin.password = "decidim123456789"                                    # change for something secure
system_admin.password_confirmation = "decidim123456789"
system_admin.save
```

## Managing organizations

Once you have your system admin setup you can also start managing the organizations in your deploy. To do it, login at the system dashboard and create a new organization
following the form instructions. After creating it, a new admin user will be created and invited to start managing it.

Remember that System admins and regular Admins are completely different users (they don't even share the same database table), so you can't use your
system user to login in as an organization admin.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
