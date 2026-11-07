# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe VotingRulesCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    subject(:cell_html) { my_cell.call }

    let(:my_cell) { cell("decidim/proposals/voting_rules", component) }
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
    let(:component) { create(:proposal_component, participatory_space:, **component_options) }
    let(:component_options) { {} }
    let(:user) { nil }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    def rule_description(rule, **)
      I18n.t("decidim.proposals.proposals.voting_rules.#{rule}.description", **)
    end

    describe "#show?" do
      subject { my_cell.show? }

      context "when voting is disabled and blocked with a proposal limit configured" do
        let(:component_options) do
          {
            settings: {
              proposal_limit: 5,
              vote_limit: 10,
              threshold_per_proposal: 73,
              can_accumulate_votes_beyond_threshold: true,
              minimum_votes_per_user: 2
            },
            step_settings: {
              participatory_space.active_step.id => {
                votes_enabled: false,
                votes_blocked: true
              }
            }
          }
        end

        it { is_expected.to be true }

        it "renders only the proposal creation limit rule" do
          expect(cell_html).to have_text(rule_description(:proposal_limit, limit: 5))
          expect(cell_html).to have_no_text(rule_description(:vote_limit, limit: 10))
          expect(cell_html).to have_no_text(rule_description(:threshold_per_proposal, limit: 73))
          expect(cell_html).to have_no_text(rule_description(:can_accumulate_votes_beyond_threshold, limit: 73))
          expect(cell_html).to have_no_text(rule_description(:minimum_votes_per_user, votes: 2))
        end
      end

      context "when proposal creation is not enabled but voting is enabled and not blocked" do
        before do
          allow(my_cell).to receive(:view_context).and_return(double(render: ""))
        end

        let(:component_options) do
          {
            settings: {
              proposal_limit: 5,
              vote_limit: 10,
              threshold_per_proposal: 73,
              can_accumulate_votes_beyond_threshold: true,
              minimum_votes_per_user: 2
            },
            step_settings: {
              participatory_space.active_step.id => {
                votes_enabled: true,
                votes_blocked: false,
                creation_enabled: false
              }
            }
          }
        end

        it { is_expected.to be true }

        it "renders only the vote related rules" do
          expect(cell_html).to have_no_text(rule_description(:proposal_limit, limit: 5))
          expect(cell_html).to have_text(rule_description(:vote_limit, limit: 10))
          expect(cell_html).to have_text(rule_description(:threshold_per_proposal, limit: 73))
          expect(cell_html).to have_text(rule_description(:can_accumulate_votes_beyond_threshold, limit: 73))
          expect(cell_html).to have_text(rule_description(:minimum_votes_per_user, votes: 2))
        end
      end

      context "when no relevant rule is configured" do
        it { is_expected.to be false }

        it "does not render the callout" do
          expect(cell_html).to render_nothing
        end
      end
    end

    describe "#proposal_rules" do
      context "when at least one rule is relevant" do
        let(:component_options) do
          {
            settings: { vote_limit: 10 },
            step_settings: {
              participatory_space.active_step.id => { votes_enabled: true }
            }
          }
        end

        it "renders the proposal voting rules dropdown" do
          output = my_cell.proposal_rules

          expect(output).to have_css("#proposal-voting-rules")
          expect(output).to have_text(rule_description(:vote_limit, limit: 10))
        end
      end

      context "when no relevant rule is configured" do
        it "does not render the proposal voting rules dropdown" do
          expect(my_cell.proposal_rules).to be_nil
        end
      end
    end
  end
end
