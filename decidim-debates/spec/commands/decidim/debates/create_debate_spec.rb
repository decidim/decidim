# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CreateDebate do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "debates" }
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
      current_component: current_component
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

    it "sets the component" do
      subject.call
      expect(debate.component).to eq current_component
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
    let(:author_follower) { create(:user, organization: organization) }
    let!(:author_follow) { create :follow, followable: user, user: author_follower }
    let(:space_follower) { create(:user, organization: organization) }
    let!(:space_follow) { create :follow, followable: participatory_process, user: space_follower }

    it "notifies the change to the author followers" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: kind_of(Decidim::Debates::Debate),
          recipient_ids: [author_follower.id],
          extra: { type: "user" }
        )
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: kind_of(Decidim::Debates::Debate),
          recipient_ids: [space_follower.id],
          extra: { type: "participatory_space" }
        )

      subject.call
    end
  end
end
