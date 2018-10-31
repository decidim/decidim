# frozen_string_literal: true

namespace :decidim do
  namespace :metrics do
    # All ------
    #
    # Get all metrics entities and execute his own rake task.
    # It admits a date-string parameter, in a 'YYYY-MM-DD' format from
    # today to all past dates
    desc "Execute all metrics calculation methods"
    task :all, [:day] => :environment do |_task, args|
      Decidim::Organization.find_each do |organization|
        Decidim.metrics_registry.all.each do |metric_manifest|
          call_metric_job(metric_manifest, organization, args.day)
        end
      end
    end

    # One ------
    #
    # Execute metric calculations for just one metric
    # It need a metric name and permits a date-string parameter, in a 'YYYY-MM-DD' format from
    # today to all past dates
    desc "Execute one metric calculation method"
    task :one, [:metric, :day] => :environment do |_task, args|
      next if args.metric.blank?
      Decidim::Organization.find_each do |organization|
        metric_manifest = Decidim.metrics_registry.for(args.metric)
        call_metric_job(metric_manifest, organization, args.day)
      end
    end

    def call_metric_job(metric_manifest, organization, day = nil)
      Decidim::MetricJob.perform_later(
        metric_manifest.manager_class,
        organization.id,
        day
      )
    end
  end
end
