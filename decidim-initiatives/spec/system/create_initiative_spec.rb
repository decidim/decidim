# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:authorized_user) { create(:user, :confirmed, organization: organization) }

  shared_examples "initiatives path redirection" do
    it "redirects to initiatives path" do
      accept_confirm do
        click_link("Send my initiative")
      end

      expect(page).to have_current_path("/initiatives")
    end
  end

  context "when access to functionality" do
    before do
      switch_to_host(organization.host)

      create(:authorization, user: authorized_user)
      login_as authorized_user, scope: :user

      visit decidim_initiatives.initiatives_path
    end

    it "Initiatives page contains a create initiative button" do
      expect(page).to have_content("New initiative")
    end
  end

  context "when creates an initiative" do
    before do
      switch_to_host(organization.host)

      create(:authorization, user: authorized_user)
      login_as authorized_user, scope: :user

      visit decidim_initiatives.initiatives_path
    end

    context "without validation" do
      let(:initiative_type_minimum_committee_members) { 2 }
      let(:signature_type) { "any" }
      let(:initiative_type_promoting_committee_enabled) { true }
      let(:initiative_type) do
        create(:initiatives_type,
               organization: organization,
               minimum_committee_members: initiative_type_minimum_committee_members,
               promoting_committee_enabled: initiative_type_promoting_committee_enabled,
               signature_type: signature_type)
      end
      let!(:other_initiative_type) { create(:initiatives_type, organization: organization) }
      let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }
      let!(:other_initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }

      before do
        switch_to_host(organization.host)
        create(:authorization, user: authorized_user)
        login_as authorized_user, scope: :user

        visit decidim_initiatives.create_initiative_path(id: :select_initiative_type)
      end

      context "and select initiative type" do
        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("Citizen initiatives are a means by which the citizenship can intervene so that the City Council can undertake actions in defence of the general interest that are within fields of municipal jurisdiction. Which initiative do you want to launch?")
          end
        end

        it "Shows the available initiative types" do
          within "main" do
            expect(page).to have_content(translated(initiative_type.title, locale: :en))
            expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative_type.description, locale: :en), tags: []))
          end
        end

        it "Do not show initiative types without related scopes" do
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

        it "Has a hidden field with the selected initiative type" do
          expect(page).to have_xpath("//input[@id='initiative_type_id']", visible: false)
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: false).value).to eq(initiative_type.id.to_s)
        end

        it "Have fields for title and description" do
          expect(page).to have_xpath("//input[@id='initiative_title']")
          expect(page).to have_xpath("//input[@id='initiative_description']", visible: false)
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("What does the initiative consist of? Write down the title and description. We recommend a short and concise title and a description focused on the proposed solution.")
          end
        end
      end

      context "when Show similar initiatives" do
        let!(:initiative) { create(:initiative, organization: organization) }

        before do
          find_button("I want to promote this initiative").click
          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click
        end

        it "Similar initiatives view is shown" do
          expect(page).to have_content("Compare")
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("If any of the following initiatives is similar to yours we encourage you to sign it. Your proposal will have more possibilities to get done.")
          end
        end

        it "Contains data about the similar initiative found" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
          expect(page).to have_content(initiative.author_name)
        end
      end

      context "when Create initiative" do
        let(:initiative) { build(:initiative) }

        before do
          find_button("I want to promote this initiative").click
          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click
        end

        it "Create view is shown" do
          expect(page).to have_content("Create")
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("Review the content of your initiative. Is your title easy to understand? Is the objective of your initiative clear?")
            expect(page).to have_content("You have to choose the type of signature. In-person, online or a combination of both")
            expect(page).to have_content("Which is the geographic scope of the initiative? City, district?")
          end
        end

        it "Information collected in previous steps is already filled" do
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: false).value).to eq(initiative_type.id.to_s)
          expect(find(:xpath, "//input[@id='initiative_title']").value).to eq(translated(initiative.title, locale: :en))
          expect(find(:xpath, "//input[@id='initiative_description']", visible: false).value).to eq(translated(initiative.description, locale: :en))
        end

        context "when only one signature collection and scope are available" do
          let(:other_initiative_type_scope) { nil }
          let(:initiative_type) { create(:initiatives_type, organization: organization, minimum_committee_members: initiative_type_minimum_committee_members, signature_type: "offline") }

          it "hides and automatically selects the values" do
            expect(page).not_to have_content("Signature collection type")
            expect(page).not_to have_content("Scope")
            expect(find(:xpath, "//input[@id='initiative_type_id']", visible: false).value).to eq(initiative_type.id.to_s)
            expect(find(:xpath, "//input[@id='initiative_signature_type']", visible: false).value).to eq("offline")
          end
        end

        context "when the initiative type does not enable custom signature end date" do
          it "does not show the signature end date" do
            expect(page).not_to have_content("End of signature collection period")
          end
        end

        context "when the initiative type enables custom signature end date" do
          let(:initiative_type) { create(:initiatives_type, :custom_signature_end_date_enabled, organization: organization, minimum_committee_members: initiative_type_minimum_committee_members, signature_type: "offline") }

          it "shows the signature end date" do
            expect(page).to have_content("End of signature collection period")
          end
        end
      end

      context "when Promotal committee" do
        let(:initiative) { build(:initiative, organization: organization, scoped_type: initiative_type_scope) }

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

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("This kind of citizen initiative requires a Promoting Commission consisting of at least #{initiative_type_minimum_committee_members} people (attestors). You must share the following link with the other people that are part of this initiative. When your contacts receive this link they will have to follow the indicated steps.")
          end
        end

        it "Contains a link to invite other users" do
          expect(page).to have_content("/committee_requests/new")
        end

        it "Contains a button to continue with next step" do
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
          let(:initiative_type) { create(:initiatives_type, organization: organization, promoting_committee_enabled: false, signature_type: signature_type) }

          it "skips the promoting committee settings" do
            expect(page).not_to have_content("Promoter committee")
            expect(page).to have_content("Finish")
          end
        end
      end

      context "when Finish", processing_uploads_for: Decidim::AttachmentUploader do
        let(:initiative) { build(:initiative) }

        before do
          find_button("I want to promote this initiative").click

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click

          select(translated(initiative_type_scope.scope.name, locale: :en), from: "Scope")
          select("Online", from: "Signature collection type")
          fill_in :initiative_attachment_title, with: "Document name"
          attach_file :initiative_attachment_file, Decidim::Dev.asset("Exampledocument.pdf")
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
              expect(page).to have_content("Congratulations! Your citizen initiative has been successfully created.")
            end
          end

          it "displays an edit link" do
            within ".column.actions" do
              expect(page).to have_link("Edit my initiative")
            end
          end
        end

        context "when minimum committee size is zero" do
          let(:initiative) { build(:initiative, organization: organization, scoped_type: initiative_type_scope) }
          let(:initiative_type_minimum_committee_members) { 0 }

          it "displays a send to technical validation link" do
            within ".column.actions" do
              expect(page).to have_link("Send my initiative")
              expect(page).to have_selector "a[data-confirm='Confirm']"
            end
          end

          it_behaves_like "initiatives path redirection"
        end

        context "when promoting committee is not enabled" do
          let(:initiative) { build(:initiative, organization: organization, scoped_type: initiative_type_scope) }
          let(:initiative_type_promoting_committee_enabled) { false }
          let(:initiative_type_minimum_committee_members) { 0 }

          it "displays a send to technical validation link" do
            within ".column.actions" do
              expect(page).to have_link("Send my initiative")
              expect(page).to have_selector "a[data-confirm='Confirm']"
            end
          end

          it_behaves_like "initiatives path redirection"
        end
      end
    end
  end
end
