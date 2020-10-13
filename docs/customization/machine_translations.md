# Using machine translations

For multilingual organizations, Decidim includes a way to integrate with amachine translation service. The aim of this integration is to provide machine translations for any user-generated content.

## Flow description

Every time a user creates or updates a translatable resource (that is, an instance of a resource that implements the `Decidim::TranslatableResource` concern), this workflow is triggered:

- A background job starts for the resource. This background job lists the fields that have been changed, and checks if any of the fields is considered translatable.
- For each translatable field that is changed, it lists the locales that need to be translated.
- For each combination field/locale a new job is fired.
- This job calls the machine translation service, which will handle how to translate that given text.

This workflow will only start if the machine translation service is configured in the installation, and the organization has the service enabled.

## Enabling the integration, installation-wise

This is an option in the Decidim initializer:

```ruby
config.enable_machine_translations = true
config.machine_translation_service = "MyApp::MyOwnTranslationService"
```

The class will need to be implemented, or reuse one from the community. Check the docs on how to implement a machine translation service.

## Enabling the integration, organization-wise

Each organization will be able to enable/disable machine translations if they want to. They can do that from the organization configuration.

