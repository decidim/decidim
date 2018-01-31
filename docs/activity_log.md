# Activity log

In order to make your component compatible with the activity log, you need to follow these steps:

1. Make your model include the `Decidim::Traceable` module. This will enable Decidim to create versions every time your model records are changed. It uses [`paper_trail`](https://github.com/airblade/paper_trail) to generate the versions.
2. Make your commands use `Decidim.traceability` to create and update records. Documentation can be found in `Decidim::Traceability`. This should properly set the author of the change in your record.
3. Create a `LogPresenter` for your model. To be improved.