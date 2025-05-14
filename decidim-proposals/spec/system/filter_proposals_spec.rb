# frozen_string_literal: true

require "spec_helper"

describe "Filter Proposals", :slow do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, skip_injection: true, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [component.participatory_space.manifest.name]) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_item: taxonomy, taxonomy_filter:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  context "when caching is enabled", :caching do
    before do
      visit_component
    end

    it "displays the filter labels in correct locales" do
      within "form.new_filter" do
        expect(page).to have_content(/Status/i)
      end

      within_language_menu do
        click_on "Català"
      end

      within "form.new_filter" do
        expect(page).to have_content(/Estat/i)
      end
    end
  end

  context "when filtering proposals by TEXT" do
    it "updates the current URL" do
      create(:proposal, component:, title: { en: "Foobar proposal" })
      create(:proposal, component:, title: { en: "Another proposal" })
      visit_component

      within "form.new_filter" do
        fill_in("filter[search_text_cont]", with: "foobar")
        within "form .filter-search" do
          find("*[type=submit]").click
        end
      end

      expect(page).to have_no_content("Another proposal")
      expect(page).to have_content("Foobar proposal")

      filter_params = CGI.parse(URI.parse(page.current_url).query)
      expect(filter_params["filter[search_text_cont]"]).to eq(["foobar"])
    end
  end

  context "when filtering proposals by ORIGIN" do
    context "when official_proposals setting is enabled" do
      before do
        component.update!(settings: { official_proposals_enabled: true })
      end

      it "can be filtered by origin" do
        visit_component

        within "form.new_filter" do
          expect(page).to have_content(/Origin/i)
        end
      end

      context "with 'official' origin" do
        it "lists the filtered proposals" do
          create_list(:proposal, 2, :official, component:)
          create(:proposal, component:)
          visit_component

          within "#dropdown-menu-filters div.filter-container", text: "Origin" do
            uncheck "All"
            check "Official"
          end

          expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        end
      end

      context "with 'participants' origin" do
        it "lists the filtered proposals" do
          create_list(:proposal, 2, component:)
          create(:proposal, :official, component:)
          visit_component

          within "#dropdown-menu-filters div.filter-container", text: "Origin" do
            uncheck "All"
            check "Participants"
          end

          expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        end
      end
    end

    context "when official_proposals setting is not enabled" do
      before do
        component.update!(settings: { official_proposals_enabled: false })
      end

      it "cannot be filtered by origin" do
        visit_component

        within "form.new_filter" do
          expect(page).to have_no_content(/Official/i)
        end
      end
    end
  end

  context "when filtering proposals by TAXONOMY" do
    let!(:taxonomy2) { create(:taxonomy, skip_injection: true, name: { en: "Taxonomy name" }, parent: root_taxonomy, organization:) }
    let!(:taxonomy_filter_item2) { create(:taxonomy_filter_item, taxonomy_item: taxonomy2, taxonomy_filter:) }
    let!(:proposals) { create_list(:proposal, 2, component:, taxonomies: [taxonomy]) }
    let(:first_proposal) { proposals.first }
    let(:last_proposal) { proposals.last }
    let!(:proposal_comment) { create(:comment, commentable: first_proposal) }
    let!(:proposal_follow) { create(:follow, followable: last_proposal) }

    before do
      component.update!(settings: { taxonomy_filters: [taxonomy_filter.id] })
      create(:proposal, component:, taxonomies: [taxonomy2])
      create(:proposal, component:, taxonomies: [])
      visit_component
    end

    it "can be filtered by taxonomy" do
      within "form.new_filter" do
        expect(page).to have_content(/Taxonomy name/i)
      end
    end

    context "when selecting one taxonomy" do
      it "lists the filtered proposals", :slow do
        within "#dropdown-menu-filters div.filter-container", text: "Taxonomy name" do
          uncheck "All"
          check decidim_sanitize_translated(taxonomy.name)
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
      end

      it "can be ordered by most commented and most followed after filtering" do
        within "#dropdown-menu-filters div.filter-container", text: "Taxonomy name" do
          uncheck "All"
          check decidim_sanitize_translated(taxonomy.name)
        end

        within "#dropdown-menu-order" do
          click_on "Most commented"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_css("[id^='proposals__proposal']:first-child", text: translated(first_proposal.title))

        within "#dropdown-menu-order" do
          click_on "Most followed"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_css("[id^='proposals__proposal']:first-child", text: translated(last_proposal.title))
      end
    end

    context "when unselecting the selected taxonomy" do
      it "lists the filtered proposals" do
        within "#dropdown-menu-filters div.filter-container", text: "Taxonomy name" do
          uncheck "All"
          check decidim_sanitize_translated(taxonomy.name)
          check "All"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 3)
      end
    end
  end

  context "when filtering proposals by STATE" do
    context "when proposal_answering component setting is enabled" do
      before do
        component.update!(settings: { proposal_answering_enabled: true })
      end

      context "when proposal_answering step setting is enabled" do
        before do
          component.update!(
            step_settings: {
              component.participatory_space.active_step.id => {
                proposal_answering_enabled: true
              }
            }
          )
        end

        it "can be filtered by state" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_content(/Status/i)
          end
        end

        it "lists accepted proposals" do
          create(:proposal, :accepted, component:)
          visit_component

          within "#dropdown-menu-filters div.filter-container", text: "Status" do
            check "All"
            uncheck "All"
            check "Accepted"
          end

          expect(page).to have_css("[id^='proposals__proposal']", count: 1)

          within "[id^='proposals__proposal']" do
            expect(page).to have_content("Accepted")
          end
        end

        it "lists the filtered proposals" do
          create(:proposal, :rejected, component:)
          visit_component

          within "#dropdown-menu-filters div.filter-container", text: "Status" do
            check "All"
            uncheck "All"
            check "Rejected"
          end

          expect(page).to have_css("[id^='proposals__proposal']", count: 1)

          within "[id^='proposals__proposal']" do
            expect(page).to have_content("Rejected")
          end
        end

        context "when there are proposals with answers not published" do
          let!(:proposal) { create(:proposal, :accepted_not_published, component:) }

          before do
            create(:proposal, :accepted, component:)

            visit_component
          end

          it "shows only accepted proposals with published answers" do
            within "#dropdown-menu-filters div.filter-container", text: "Status" do
              check "All"
              uncheck "All"
              check "Accepted"
            end

            expect(page).to have_css("[id^='proposals__proposal']", count: 1)

            within "[id^='proposals__proposal']" do
              expect(page).to have_content("Accepted")
            end
          end

          it "shows accepted proposals with not published answers as not answered" do
            within "#dropdown-menu-filters div.filter-container", text: "Status" do
              check "All"
              uncheck "All"
              check "Not answered"
            end

            expect(page).to have_css("[id^='proposals__proposal']", count: 1)

            within "[id^='proposals__proposal']" do
              expect(page).to have_content(translated(proposal.title))
              expect(page).to have_no_content("Accepted")
            end
          end
        end
      end

      context "when proposal_answering step setting is disabled" do
        before do
          component.update!(
            step_settings: {
              component.participatory_space.active_step.id => {
                proposal_answering_enabled: false
              }
            }
          )
        end

        it "cannot be filtered by state" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_no_content(/Status/i)
          end
        end
      end
    end

    context "when proposal_answering component setting is not enabled" do
      before do
        component.update!(settings: { proposal_answering_enabled: false })
      end

      it "cannot be filtered by state" do
        visit_component

        within "form.new_filter" do
          expect(page).to have_no_content(/Status/i)
        end
      end
    end
  end

  context "when filtering proposals by ACTIVITY" do
    let(:active_step_id) { component.participatory_space.active_step.id }
    let!(:voted_proposal) { create(:proposal, component:) }
    let!(:vote) { create(:proposal_vote, proposal: voted_proposal, author: user) }
    let!(:proposal_list) { create_list(:proposal, 3, component:) }
    let!(:created_proposal) { create(:proposal, component:, users: [user]) }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
        visit_component
      end

      it "can be filtered by activity" do
        within "form.new_filter" do
          expect(page).to have_content(/Activity/i)
        end
      end

      it "can be filtered by my proposals" do
        within "form.new_filter" do
          expect(page).to have_content(/My proposals/i)
        end
      end

      it "lists the filtered proposals created by the user" do
        within "form.new_filter" do
          find("input[value='my_proposals']").click
        end
        expect(page).to have_css("[id^='proposals__proposal']", count: 1)
      end

      context "when votes are enabled" do
        before do
          component.update!(step_settings: { active_step_id => { votes_enabled: true } })
          visit_component
        end

        it "can be filtered by voted" do
          within "form.new_filter" do
            expect(page).to have_content(/Voted/i)
          end
        end

        it "lists the filtered proposals voted by the user" do
          within "form.new_filter" do
            find("input[value='voted']").click
          end

          expect(page).to have_css("[id^='proposals__proposal']", text: translated(voted_proposal.title))
        end
      end

      context "when votes are not enabled" do
        before do
          component.update!(step_settings: { active_step_id => { votes_enabled: false } })
          visit_component
        end

        it "cannot be filtered by voted" do
          within "form.new_filter" do
            expect(page).to have_no_content(/Voted/i)
          end
        end
      end
    end

    context "when the user is NOT logged in" do
      it "cannot be filtered by activity" do
        visit_component
        within "form.new_filter" do
          expect(page).to have_no_content(/Activity/i)
        end
      end
    end
  end

  context "when filtering proposals by TYPE" do
    context "when there are amendments to proposals" do
      let!(:proposal) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, component:) }
      let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }

      before do
        visit_component
      end

      context "with 'all' type" do
        it "lists the filtered proposals" do
          find('input[name="filter[type]"][value="all"]').click

          expect(page).to have_css("[id^='proposals__proposal']", count: 2)
          expect(page).to have_content("Amendment", count: 2)
        end
      end

      context "with 'proposals' type" do
        it "lists the filtered proposals" do
          within "#dropdown-menu-filters div.filter-container", text: "Type" do
            choose "Proposals"
          end

          expect(page).to have_css("[id^='proposals__proposal']", count: 1)
          expect(page).to have_content("Amendment", count: 1)
        end
      end

      context "with 'amendments' type" do
        it "lists the filtered proposals" do
          within "#dropdown-menu-filters div.filter-container", text: "Type" do
            choose "Amendments"
          end

          expect(page).to have_css("[id^='proposals__proposal']", count: 1)
          expect(page).to have_content("Amendment", count: 2)
        end
      end

      context "when amendments_enabled component setting is enabled" do
        context "and amendments_visibility component step_setting is set to 'participants'" do
          context "when the user is logged in" do
            before do
              visit decidim.root_path

              component.update!(settings: { amendments_enabled: true })
              component.update!(
                step_settings: {
                  component.participatory_space.active_step.id => {
                    amendments_visibility: "participants"
                  }
                }
              )
              login_as user, scope: :user
              sleep 1
              visit_component
            end

            context "and has amended a proposal" do
              let!(:new_emendation) { create(:proposal, component:) }
              let!(:new_amendment) { create(:amendment, amendable: proposal, emendation: new_emendation, amender: new_emendation.creator_author) }
              let(:user) { new_amendment.amender }

              it "can be filtered by type" do
                within "form.new_filter" do
                  expect(page).to have_content(/Type/i)
                end
              end

              it "lists only their amendments" do
                within "#dropdown-menu-filters div.filter-container", text: "Type" do
                  choose "Amendments"
                end
                expect(page).to have_css("[id^='proposals__proposal']", count: 1)
                expect(page).to have_content("Amendment", count: 2)
                expect(page).to have_content(translated(new_emendation.title))
                expect(page).to have_no_content(translated(emendation.title))
              end
            end

            context "and has NOT amended a proposal" do
              it "cannot be filtered by type" do
                within "form.new_filter" do
                  expect(page).to have_no_content(/Type/i)
                end
              end
            end
          end

          context "when the user is NOT logged in" do
            before do
              visit decidim.root_path
              component.update!(settings: { amendments_enabled: true })
              component.update!(
                step_settings: {
                  component.participatory_space.active_step.id => {
                    amendments_visibility: "participants"
                  }
                }
              )
              visit_component
            end

            it "cannot be filtered by type" do
              within "form.new_filter" do
                expect(page).to have_no_content(/Type/i)
              end
            end
          end
        end
      end

      context "when amendments_enabled component setting is NOT enabled" do
        before do
          component.update!(settings: { amendments_enabled: false })
        end

        context "and amendments_visibility component step_setting is set to 'participants'" do
          before do
            component.update!(
              step_settings: {
                component.participatory_space.active_step.id => {
                  amendments_visibility: "participants"
                }
              }
            )
          end

          context "when the user is logged in" do
            context "and has amended a proposal" do
              let!(:new_emendation) { create(:proposal, component:) }
              let!(:new_amendment) { create(:amendment, amendable: proposal, emendation: new_emendation, amender: new_emendation.creator_author) }
              let(:user) { new_amendment.amender }

              before do
                login_as user, scope: :user
                visit_component
              end

              it "can be filtered by type" do
                within "form.new_filter" do
                  expect(page).to have_content(/Type/i)
                end
              end

              it "lists all the amendments" do
                within "#dropdown-menu-filters div.filter-container", text: "Type" do
                  choose "Amendments"
                end
                expect(page).to have_css("[id^='proposals__proposal']", count: 2)
                expect(page).to have_content("Amendment", count: 3)
                expect(page).to have_content(translated(new_emendation.title))
                expect(page).to have_content(translated(emendation.title))
              end
            end

            context "and has NOT amended a proposal" do
              before do
                login_as user, scope: :user
                visit_component
              end

              it "can be filtered by type" do
                within "form.new_filter" do
                  expect(page).to have_content(/Type/i)
                end
              end
            end
          end

          context "when the user is NOT logged in" do
            before do
              visit_component
            end

            it "can be filtered by type" do
              within "form.new_filter" do
                expect(page).to have_content(/Type/i)
              end
            end
          end
        end
      end
    end
  end

  context "when using the browser history", :slow do
    before do
      create_list(:proposal, 2, component:)
      create_list(:proposal, 2, :official, component:)
      create_list(:proposal, 2, :official, :accepted, component:)
      create_list(:proposal, 2, :official, :rejected, component:)

      visit_component
    end

    it "recover filters from initial pages" do
      within "#dropdown-menu-filters div.filter-container", text: "Status" do
        check "Rejected"
      end

      expect(page).to have_css("[id^='proposals__proposal']", count: 8)

      page.go_back

      expect(page).to have_css("[id^='proposals__proposal']", count: 6)
    end

    it "recover filters from previous pages" do
      within "#dropdown-menu-filters div.filter-container", text: "Status" do
        check "All"
        uncheck "All"
      end
      within "#dropdown-menu-filters div.filter-container", text: "Origin" do
        uncheck "All"
      end

      within "#dropdown-menu-filters div.filter-container", text: "Origin" do
        check "Official"
      end

      within "#dropdown-menu-filters div.filter-container", text: "Status" do
        check "Accepted"
      end

      expect(page).to have_css("[id^='proposals__proposal']", count: 2)

      page.go_back

      page.refresh
      expect(page).to have_css("[id^='proposals__proposal']", count: 6)

      page.go_back

      page.refresh
      expect(page).to have_css("[id^='proposals__proposal']", count: 8)

      page.go_forward

      page.refresh
      expect(page).to have_css("[id^='proposals__proposal']", count: 6)
    end
  end

  context "when using the 'back to list' link", :slow do
    before do
      create_list(:proposal, 2, component:)
      create_list(:proposal, 2, :official, component:)
      create_list(:proposal, 2, :official, :accepted, component:)
      create_list(:proposal, 2, :official, :rejected, component:)

      visit_component
    end

    it "saves and restores the filtering" do
      expect(page).to have_css("[id^='proposals__proposal']", count: 6)

      within "#dropdown-menu-filters div.filter-container", text: "Status" do
        check "Rejected"
      end

      expect(page).to have_css("[id^='proposals__proposal']", count: 8)
    end
  end
end
