# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Elections::AdminLog::ElectionPresenter, type: :helper do
    subject { described_class.new(action_log, helper) }

    let(:action_log) do
      create(
        :action_log,
        action: publish
      )
    end
    let(:publish) { :publish }

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    describe "#present" do
      context "when the election is published" do
        it "shows the election has been published" do
          expect(subject.present).to include(" published the ")
        end
      end

      context "when the election is unpublished" do
        let(:action_log) do
          create(
            :action_log,
            action: unpublish
          )
        end

        let(:unpublish) { :unpublish }

        it "shows the election has been unpublished" do
          expect(subject.present).to include(" unpublished the ")
        end
      end
    end
  end
end
