# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::BasePresenter, type: :helper do
  subject { presenter }

  let(:presenter) { described_class.new(action_log, helper) }
  let(:action_log) { create :action_log, action: action, created_at: Date.new(2018, 1, 2).at_midnight }
  let(:user) { action_log.user }
  let(:participatory_space) { action_log.participatory_space }
  let(:resource) { action_log.resource }
  let(:action) { :create }
  let(:version_double) { double(present?: false) }

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
          diff_presenter_double = double(present: true)
          allow(Decidim::Log::DiffPresenter)
            .to receive(:new).and_return(diff_presenter_double)

          expect(diff_presenter_double)
            .to receive(:present)

          subject
        end
      end
    end

    context "when the user exists" do
      it "links to their profile" do
        expect(subject).to include("href=\"/profiles/#{user.nickname}\">")
      end
    end

    context "when the user doesn't exist" do
      it "doesn't link to their profile" do
        user_name = user.name
        user.destroy
        action_log.reload

        expect(subject).not_to include("href=\"/profiles/")
        expect(subject).to include(user_name)
      end
    end

    describe "resource" do
      let(:title) { resource.title }
      let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }

      context "when the resource exists" do
        it "links to its public page" do
          expect(subject).to have_link(title, href: resource_path)
        end
      end

      context "when the resource doesn't exist" do
        it "doesn't link to its public page" do
          resource.destroy
          action_log.reload

          expect(subject).not_to have_link(title)
          expect(subject).to include(title)
        end
      end
    end

    describe "participatory space" do
      let(:title) { participatory_space.title["en"] }
      let(:participatory_space_path) { Decidim::ResourceLocatorPresenter.new(participatory_space).path }

      context "when the space exists" do
        it "links to its public page" do
          expect(subject).to have_link(title, href: participatory_space_path)
        end
      end

      context "when the space doesn't exist" do
        before do
          participatory_space.destroy
          action_log.reload
        end

        it "doesn't link to its public page" do
          expect(subject).not_to have_link(title)
          expect(subject).to include(title)
        end

        it "doesn't link to the resource public page" do
          expect(subject).not_to have_link(resource.title)
          expect(subject).to include(resource.title)
        end
      end
    end
  end
end
