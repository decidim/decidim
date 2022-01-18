# frozen_string_literal: true

shared_examples "manage sortitions" do
  describe "creation" do
    let!(:proposal_component) do
      create(:proposal_component, :published, participatory_space: current_component.participatory_space)
    end

    before do
      click_link "New sortition"
    end

    it "Requires a title" do
      within "form" do
        expect(page).to have_content(/Title/i)
      end
    end

    it "can be related to a category" do
      within "form" do
        expect(page).to have_content(/Categories of the set of proposals in which you want to apply the draw/i)
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
      let(:sortition_dice) { ::Faker::Number.between(from: 1, to: 6) }
      let(:sortition_target_items) { ::Faker::Number.between(from: 1, to: 10) }
      let!(:proposal) { create :proposal, component: proposal_component }

      it "shows the sortition details" do
        within ".new_sortition" do
          fill_in :sortition_dice, with: sortition_dice
          fill_in :sortition_target_items, with: sortition_target_items
          select translated(proposal_component.name), from: :sortition_decidim_proposals_component_id
          fill_in_i18n_editor(
            :sortition_witnesses,
            "#sortition-witnesses-tabs",
            en: "Witnesses",
            es: "Testigos",
            ca: "Testimonis"
          )
          fill_in_i18n_editor(
            :sortition_additional_info,
            "#sortition-additional_info-tabs",
            en: "additional info",
            es: "Información adicional",
            ca: "Informació adicional"
          )

          fill_in_i18n(
            :sortition_title,
            "#sortition-title-tabs",
            en: "Title",
            es: "Título",
            ca: "Títol"
          )

          accept_confirm { find("*[type=submit]").click }
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content(/Title/i)

        sortition = Decidim::Sortitions::Sortition.last
        within ".sortition" do
          expect(page).to have_content(/Draw time/i)
          expect(page).to have_content(/Dice/i)
          expect(page).to have_content(/Items to select/i)
          expect(page).to have_content(/Category/i)
          expect(page).to have_content(/All categories/i)
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
      end
    end
  end
end
