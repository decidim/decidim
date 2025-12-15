# Release Notes

## 1. Upgrade notes

NOTE: This is the draft for the releases notes. If you are an implementer or someone that is upgrading a Decidim installation, we recommend
checking out the last version of this document in the [GitHub page for the releases of this branch](https://github.com/decidim/decidim/releases/).

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

### 1.1. Update your ruby version

If you're using rbenv, this is done with the following commands:

```console
rbenv install 3.x.x
rbenv local 3.x.x
```

You may need to change your `.ruby-version` file too.

If not, you need to adapt it to your environment, for instance by changing the decidim docker image to use ruby:3.x.x.

### 1.2. Update your Gemfile

```ruby
gem "decidim", github: "decidim/decidim"
gem "decidim-dev", github: "decidim/decidim"
```

### 1.3. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
bin/rails decidim:upgrade:encryption
# skip this command if you have run it before:
bin/rails decidim:upgrade:clean:remove_private_exports_attachments
echo "/public/sw.js*" >> .gitignore
bin/rails decidim:upgrade:remove_deleted_users_left_data
bin/rails decidim:upgrade:fix_deleted_private_follows
bin/rails data:migrate
```

### 1.4. AWS/Azure/Google Cloud assets storage

There is a bug related to the cache expiration using Active Storage (assets, such as images). For fixing this issue, the Rails team added an extra active storage parameter, `public: true` that you can add it to your storage configuration. If you followed the step `3.4. Deprecation of Rails.application.secrets` and changed your `config/storage.yml` file you don't need to do anything else.

This will also change the URL that is used, so you will need to update your [Content Security Policy](https://docs.decidim.org/en/develop/customize/content_security_policy.html), adding the new URL in the policies "default-src", "img-src", "media-src", and "connect-src". For instance, in the case of S3 with AWS, the format of the URL is the following:  `https://BUCKET-NAME.s3.amazonaws.com/ASSET_ID`.

Apart of that, you also need to configure your preferred cloud service provider to support this. We recommend you to follow the Rails official guide for [Active Storage configuration](https://guides.rubyonrails.org/v7.0/active_storage_overview.html#setup).

You can read more about this change on PR [#15005](https://github.com/decidim/decidim/pull/15005/).

### 1.5. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Module deprecations

As part of our ongoing efforts to improve and make simpler Decidim, the following modules will be **deprecated** in this version (v0.31) and **removed** in the next major version (v0.32):

#### Collaborative Drafts

The Collaborative Drafts feature in the Proposals module (`decidim-proposals`) will be removed in v0.32. Organizations using this feature can switch to the new proposal co-authorship feature.

#### Sortitions (decidim-sortitions)

The Sortitions module (`decidim-sortitions`) is removed in v0.32. This module provided functionality to randomly select participants or proposals. Organizations relying on this feature should consider implementing alternative selection mechanisms.

#### Polls in Meetings (decidim-meetings polls functionality)

The Polls feature within the Meetings module (`decidim-meetings`) will be removed in a future version (to be determined). This feature allowed meeting organizers to create polls during meetings. Organizations using meeting polls should plan to use external polling tools (for instance, through Jitsi) or migrate to other voting mechanisms available in Decidim, such as the new Elections module (`decidim-elections`).

### 2.2. Old private exports are now expired

Due to some data consistency issues with the private exports, we have decided to expire all the previously generated files. Users are able to request and receive a new private export file.

if you are upgrading from a lover version like 0.30, and you have already ran this command, you can skip this step.

Run the following command to expire all the private exports:

```console
bin/rails decidim:upgrade:clean:remove_private_exports_attachments
```

You can read more about this change on PR [#15020](https://github.com/decidim/decidim/pull/15020).

### 2.3. Add data migrations

At the moment we are adding this gem so we can start doing data migrations for fixes when v0.33.0 is released. You can read more about this at [Data migrations doc](https://docs.decidim.org/en/develop/develop/guide_data_migrations.html).

You can read more about this change on PR [#15501](https://github.com/decidim/decidim/pull/15501).

#### 2.4. Fix gitignore for ServiceWorker related files

We detected a bug where some dynamic files are not added to the gitignore, so they could be committed to the repository. For fixing it, you need to add them to your gitignore file:

```bash
echo "/public/sw.js*" >> .gitignore
```

You can read more about this change on PR [#15601](https://github.com/decidim/decidim/pull/15601).

### 2.5. Add locale to the url

For a long time Decidim has been using internally the user browser to detect the language of the user. This has been changed to use the locale of the url instead.

This improves the user experience by allowing the platform to send emails with the correct language, linking any resource to the correct language preferred by the user.

It also enables the users of multi language platforms to share the links to the resources within their own language.

```text
    /en/processes/here-slug/f/57/elections/5 # if seen in english
    /ca/processes/here-slug/f/57/elections/5 # if seen in catalan
```

You can read more about this change on PR [#14432](https://github.com/decidim/decidim/pull/14432).

### 2.6. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. Fix incorrect ActionLog entries

The action of hiding a component from a menu was being stored as a public action. These can lead to crashing the application if some related participatory space is removed.

In order to correct the existing entries you should run the following rake task:

```bash
bin/rails decidim:upgrade:fix_action_log
```

You can read more about this change on PR [#15390](https://github.com/decidim/decidim/pull/15390).

### 3.2. Remove user data left behind by `Decidim::DestroyAccount`

When a user deletes their account and the `Decidim::DestroyAccount` command is executed, certain related data such as authorizations, versions, private exports, access grants, access tokens, notifications, and reminders were left behind. To fix this issue, we've added a new rake task to clean up the leftover data for previously deleted users.

```ruby
bin/rails decidim:upgrade:remove_deleted_users_left_data
```

You can read more about this change on PR [#14731](https://github.com/decidim/decidim/pull/14731).

### 3.3. Remove the follows of former private users

To delete the follows of ex private users of non transparent assemblies or processes, run

```console
bin/rails decidim:upgrade:fix_deleted_private_follows
```

You can read more about this change on PR [#12878](https://github.com/decidim/decidim/pull/12878).

### 3.4. webpack-dev-server upgrade

Back in [#15534](https://github.com/decidim/decidim/pull/15534) we upgraded webpack-dev-server to version 5.2.2. In order to successfully upgrade you need to edit your `config/shakapacker.yml` and remove the `https` option under `dev_server` key.

You can read more about this change on PR [#15534](https://github.com/decidim/decidim/pull/15534), [#15674](https://github.com/decidim/decidim/pull/15674).

### 3.5. [[TITLE OF THE ACTION]]

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples
with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

### 4.1. [[TITLE OF THE TASK]]

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rails decidim:TASK
```

You can read more about this change on PR [#XXXX](https://github.com/decidim/decidim/pull/XXXX).

## 5. Changes in APIs

### 5.1. Encryption mechanism changes

As we have upgraded Rails from 7.0 we have improved the security of the application by upgrading the encryption mechanism from SHA1 to SHA256.

All the previously encrypted attributes can be decoded, but on the next record change, the new data will be saved as SHA256. To manually upgrade authorization data, or the initiative votes metadata, you will need to run the below task.

```bash
bin/rails decidim:upgrade:encryption
```

If you need to update any data generated by a 3rd party module, you could create a rake task like the one below:

```ruby
# frozen_string_literal: true

namespace :myapp do
  namespace :upgrade do
    task encryption: :environment do
      Decidim::Namespace::Model.find_each do |instance|
        decrypted = Decidim::AttributeEncryptor.decrypt(instance.encrypted_attribute)

        instance.encrypted_attribute = Decidim::AttributeEncryptor.encrypt(decrypted)
        instance.save!
      end
    end
  end
end

Rake::Task["decidim:upgrade:encryption"].enhance do
  Rake::Task["myapp:upgrade:encryption"].invoke
end

```

You can read more about this change on PR [#14800](https://github.com/decidim/decidim/pull/14800).

### 5.2. [[TITLE OF THE CHANGE]]

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
