# frozen_string_literal: true

require "decidim/metric_entity"

namespace :decidim do
  namespace :metrics do
    # All ------
    #
    # Execute all metrics calculation methods
    task :all, [:day] => :environment do |_task, args|
      # Rake::Task["decidim:metrics:users_metric"].invoke(args.day)
      Decidim::MetricEntity.metric_entities.each do |entity|
        puts " ------------ Executing #{entity} entity"
        Rake::Task["decidim:metrics:#{entity}"].invoke(args.day)
      end
    end

    # UsersMetric ------
    #
    # Execute UsersMetric's calculation method for today or a given date
    task :users_metric, [:day] => :environment do |_task, args|
      metric = Decidim::Metrics::UsersMetricManage.for(args.day)
      next unless metric.valid?
      Decidim::Organization.all.each do |organization|
        metric.clean
        metric.with_context(organization)
        metric.query
        metric.registry!
      end
    end
  end
end
