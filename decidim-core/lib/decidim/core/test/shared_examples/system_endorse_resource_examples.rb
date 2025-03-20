# frozen_string_literal: true

require "spec_helper"

shared_context "with resources to be endorsed or not" do
  include_context "with a component"

  # Should be overridden and create one main resource
  let!(:resource) { nil }
  # the name of the resource to be clicked from the component view
  let(:resource_name) { nil }
  # Should be overridden and create 3 extra resources in the current component
  let!(:resources) { nil }
end

shared_examples "Endorse resource system specs" do
  def expect_page_not_to_include_endorsements
    expect(page).to have_no_button("Like")
    expect(page).to have_no_css("#resource-#{resource.id}-endorsements-count")
  end

  def visit_resource
    visit_component
    click_on resource_name
  end

  context "when endorsements are not enabled" do
    let(:component_traits) { [:with_endorsements_disabled] }

    context "when the user is not logged in" do
      it "does not show the endorse resource button and counts" do
        visit_resource
        expect_page_not_to_include_endorsements
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "does not show the endorse resource button and counts" do
        visit_resource
        expect_page_not_to_include_endorsements
      end
    end
  end

  context "when endorsements are enabled but blocked" do
    let(:component_traits) { [:with_endorsements_enabled, :with_endorsements_blocked] }

    it "shows the endorsements count and the endorse button is disabled" do
      visit_resource
      expect(page).to have_css("#resource-#{resource.id}-endorsement-block button[disabled='true']")
    end
  end

  context "when endorsements are enabled" do
    let(:component_traits) { [:with_endorsements_enabled] }

    context "when the user is not logged in" do
      it "is given the option to sign in" do
        visit_resource
        within "#resource-#{resource.id}-endorsement-block" do
          click_on "Like"
        end

        expect(page).to have_css("#loginModal", visible: :visible)
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "when the resource is not endorsed yet" do
        it "is able to endorse the resource" do
          visit_resource
          within "#resource-#{resource.id}-endorsement-block" do
            click_on "Like"
            expect(page).to have_button("Dislike")
          end
        end
      end

      context "when the resource is already endorsed" do
        let!(:endorsement) { create(:endorsement, resource:, author: user) }

        it "is not able to endorse it again" do
          visit_resource
          within "#resource-#{resource.id}-endorsement-block" do
            expect(page).to have_button("Dislike")
            expect(page).to have_no_button("Like")
          end
        end

        it "is able to undo the endorsement" do
          visit_resource
          within "#resource-#{resource.id}-endorsement-block" do
            click_on "Dislike"
            expect(page).to have_button("Like")
          end
        end
      end

      context "when verification is required" do
        let(:permissions) do
          {
            endorse: {
              authorization_handlers: {
                "dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        end

        before do
          organization.available_authorizations = ["dummy_authorization_handler"]
          organization.save!
          component.update(permissions:)
        end

        context "when user is NOT verified" do
          it "is NOT able to endorse" do
            visit_resource
            within "#resource-#{resource.id}-endorsement-block" do
              click_on "Like"
            end
            expect(page).to have_css("#authorizationModal", visible: :visible)
          end
        end

        context "when user IS verified" do
          before do
            handler_params = { user: }
            handler_name = "dummy_authorization_handler"
            handler = Decidim::AuthorizationHandler.handler_for(handler_name, handler_params)

            Decidim::Authorization.create_or_update_from(handler)
          end

          it "IS able to endorse", :slow do
            visit_resource
            within "#resource-#{resource.id}-endorsement-block" do
              click_on "Like"
            end
            expect(page).to have_button("Dislike")
          end
        end
      end

      context "when user being a part of a group" do
        let(:component_traits) { [:with_endorsements_enabled] }
        let!(:user_group) do
          create(
            :user_group,
            :verified,
            name: "Tester's Organization",
            nickname: "test_org",
            email: "t.mail.org@example.org",
            users: [user],
            organization:
          )
        end

        before do
          organization.update(user_groups_enabled:)
          login_as user, scope: :user
          visit_resource
        end

        context "when organization is not allowing user groups" do
          let(:user_groups_enabled) { false }

          it "is able to endorse the resource" do
            within "#resource-#{resource.id}-endorsement-block" do
              click_on "Like"
              expect(page).to have_button("Dislike")
            end
          end
        end

        context "when organization allows user groups" do
          let(:user_groups_enabled) { true }

          it "opens a modal where you select identity as a user or a group" do
            click_on "Like"
            expect(page).to have_content("Select identity")
            expect(page).to have_content("Tester's Organization")
            expect(page).to have_content(user.name)
          end

          def add_likes
            click_on "Like"
            within "#user-identities" do
              click_on "Tester's Organization"
              click_on user.name
              click_on "Done"
            end
            visit_resource
            click_on "Dislike"
          end

          context "when both identities picked" do
            it "likes the post as a group and a user" do
              add_likes

              within ".identities-modal__list" do
                expect(page).to have_css(".is-selected", count: 2)
              end
            end
          end

          context "when like cancelled as a user" do
            it "does not cancel group like" do
              add_likes
              find(".is-selected", match: :first).click
              click_on "Done"
              visit current_path
              click_on "Like"

              within ".identities-modal__list" do
                expect(page).to have_css(".is-selected", count: 1)
                within ".is-selected" do
                  expect(page).to have_content("Tester's Organization")
                end
              end
            end
          end

          context "when like cancelled as a group" do
            it "does not cancel user like" do
              add_likes
              page.all(".is-selected")[1].click
              click_on "Done"
              visit current_path
              click_on "Dislike"

              within ".identities-modal__list" do
                expect(page).to have_css(".is-selected", count: 1)
                within ".is-selected" do
                  expect(page).to have_text(user.name, exact: true)
                end
              end
            end
          end
        end
      end
    end
  end
end
