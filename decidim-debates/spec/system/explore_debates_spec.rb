# frozen_string_literal: true

require "spec_helper"

describe "Explore debates" do
  include_context "with a component"
  include_context "with taxonomy filters context"
  let(:manifest_name) { "debates" }
  let(:participatory_space_manifests) { [participatory_process.manifest.name] }
  let(:taxonomies) { [taxonomy] }

  before do
    switch_to_host(organization.host)
    component_settings = component["settings"]["global"].merge!(taxonomy_filters: [taxonomy_filter.id])
    component.update!(settings: component_settings)
  end

  describe "index" do
    let(:debates_count) { 5 }
    let!(:debates) do
      create_list(
        :debate,
        debates_count,
        component:,
        start_time: Time.zone.local(2016, 12, 13, 14, 15),
        end_time: Time.zone.local(2016, 12, 13, 16, 17)
      )
    end

    it "shows the component name in the sidebar" do
      visit_component

      within("aside") do
        expect(page).to have_content(translated(component.name))
      end
    end

    it "lists all debates for the given process" do
      visit_component

      expect(page).to have_css("a.card__list", count: debates_count)

      debates.each do |debate|
        expect(page).to have_content(translated(debate.title))
      end
    end

    context "when there are no debates" do
      let(:debates) { nil }

      it "shows an empty page with a message" do
        visit_component

        within "main.layout-2col__main" do
          expect(page).to have_content "There are no debates yet"
        end
      end

      context "when filtering by scope" do
        it "shows an empty page with a message" do
          visit_component

          within "#panel-dropdown-menu-taxonomy-#{taxonomy.parent.id}" do
            click_filter_item decidim_escape_translated(taxonomy.name)
          end

          within "main.layout-2col__main" do
            expect(page).to have_content("There are no debates with this criteria")
          end
        end
      end
    end

    context "when there are a lot of debates" do
      let!(:debates) do
        create_list(:debate, Decidim::Paginable::OPTIONS.first + 5, component:)
      end

      it "paginates them" do
        visit_component

        expect(page).to have_css("a.card__list", count: Decidim::Paginable::OPTIONS.first)

        click_on "Next"

        expect(page).to have_css("[data-pages] [data-page][aria-current='page']", text: "2")

        expect(page).to have_css("a.card__list", count: 5)
      end
    end

    context "when there are open debates" do
      let(:debates) { nil }
      let!(:open_debate) do
        create(
          :debate,
          component:,
          start_time: nil,
          end_time: nil
        )
      end
      let!(:closed_debate) do
        create(
          :debate,
          component:,
          closed_at: 1.day.ago,
          conclusions: { en: "Conclusions" }
        )
      end

      it "the card informs their status" do
        visit_component
        within "#debates__debate_#{open_debate.id}" do
          expect(page).to have_content "Open debate"
        end

        within "#debates__debate_#{closed_debate.id}" do
          expect(page).to have_content "Closed"
        end
      end
    end

    context "when there is an announcement set" do
      let(:announcement) do
        { en: "Important announcement" }
      end

      context "with the component's settings" do
        before do
          component.update!(settings: { announcement: })
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
                announcement:
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
      context "when filtering by text" do
        it "updates the current URL" do
          create(:debate, component:, title: { en: "Foobar debate" })
          create(:debate, component:, title: { en: "Another debate" })
          visit_component

          within "form.new_filter" do
            fill_in("filter[search_text_cont]", with: "foobar")
            within "div.filter-search" do
              click_on
            end
          end

          expect(page).to have_no_content("Another debate")
          expect(page).to have_content("Foobar debate")

          filter_params = CGI.parse(URI.parse(page.current_url).query)
          expect(filter_params["filter[search_text_cont]"]).to eq(["foobar"])
        end
      end

      context "when filtering by origin" do
        context "with 'official' origin" do
          let!(:debates) { create_list(:debate, 2, component:) }

          it "lists the filtered debates" do
            create(:debate, :participant_author, component:)
            visit_component

            within "#panel-dropdown-menu-origin" do
              uncheck "All"
              check "Official"
            end

            expect(page).to have_css("a.card__list", count: 2)
          end
        end

        context "with 'participants' origin" do
          let!(:debates) { create_list(:debate, 2, :participant_author, component:) }

          it "lists the filtered debates" do
            create(:debate, component:)
            visit_component

            within "#panel-dropdown-menu-origin" do
              uncheck "All"
              check "Participants"
            end

            expect(page).to have_css("a.card__list", count: 2)
          end
        end
      end

      context "when filtering by taxonomy" do
        let(:taxonomy2) { create(:taxonomy, :with_parent, organization:) }
        let(:debates) { create_list(:debate, 3, component:, taxonomies: [taxonomy2]) }

        before do
          create(:debate, component:, taxonomies:)
          login_as user, scope: :user
          visit_component
        end

        it "can be filtered by taxonomy" do
          within "#panel-dropdown-menu-taxonomy-#{root_taxonomy.id}" do
            uncheck "All"
            check decidim_escape_translated(taxonomy.name)
          end

          expect(page).to have_css("a.card__list", count: 1)
        end
      end
    end

    context "with hidden debates" do
      let(:debate) { debates.last }

      before do
        create(:moderation, :hidden, reportable: debate)
        visit_component
      end

      it "does not list the hidden debates" do
        expect(page).to have_css("a.card__list", count: debates_count - 1)
        expect(page).to have_no_content(translated(debate.title))
      end
    end

    context "with comment metadata" do
      let!(:comment) { create(:comment, commentable: debates) }
      let!(:debates) { create(:debate, :open_ama, component:) }

      it "shows the comments count" do
        visit_component

        within ".card__list-metadata [data-comments-count]" do
          expect(page).to have_content("1")
        end
      end
    end
  end

  context "when component is not commentable" do
    let(:component) { create(:debante_component, :with_comments_blocked, participatory_space:) }
    let(:resources) { create_list(:debate, 3, component:) }

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
        component:,
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

      within ".layout-item__aside" do
        expect(page).to have_content(13)
        expect(page).to have_content(/Dec/i)
        expect(page).to have_content(/14:15 → 16:17/)
      end
    end

    context "without taxonomies" do
      it "does not show any tag" do
        expect(page).to have_no_selector("[data-tags]")
      end
    end

    context "with a taxonomy" do
      let(:debate) { create(:debate, component:, taxonomies:) }

      it "shows tags for taxonomy" do
        expect(page).to have_css("[data-tags]")

        within "[data-tags]" do
          expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
        end
      end
    end

    context "when debate is official" do
      let!(:debate) { create(:debate, author: organization, description: { en: content }, component:) }

      it_behaves_like "rendering safe content", ".editor-content"
    end

    context "when rich text editor is enabled for participants" do
      let!(:debate) { create(:debate, author: user, description: { en: content }, component:) }

      before do
        organization.update(rich_text_editor_in_public_views: true)
        visit path
      end

      it_behaves_like "rendering safe content", ".editor-content"
    end

    context "when rich text editor is NOT enabled on the frontend" do
      let!(:debate) { create(:debate, author: user, description: { en: content }, component:) }

      it_behaves_like "rendering unsafe content", ".editor-content"
    end
  end
end
