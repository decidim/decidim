# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly participatory processes", type: :system do
  include_context "when admin administrating an assembly"

  # it_behaves_like "manage assemblies"
  let!(:assembly_participatory_process) do
    create :assembly_participatory_process,
           assembly: assembly
  end

  let(:participatory_process) { create :participatory_process, organization: assembly.organization}

  describe "creating an assembly participatory process" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path

      within "#assemblies table" do
        click_link translated(assembly.title)
      end
    end

    context "when can create assembly participatory process" do
      before do
        within ".secondary-nav" do
          click_link "Related Participatory Process"
        end
      end

      it "shows assembly participatory process list" do
        within "#assembly_participatory_processes table" do
          expect(page).to have_content(translated(assembly_participatory_process.participatory_process.title))
        end
      end

      it "creates a new assembly participatory process" do
        within "#assembly_participatory_processes .card-title" do
          page.find("a.button").click
        end

        within ".new_assembly_participatory_process" do
          puts "-----------------"
          puts "#{translated(participatory_process.title)}"
          puts "-----------------"
          select translated(participatory_process.title), from: :assembly_participatory_process_participatory_process_id
          # select "Select a related participatory process", from: :assembly_participatory_process_participatory_process_id

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within ".container" do
          expect(page).to have_content(translated(participatory_process.title))
        end
      end
    end

  end


  # describe "deleting an assembly" do
  #   let!(:assembly2) { create(:assembly, organization: organization) }
  #
  #   before do
  #     switch_to_host(organization.host)
  #     login_as user, scope: :user
  #     visit decidim_admin_assemblies.assemblies_path
  #   end
  #
  #   it "deletes an assembly" do
  #     click_link translated(assembly2.title)
  #     accept_confirm { click_link "Destroy" }
  #
  #     expect(page).to have_admin_callout("successfully")
  #
  #     within "table" do
  #       expect(page).not_to have_content(translated(assembly2.title))
  #     end
  #   end
  # end
end
