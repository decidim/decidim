# frozen_string_literal: true

require "spec_helper"

describe "Private Assemblies" do
  let!(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, :published, organization:) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user2) { create(:user, :confirmed, organization:) }
  let!(:assembly_private_user) { create(:assembly_private_user, user: other_user, privatable_to: private_assembly) }
  let!(:assembly_private_user2) { create(:assembly_private_user, user: other_user2, privatable_to: private_assembly) }

  context "when there are private assemblies" do
    context "and the assembly is transparent" do
      let!(:private_assembly) { create(:assembly, :published, organization:, private_space: true, is_transparent: true) }

      context "and no user is logged in" do
        before do
          switch_to_host(organization.host)
          visit decidim_assemblies.assemblies_path(locale: I18n.locale)
        end

        it "lists all the assemblies" do
          within "#assemblies-grid" do
            within "#assemblies-grid h2" do
              expect(page).to have_content("2")
            end

            expect(page).to have_content(translated(assembly.title, locale: :en))
            expect(page).to have_css(".card__grid", count: 2)

            expect(page).to have_content(translated(private_assembly.title, locale: :en))
          end
        end
      end

      context "when user is logged in" do
        context "when is not an assembly private user" do
          before do
            switch_to_host(organization.host)
            login_as user, scope: :user
            visit decidim_assemblies.assemblies_path(locale: I18n.locale)
          end

          it "lists all the assemblies" do
            within "#assemblies-grid" do
              within "#assemblies-grid h2" do
                expect(page).to have_content("2")
              end

              expect(page).to have_content(translated(assembly.title, locale: :en))
              expect(page).to have_css(".card__grid", count: 2)

              expect(page).to have_content(translated(private_assembly.title, locale: :en))
            end
          end
        end

        context "when the user is admin" do
          before do
            switch_to_host(organization.host)
            login_as admin, scope: :user
            visit decidim_assemblies.assemblies_path(locale: I18n.locale)
          end

          it "does not show the privacy warning in attachments admin" do
            visit decidim_admin_assemblies.assembly_attachments_path(private_assembly)
            within "#attachments" do
              expect(page).to have_no_content("Any participant could share this document to others")
            end
          end
        end
      end
    end

    context "when the assembly is not transparent" do
      let!(:private_assembly) { create(:assembly, :published, organization:, private_space: true, is_transparent: false) }

      context "and no user is logged in" do
        before do
          switch_to_host(organization.host)
          visit decidim_assemblies.assemblies_path(locale: I18n.locale)
        end

        it "does not list the private assembly" do
          within "#assemblies-grid" do
            within "#assemblies-grid h2" do
              expect(page).to have_content("1")
            end

            expect(page).to have_content(translated(assembly.title, locale: :en))
            expect(page).to have_css(".card__grid", count: 1)

            expect(page).to have_no_content(translated(private_assembly.title, locale: :en))
          end
        end
      end

      context "when user is logged in and is not an assembly private user" do
        context "when the user is not admin" do
          before do
            switch_to_host(organization.host)
            login_as user, scope: :user
            visit decidim_assemblies.assemblies_path(locale: I18n.locale)
          end

          it "does not list the private assembly" do
            within "#assemblies-grid" do
              within "#assemblies-grid h2" do
                expect(page).to have_content("1")
              end

              expect(page).to have_content(translated(assembly.title, locale: :en))
              expect(page).to have_css(".card__grid", count: 1)

              expect(page).to have_no_content(translated(private_assembly.title, locale: :en))
            end
          end
        end

        context "when the user is admin" do
          before do
            switch_to_host(organization.host)
            login_as admin, scope: :user
            visit decidim_assemblies.assemblies_path(locale: I18n.locale)
          end

          it "lists private assemblies" do
            within "#assemblies-grid" do
              within "#assemblies-grid h2" do
                expect(page).to have_content("2")
              end

              expect(page).to have_content(translated(assembly.title, locale: :en))
              expect(page).to have_content(translated(private_assembly.title, locale: :en))
              expect(page).to have_css(".card__grid", count: 2)
            end
          end

          it "links to the individual assembly page" do
            first(".card__grid-text", text: translated(private_assembly.title, locale: :en)).click

            expect(page).to have_current_path decidim_assemblies.assembly_path(private_assembly, locale: I18n.locale)
            expect(page).to have_content "This is a private assembly"
          end

          it "shows the privacy warning in attachments admin" do
            visit decidim_admin_assemblies.assembly_attachments_path(private_assembly)
            within "#attachments" do
              expect(page).to have_content("Any participant could share this document to others")
            end
          end
        end
      end

      context "when user is logged in and is an assembly private user" do
        before do
          switch_to_host(organization.host)
          login_as other_user, scope: :user
          visit decidim_assemblies.assemblies_path(locale: I18n.locale)
        end

        it "lists private assemblies" do
          within "#assemblies-grid" do
            within "#assemblies-grid h2" do
              expect(page).to have_content("2")
            end

            expect(page).to have_content(translated(assembly.title, locale: :en))
            expect(page).to have_content(translated(private_assembly.title, locale: :en))
            expect(page).to have_css(".card__grid", count: 2)
          end
        end

        it "links to the individual assembly page" do
          first(".card__grid-text", text: translated(private_assembly.title, locale: :en)).click

          expect(page).to have_current_path decidim_assemblies.assembly_path(private_assembly, locale: I18n.locale)
          expect(page).to have_content "This is a private assembly"
        end
      end
    end
  end
end
