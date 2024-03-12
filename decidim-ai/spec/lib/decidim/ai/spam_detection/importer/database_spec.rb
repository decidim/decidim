# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::Importer::Database do
  around do |example|
    resources = Decidim::Ai.trained_models

    example.run

    Decidim::Ai.trained_models = resources
  end

  shared_examples "resource is being indexed" do
    let(:organization) { create(:organization) }
    let!(:author) { create(:user, organization:) }
    let(:component) { create(:component, participatory_space:, manifest_name:) }
    let(:participatory_space) { create(:participatory_process, organization:) }

    it "successfully loads the dataset" do
      instance = Decidim::Ai::SpamDetection::Service.new
      allow(Decidim::Ai).to receive(:spam_detection_instance).and_return(instance)
      expect(instance).to receive(:train).exactly(training).times

      described_class.call
    end
  end

  context "when trained model is Decidim::Initiative" do
    let(:organization) { create(:organization) }
    let!(:author) { create(:user, organization:) }
    let!(:participatory_space) { create_list(:initiative, 4, author:, organization:) }
    let(:training) { 8 }

    before do
      Decidim::Ai.trained_models = { "Decidim::Initiative" => "Decidim::Ai::SpamDetection::Resource::Initiative" }
    end

    it "successfully loads the dataset" do
      instance = Decidim::Ai::SpamDetection::Service.new
      allow(Decidim::Ai).to receive(:spam_detection_instance).and_return(instance)
      expect(instance).to receive(:train).exactly(training).times

      described_class.call
    end
  end

  context "when trained model is Decidim::Comment::Comment" do
    let(:manifest_name) { "dummy" }
    let(:dummy_resource) { create(:dummy_resource, component:) }
    let(:commentable) { dummy_resource }
    let!(:comments) { create_list(:comment, 4, author:, commentable:) }
    let(:training) { 4 }

    before do
      Decidim::Ai.trained_models = { "Decidim::Comments::Comment" => "Decidim::Ai::SpamDetection::Resource::Comment" }
    end

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

    before do
      Decidim::Ai.trained_models = { "Decidim::Meetings::Meeting" => "Decidim::Ai::SpamDetection::Resource::Meeting" }
    end

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

    before do
      Decidim::Ai.trained_models = { "Decidim::Proposals::Proposal" => "Decidim::Ai::SpamDetection::Resource::Proposal" }
    end

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

    before do
      Decidim::Ai.trained_models = { "Decidim::Proposals::CollaborativeDraft" => "Decidim::Ai::SpamDetection::Resource::CollaborativeDraft" }
    end

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

    before do
      Decidim::Ai.trained_models = { "Decidim::Debates::Debate" => "Decidim::Ai::SpamDetection::Resource::Debate" }
    end

    include_examples "resource is being indexed"
  end

  context "when trained model is Decidim::User" do
    let(:tested) { 3 }
    let(:training) { tested + 1 } # tested + author in shared example

    let!(:user) { create_list(:user, tested, organization:, about: "Something about me") }

    before do
      Decidim::Ai.trained_models = { "Decidim::User" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity" }
    end

    include_examples "resource is being indexed"
  end

  context "when trained model is Decidim::UserGroup" do
    let(:tested) { 3 }
    let(:training) { tested + 1 } # tested + author in shared example

    let!(:user) { create_list(:user_group, tested, organization:) }

    before do
      Decidim::Ai.trained_models = { "Decidim::UserGroup" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity" }
    end

    include_examples "resource is being indexed"
  end
end
