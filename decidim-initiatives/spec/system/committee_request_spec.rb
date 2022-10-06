# frozen_string_literal: true

require "spec_helper"

describe "Decidim::Initiatives::CommitteeRequestController", type: :system do
  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, :created, organization:) }

  context "when GET new" do
    context "and owner requests membership" do
      it "Owner is not allowed to request membership" do
        switch_to_host(organization.host)

        create(:authorization, user: initiative.author)
        login_as initiative.author, scope: :user

        visit decidim_initiatives.new_initiative_committee_request_path(initiative.to_param)
        expect(page).to have_content("You are not authorized to perform this action")
      end
    end

    context "and authorized user" do
      let(:user) { create(:user, :confirmed, organization:) }

      it "are allowed to request membership" do
        switch_to_host(organization.host)
        create(:authorization, user:)
        login_as user, scope: :user

        visit decidim_initiatives.new_initiative_committee_request_path(initiative.to_param)
        expect(page).to have_content("You are about to request becoming a member of the promoter committee of this initiative")
      end
    end

    context "and unauthorized users do" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
      end

      it "are not allowed to request membership" do
        visit decidim_initiatives.new_initiative_committee_request_path(initiative.to_param)
        expect(page).to have_content("You are not authorized to perform this action")
      end
    end

    context "and user is not connected" do
      before do
        switch_to_host(organization.host)
        visit decidim_initiatives.new_initiative_committee_request_path(initiative.to_param)
      end

      it "are allowed to request membership" do
        expect(page).to have_current_path decidim_initiatives.new_initiative_committee_request_path(initiative.to_param)
        expect(page).to have_content("You are about to request becoming a member of the promoter committee of this initiative")
      end

      context "when requesting membership" do
        it "an authentication modal is opened" do
          click_link "Continue"
          expect(page).to have_content("Please sign in")
        end
      end
    end
  end
end
