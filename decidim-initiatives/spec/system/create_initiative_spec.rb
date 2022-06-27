# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create :organization, available_authorizations: ["dummy_authorization_handler"] }
  let!(:authorized_user) { create(:user, :confirmed, organization:) }
  let!(:authorization) { create(:authorization, user: authorized_user) }
  let(:login) { true }

  shared_examples "initiatives path redirection" do
    it "redirects to initiatives path" do
      accept_confirm do
        click_link("Send my initiative")
      end

      expect(page).to have_current_path("/initiatives")
    end
  end

  before do
    switch_to_host(organization.host)
    login_as(authorized_user, scope: :user) if authorized_user && login
    visit decidim_initiatives.initiatives_path
  end

  describe "create initiative verification" do
    context "when the user is logged in" do
      context "and they're verified" do
        it "they are taken to the initiative form" do
          click_link "New initiative"
          expect(page).to have_content("Which initiative do you want to launch")
        end
      end

      context "and they aren't verified" do
        let(:authorization) { nil }

        it "they need to verify" do
          click_button "New initiative"
          expect(page).to have_content("Authorization required")
        end

        it "they are redirected to the initiative form after verifying" do
          click_button "New initiative"
          click_link "View authorizations"
          click_link "Example authorization"
          fill_in "Document number", with: "123456789X"
          click_button "Send"
          expect(page).to have_content("Which initiative do you want to launch")
        end
      end
    end

    context "when they aren't logged in" do
      let(:login) { false }

      it "they need to login in" do
        click_button "New initiative"
        expect(page).to have_content("Please sign in")
      end

      context "when they are verified" do
        it "they are redirected to the initiative form after log in" do
          click_button "New initiative"
          fill_in "Email", with: authorized_user.email
          fill_in "Password", with: "decidim123456789"
          click_button "Log in"

          expect(page).to have_content("Which initiative do you want to launch")
        end
      end

      context "when they aren't verified" do
        before do
          Decidim::Authorization.delete_all
        end

        it "they are shown an error" do
          click_button "New initiative"
          fill_in "Email", with: authorized_user.email
          fill_in "Password", with: "decidim123456789"
          click_button "Log in"

          expect(page).to have_content("You are not authorized to perform this action")
        end
      end
    end
  end

  describe "creating an initiative" do
    context "without validation" do
      let(:initiative_type_minimum_committee_members) { 2 }
      let(:signature_type) { "any" }
      let(:initiative_type_promoting_committee_enabled) { true }
      let(:initiative_type) do
        create(:initiatives_type,
               organization:,
               minimum_committee_members: initiative_type_minimum_committee_members,
               promoting_committee_enabled: initiative_type_promoting_committee_enabled,
               signature_type:)
      end
      let!(:other_initiative_type) { create(:initiatives_type, organization:) }
      let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }
      let!(:other_initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }

      before do
        click_link "New initiative"
      end

      context "and select initiative type" do
        it "offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("Initiatives are a means by which the participants can intervene so that the organization can undertake actions in defence of the general interest. Which initiative do you want to launch?")
          end
        end

        it "shows the available initiative types" do
          within "main" do
            expect(page).to have_content(translated(initiative_type.title, locale: :en))
            expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative_type.description, locale: :en), tags: []))
          end
        end

        it "do not show initiative types without related scopes" do
          within "main" do
            expect(page).not_to have_content(translated(other_initiative_type.title, locale: :en))
            expect(page).not_to have_content(ActionView::Base.full_sanitizer.sanitize(translated(other_initiative_type.description, locale: :en), tags: []))
          end
        end
      end

      context "and fill basic data" do
        before do
          find_button("I want to promote this initiative").click
        end

        it "has a hidden field with the selected initiative type" do
          expect(page).to have_xpath("//input[@id='initiative_type_id']", visible: :all)
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
        end

        it "have fields for title and description" do
          expect(page).to have_xpath("//input[@id='initiative_title']")
          expect(page).to have_xpath("//input[@id='initiative_description']", visible: :all)
        end

        it "offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("What does the initiative consist of? Write down the title and description. We recommend a short and concise title and a description focused on the proposed solution.")
          end
        end
      end

      context "when there is only one initiative type" do
        let!(:other_initiative_type) { nil }

        it "doesn't displays initiative types" do
          expect(page).not_to have_current_path(decidim_initiatives.create_initiative_path(id: :select_initiative_type))
        end

        it "doesn't display the 'choose' step" do
          within ".wizard__steps" do
            expect(page).not_to have_content("Choose")
          end
        end

        it "has a hidden field with the selected initiative type" do
          expect(page).to have_xpath("//input[@id='initiative_type_id']", visible: :all)
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
        end

        it "have fields for title and description" do
          expect(page).to have_xpath("//input[@id='initiative_title']")
          expect(page).to have_xpath("//input[@id='initiative_description']", visible: :all)
        end

        it "offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("What does the initiative consist of? Write down the title and description. We recommend a short and concise title and a description focused on the proposed solution.")
          end
        end
      end

      context "when Show similar initiatives" do
        let!(:initiative) { create(:initiative, organization:) }

        before do
          find_button("I want to promote this initiative").click
          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click
        end

        it "similar initiatives view is shown" do
          expect(page).to have_content("Compare")
        end

        it "offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("If any of the following initiatives is similar to yours we encourage you to sign it. Your proposal will have more possibilities to get done.")
          end
        end

        it "contains data about the similar initiative found" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
          expect(page).to have_content(initiative.author_name)
        end
      end

      context "when create initiative" do
        let(:initiative) { build(:initiative) }

        context "when there is only one initiative type" do
          let!(:other_initiative_type) { nil }

          before do
            fill_in "Title", with: translated(initiative.title, locale: :en)
            fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
            find_button("Continue").click
          end

          it "have no 'Initiative type' grey field" do
            expect(page).not_to have_content("Initiative type")
            expect(page).not_to have_css("#type_description")
          end
        end

        context "when there are several initiatives type" do
          before do
            find_button("I want to promote this initiative").click
            fill_in "Title", with: translated(initiative.title, locale: :en)
            fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
            find_button("Continue").click
          end

          it "create view is shown" do
            expect(page).to have_content("Create")
          end

          it "offers contextual help" do
            within ".callout.secondary" do
              expect(page).to have_content("Review the content of your initiative. Is your title easy to understand? Is the objective of your initiative clear?")
              expect(page).to have_content("You have to choose the type of signature. In-person, online or a combination of both")
              expect(page).to have_content("Which is the geographic scope of the initiative?")
            end
          end

          it "shows information collected in previous steps already filled" do
            expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
            expect(find(:xpath, "//input[@id='initiative_title']").value).to eq(translated(initiative.title, locale: :en))
            expect(find(:xpath, "//input[@id='initiative_description']", visible: :all).value).to eq(translated(initiative.description, locale: :en))
          end

          context "when only one signature collection and scope are available" do
            let(:other_initiative_type_scope) { nil }
            let(:initiative_type) { create(:initiatives_type, organization:, minimum_committee_members: initiative_type_minimum_committee_members, signature_type: "offline") }

            it "hides and automatically selects the values" do
              expect(page).not_to have_content("Signature collection type")
              expect(page).not_to have_content("Scope")
              expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
              expect(find(:xpath, "//input[@id='initiative_signature_type']", visible: :all).value).to eq("offline")
            end
          end

          context "when the scope isn't selected" do
            it "shows an error" do
              select("Online", from: "Signature collection type")
              find_button("Continue").click
              expect(page).to have_content("There's an error in this field")
            end
          end

          context "when the initiative type does not enable custom signature end date" do
            it "does not show the signature end date" do
              expect(page).not_to have_content("End of signature collection period")
            end
          end

          context "when the initiative type enables custom signature end date" do
            let(:initiative_type) { create(:initiatives_type, :custom_signature_end_date_enabled, organization:, minimum_committee_members: initiative_type_minimum_committee_members, signature_type: "offline") }

            it "shows the signature end date" do
              expect(page).to have_content("End of signature collection period")
            end
          end

          context "when the initiative type does not enable area" do
            it "does not show the area" do
              expect(page).not_to have_content("Area")
            end
          end

          context "when the initiative type enables area" do
            let(:initiative_type) { create(:initiatives_type, :area_enabled, organization:, minimum_committee_members: initiative_type_minimum_committee_members, signature_type: "offline") }

            it "shows the area" do
              expect(page).to have_content("Area")
            end
          end
        end
      end

      context "when there's a promoter committee" do
        let(:initiative) { build(:initiative, organization:, scoped_type: initiative_type_scope) }

        before do
          find_button("I want to promote this initiative").click

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click

          select("Online", from: "Signature collection type")
          select(translated(initiative_type_scope.scope.name, locale: :en), from: "Scope")
          find_button("Continue").click
        end

        it "shows the promoter committee" do
          expect(page).to have_content("Promoter committee")
        end

        it "offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("This kind of initiative requires a Promoting Commission consisting of at least #{initiative_type_minimum_committee_members} people (attestors). You must share the following link with the other people that are part of this initiative. When your contacts receive this link they will have to follow the indicated steps.")
          end
        end

        it "contains a link to invite other users" do
          expect(page).to have_content("/committee_requests/new")
        end

        it "contains a button to continue with next step" do
          expect(page).to have_content("Continue")
        end

        context "when minimum committee size is zero" do
          let(:initiative_type_minimum_committee_members) { 0 }

          it "skips to next step" do
            within(".step--active") do
              expect(page).not_to have_content("Promoter committee")
              expect(page).to have_content("Finish")
            end
          end
        end

        context "and it's disabled at the type scope" do
          let(:initiative_type) { create(:initiatives_type, organization:, promoting_committee_enabled: false, signature_type:) }

          it "skips the promoting committee settings" do
            expect(page).not_to have_content("Promoter committee")
            expect(page).to have_content("Finish")
          end
        end
      end

      context "when finish" do
        let(:initiative) { build(:initiative) }

        before do
          find_button("I want to promote this initiative").click

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click

          select(translated(initiative_type_scope.scope.name, locale: :en), from: "Scope")
          select("Online", from: "Signature collection type")
          dynamically_attach_file(:initiative_documents, Decidim::Dev.asset("Exampledocument.pdf"))
          find_button("Continue").click
        end

        context "when minimum committee size is above zero" do
          before do
            find_link("Continue").click
          end

          it "finish view is shown" do
            expect(page).to have_content("Finish")
          end

          it "Offers contextual help" do
            within ".callout.secondary" do
              expect(page).to have_content("Congratulations! Your initiative has been successfully created.")
            end
          end

          it "displays an edit link" do
            within ".actions" do
              expect(page).to have_link("Edit my initiative")
            end
          end
        end

        context "when minimum committee size is zero" do
          let(:initiative) { build(:initiative, organization:, scoped_type: initiative_type_scope) }
          let(:initiative_type_minimum_committee_members) { 0 }

          it "displays a send to technical validation link" do
            expected_message = "You are going to send the initiative for an admin to review it and publish it. Once published you will not be able to edit it. Are you sure?"
            within ".actions" do
              expect(page).to have_link("Send my initiative")
              expect(page).to have_selector "a[data-confirm='#{expected_message}']"
            end
          end

          it_behaves_like "initiatives path redirection"
        end

        context "when promoting committee is not enabled" do
          let(:initiative) { build(:initiative, organization:, scoped_type: initiative_type_scope) }
          let(:initiative_type_promoting_committee_enabled) { false }
          let(:initiative_type_minimum_committee_members) { 0 }

          expected_message = "You are going to send the initiative for an admin to review it and publish it. Once published you will not be able to edit it. Are you sure?"

          it "displays a send to technical validation link" do
            within ".actions" do
              expect(page).to have_link("Send my initiative")
              expect(page).to have_selector "a[data-confirm='#{expected_message}']"
            end
          end

          it_behaves_like "initiatives path redirection"
        end
      end
    end
  end
end
