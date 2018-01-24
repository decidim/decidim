# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CreateDebate do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_space: participatory_process, manifest_name: "debates" }
  let(:category) { create :category, participatory_space: participatory_process }
  let(:user) { create :user, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      title: "title",
      description: "description",
      user_group_id: nil,
      category: category,
      current_user: user,
      current_feature: current_feature
    )
  end
  let(:invalid) { false }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:debate) { Decidim::Debates::Debate.last }

    it "creates the debate" do
      expect { subject.call }.to change { Decidim::Debates::Debate.count }.by(1)
    end

    it "sets the category" do
      subject.call
      expect(debate.category).to eq category
    end

    it "sets the feature" do
      subject.call
      expect(debate.feature).to eq current_feature
    end

    it "sets the author" do
      subject.call
      expect(debate.author).to eq user
    end

    it "sets the title with i18n" do
      subject.call
      expect(debate.title.values.uniq).to eq ["title"]
      expect(debate.title.keys).to match_array organization.available_locales
    end

    it "sets the description with i18n" do
      subject.call
      expect(debate.description.values.uniq).to eq ["description"]
      expect(debate.description.keys).to match_array organization.available_locales
    end
  end

  describe "events" do
    let(:follower) { create(:user, organization: organization) }
    let!(:follow) { create :follow, followable: user, user: follower }

    it "notifies the change" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: kind_of(Decidim::Debates::Debate),
          recipient_ids: [follower.id]
        )

      subject.call
    end
  end
end
