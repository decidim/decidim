# frozen_string_literal: true

shared_examples "participatory space members" do
  let(:blocks_manifests) { [] }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: participatory_space.organization) }
  let(:unpublished_user) { create(:user, organization: participatory_space.organization) }
  # A visitor allowed to reach the space homepage even when the space is
  # private (e.g. an organization admin). Homepage checks use it so that they
  # inspect the actual homepage instead of a redirect target.
  let(:allowed_visitor) { create(:user, :admin, :confirmed, organization: participatory_space.organization) }
  # Spaces whose members page is not publicly accessible (e.g. private
  # participatory processes) require a logged in member. Host specs can opt in
  # by overriding this to true.
  let(:login_as_member) { false }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no members and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { members_path }
    end
  end

  context "when there are no members and accessing from the space homepage" do
    before do
      login_as allowed_visitor, scope: :user
    end

    context "and the main data content block is disabled" do
      it "the menu nav is not shown" do
        visit participatory_space_homepage_path

        expect(page).to have_current_path participatory_space_homepage_path
        expect(page).to have_no_css(".participatory-space__nav-container")
      end
    end

    context "and the main data content block is enabled" do
      let(:blocks_manifests) { ["main_data"] }

      it "the menu link is not shown" do
        visit participatory_space_homepage_path

        expect(page).to have_current_path participatory_space_homepage_path
        expect(page).to have_no_content("Members")
      end
    end
  end

  context "when the participatory space does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { unexisting_participatory_space_members_path }
    end
  end

  context "when there are some members and all are unpublished" do
    before do
      create(:participatory_space_private_user, user:, privatable_to: participatory_space, published: false)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { members_path }
      end
    end

    context "and accessing from the homepage" do
      before do
        login_as allowed_visitor, scope: :user
      end

      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit participatory_space_homepage_path

          expect(page).to have_current_path participatory_space_homepage_path
          expect(page).to have_no_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is not shown" do
          visit participatory_space_homepage_path

          expect(page).to have_current_path participatory_space_homepage_path
          expect(page).to have_no_content("Members")
        end
      end
    end
  end

  context "when there are some published members" do
    let!(:member) { create(:participatory_space_private_user, user:, privatable_to: participatory_space, published: true) }
    let!(:unpublished_member) { create(:participatory_space_private_user, user: unpublished_user, privatable_to: participatory_space, published: false) }

    before do
      login_as(member.user, scope: :user) if login_as_member
      visit members_path
    end

    context "and accessing from the space homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit participatory_space_homepage_path

          expect(page).to have_no_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is shown" do
          visit participatory_space_homepage_path

          within ".participatory-space__nav-container" do
            expect(page).to have_content("Members")
            click_on "Members"
          end

          expect(page).to have_current_path members_path
        end
      end

      it "lists all the members" do
        within "#assembly_members-grid" do
          expect(page).to have_css(".profile__user", count: 1)
          expect(page).to have_no_content(Decidim::ParticipatorySpacePrivateUserPresenter.new(unpublished_member).name)
        end

        click_on(member.name)

        expect(page).to have_content("Profile")
      end
    end

    context "when there are more members than the pagination per_page limit" do
      let(:per_page) { Decidim::Paginable::OPTIONS.first }
      let(:users) { create_list(:user, per_page + 5, organization: participatory_space.organization) }
      let!(:extra_members) do
        users.map do |user|
          create(:participatory_space_private_user, privatable_to: participatory_space, user:, published: true)
        end
      end

      before do
        visit members_path
      end

      it "paginates the members list" do
        within "#assembly_members-grid" do
          expect(page).to have_css(".profile__user", count: per_page)
        end
      end

      it "shows pagination controls" do
        within("div[data-pagination]") do
          expect(page).to have_css('nav[aria-label="Pagination"]')
        end
      end

      it "navigates to the next page" do
        within "nav[aria-label=\"Pagination\"]" do
          click_on "Next"
        end

        within "#assembly_members-grid" do
          expect(page).to have_css(".profile__user", count: 6)
        end
      end

      it "maintains pagination when navigating back" do
        within "nav[aria-label=\"Pagination\"]" do
          click_on "Next"
        end

        within "nav[aria-label=\"Pagination\"]" do
          click_on "Prev"
        end

        within "#assembly_members-grid" do
          expect(page).to have_css(".profile__user", count: per_page)
        end
      end

      it "shows the correct page number in the URL" do
        within "nav[aria-label=\"Pagination\"]" do
          click_on "Next"
        end

        expect(page).to have_current_path(/page=2/)
      end
    end
  end
end
