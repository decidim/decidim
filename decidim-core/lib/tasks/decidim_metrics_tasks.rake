# frozen_string_literal: true

require "decidim/metric_entity"

namespace :decidim do
  namespace :metrics do
    # All ------
    #
    # Get all metrics entities and execute his own rake task.
    # It admits a date-string parameter, in a 'YYYY-MM-DD' format from
    # today to all past dates
    desc "Execute all metrics calculation methods"
    task :all, [:day] => :environment do |_task, args|
      Decidim::MetricEntity.metric_entities.each do |entity|
        puts " ------------ Executing #{entity} entity"
        Rake::Task["decidim:metrics:#{entity.underscore}"].invoke(args.day)
      end
    end

    # UsersMetric ------
    #
    # User's metric specific rake task
    desc "Execute UsersMetric's calculation method"
    task :users_metric, [:day] => :environment do |_task, args|
      metric = Decidim::Metrics::UsersMetricManage.for(args.day)
      next unless metric.valid?
      Decidim::Organization.find_each do |organization|
        metric.clean
        metric.with_context(organization)
        metric.query
        metric.registry!
      end
    end
  end
end
