# Release Notes

## 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.2. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
```

### 1.3. Follow the steps and commands detailed in these notes

## 2. General notes

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. [[TITLE OF THE ACTION]]

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
 with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. [[TITLE OF THE TASK]]

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rails decidim:TASK
```

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 5. Changes in APIs

### 5.1. [[TITLE OF THE CHANGE]]

In order to [[REASONING (e.g. improve the maintenance of the code base)]] we have changed...

If you have used code as such:

```ruby
# Explain the usage of the API as it was in the previous version
result = 1 + 1 if before
```

You need to change it to:

```ruby
# Explain the usage of the API as it is in the new version
result = 1 + 1 if after
```

### 5.8 Migration of Proposal states in own table

As of [\#12052](https://github.com/decidim/decidim/pull/12052) all the proposals states are kept in a separate database table, enabling end users to customize the states of the proposals. By default we will create for any proposal component that is being installed in the project 5 default states that cannot be disabled nor deleted. These states are:

- Not Answered ( default state for any new created proposal )
- Evaluating
- Accepted
- Rejected
- Withdrawn ( special states for proposals that have been withdrawn by the author )

For any of the above states you can customize the name, description, css class used by labels. You can also decide which states the user can receive a notification or an answer.

You do not need to run any task to migrate the existing states, as we will automatically migrate the existing states to the new table.

You can see more details about this change on PR [\#12052](https://github.com/decidim/decidim/pull/12052)
