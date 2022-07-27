# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebateActivityCell, type: :cell do
      controller Decidim::LastActivitiesController

      let!(:debate) { create(:debate) }
      let(:action) { :publish }
      let(:action_log) do
        create(
          :action_log,
          action:,
          resource: debate,
          organization: debate.organization,
          component: debate.component,
          participatory_space: debate.participatory_space
        )
      end

      context "when rendering" do
        it "renders the card" do
          html = cell("decidim/debates/debate_activity", action_log).call
          expect(html).to have_css("#action-#{action_log.id} .card__content")
        end

        context "when action is update" do
          let(:action) { :update }

          it "renders the correct title" do
            html = cell("decidim/debates/debate_activity", action_log).call
            expect(html).to have_css("#action-#{action_log.id} .card__content")
            expect(html).to have_content("Debate updated")
          end
        end

        context "when action is create" do
          let(:action) { :create }

          it "renders the correct title" do
            html = cell("decidim/debates/debate_activity", action_log).call
            expect(html).to have_css("#action-#{action_log.id} .card__content")
            expect(html).to have_content("New debate")
          end
        end

        context "when action is publish" do
          it "renders the correct title" do
            html = cell("decidim/debates/debate_activity", action_log).call
            expect(html).to have_css("#action-#{action_log.id} .card__content")
            expect(html).to have_content("New debate")
          end
        end
      end
    end
  end
end
