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
```

### 1.4. AWS/Azure/Google Cloud assets storage

As of this upgrade, you can avoid the asset caching issue due to the authentication token that expires. The rails team added an extra active storage parameter, `public: true` that you can add it to your s3 configuration in your storage.yml

```yaml
s3:
  service: S3
  public: <%= Decidim::Env.new("AWS_PUBLIC", "false").to_boolean_string %>
  access_key_id: <%= Decidim::Env.new("AWS_ACCESS_KEY_ID").to_s %>
  secret_access_key: <%= Decidim::Env.new("AWS_SECRET_ACCESS_KEY").to_s %>
  bucket: <%= Decidim::Env.new("AWS_BUCKET").to_s %>
  <%= "region: #{Decidim::Env.new("AWS_REGION").to_s}" if Decidim::Env.new("AWS_REGION").present? %>
  <%= "endpoint: #{ Decidim::Env.new("AWS_ENDPOINT").to_s}" if Decidim::Env.new("AWS_ENDPOINT").present? %>
```

The parameter will actually strip from any asset url the `X-Amz-Credential` parameter, leaving the asset storage url like: `https://BUCKET-NAME.s3.amazonaws.com/ASSET_ID`, making it easier to cache.

To achieve that, the Content Security Policy (found in [system panel](https://docs.decidim.org/en/develop/configure/system)) comes to your aid. Populate (or append to) the following fields with the bucket url (ex: <https://decidim-bucket.s3.amazonaws.com/>): `Default src`, `Img src`, `Media src` and `Connect src`.

Apart of that, you also need to configure your preferred cloud service provider to support this. We recommend you to follow the Rails official guide for [Active Storage configuration](https://guides.rubyonrails.org/v7.0/active_storage_overview.html#setup).

### 1.5. Follow the steps and commands detailed in these notes

## 2. General notes

### 2.1. Module deprecations

As part of our ongoing efforts to improve and make simpler Decidim, the following modules will be **deprecated** in this version (v0.31) and **removed** in the next major version (v0.32):

#### Collaborative Drafts

The Collaborative Drafts feature in the Proposals module (`decidim-proposals`) will be removed in v0.32. Organizations using this feature can switch to the new proposal co-authorship feature.

#### Sortitions (decidim-sortitions)

The Sortitions module (`decidim-sortitions`) will be removed in v0.32. This module provided functionality to randomly select participants or proposals. Organizations relying on this feature should consider implementing alternative selection mechanisms.

#### Polls in Meetings (decidim-meetings polls functionality)

The Polls feature within the Meetings module (`decidim-meetings`) will be removed in a future version (to be determined). This feature allowed meeting organizers to create polls during meetings. Organizations using meeting polls should plan to use external polling tools (for instance, through Jitsi) or migrate to other voting mechanisms available in Decidim, such as the new Elections module (`decidim-elections`).

## 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

### 3.1. [[TITLE OF THE ACTION]]

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
