# frozen_string_literal: true

require "spec_helper"

describe "Assembly private users" do
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, :with_content_blocks, organization:, blocks_manifests:, private_space: true) }
  let(:privatable_to) { assembly }
  let(:blocks_manifests) { [] }

  let(:user) { create(:user, organization: privatable_to.organization) }
  let(:ceased_user) { create(:user, organization: privatable_to.organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no assembly members and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_participatory_space_private_users_path(assembly, locale: I18n.locale) }
    end
  end

  context "when there are no assembly members and accessing from the assembly homepage" do
    context "and the main data content block is disabled" do
      it "the menu nav is not shown" do
        visit decidim_assemblies.assembly_path(assembly, locale: I18n.locale)

        expect(page).to have_no_css(".participatory-space__nav-container")
      end
    end

    context "and the main data content block is enabled" do
      let(:blocks_manifests) { ["main_data"] }

      it "the menu link is not shown" do
        visit decidim_assemblies.assembly_path(assembly, locale: I18n.locale)

        expect(page).to have_no_content("Members")
      end
    end
  end

  context "when the assembly does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_participatory_space_private_users_path(assembly_slug: 999_999_999, locale: I18n.locale) }
    end
  end

  context "when there are some assembly members and all are unpublished" do
    before do
      create(:participatory_space_private_user, user:, privatable_to:, published: false)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_assemblies.assembly_participatory_space_private_users_path(assembly, locale: I18n.locale) }
      end
    end

    context "and accessing from the homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit decidim_assemblies.assembly_path(assembly, locale: I18n.locale)

          expect(page).to have_no_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is not shown" do
          visit decidim_assemblies.assembly_path(assembly, locale: I18n.locale)

          expect(page).to have_no_content("Members")
        end
      end
    end
  end

  context "when there are some published assembly members" do
    let!(:private_user) { create(:participatory_space_private_user, user:, privatable_to:, published: true) }
    let!(:ceased_private_user) { create(:participatory_space_private_user, user: ceased_user, privatable_to:, published: false) }

    before do
      visit decidim_assemblies.assembly_participatory_space_private_users_path(assembly, locale: I18n.locale)
    end

    context "and accessing from the assembly homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit decidim_assemblies.assembly_path(assembly, locale: I18n.locale)

          expect(page).to have_no_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is shown" do
          visit decidim_assemblies.assembly_path(assembly, locale: I18n.locale)

          within ".participatory-space__nav-container" do
            expect(page).to have_content("Members")
            click_on "Members"
          end

          expect(page).to have_current_path decidim_assemblies.assembly_participatory_space_private_users_path(assembly, locale: I18n.locale)
        end
      end

      it "lists all the non ceased assembly members" do
        within "#assembly_members-grid" do
          expect(page).to have_css(".profile__user", count: 1)

          expect(page).to have_no_content(Decidim::ParticipatorySpacePrivateUserPresenter.new(ceased_private_user).name)
        end
      end
    end
  end
end
