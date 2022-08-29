# frozen_string_literal: true

require "spec_helper"

describe "Assembly members", type: :system do
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no assembly members and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_assembly_members_path(assembly) }
    end
  end

  context "when there are no assembly members and accessing from the assembly homepage" do
    it "the menu link is not shown" do
      visit decidim_assemblies.assembly_path(assembly)

      within ".main-nav" do
        expect(page).to have_no_content("Members")
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
      it "the menu link is not shown" do
        visit decidim_assemblies.assembly_path(assembly)

        within ".process-header" do
          expect(page).to have_no_content("MEMBERS")
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
      it "the menu link is shown" do
        visit decidim_assemblies.assembly_path(assembly)

        within ".process-nav" do
          expect(page).to have_content("MEMBERS")
          click_link "Members"
        end

        expect(page).to have_current_path decidim_assemblies.assembly_assembly_members_path(assembly)
      end
    end

    it "lists all the non ceased assembly members" do
      within "#assembly_members-grid" do
        expect(page).to have_selector(".card--member", count: 2)

        assembly_members.each do |assembly_member|
          expect(page).to have_content(Decidim::AssemblyMemberPresenter.new(assembly_member).name)
        end

        expect(page).not_to have_content(Decidim::AssemblyMemberPresenter.new(ceased_assembly_member).name)
      end
    end
  end
end
