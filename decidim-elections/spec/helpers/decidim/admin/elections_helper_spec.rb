# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe ElectionsHelper do
        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:elections_component, participatory_space: participatory_process) }
        let(:election) { create(:election, :with_token_csv_census, component:) }
        let(:question) { create(:election_question, election:) }
        let(:user) { create(:user, organization:) }

        before do
          allow(helper).to receive(:current_organization).and_return(organization)
          allow(helper).to receive(:current_user).and_return(current_user)
          allow(helper).to receive(:update_question_status_election_path).and_return("/elections/#{election.id}/update_question_status")
        end

        shared_examples "returns user presenter" do |helper_method|
          it "wraps voter in presenter" do
            voter = create(:voter, election:)
            allow(election).to receive(:census_ready?).and_return(true) if helper_method == :preview_users
            allow(election.census).to receive(:users).with(election, 0).and_return([voter]) if helper_method == :preview_users

            result = helper.send(helper_method, election, *(helper_method == :present_user ? [voter] : []))

            presenter = helper_method == :preview_users ? result.first : result
            expect(presenter).to be_a(Decidim::Elections::Censuses::UserPresenter)
            expect(presenter.user).to eq(voter)
          end
        end

        describe "#census_count" do
          it "returns 0 when no census present" do
            election_without_census = create(:election)
            allow(election_without_census).to receive(:census).and_return(nil)

            expect(helper.census_count(election_without_census)).to eq(0)
          end

          it "returns actual census count" do
            expect(helper.census_count(election)).to eq(3)
          end
        end

        describe "#preview_users" do
          it "returns nil when census not ready" do
            allow(election).to receive(:census_ready?).and_return(false)
            expect(helper.preview_users(election)).to be_nil
          end

          include_examples "returns user presenter", :preview_users
        end

        describe "#present_user" do
          include_examples "returns user presenter", :present_user
        end

        describe "#election_status_with_label" do
          it "renders status with correct CSS class" do
            allow(election).to receive(:per_question?).and_return(false)
            allow(election).to receive(:status).and_return(:ongoing)
            allow(election).to receive(:localized_status).and_return("Ongoing")

            html = helper.election_status_with_label(election)

            expect(html).to include("Ongoing")
            expect(html).to include("ongoing label")
          end
        end

        describe "#enable_question_voting_button" do
          let(:voting_enabled) { false }
          let(:published_results) { false }
          let(:can_enable_voting) { false }

          before do
            allow(question).to receive(:voting_enabled?).and_return(voting_enabled)
            allow(question).to receive(:published_results?).and_return(published_results)
            allow(question).to receive(:can_enable_voting?).and_return(can_enable_voting)
          end

          it "does not render button" do
            expect(helper.enable_question_voting_button(question)).to be_nil
          end

          context "when can enable voting" do
            let(:can_enable_voting) { true }

            it "renders button to enable voting" do
              html = helper.enable_question_voting_button(question)
              expect(html).to include("form")
              expect(html).to include(I18n.t("decidim.elections.admin.dashboard.results.start_question_button"))
            end
          end

          context "when results published" do
            let(:published_results) { true }

            it "does not render button" do
              expect(helper.enable_question_voting_button(question)).to be_nil
            end
          end

          context "when voting is enabled" do
            let(:voting_enabled) { true }

            it "renders status label instead of button" do
              allow(question).to receive(:voting_enabled?).and_return(true)
              html = helper.enable_question_voting_button(question)
              expect(html).to include("status-label")
              expect(html).to include(I18n.t("decidim.elections.status.voting_enabled"))
            end
          end

          context "when election has not started" do
            before do
              allow(election).to receive(:scheduled?).and_return(true)
            end

            it "does not render button" do
              expect(helper.enable_question_voting_button(question)).to be_nil
            end
          end
        end

        describe "#publish_question_button" do
          let(:published_results) { false }
          let(:publishable_results) { false }

          before do
            allow(question).to receive(:published_results?).and_return(published_results)
            allow(question).to receive(:publishable_results?).and_return(publishable_results)
          end

          it "renders the button disabled" do
            html = helper.publish_question_button(question)

            expect(html).to include("form")
            expect(html).to include("disabled=\"disabled\"")
            expect(html).to include(I18n.t("decidim.elections.admin.dashboard.results.publish_button"))
          end

          context "when results are publishable" do
            let(:publishable_results) { true }

            it "renders publish button if publishable" do
              html = helper.publish_question_button(question)

              expect(html).to include("form")
              expect(html).not_to include("disabled=\"disabled\"")
              expect(html).to include(I18n.t("decidim.elections.admin.dashboard.results.publish_button"))
            end
          end

          context "when results are published" do
            let(:published_results) { true }

            it "renders status label instead of button" do
              allow(question).to receive(:published_results?).and_return(true)
              html = helper.publish_question_button(question)

              expect(html).to include("status-label")
              expect(html).to include(I18n.t("decidim.elections.status.results_published"))
            end
          end
        end
      end
    end
  end
end
