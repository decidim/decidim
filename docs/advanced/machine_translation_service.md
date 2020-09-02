# Create your own machine translation service

You can use the `Decidim::Dev::DummyTranslator` service as a base. Any new translator service will need to implement the same API as this class.

## Integrating with async services

Some translation services are async, which means that some extra work is needed. This is the main overview:

- The Translation service will only send the translation request. It should have a way to send what resource, field and target locale are related to that translation.
- You'll need to create a custom controller in your application to receive the callback from the translation service when the translation is finished
- From that new endpoint, find a way to find the related resource, field and target locale. Then start a `Decidim::MachineTranslationSaveJob` with that data. This job will handle how to save the data in the DB.

