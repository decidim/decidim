# frozen_string_literal: true

shared_examples "participatory space members" do
  let(:blocks_manifests) { [] }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: participatory_space.organization) }
  let(:unpublished_user) { create(:user, organization: participatory_space.organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no members and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { members_path }
    end
  end

  context "when there are no members and accessing from the space homepage" do
    context "and the main data content block is disabled" do
      it "the menu nav is not shown" do
        visit participatory_space_homepage_path

        expect(page).to have_no_css(".participatory-space__nav-container")
      end
    end

    context "and the main data content block is enabled" do
      let(:blocks_manifests) { ["main_data"] }

      it "the menu link is not shown" do
        visit participatory_space_homepage_path

        expect(page).to have_no_text("Members")
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
      create(:member, user:, participatory_space:, published: false)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { members_path }
      end
    end

    context "and accessing from the homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit participatory_space_homepage_path

          expect(page).to have_no_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is not shown" do
          visit participatory_space_homepage_path

          expect(page).to have_no_text("Members")
        end
      end
    end
  end

  context "when there are some published members" do
    let!(:member) { create(:member, user:, participatory_space:, published: true) }
    let!(:unpublished_member) { create(:member, user: unpublished_user, participatory_space:, published: false) }

    before do
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
            expect(page).to have_text("Members")
            click_on "Members"
          end

          expect(page).to have_current_path members_path
        end
      end

      it "lists all the members" do
        within ".layout-main__section" do
          expect(page).to have_css(".profile__user", count: 1)
          expect(page).to have_no_text(decidim_sanitize(unpublished_member.name))
        end

        click_on(member.name)

        expect(page).to have_text("Profile")
      end
    end

    context "when there are more members than the pagination per_page limit" do
      let(:per_page) { Decidim::Paginable::OPTIONS.first }
      let(:users) { create_list(:user, per_page + 5, organization: participatory_space.organization) }
      let!(:extra_members) do
        users.map do |user|
          create(:member, participatory_space:, user:, published: true)
        end
      end

      before do
        visit members_path
      end

      it "paginates the members list" do
        within ".layout-main__section" do
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

        within ".layout-main__section" do
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

        within ".layout-main__section" do
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
