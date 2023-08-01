# frozen_string_literal: true

require "spec_helper"

describe "Executing Decidim Ai tasks" do
  describe "rake decidim:ai:create_reporting_user", type: :task do
    context "when executing task" do
      let!(:organization) { create(:organization) }

      it "successfully invokes the user creation" do
        expect { Rake::Task[:"decidim:ai:create_reporting_user"].invoke }.to change(Decidim::User, :count).by(1)
      end
    end
  end

  describe "rake decidim:ai:load_plugin_dataset", type: :task do
    context "when executing task" do
      it "successfully loads the dataset" do
        instance = Decidim::Ai::SpamDetection::Service.new
        allow(Decidim::Ai).to receive(:spam_detection_instance).and_return(instance)
        expect(instance).to receive(:train).at_least(10).times

        Rake::Task[:"decidim:ai:load_plugin_dataset"].invoke
      end
    end
  end

  describe "rake decidim:ai:load_application_dataset", type: :task do
    context "when executing task" do
      it "successfully loads the dataset" do
        instance = Decidim::Ai::SpamDetection::Service.new
        allow(Decidim::Ai).to receive(:spam_detection_instance).and_return(instance)
        expect(instance).to receive(:train).exactly(4).times

        Rake::Task[:"decidim:ai:load_application_dataset"].invoke("spec/support/test.csv")
      end
    end
  end

  describe "rake decidim:ai:reset_training_model", type: :task do
    context "when executing task" do
      it "calls reset on the spam detection instance" do
        instance = Decidim::Ai::SpamDetection::Service.new
        allow(Decidim::Ai).to receive(:spam_detection_instance).and_return(instance)
        expect(instance).to receive(:reset).exactly(1).time

        Rake::Task[:"decidim:ai:reset"].invoke
      end
    end
  end
end
