# frozen_string_literal: true

require "spec_helper"

describe "Assembly members", type: :system do
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, :with_content_blocks, organization:, blocks_manifests:) }
  let(:blocks_manifests) { [] }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no assembly members and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_assembly_members_path(assembly) }
    end
  end

  context "when there are no assembly members and accessing from the assembly homepage" do
    context "and the main data content block is disabled" do
      it "the menu nav is not shown" do
        visit decidim_assemblies.assembly_path(assembly)

        expect(page).not_to have_css(".participatory-space__nav-container")
      end
    end

    context "and the main data content block is enabled" do
      let(:blocks_manifests) { ["main_data"] }

      it "the menu link is not shown" do
        visit decidim_assemblies.assembly_path(assembly)

        expect(page).not_to have_content("Members")
      end
    end
  end

  context "when the assembly does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_assembly_members_path(assembly_slug: 999_999_999) }
    end
  end

  context "when there are some assembly members and all are ceased" do
    before do
      create(:assembly_member, :ceased, assembly:)
      create(:assembly_member)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_assemblies.assembly_assembly_members_path(assembly) }
      end
    end

    context "and accessing from the homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit decidim_assemblies.assembly_path(assembly)

          expect(page).not_to have_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is not shown" do
          visit decidim_assemblies.assembly_path(assembly)

          expect(page).not_to have_content("Members")
        end
      end
    end
  end

  context "when there are some published assembly members" do
    let!(:assembly_members) { create_list(:assembly_member, 2, assembly:) }
    let!(:ceased_assembly_member) { create(:assembly_member, :ceased, assembly:) }

    before do
      visit decidim_assemblies.assembly_assembly_members_path(assembly)
    end

    context "and accessing from the assembly homepage" do
      context "and the main data content block is disabled" do
        it "the menu nav is not shown" do
          visit decidim_assemblies.assembly_path(assembly)

          expect(page).not_to have_css(".participatory-space__nav-container")
        end
      end

      context "and the main data content block is enabled" do
        let(:blocks_manifests) { ["main_data"] }

        it "the menu link is shown" do
          visit decidim_assemblies.assembly_path(assembly)

          within ".participatory-space__nav-container" do
            expect(page).to have_content("Members")
            click_link "Members"
          end

          expect(page).to have_current_path decidim_assemblies.assembly_assembly_members_path(assembly)
        end
      end

      it "lists all the non ceased assembly members" do
        within "#assembly_members-grid" do
          expect(page).to have_selector(".profile__user", count: 2)

          expect(page).not_to have_content(Decidim::AssemblyMemberPresenter.new(ceased_assembly_member).name)
        end
      end
    end
  end
end
