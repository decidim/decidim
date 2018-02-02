# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::BasePresenter, type: :helper do
  subject { described_class.new(action_log, helper) }

  let(:action_log) { create :action_log, action: action }
  let(:user) { action_log.user }
  let(:participatory_space) { action_log.participatory_space }
  let(:resource) { action_log.resource }
  let(:action) { :create }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    subject { described_class.new(action_log, helper).present }

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
    end

    context "when the user exists" do
      it "links to their profile" do
        expect(subject).to include("<a href=\"/profiles/#{user.nickname}\">")
      end
    end

    context "when the user doesn't exist" do
      it "doesn't link to their profile" do
        nickname = user.nickname
        user_name = user.name
        user.destroy
        action_log.reload

        expect(subject).not_to include("<a href=\"/profiles/")
        expect(subject).to include(nickname)
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
