# frozen_string_literal: true

shared_examples "manage sortitions" do
  describe "creation" do
    let(:taxonomy) { create(:taxonomy, :with_parent, organization: current_component.organization) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent, participatory_space_manifests: [current_component.participatory_space.manifest.name]) }
    let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
    let!(:proposal_component) do
      create(:proposal_component, :published, participatory_space: current_component.participatory_space)
    end

    before do
      current_component.update!(settings: { taxonomy_filters: [taxonomy_filter.id] })
      click_on "New sortition"
    end

    it "Requires a title" do
      within "form" do
        expect(page).to have_content(/Title/i)
      end
    end

    it "can be related to taxonomies" do
      within "form" do
        expect(page).to have_content(/Taxonomies of the set of proposals in which you want to apply the draw/i)
      end
    end

    it "Requires a random number" do
      within "form" do
        expect(page).to have_content(/Result of die roll/i)
      end
    end

    it "Requires the number of proposals to select" do
      within "form" do
        expect(page).to have_content(/Number of proposals to be selected/i)
      end
    end

    it "Requires the proposals component" do
      within "form" do
        expect(page).to have_content(/Proposals set/i)
      end
    end

    it "Requires the witnesses" do
      within "form" do
        expect(page).to have_content(/Witnesses/i)
      end
    end

    it "Requires additional information" do
      within "form" do
        expect(page).to have_content(/Sortition information/i)
      end
    end

    context "when creates a sortition" do
      let(:sortition_dice) { Faker::Number.between(from: 1, to: 6) }
      let(:sortition_target_items) { Faker::Number.between(from: 1, to: 10) }
      let!(:proposal) { create(:proposal, component: proposal_component) }
      let(:attributes) { attributes_for(:sortition, component: current_component) }

      it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='sortition-additional_info-tabs']", "full"
      it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='sortition-witnesses-tabs']", "content"

      it "shows the sortition details", versioning: true do
        within ".new_sortition" do
          fill_in :sortition_dice, with: sortition_dice
          fill_in :sortition_target_items, with: sortition_target_items
          select translated(proposal_component.name), from: :sortition_decidim_proposals_component_id

          fill_in_i18n_editor(:sortition_witnesses, "#sortition-witnesses-tabs", **attributes[:witnesses].except("machine_translations"))
          fill_in_i18n_editor(:sortition_additional_info, "#sortition-additional_info-tabs", **attributes[:additional_info].except("machine_translations"))
          fill_in_i18n(:sortition_title, "#sortition-title-tabs", **attributes[:title].except("machine_translations"))

          accept_confirm { find("*[type=submit]").click }
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content(/Title/i)

        sortition = Decidim::Sortitions::Sortition.last
        within ".sortition" do
          expect(page).to have_content(/Draw time/i)
          expect(page).to have_content(/Dice/i)
          expect(page).to have_content(/Items to select/i)
          expect(page).to have_content(/Taxonomies/i)
          expect(page).to have_content(/All taxonomies/i)
          expect(page).to have_content(/Proposals component/i)
          expect(page).to have_content(translated(proposal_component.name))
          expect(page).to have_content(/Seed/i)
          expect(page).to have_content(sortition.seed)
        end

        within ".proposals" do
          expect(page).to have_content(/Proposals selected for draw/i)
          expect(sortition.proposals).not_to be_empty
          sortition.proposals.each do |p|
            expect(page).to have_content(translated(p.title))
          end
        end

        visit decidim_admin.root_path
        expect(page).to have_content("created the #{translated(attributes[:title])} sortition")
      end
    end
  end
end
