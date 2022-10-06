# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Votings::AdminLog::BallotStylePresenter, type: :helper do
    subject { described_class.new(action_log, helper) }

    let(:resource) { create(:ballot_style) }
    let(:action_log) do
      create(
        :action_log,
        action:,
        resource:,
        extra_data: { code: resource.code }
      )
    end

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    describe "#present" do
      context "when the ballot style is created" do
        let(:action) { :create }

        it "shows that the ballot style has been created" do
          expect(subject.present).to include(resource.code)
          expect(subject.present).to include("created a ballot style")
        end
      end

      context "when the ballot style is updated" do
        let(:action) { :update }

        it "shows that the ballot style has been created" do
          expect(subject.present).to include(resource.code)
          expect(subject.present).to include("updated the ballot style")
        end
      end

      context "when the ballot style is deleted" do
        let(:action) { :delete }

        before do
          resource.destroy!
          action_log.reload
        end

        it "shows that the ballot style has been created" do
          expect(subject.present).to include(resource.code)
          expect(subject.present).to include("deleted the ballot style")
        end
      end
    end
  end
end
