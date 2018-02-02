# Activity log

In order to make your component compatible with the activity log, you need to follow these steps:

1. Make your model include the `Decidim::Traceable` module. This will enable Decidim to create versions every time your model records are changed. It uses [`paper_trail`](https://github.com/airblade/paper_trail) to generate the versions.
2. Make your commands use `Decidim.traceability` to create and update records. Documentation can be found in `Decidim::Traceability`. This should properly set the author of the change in your record.
3. Create a `Presenter` for your model for the log you need. Presenters should be named as `Decidim::<your module name>::<log name>::<your model name>Presenter`. There's currently only one log, `AdminLog`. This means that if your model is `Decidim::Accountability::Result`, then your admin log presenter is must be `Decidim::Accountability::AdminLog::ResultPresenter`

## Multiple logs
Alhotugh Decidim currently only has a log for the admin section, in the future we might need an activity log for the public part. It's easy to assume we might need to render the same data in different formats, so we need to differentiate the presenters for each log. The current system handles the case for multiple logs, although we only have one.