# frozen_string_literal: true

require "spec_helper"
require "support/tasks"

describe "Executing Decidim Metrics tasks" do
  describe "rake decidim:metrics:all", type: :task do
    let!(:organizations) { create_list(:organization, 2) }

    after do
      clear_enqueued_jobs
    end

    context "when executing task" do
      it "have to be executed without failures" do
        Rake::Task[:"decidim:metrics:all"].reenable
        expect { Rake::Task[:"decidim:metrics:all"].invoke }.not_to raise_error
      end

      it "creates jobs for each organization" do
        Rake::Task[:"decidim:metrics:all"].reenable
        expect { Rake::Task[:"decidim:metrics:all"].invoke }.to have_enqueued_job(Decidim::MetricJob).at_least(Decidim.metrics_registry.all.size * Decidim::Organization.count).times
      end
    end
  end

  describe "rake decidim:metrics:one", type: :task do
    let!(:organizations) { create_list(:organization, 2) }

    context "when executing task" do
      after do
        clear_enqueued_jobs
      end

      it "have to be executed without failures" do
        Rake::Task[:"decidim:metrics:one"].reenable
        expect { Rake::Task[:"decidim:metrics:one"].invoke(Decidim.metrics_registry.all.first.metric_name) }.not_to raise_error
      end

      it "creates jobs for each organization" do
        Rake::Task[:"decidim:metrics:one"].reenable
        expect { Rake::Task[:"decidim:metrics:one"].invoke(Decidim.metrics_registry.all.first.metric_name) }.to have_enqueued_job(Decidim::MetricJob).at_least(Decidim::Organization.count).times
      end

      it "does nos create jobs if no name given" do
        Rake::Task[:"decidim:metrics:one"].reenable
        expect { Rake::Task[:"decidim:metrics:one"].invoke }.to have_enqueued_job(Decidim::MetricJob).exactly(0).times
      end
    end
  end
end
