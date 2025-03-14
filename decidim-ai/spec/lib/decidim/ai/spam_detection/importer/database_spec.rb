# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Importer::Database do
  around do |example|
    resources = Decidim::Ai::SpamDetection.resource_models

    example.run

    Decidim::Ai::SpamDetection.resource_models = resources
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

    let!(:meetings) do
      create_list(:meeting, 4, component:, author:,
                               title: { en: "Some proposal that is not blocked" },
                               description: { en: "The body for the meeting." })
    end
    let(:resource_models) { { "Decidim::Meetings::Meeting" => "Decidim::Ai::SpamDetection::Resource::Meeting" } }

    include_examples "resource is being indexed"
  end

  context "when trained model is Decidim::Proposals::Proposal" do
    let(:manifest_name) { "proposals" }
    let(:training) { 8 }

    let!(:proposals) do
      create_list(:proposal, 4,
                  :published,
                  component:,
                  users: [author],
                  title: "Some proposal that is not blocked",
                  body: "The body for the proposal.")
    end
    let(:resource_models) { { "Decidim::Proposals::Proposal" => "Decidim::Ai::SpamDetection::Resource::Proposal" } }

    include_examples "resource is being indexed"
  end

  context "when trained model is Decidim::Proposals::CollaborativeDraft" do
    let(:manifest_name) { "proposals" }
    let(:training) { 8 }

    let!(:collaborative_drafts) do
      create_list(:collaborative_draft, 4,
                  component:,
                  users: [author],
                  title: "Some draft that is not blocked",
                  body: "The body for the proposal.")
    end
    let(:resource_models) { { "Decidim::Proposals::CollaborativeDraft" => "Decidim::Ai::SpamDetection::Resource::CollaborativeDraft" } }

    include_examples "resource is being indexed"
  end

  context "when trained model is Decidim::Debates::Debate" do
    let(:manifest_name) { "debates" }
    let(:training) { 8 }

    let!(:debates) do
      create_list(:debate, 4,
                  author:, component:,
                  title: { en: "Some proposal that is not blocked" },
                  description: { en: "The body for the meeting." })
    end
    let(:resource_models) { { "Decidim::Debates::Debate" => "Decidim::Ai::SpamDetection::Resource::Debate" } }

    include_examples "resource is being indexed"
  end

  context "when trained model is Decidim::User" do
    let(:tested) { 3 }
    let(:training) { tested + 1 } # tested + author in shared example

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
