# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::BasePresenter, type: :helper do
  subject { presenter }

  let(:presenter) { described_class.new(action_log, helper) }
  let(:action_log) { create :action_log, user: user, action: action, created_at: Date.new(2018, 1, 2).at_midnight }
  let(:user) { create :user, name: "Alice Doe" }
  let(:participatory_space) { action_log.participatory_space }
  let(:resource) { action_log.resource }
  let(:action) { :create }
  let(:version_double) { double(present?: false) }
  let(:presenter_double) { double(present: true) }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
    allow(presenter).to receive(:version).and_return(version_double)
  end

  describe "#present" do
    subject { presenter.present }

    it "shows the date of the action" do
      expect(subject).to include("02/01/2018 00:00")
    end

    it "renders a basic log sentence" do
      expect(subject).to include("create")
      expect(subject).to include(user.name)
      expect(subject).to include(user.nickname)
      expect(subject).to include(resource.title)
      expect(subject).to include(participatory_space.title["en"])
    end

    context "when the action is update" do
      let(:action) { :update }

      it "renders a basic log sentence" do
        expect(subject).to include("update")
        expect(subject).to include(user.name)
        expect(subject).to include(user.nickname)
        expect(subject).to include(resource.title)
        expect(subject).to include(participatory_space.title["en"])
      end

      context "when version exists" do
        let(:version_double) { double(present?: true, changeset: {}) }

        it "renders a dropdown" do
          expect(subject).to include("class=\"logs__log__actions-dropdown\"")
        end

        it "renders the diff" do
          allow(Decidim::Log::DiffPresenter)
            .to receive(:new).and_return(presenter_double)

          expect(presenter_double)
            .to receive(:present)

          subject
        end
      end
    end

    it "renders the user" do
      allow(Decidim::Log::UserPresenter)
        .to receive(:new).and_return(presenter_double)

      expect(presenter_double)
        .to receive(:present)

      subject
    end

    it "renders the space" do
      allow(Decidim::Log::SpacePresenter)
        .to receive(:new).and_return(presenter_double)

      expect(presenter_double)
        .to receive(:present)

      subject
    end

    it "renders the resource" do
      allow(Decidim::Log::ResourcePresenter)
        .to receive(:new).and_return(presenter_double)

      expect(presenter_double)
        .to receive(:present)

      subject
    end
  end
end
