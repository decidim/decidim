# frozen_string_literal: true

require "spec_helper"

describe "Filter Proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

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
          create_list(:proposal, 2, :official, component: component, scope: scope)
          create(:proposal, component: component, scope: scope)
          visit_component

          within ".filters .origin_chained_check_boxes_filter" do
            uncheck "All"
            check "Official"
          end

          expect(page).to have_css(".card--proposal", count: 2)
          expect(page).to have_content("2 PROPOSALS")
        end
      end

      context "with 'citizens' origin" do
        it "lists the filtered proposals" do
          create_list(:proposal, 2, component: component, scope: scope)
          create(:proposal, :official, component: component, scope: scope)
          visit_component

          within ".filters .origin_chained_check_boxes_filter" do
            uncheck "All"
            check "Citizens"
          end

          expect(page).to have_css(".card--proposal", count: 2)
          expect(page).to have_content("2 PROPOSALS")
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

  context "when filtering proposals by SCOPE" do
    let(:scopes_picker) { select_data_picker(:filter_scope_id, multiple: true, global_value: "global") }
    let!(:scope2) { create :scope, organization: participatory_process.organization }

    before do
      create_list(:proposal, 2, component: component, scope: scope)
      create(:proposal, component: component, scope: scope2)
      create(:proposal, component: component, scope: nil)
      visit_component
    end

    it "can be filtered by scope" do
      within "form.new_filter" do
        expect(page).to have_content(/Scope/i)
      end
    end

    context "when selecting the global scope" do
      it "lists the filtered proposals", :slow do
        within ".filters .scope_id_chained_check_boxes_filter" do
          uncheck "All"
          check "Global"
        end

        expect(page).to have_css(".card--proposal", count: 1)
        expect(page).to have_content("1 PROPOSAL")
      end
    end

    context "when selecting one scope" do
      it "lists the filtered proposals", :slow do
        within ".filters .scope_id_chained_check_boxes_filter" do
          uncheck "All"
          check scope.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card--proposal", count: 2)
        expect(page).to have_content("2 PROPOSALS")
      end
    end

    context "when selecting the global scope and another scope" do
      it "lists the filtered proposals", :slow do
        within ".filters .scope_id_chained_check_boxes_filter" do
          uncheck "All"
          check "Global"
          check scope.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card--proposal", count: 3)
        expect(page).to have_content("3 PROPOSALS")
      end
    end

    context "when unselecting the selected scope" do
      it "lists the filtered proposals" do
        within ".filters .scope_id_chained_check_boxes_filter" do
          uncheck "All"
          check scope.name[I18n.locale.to_s]
          check "Global"
          uncheck scope.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card--proposal", count: 1)
        expect(page).to have_content("1 PROPOSAL")
      end
    end

    context "when process is related to a scope" do
      let(:participatory_process) { scoped_participatory_process }

      it "cannot be filtered by scope" do
        visit_component

        within "form.new_filter" do
          expect(page).to have_no_content(/Scopes/i)
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
          create(:proposal, :accepted, component: component, scope: scope)
          visit_component

          within ".filters .state_chained_check_boxes_filter" do
            check "All"
            uncheck "All"
            check "Accepted"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")

          within ".card--proposal" do
            expect(page).to have_content("ACCEPTED")
          end
        end

        it "lists the filtered proposals" do
          create(:proposal, :rejected, component: component, scope: scope)
          visit_component

          within ".filters .state_chained_check_boxes_filter" do
            check "All"
            uncheck "All"
            check "Rejected"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")

          within ".card--proposal" do
            expect(page).to have_content("REJECTED")
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

  context "when filtering proposals by CATEGORY", :slow do
    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "can be filtered by category" do
        create_list(:proposal, 3, component: component)
        create(:proposal, component: component, category: category)

        visit_component

        within ".filters .category_id_chained_check_boxes_filter" do
          uncheck "All"
          check category.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card--proposal", count: 1)
      end
    end
  end

  context "when filtering proposals by ACTIVITY" do
    let(:active_step_id) { component.participatory_space.active_step.id }
    let!(:voted_proposal) { create(:proposal, component: component) }
    let!(:vote) { create(:proposal_vote, proposal: voted_proposal, author: user) }
    let!(:proposal_list) { create_list(:proposal, 3, component: component) }
    let!(:created_proposal) { create(:proposal, component: component, users: [user]) }

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
        expect(page).to have_css(".card--proposal", count: 1)
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

          expect(page).to have_css(".card--proposal", text: voted_proposal.title)
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
      let!(:proposal) { create(:proposal, component: component, scope: scope) }
      let!(:emendation) { create(:proposal, component: component, scope: scope) }
      let!(:amendment) { create(:amendment, amendable: proposal, emendation: emendation) }

      before do
        visit_component
      end

      context "with 'all' type" do
        it "lists the filtered proposals" do
          find('input[name="filter[type]"][value="all"]').click

          expect(page).to have_css(".card.card--proposal", count: 2)
          expect(page).to have_content("2 PROPOSALS")
          expect(page).to have_content("AMENDMENT", count: 1)
        end
      end

      context "with 'proposals' type" do
        it "lists the filtered proposals" do
          within ".filters" do
            choose "Proposals"
          end

          expect(page).to have_css(".card.card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")
          expect(page).to have_content("AMENDMENT", count: 0)
        end
      end

      context "with 'amendments' type" do
        it "lists the filtered proposals" do
          within ".filters" do
            choose "Amendments"
          end

          expect(page).to have_css(".card.card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")
          expect(page).to have_content("AMENDMENT", count: 1)
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
              let!(:new_emendation) { create(:proposal, component: component, scope: scope) }
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
                within ".filters" do
                  choose "Amendments"
                end
                expect(page).to have_css(".card.card--proposal", count: 1)
                expect(page).to have_content("1 PROPOSAL")
                expect(page).to have_content("AMENDMENT", count: 1)
                expect(page).to have_content(new_emendation.title)
                expect(page).to have_no_content(emendation.title)
              end
            end

            context "and has NOT amended a proposal" do
              before do
                login_as user, scope: :user
                visit_component
              end

              it "cannot be filtered by type" do
                within "form.new_filter" do
                  expect(page).to have_no_content(/Type/i)
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
              let!(:new_emendation) { create(:proposal, component: component, scope: scope) }
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
                within ".filters" do
                  choose "Amendments"
                end
                expect(page).to have_css(".card.card--proposal", count: 2)
                expect(page).to have_content("2 PROPOSAL")
                expect(page).to have_content("AMENDMENT", count: 2)
                expect(page).to have_content(new_emendation.title)
                expect(page).to have_content(emendation.title)
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
end
