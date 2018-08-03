# frozen_string_literal: true

require "decidim/metric_entity"

namespace :decidim do
  namespace :metrics do
    # ProposalsMetric ------
    #
    # Execute ProposalsMetric's calculation method for today or a given date
    task :proposals_metric, [:day] => :environment do |_task, args|
      metric = Decidim::Proposals::Metrics::ProposalsMetricManage.for(args.day)
      next unless metric.valid?
      Decidim::Organization.find_each do |organization|
        metric.clean
        metric.with_context(organization)
        metric.query
        metric.registry!
      end
    end

    # AcceptedProposalsMetric ------
    #
    # Execute AcceptedProposalsMetric's calculation method for today or a given date
    task :accepted_proposals_metric, [:day] => :environment do |_task, args|
      metric = Decidim::Proposals::Metrics::AcceptedProposalsMetricManage.for(args.day)
      next unless metric.valid?
      Decidim::Organization.find_each do |organization|
        metric.clean
        metric.with_context(organization)
        metric.query
        metric.registry!
      end
    end

    # VotesMetric ------
    #
    # Execute VotesMetric's calculation method for today or a given date
    task :votes_metric, [:day] => :environment do |_task, args|
      metric = Decidim::Proposals::Metrics::VotesMetricManage.for(args.day)
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
