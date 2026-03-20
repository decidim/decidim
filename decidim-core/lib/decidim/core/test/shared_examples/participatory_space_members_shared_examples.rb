# frozen_string_literal: true

shared_examples "participatory space members" do
  let(:blocks_manifests) { [] }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: participatory_space.organization) }
  let(:ceased_user) { create(:user, organization: participatory_space.organization) }

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

          expect(page).to have_no_content("Members")
        end
      end
    end
  end

  context "when there are some published members" do
    let!(:member) { create(:member, user:, participatory_space:, published: true) }
    let!(:ceased_member) { create(:member, user: ceased_user, participatory_space:, published: false) }

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
            expect(page).to have_content("Members")
            click_on "Members"
          end

          expect(page).to have_current_path members_path
        end
      end

      it "lists all the non ceased members" do
        within ".layout-main__section" do
          expect(page).to have_css(".profile__user", count: 1)

          expect(page).to have_no_content(Decidim::ParticipatorySpace::MemberPresenter.new(ceased_member).name)
        end
      end
    end
  end
end
