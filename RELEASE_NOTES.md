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

### 3.1. CarrierWave removal

Back in Decidim 0.25 we have added ActiveStorage (via [\#7902](https://github.com/decidim/decidim/pull/7902)) as main uploader instead of CarrierWave.

We've left some code to ease-up with the migration process during these last versions.

In your application, you need to remove the initializer:

```console
rm config/initializers/carrierwave.rb
```

You can read more about this change on PR [\#12200](https://github.com/decidim/decidim/pull/12200).

### 3.2. Verifications documents configurations

Until now we have hard-coded the document types for verifications with types from Spain legislation ("DNI, NIE and passport"). We have change it to "Identification number and passport", and allow installations to adapt them to their own needs.

If you want to go back to the old setting, you need to follow these steps:

1. Add to your config/secrets.yml the `decidim.verifications.document_types` key:
```erb
decidim_default: &decidim_default
  application_name: <%%= Decidim::Env.new("DECIDIM_APPLICATION_NAME", "My Application Name").to_json %>
  (...)
  verifications:
    document_types: <%%= Decidim::Env.new("VERIFICATIONS_DOCUMENT_TYPES", %w(identification_number passport)).to_array.to_json %>
```
2. Add to your `config/initializers/decidim.rb` the following snippet in the bottom of the file:
```ruby
if Decidim.module_installed? :verifications
  Decidim::Verifications.configure do |config|
    config.document_types = Rails.application.secrets.dig(:decidim, :verifications, :document_types).presence || %w(identification_number passport)
  end
end
```
3. Add the values that you want to define using the environmnet variable `VERIFICATIONS_DOCUMENT_TYPES`.
```env
VERIFICATIONS_DOCUMENT_TYPES="dni,nie,passport"
```
4. Add the translation of these values to your i18n files (i.e. `config/locales/en.yml`).
```yaml
en:
  decidim:
    verifications:
        id_documents:
          dni: DNI
          nie: NIE
          passport: Passport
```

You can read more about this change on PR [\#XXXX](https://github.com/decidim/decidim/pull/12306)
### 3.3. [[TITLE OF THE ACTION]]

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

### 5.1.1 Identification numbers

For the verification of the participants' data in Verifications, you can configure which type of documents a participant can have. By default these documents are `identification_number` and `passport`, but in some countries you may need to adapt these to your region or governmental specific needs. For instance, in Spain there are `dni`, `nie` and `passport`.

For configuring these you can do so with the Environment Variable `VERIFICATIONS_DOCUMENT_TYPES`.

```env
VERIFICATIONS_DOCUMENT_TYPES="dni,nie,passport"
```

You need to also add the following keys in your i18n files (i.e. `config/locales/en.yml`). By default in the verifications, `indentification_number` is currently being used as a universal example. Below are examples of adding `dni`, `nie` and `passport` locally used in Spain.

```yaml
en:
  decidim:
    verifications:
        id_documents:
          dni: DNI
          nie: NIE
          passport: Passport
```

You can read more about this change on PR [\#12306](https://github.com/decidim/decidim/pull/12306).

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
