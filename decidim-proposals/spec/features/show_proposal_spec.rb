# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :feature do
  include_context "feature"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: participatory_process.organization }
  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder::Lookup::Test.add_stub(
      address,
      [{ "latitude" => latitude, "longitude" => longitude }]
    )
  end

  context "viewing a single proposal" do
    let!(:feature) do
      create(:proposal_feature,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    let!(:proposals) { create_list(:proposal, 3, feature: feature) }

    it "allows viewing a single proposal" do
      proposal = proposals.first

      visit_feature

      click_link proposal.title

      expect(page).to have_content(proposal.title)
      expect(page).to have_content(proposal.body)
      expect(page).to have_content(proposal.author.name)
      expect(page).to have_content(proposal.reference)
    end

    context "when process is not related to any scope" do
      let!(:proposal) { create(:proposal, feature: feature, scope: scope) }

      before do
        participatory_process.update_attributes!(scope: nil)
      end

      it "can be filtered by scope" do
        visit_feature
        click_link proposal.title
        expect(page).to have_content(translated(scope.name))
      end
    end

    context "when process is related to a scope" do
      let!(:proposal) { create(:proposal, feature: feature, scope: scope) }

      before do
        participatory_process.update_attributes!(scope: scope)
      end

      it "does not show the scope name" do
        visit_feature
        click_link proposal.title
        expect(page).to have_no_content(translated(scope.name))
      end
    end

    context "when it is an official proposal" do
      let!(:official_proposal) { create(:proposal, feature: feature, author: nil) }

      it "shows the author as official" do
        visit_feature
        click_link official_proposal.title
        expect(page).to have_content("Official proposal")
      end
    end

    context "when a proposal has comments" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:author) { create(:user, :confirmed, organization: feature.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: proposal) }

      it "shows the comments" do
        visit_feature
        click_link proposal.title

        comments.each do |comment|
          expect(page).to have_content(comment.body)
        end
      end
    end

    context "when a proposal has been linked in a meeting" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:meeting_feature) do
        create(:feature, manifest_name: :meetings, participatory_space: proposal.feature.participatory_space)
      end
      let(:meeting) { create(:meeting, feature: meeting_feature) }

      before do
        meeting.link_resources([proposal], "proposals_from_meeting")
      end

      it "shows related meetings" do
        visit_feature
        click_link proposal.title

        expect(page).to have_i18n_content(meeting.title)
      end
    end

    context "when a proposal has been linked in a result" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:dummy_feature) do
        create(:feature, manifest_name: :dummy, participatory_space: proposal.feature.participatory_space)
      end
      let(:dummy_resource) { create(:dummy_resource, feature: dummy_feature) }

      before do
        dummy_resource.link_resources([proposal], "included_proposals")
      end

      it "shows related resources" do
        visit_feature
        click_link proposal.title

        expect(page).to have_i18n_content(dummy_resource.title)
      end
    end

    context "when a proposal is in evaluation" do
      let!(:proposal) { create(:proposal, :evaluating, :with_answer, feature: feature) }

      it "shows a badge and an answer" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Evaluating")

        within ".callout.secondary" do
          expect(page).to have_content("This proposal is being evaluated")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been rejected" do
      let!(:proposal) { create(:proposal, :rejected, :with_answer, feature: feature) }

      it "shows the rejection reason" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Rejected")

        within ".callout.warning" do
          expect(page).to have_content("This proposal has been rejected")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been accepted" do
      let!(:proposal) { create(:proposal, :accepted, :with_answer, feature: feature) }

      it "shows the acceptance reason" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Accepted")

        within ".callout.success" do
          expect(page).to have_content("This proposal has been accepted")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when the proposals'a author account has been deleted" do
      let(:proposal) { proposals.first }

      before do
        Decidim::DestroyAccount.call(proposal.author, Decidim::DeleteAccountForm.from_params({}))
      end

      it "the user is displayed as a deleted user" do
        visit_feature

        click_link proposal.title

        expect(page).to have_content("Deleted user")
      end
    end
  end

  context "when a proposal has been linked in a project" do
    let(:feature) do
      create(:proposal_feature,
             manifest: manifest,
             participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, feature: feature) }
    let(:budget_feature) do
      create(:feature, manifest_name: :budgets, participatory_space: proposal.feature.participatory_space)
    end
    let(:project) { create(:project, feature: budget_feature) }

    before do
      project.link_resources([proposal], "included_proposals")
    end

    it "shows related projects" do
      visit_feature
      click_link proposal.title

      expect(page).to have_i18n_content(project.title)
    end
  end
end
