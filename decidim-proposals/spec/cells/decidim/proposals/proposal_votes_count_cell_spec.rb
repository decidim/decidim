# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalVotesCountCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    subject(:cell_html) { my_cell.call }

    let(:my_cell) { cell("decidim/proposals/proposal_votes_count", proposal, from_proposals_list:) }
    let(:from_proposals_list) { false }
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:assembly, :open, organization:) }
    let(:component) { create(:proposal_component, participatory_space:) }
    let!(:proposal) { create(:proposal, component:) }
    let(:user) { create(:user, organization:) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    describe "show" do
      let(:votes_count_selector) { "#proposal-#{proposal.id}-votes-count" }

      context "when votes are hidden" do
        before do
          component.update!(default_step_settings: { votes_hidden: true, votes_enabled: true })
        end

        it "renders nothing" do
          expect(subject).to have_no_css(votes_count_selector)
        end
      end

      context "when the user can participate in the space" do
        it "renders the progress bar" do
          expect(subject).to have_css(votes_count_selector)
        end
      end

      context "when the user is an admin" do
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_space) { create(:assembly, :restricted, organization:) }

        it "renders the progress bar" do
          expect(subject).to have_css(votes_count_selector)
        end
      end

      context "when the space is a transparent assembly" do
        let(:participatory_space) { create(:assembly, :transparent, organization:) }

        it "renders the progress bar" do
          expect(subject).to have_css(votes_count_selector)
        end
      end

      context "when the space is restricted and the user is not a member" do
        let(:participatory_space) { create(:assembly, :restricted, organization:) }

        it "renders nothing" do
          expect(subject).to have_no_css(votes_count_selector)
        end
      end

      context "when there is no current user" do
        let(:user) { nil }
        let(:participatory_space) { create(:assembly, :restricted, organization:) }

        it "renders nothing" do
          expect(subject).to have_no_css(votes_count_selector)
        end

        context "and the space is transparent" do
          let(:participatory_space) { create(:assembly, :transparent, organization:) }

          it "renders the progress bar" do
            expect(subject).to have_css(votes_count_selector)
          end
        end
      end

      context "when participatory texts are enabled and rendered from the proposals list" do
        let(:from_proposals_list) { true }
        let(:component) { create(:proposal_component, :with_participatory_texts_enabled, participatory_space:) }

        it "renders the participatory texts variant" do
          expect(subject).to have_css(votes_count_selector)
          expect(subject).to have_no_css(".card__proposals-votes-limited, .card__proposals-votes-unlimited")
        end
      end
    end
  end
end
