# frozen_string_literal: true

require "spec_helper"

describe "Explore debates", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_component) { create :debates_component, participatory_space: participatory_process }
  let(:debates_count) { 5 }
  let!(:debates) do
    create_list(
      :debate,
      debates_count,
      component: current_component,
      start_time: Time.zone.local(2016, 12, 13, 14, 15),
      end_time: Time.zone.local(2016, 12, 13, 16, 17)
    )
  end

  before do
    switch_to_host(organization.host)
  end

  describe "index" do
    let(:path) { decidim_participatory_process_debates.debates_path(participatory_process_slug: participatory_process.slug, component_id: current_component.id) }

    it "lists all debates for the given process" do
      visit path

      expect(page).to have_selector("article.card", count: debates_count)

      debates.each do |debate|
        expect(page).to have_content(translated(debate.title))
      end
    end

    context "when there are a lot of debates" do
      before do
        create_list(:debate, Decidim::Paginable::OPTIONS.first + 5, component: component)
      end

      it "paginates them" do
        visit_component

        expect(page).to have_css(".card--debate", count: Decidim::Paginable::OPTIONS.first)

        click_link "Next"

        expect(page).to have_selector(".pagination .current", text: "2")

        expect(page).to have_css(".card--debate", count: 5)
      end
    end

    context "when there's an announcement set" do
      let(:announcement) do
        { en: "Important announcement" }
      end

      context "with the component's settings" do
        before do
          component.update!(settings: { announcement: announcement })
        end

        it "shows the announcement" do
          visit_component
          expect(page).to have_content("Important announcement")
        end
      end

      context "with the step's settings" do
        before do
          component.update!(
            step_settings: {
              component.participatory_space.active_step.id => {
                announcement: announcement
              }
            }
          )
        end

        it "shows the announcement" do
          visit_component
          expect(page).to have_content("Important announcement")
        end
      end
    end

    context "when filtering" do
      context "when filtering by origin" do
        context "with 'official' origin" do
          it "lists the filtered debates" do
            create_list(:debate, 2, component: component)
            create(:debate, :with_author, component: component)
            visit_component

            within ".filters" do
              choose "Official"
            end

            expect(page).to have_css(".card--debate", count: 2)
            expect(page).to have_content("2 DEBATES")
          end
        end

        context "with 'citizens' origin" do
          it "lists the filtered debates" do
            create_list(:debate, 2, :with_author, component: component)
            create(:debate, component: component)
            visit_component

            within ".filters" do
              choose "Citizens"
            end

            expect(page).to have_css(".card--debate", count: 2)
            expect(page).to have_content("2 DEBATES")
          end
        end
      end

      context "when filtering by category" do
        before do
          login_as user, scope: :user
        end

        it "can be filtered by category" do
          create_list(:debate, 3, component: component)
          create(:debate, component: component, category: category)

          visit_component

          within "form.new_filter" do
            select category.name[I18n.locale.to_s], from: "filter[category_id]"
          end

          expect(page).to have_css(".card--debate", count: 1)
        end
      end
    end

    context "with hidden debates" do
      let(:debate) { debates.last }

      before do
        create :moderation, :hidden, reportable: debate
      end

      it "does not list the hidden debates" do
        visit path

        expect(page).to have_selector("article.card", count: debates_count - 1)

        expect(page).to have_no_content(translated(debate.title))
      end
    end
  end

  context "when component is not commentable" do
    let(:ressources) { create_list(:debate, 3, component: current_component) }

    it_behaves_like "an uncommentable component"
  end

  describe "show" do
    let(:path) do
      decidim_participatory_process_debates.debate_path(
        id: debate.id,
        participatory_process_slug: participatory_process.slug,
        component_id: current_component.id
      )
    end
    let(:debates_count) { 1 }
    let(:debate) { debates.first }

    before do
      visit path
    end

    it "shows all debate info" do
      expect(page).to have_i18n_content(debate.title)
      expect(page).to have_i18n_content(debate.description)
      expect(page).to have_i18n_content(debate.information_updates)
      expect(page).to have_i18n_content(debate.instructions)

      within ".section.view-side" do
        expect(page).to have_content(13)
        expect(page).to have_content(/December/i)
        expect(page).to have_content("14:15 - 16:17")
      end
    end

    context "without category" do
      it "does not show any tag" do
        expect(page).not_to have_selector("ul.tags.tags--debate")
      end
    end

    context "with a category" do
      let(:debate) do
        debate = debates.first
        debate.category = create :category, participatory_space: participatory_process
        debate.save
        debate
      end

      it "shows tags for category" do
        expect(page).to have_selector("ul.tags.tags--debate")

        within "ul.tags.tags--debate" do
          expect(page).to have_content(translated(debate.category.name))
        end
      end
    end
  end
end
