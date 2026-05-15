# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Importer::Database do
  around do |example|
    resources = Decidim::Ai::SpamDetection.resource_models

    example.run

    Decidim::Ai::SpamDetection.resource_models = resources
  end

  shared_examples "some resources are being spam" do
    before do
      Decidim::Ai::SpamDetection.resource_models = resource_models
      allow(Decidim::Ai::SpamDetection).to receive(:resource_classifier).and_return(instance)
    end

    let(:reporting_user) { author }
    let(:spam_count) { 2 }
    let!(:parent) { create(:report, reason: "parent_hidden", user: reporting_user, moderation: create(:moderation, :hidden, reportable: resources.last)) }
    Decidim::Report::REASONS.excluding("parent_hidden").each do |reason|
      let!(:report) { create(:report, reason:, user: reporting_user, moderation: create(:moderation, :hidden, reportable:)) }

      it "successfully loads the dataset when there are resources marked as #{reason}" do
        allow(instance).to receive(:train)

        described_class.call

        expect(instance).to have_received(:train).with(:ham, anything).at_least(training - spam_count)
        expect(instance).to have_received(:train).with(:spam, anything).at_least(spam_count)
        expect(instance).to have_received(:train).with(:spam, "Hidden resource").at_least(1)
      end
    end
  end

  shared_examples "resource is being indexed" do
    let(:organization) { create(:organization) }
    let!(:author) { create(:user, organization:) }
    let(:component) { create(:component, participatory_space:, manifest_name:) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:instance) { Decidim::Ai::SpamDetection::Service.new(registry: Decidim::Ai::SpamDetection.resource_registry) }

    before do
      Decidim::Ai::SpamDetection.resource_models = resource_models
      allow(Decidim::Ai::SpamDetection).to receive(:resource_classifier).and_return(instance)
    end

    it "successfully loads the dataset" do
      expect(instance).to receive(:train).exactly(training).times

      described_class.call
    end
  end

  context "when trained model is Decidim::Initiative" do
    let(:organization) { create(:organization) }
    let!(:author) { create(:user, organization:) }
    let(:training) { 8 }
    let!(:resource_models) { { "Decidim::Initiative" => "Decidim::Ai::SpamDetection::Resource::Initiative" } }

    include_examples "resource is being indexed" do
      let!(:participatory_space) { create_list(:initiative, 4, author:, organization:) }
    end
  end

  context "when trained model is Decidim::Comment::Comment" do
    let(:manifest_name) { "dummy" }
    let(:dummy_resource) { create(:dummy_resource, component:) }
    let(:commentable) { dummy_resource }
    let!(:comments) { create_list(:comment, 4, author:, commentable:) }
    let(:training) { 4 }
    let(:resource_models) { { "Decidim::Comments::Comment" => "Decidim::Ai::SpamDetection::Resource::Comment" } }

    include_examples "resource is being indexed"
  end

  context "when trained model is Decidim::Meetings::Meeting" do
    let(:manifest_name) { "meetings" }
    let(:training) { 20 }

    let!(:reportable) { create(:meeting, component:, author:, title: { en: "Hidden resource" }) }
    let!(:resources) { create_list(:meeting, 3, component:, author:) }

    let(:resource_models) { { "Decidim::Meetings::Meeting" => "Decidim::Ai::SpamDetection::Resource::Meeting" } }

    include_examples "resource is being indexed"
    include_examples "some resources are being spam" do
      let(:spam_count) { 5 }
    end
  end

  context "when trained model is Decidim::Proposals::Proposal" do
    let(:manifest_name) { "proposals" }
    let(:training) { 8 }

    let!(:reportable) { create(:proposal, :published, component:, users: [author], title: { en: "Hidden resource" }) }
    let!(:resources) { create_list(:proposal, 3, :published, component:, users: [author]) }
    let(:resource_models) { { "Decidim::Proposals::Proposal" => "Decidim::Ai::SpamDetection::Resource::Proposal" } }

    include_examples "resource is being indexed"
    include_examples "some resources are being spam"
  end

  context "when trained model is Decidim::Debates::Debate" do
    let(:manifest_name) { "debates" }
    let(:training) { 8 }

    let!(:reportable) do
      create(:debate,
             author:, component:,
             title: { en: "Hidden resource" })
    end
    let!(:resources) do
      create_list(:debate, 3,
                  author:, component:,
                  title: { en: "Some proposal that is not blocked" })
    end
    let(:resource_models) { { "Decidim::Debates::Debate" => "Decidim::Ai::SpamDetection::Resource::Debate" } }

    include_examples "resource is being indexed"
    include_examples "some resources are being spam"
  end

  context "when trained model is Decidim::User" do
    let(:tested) { 3 }
    let(:training) { 4 } # tested + author in shared example

    let!(:user) { create_list(:user, tested, organization:, about: "Something about me") }
    let(:resource_models) { { "Decidim::User" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity" } }

    include_examples "resource is being indexed" do
      let(:instance) { Decidim::Ai::SpamDetection::Service.new(registry: Decidim::Ai::SpamDetection.user_registry) }

      before do
        allow(Decidim::Ai::SpamDetection).to receive(:user_classifier).and_return(instance)
      end
    end
  end
end
