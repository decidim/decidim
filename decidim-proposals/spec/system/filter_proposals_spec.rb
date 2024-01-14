# frozen_string_literal: true

require "spec_helper"

describe "Filter Proposals", :slow do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:scope) { create(:scope, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization:, scope:) }

  context "when caching is enabled", :caching do
    before do
      visit_component
    end

    it "displays the filter labels in correct locales" do
      within "form.new_filter" do
        expect(page).to have_content(/Status/i)
      end

      within_language_menu do
        click_link "Català"
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

      expect(page).not_to have_content("Another proposal")
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
          create_list(:proposal, 2, :official, component:, scope:)
          create(:proposal, component:, scope:)
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
          create_list(:proposal, 2, component:, scope:)
          create(:proposal, :official, component:, scope:)
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
          expect(page).not_to have_content(/Official/i)
        end
      end
    end
  end

  context "when filtering proposals by SCOPE" do
    let!(:scope2) { create(:scope, organization: participatory_process.organization) }
    let!(:proposals) { create_list(:proposal, 2, component:, scope:) }
    let(:first_proposal) { proposals.first }
    let(:last_proposal) { proposals.last }
    let!(:proposal_comment) { create(:comment, commentable: first_proposal) }
    let!(:proposal_follow) { create(:follow, followable: last_proposal) }

    before do
      create(:proposal, component:, scope: scope2)
      create(:proposal, component:, scope: nil)
      visit_component
    end

    it "can be filtered by scope" do
      within "form.new_filter" do
        expect(page).to have_content(/Scope/i)
      end
    end

    context "when selecting the global scope" do
      it "lists the filtered proposals", :slow do
        within "#dropdown-menu-filters div.filter-container", text: "Scope" do
          uncheck "All"
          check "Global"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 1)
      end
    end

    context "when selecting one scope" do
      it "lists the filtered proposals", :slow do
        within "#dropdown-menu-filters div.filter-container", text: "Scope" do
          uncheck "All"
          check scope.name[I18n.locale.to_s]
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
      end

      it "can be ordered by most commented and most followed after filtering" do
        within "#dropdown-menu-filters div.filter-container", text: "Scope" do
          uncheck "All"
          check scope.name[I18n.locale.to_s]
        end

        within "#dropdown-menu-order" do
          click_link "Most commented"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_selector("[id^='proposals__proposal']:first-child", text: translated(first_proposal.title))

        within "#dropdown-menu-order" do
          click_link "Most followed"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_selector("[id^='proposals__proposal']:first-child", text: translated(last_proposal.title))
      end
    end

    context "when selecting the global scope and another scope" do
      it "lists the filtered proposals", :slow do
        within "#dropdown-menu-filters div.filter-container", text: "Scope" do
          uncheck "All"
          check "Global"
          check scope.name[I18n.locale.to_s]
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 3)
      end
    end

    context "when unselecting the selected scope" do
      it "lists the filtered proposals" do
        within "#dropdown-menu-filters div.filter-container", text: "Scope" do
          uncheck "All"
          check scope.name[I18n.locale.to_s]
          check "Global"
          uncheck scope.name[I18n.locale.to_s]
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 1)
      end
    end

    context "when process is related to a scope" do
      let(:participatory_process) { scoped_participatory_process }

      it "cannot be filtered by scope" do
        visit_component

        within "form.new_filter" do
          expect(page).not_to have_content(/Scope/i)
        end
      end

      context "with subscopes" do
        let!(:subscopes) { create_list(:subscope, 5, parent: scope) }

        it "can be filtered by scope" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_content(/Scope/i)
          end
        end
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
          create(:proposal, :accepted, component:, scope:)
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
          create(:proposal, :rejected, component:, scope:)
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
          let!(:proposal) { create(:proposal, :accepted_not_published, component:, scope:) }

          before do
            create(:proposal, :accepted, component:, scope:)

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
              expect(page).not_to have_content("Accepted")
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
            expect(page).not_to have_content(/Status/i)
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
          expect(page).not_to have_content(/Status/i)
        end
      end
    end
  end

  context "when filtering proposals by CATEGORY", :slow do
    context "when the user is logged in" do
      let!(:category2) { create(:category, participatory_space: participatory_process) }
      let!(:category3) { create(:category, participatory_space: participatory_process) }
      let!(:proposal1) { create(:proposal, component:, category:) }
      let!(:proposal2) { create(:proposal, component:, category: category2) }
      let!(:proposal3) { create(:proposal, component:, category: category3) }
      let!(:proposal4) { create(:proposal, component:, category:) }
      let!(:proposal1_comment) { create(:comment, commentable: proposal1) }
      let!(:proposal4_follow) { create(:follow, followable: proposal4) }

      before do
        login_as user, scope: :user
      end

      it "can be filtered by a category" do
        visit_component

        within "#dropdown-menu-filters div.filter-container", text: "Category" do
          uncheck "All"
          check category.name[I18n.locale.to_s]
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
      end

      it "can be filtered by two categories" do
        visit_component

        within "#dropdown-menu-filters div.filter-container", text: "Category" do
          uncheck "All"
          check category.name[I18n.locale.to_s]
          check category2.name[I18n.locale.to_s]
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 3)
      end

      it "can be ordered by most commented and most followed after filtering" do
        visit_component

        within "#dropdown-menu-filters div.filter-container", text: "Category" do
          uncheck "All"
          check category.name[I18n.locale.to_s]
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)

        within "#dropdown-menu-order" do
          click_link "Most commented"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_selector("[id^='proposals__proposal']:first-child", text: translated(proposal1.title))

        within "#dropdown-menu-order" do
          click_link "Most followed"
        end

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_selector("[id^='proposals__proposal']:first-child", text: translated(proposal4.title))
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

        it "can be filtered by supported" do
          within "form.new_filter" do
            expect(page).to have_content(/Supported/i)
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

        it "cannot be filtered by supported" do
          within "form.new_filter" do
            expect(page).not_to have_content(/Supported/i)
          end
        end
      end
    end

    context "when the user is NOT logged in" do
      it "cannot be filtered by activity" do
        visit_component
        within "form.new_filter" do
          expect(page).not_to have_content(/Activity/i)
        end
      end
    end
  end

  context "when filtering proposals by TYPE" do
    context "when there are amendments to proposals" do
      let!(:proposal) { create(:proposal, component:, scope:) }
      let!(:emendation) { create(:proposal, component:, scope:) }
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
        before do
          component.update!(settings: { amendments_enabled: true })
        end

        context "and amendments_visbility component step_setting is set to 'participants'" do
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
              let!(:new_emendation) { create(:proposal, component:, scope:) }
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

              it "lists only their amendments" do
                within "#dropdown-menu-filters div.filter-container", text: "Type" do
                  choose "Amendments"
                end
                expect(page).to have_css("[id^='proposals__proposal']", count: 1)
                expect(page).to have_content("Amendment", count: 2)
                expect(page).to have_content(translated(new_emendation.title))
                expect(page).not_to have_content(translated(emendation.title))
              end
            end

            context "and has NOT amended a proposal" do
              before do
                login_as user, scope: :user
                visit_component
              end

              it "cannot be filtered by type" do
                within "form.new_filter" do
                  expect(page).not_to have_content(/Type/i)
                end
              end
            end
          end

          context "when the user is NOT logged in" do
            before do
              visit_component
            end

            it "cannot be filtered by type" do
              within "form.new_filter" do
                expect(page).not_to have_content(/Type/i)
              end
            end
          end
        end
      end

      context "when amendments_enabled component setting is NOT enabled" do
        before do
          component.update!(settings: { amendments_enabled: false })
        end

        context "and amendments_visbility component step_setting is set to 'participants'" do
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
              let!(:new_emendation) { create(:proposal, component:, scope:) }
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
