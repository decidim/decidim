# frozen_string_literal: true

require "spec_helper"

describe "Explore debates", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  before do
    switch_to_host(organization.host)
  end

  describe "index" do
    let(:debates_count) { 5 }
    let!(:debates) do
      create_list(
        :debate,
        debates_count,
        component: component,
        start_time: Time.zone.local(2016, 12, 13, 14, 15),
        end_time: Time.zone.local(2016, 12, 13, 16, 17)
      )
    end

    it "lists all debates for the given process" do
      visit_component

      expect(page).to have_selector(".card--debate", count: debates_count)

      debates.each do |debate|
        expect(page).to have_content(translated(debate.title))
      end
    end

    context "when there are a lot of debates" do
      let!(:debates) do
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
          visit_component
        end

        it "shows the announcement" do
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
          visit_component
        end

        it "shows the announcement" do
          expect(page).to have_content("Important announcement")
        end
      end
    end

    context "when filtering" do
      context "when filtering by origin" do
        context "with 'official' origin" do
          let!(:debates) { create_list(:debate, 2, component: component) }

          it "lists the filtered debates" do
            create(:debate, :citizen_author, component: component)
            visit_component

            within ".filters .origin_check_boxes_tree_filter" do
              uncheck "All"
              check "Official"
            end

            expect(page).to have_css(".card--debate", count: 2)
            expect(page).to have_content("2 DEBATES")
          end
        end

        context "with 'citizens' origin" do
          let!(:debates) { create_list(:debate, 2, :citizen_author, component: component) }

          it "lists the filtered debates" do
            create(:debate, component: component)
            visit_component

            within ".filters .origin_check_boxes_tree_filter" do
              uncheck "All"
              check "Citizens"
            end

            expect(page).to have_css(".card--debate", count: 2)
            expect(page).to have_content("2 DEBATES")
          end
        end
      end

      context "when filtering by category" do
        let(:category2) { create :category, participatory_space: participatory_space }
        let(:debates) { create_list(:debate, 3, component: component, category: category2) }

        before do
          create(:debate, component: component, category: category)
          login_as user, scope: :user
          visit_component
        end

        it "can be filtered by category" do
          within ".filters .category_id_check_boxes_tree_filter" do
            uncheck "All"
            check category.name[I18n.locale.to_s]
          end

          expect(page).to have_css(".card--debate", count: 1)
        end
      end
    end

    context "with hidden debates" do
      let(:debate) { debates.last }

      before do
        create :moderation, :hidden, reportable: debate
        visit_component
      end

      it "does not list the hidden debates" do
        expect(page).to have_selector(".card--debate", count: debates_count - 1)
        expect(page).to have_no_content(translated(debate.title))
      end
    end

    context "with comment metadata" do
      let!(:comment) { create(:comment, commentable: debates) }
      let!(:debates) { create(:debate, :open_ama, component: component) }

      it "shows the last comment author and the time" do
        visit_component

        within ".card__footer" do
          expect(page).to have_content("Commented")
        end
      end
    end
  end

  context "when component is not commentable" do
    let(:component) { create :debante_component, :with_comments_blocked, participatory_space: participatory_space }
    let(:resources) { create_list(:debate, 3, component: component) }

    it_behaves_like "an uncommentable component"
  end

  describe "show" do
    let(:path) do
      decidim_participatory_process_debates.debate_path(
        id: debate.id,
        participatory_process_slug: participatory_space.slug,
        component_id: component.id
      )
    end
    let!(:debate) do
      create(
        :debate,
        :open_ama,
        component: component,
        start_time: Time.zone.local(2016, 12, 13, 14, 15),
        end_time: Time.zone.local(2016, 12, 13, 16, 17)
      )
    end

    before do
      visit path
    end

    it "shows all debate info" do
      expect(page).to have_i18n_content(debate.title)
      expect(page).to have_i18n_content(debate.description, strip_tags: true)
      expect(page).to have_i18n_content(debate.information_updates, strip_tags: true)
      expect(page).to have_i18n_content(debate.instructions, strip_tags: true)

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
        debate = create(:debate, component: component)
        debate.category = create :category, participatory_space: participatory_space
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

    context "when debate is official" do
      let!(:debate) { create(:debate, author: organization, description: content, component: component) }

      it_behaves_like "rendering safe content", ".columns.mediumlarge-8.mediumlarge-pull-4"
    end

    context "when rich text editor is enabled for participants" do
      let!(:debate) { create(:debate, author: user, description: content, component: component) }

      before do
        organization.update(rich_text_editor_in_public_views: true)
        visit path
      end

      it_behaves_like "rendering safe content", ".columns.mediumlarge-8.mediumlarge-pull-4"
    end

    context "when rich text editor is NOT enabled on the frontend" do
      let!(:debate) { create(:debate, author: user, description: content, component: component) }

      it_behaves_like "rendering unsafe content", ".columns.mediumlarge-8.mediumlarge-pull-4"
    end
  end
end
