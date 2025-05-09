# frozen_string_literal: true

require "spec_helper"

shared_context "with resources to be liked or not" do
  include_context "with a component"

  # Should be overridden and create one main resource
  let!(:resource) { nil }
  # the name of the resource to be clicked from the component view
  let(:resource_name) { nil }
  # Should be overridden and create 3 extra resources in the current component
  let!(:resources) { nil }
end

shared_examples "Like resource system specs" do
  def expect_page_not_to_include_endorsements
    expect(page).to have_no_button("Like")
    expect(page).to have_no_css("#resource-#{resource.id}-likes-count")
  end

  def visit_resource
    visit_component
    click_on resource_name
  end

  context "when likes are not enabled" do
    let(:component_traits) { [:with_endorsements_disabled] }

    context "when the user is not logged in" do
      it "does not show the like resource button and counts" do
        visit_resource
        expect_page_not_to_include_endorsements
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "does not show the like resource button and counts" do
        visit_resource
        expect_page_not_to_include_endorsements
      end
    end
  end

  context "when likes are enabled but blocked" do
    let(:component_traits) { [:with_endorsements_enabled, :with_endorsements_blocked] }

    it "shows the likes count and the like button is disabled" do
      visit_resource
      expect(page).to have_css("#resource-#{resource.id}-like-block button[disabled='true']")
    end
  end

  context "when likes are enabled" do
    let(:component_traits) { [:with_endorsements_enabled] }

    context "when the user is not logged in" do
      it "is given the option to sign in" do
        visit_resource
        within "#resource-#{resource.id}-like-block" do
          click_on "Like"
        end

        expect(page).to have_css("#loginModal", visible: :visible)
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "when the resource is not liked yet" do
        it "is able to like the resource" do
          visit_resource
          within "#resource-#{resource.id}-like-block" do
            click_on "Like"
            expect(page).to have_button("Like")
            expect(page).to have_css('svg use[href*="ri-heart-fill"]')
            expect(page).to have_css('#like-button[aria-label="Undo the like"]')
          end
        end

        it "has likes from other users" do
          author = create(:user, :confirmed, organization: resource.organization)
          create(:like, resource:, author:)
          visit_resource
          within "#endorser-list-#{resource.id}" do
            expect(page).to have_content("Liked by #{author.name}")
            click_on author.name
          end
          expect(page).to have_content("Liked by")
          within "#endorsersModal-#{resource.id}" do
            expect(page).to have_content(author.name)
            expect(page).to have_no_content(user.name)
          end
        end
      end

      context "when the resource is already liked" do
        let!(:like) { create(:like, resource:, author: user) }

        it "is not able to like it again" do
          visit_resource
          within "#resource-#{resource.id}-like-block" do
            expect(page).to have_css('svg use[href*="ri-heart-fill"]')
            expect(page).to have_css('#like-button[aria-label="Undo the like"]')
            expect(page).to have_no_css('svg use[href*="ri-heart-line"]')
          end
        end

        it "is able to undo the like" do
          visit_resource
          within "#resource-#{resource.id}-like-block" do
            expect(page).to have_css('svg use[href*="ri-heart-fill"]')
            expect(page).to have_css('#like-button[aria-label="Undo the like"]')
            click_on "Like"
            expect(page).to have_css('svg use[href*="ri-heart-line"]')
            expect(page).to have_css('#like-button[aria-label="Like"]')
            expect(page).to have_button("Like")
          end
        end

        it "can show the likes pop-up" do
          visit_resource
          within "#endorser-list-#{resource.id}" do
            expect(page).to have_content("Liked by you")
            click_on "you"
          end
          expect(page).to have_content("Liked by")
          within "#endorsersModal-#{resource.id}" do
            expect(page).to have_content(user.name)
          end
        end
      end

      context "when verification is required" do
        let(:permissions) do
          {
            like: {
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
          it "is NOT able to like" do
            visit_resource
            within "#resource-#{resource.id}-like-block" do
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

          it "IS able to like", :slow do
            visit_resource
            within "#resource-#{resource.id}-like-block" do
              expect(page).to have_css('svg use[href*="ri-heart-line"]')
              expect(page).to have_css('#like-button[aria-label="Like"]')
              click_on "Like"
              expect(page).to have_button("Like")
              expect(page).to have_css('#like-button[aria-label="Undo the like"]')
              expect(page).to have_css('svg use[href*="ri-heart-fill"]')
            end
          end
        end
      end
    end
  end
end
