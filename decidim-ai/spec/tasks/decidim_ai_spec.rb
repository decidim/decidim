# frozen_string_literal: true

require "spec_helper"

describe "Executing Decidim Ai tasks" do
  describe "rake decidim:ai:spam:create_reporting_user", type: :task do
    context "when executing task" do
      let!(:organization) { create(:organization) }

      it "successfully invokes the user creation" do
        expect { Rake::Task[:"decidim:ai:spam:create_reporting_user"].invoke }.to change(Decidim::User, :count).by(1)
      end
    end
  end

  describe "rake decidim:ai:spam:load_application_dataset", type: :task do
    context "when executing task" do
      it "successfully loads the dataset" do
        instance = Decidim::Ai::SpamDetection::Service.new(registry: Decidim::Ai::SpamDetection.resource_registry)
        allow(Decidim::Ai::SpamDetection).to receive(:resource_classifier).and_return(instance)
        expect(instance).to receive(:train).exactly(4).times

        Rake::Task[:"decidim:ai:spam:load_application_dataset"].invoke("spec/support/test.csv")
      end
    end
  end

  describe "rake decidim:ai:spam:reset_training_model", type: :task do
    context "when executing task" do
      it "calls reset on the spam detection instance" do
        instance = Decidim::Ai::SpamDetection::Service.new(registry: Decidim::Ai::SpamDetection.resource_registry)
        allow(Decidim::Ai::SpamDetection).to receive(:resource_classifier).and_return(instance)
        expect(instance).to receive(:reset).exactly(1).time

        Rake::Task[:"decidim:ai:spam:reset"].invoke
      end
    end
  end
end
