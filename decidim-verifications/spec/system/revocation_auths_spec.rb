# frozen_string_literal: true

require "spec_helper"

describe "Authorizations revocation flow" do
  let(:organization) { create(:organization, available_authorizations: [authorization_name, other_authorization_name]) }
  let(:authorization_name) { "dummy_authorization_handler" }
  let(:other_authorization_name) { "another_dummy_authorization_handler" }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:regular_user) { create(:user, :confirmed, organization:) }
  let(:managed_user) { create(:user, :confirmed, :managed, organization:) }
  let(:other_method_user) { create(:user, :confirmed, organization:) }
  let(:workflow_fullname) { Decidim::Verifications::Adapter.from_element(authorization_name).fullname }
  let(:total_option_label) { t("decidim.admin.menu.authorization_revocation.total_verified") }
  let(:impersonated_option_label) { t("decidim.admin.menu.authorization_revocation.impersonated_only") }
  let(:date_field_locator) { "revocations_#{authorization_name}_before_date_input_date" }

  let!(:regular_authorization) { create(:authorization, name: authorization_name, user: regular_user) }
  let!(:managed_authorization) { create(:authorization, name: authorization_name, user: managed_user) }
  let!(:other_method_authorization) { create(:authorization, name: other_authorization_name, user: other_method_user) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.authorization_workflows_path
  end

  it "shows the intro and a section per available method with its verification counts" do
    expect(page).to have_text(t("decidim.admin.authorization_workflows.index.title"))
    expect(page).to have_text(t("decidim.admin.authorization_workflows.index.intro"))
    expect(page).to have_css("h2", text: workflow_fullname)

    within "[data-revocations='#{authorization_name}']" do
      expect(find("label", text: total_option_label)).to have_text("2")
      expect(find("label", text: impersonated_option_label)).to have_text("1")
    end
  end

  context "when a verification method has no granted authorizations" do
    let!(:regular_authorization) { create(:authorization, :pending, name: authorization_name, user: regular_user) }
    let!(:managed_authorization) { create(:authorization, :pending, name: authorization_name, user: managed_user) }
    let!(:other_method_authorization) { create(:authorization, :pending, name: other_authorization_name, user: other_method_user) }

    it "disables the total and impersonated radios" do
      within "[data-revocations='#{authorization_name}']" do
        expect(page).to have_field(total_option_label, disabled: true)
        expect(page).to have_field(impersonated_option_label, disabled: true)
      end
    end
  end

  context "when selecting a revocation option" do
    it "shows the date field from the start and the sticky bar once an option is picked" do
      within "[data-revocations='#{authorization_name}']" do
        expect(page).to have_css("[data-revocations-date]", visible: :visible)
        expect(page).to have_text(t("decidim.admin.menu.authorization_revocation.before_date_hint"))
        expect(page).to have_text(t("decidim.admin.menu.authorization_revocation.before_date_info"))
        expect(page).to have_no_button(t("decidim.admin.menu.authorization_revocation.revoke_button"))

        choose total_option_label

        expect(page).to have_button(t("decidim.admin.menu.authorization_revocation.revoke_button"))
      end
    end
  end

  context "when confirming a revocation" do
    it "includes the count and the method name in the impersonated confirm dialog" do
      message = accept_confirm do
        within "[data-revocations='#{authorization_name}']" do
          choose impersonated_option_label
          click_button t("decidim.admin.menu.authorization_revocation.revoke_button")
        end
      end

      expect(message).to include(
        strip_tags(I18n.t("decidim.admin.menu.authorization_revocation.destroy.confirm_message.impersonated.all_html", count: 1, workflow: workflow_fullname))
      )
    end

    it "includes the count and the method name in the total confirm dialog" do
      message = accept_confirm do
        within "[data-revocations='#{authorization_name}']" do
          choose total_option_label
          click_button t("decidim.admin.menu.authorization_revocation.revoke_button")
        end
      end

      expect(message).to include(
        strip_tags(I18n.t("decidim.admin.menu.authorization_revocation.destroy.confirm_message.total.all_html", count: 2, workflow: workflow_fullname))
      )
    end

    context "with authorizations created on different dates" do
      let!(:regular_authorization) { create(:authorization, name: authorization_name, user: regular_user, created_at: Date.new(2020, 1, 1)) }
      let!(:managed_authorization) { create(:authorization, name: authorization_name, user: managed_user, created_at: Date.new(2024, 6, 1)) }

      it "includes the picked date and the recalculated count in the total confirm dialog" do
        message = accept_confirm do
          within "[data-revocations='#{authorization_name}']" do
            choose total_option_label
            fill_in_datepicker date_field_locator, with: "15/03/2022"
            find("[data-revocations-date] p", match: :first).click

            expect(page).to have_css("[data-revocations-bar] [type='submit'][data-confirm*='15/03/2022']")
            click_button t("decidim.admin.menu.authorization_revocation.revoke_button")
          end
        end

        expect(message).to include(
          strip_tags(I18n.t("decidim.admin.menu.authorization_revocation.destroy.confirm_message.total.before_date_html", count: 1, workflow: workflow_fullname, date: "15/03/2022"))
        )
      end

      it "shows a zero count in the confirm dialog when the picked date predates every authorization" do
        message = accept_confirm do
          within "[data-revocations='#{authorization_name}']" do
            choose total_option_label
            fill_in_datepicker date_field_locator, with: "01/01/2019"
            find("[data-revocations-date] p", match: :first).click

            expect(page).to have_css("[data-revocations-bar] [type='submit'][data-confirm*='01/01/2019']")
            click_button t("decidim.admin.menu.authorization_revocation.revoke_button")
          end
        end

        expect(message).to include(
          strip_tags(I18n.t("decidim.admin.menu.authorization_revocation.destroy.confirm_message.total.before_date_html", count: 0, workflow: workflow_fullname, date: "01/01/2019"))
        )
      end

      it "falls back to the full count when the picked date is erased" do
        message = accept_confirm do
          within "[data-revocations='#{authorization_name}']" do
            choose total_option_label
            fill_in_datepicker date_field_locator, with: "15/03/2022"
            find("[data-revocations-date] p", match: :first).click
            expect(page).to have_css("[data-revocations-bar] [type='submit'][data-confirm*='15/03/2022']")

            find_by_id(date_field_locator).send_keys([:backspace] * 10)
            find("[data-revocations-date] p", match: :first).click
            expect(page).to have_css("[data-revocations-bar] [type='submit']:not([data-confirm*='15/03/2022'])")
            click_button t("decidim.admin.menu.authorization_revocation.revoke_button")
          end
        end

        expect(message).to include(
          strip_tags(I18n.t("decidim.admin.menu.authorization_revocation.destroy.confirm_message.total.all_html", count: 2, workflow: workflow_fullname))
        )
      end

      it "counts every authorization when the picked date is in the future" do
        tomorrow = (Time.zone.today + 1.day).strftime("%d/%m/%Y")

        message = accept_confirm do
          within "[data-revocations='#{authorization_name}']" do
            choose total_option_label
            fill_in_datepicker date_field_locator, with: tomorrow
            find("[data-revocations-date] p", match: :first).click

            expect(page).to have_css("[data-revocations-bar] [type='submit'][data-confirm*='#{tomorrow}']")
            click_button t("decidim.admin.menu.authorization_revocation.revoke_button")
          end
        end

        expect(message).to include(
          strip_tags(I18n.t("decidim.admin.menu.authorization_revocation.destroy.confirm_message.total.before_date_html", count: 2, workflow: workflow_fullname, date: tomorrow))
        )
      end
    end
  end

  context "when revoking impersonated authorizations for a method" do
    it "revokes only the impersonated authorizations of that method" do
      perform_enqueued_jobs do
        within "[data-revocations='#{authorization_name}']" do
          choose impersonated_option_label
          accept_confirm { click_button t("decidim.admin.menu.authorization_revocation.revoke_button") }
        end

        expect(page).to have_text(I18n.t("decidim.admin.menu.authorization_revocation.revoked.impersonated", count: 1, workflow: workflow_fullname))
      end

      expect(Decidim::Authorization.exists?(managed_authorization.id)).to be(false)
      expect(Decidim::Authorization.exists?(regular_authorization.id)).to be(true)
      expect(Decidim::Authorization.exists?(other_method_authorization.id)).to be(true)
    end
  end

  context "when revoking a method's authorizations with no date picked" do
    it "revokes all granted authorizations of that method" do
      perform_enqueued_jobs do
        within "[data-revocations='#{authorization_name}']" do
          choose total_option_label
          accept_confirm { click_button t("decidim.admin.menu.authorization_revocation.revoke_button") }
        end

        expect(page).to have_text(I18n.t("decidim.admin.menu.authorization_revocation.revoked.total", count: 2, workflow: workflow_fullname))
      end

      expect(Decidim::Authorization.exists?(regular_authorization.id)).to be(false)
      expect(Decidim::Authorization.exists?(managed_authorization.id)).to be(false)
      expect(Decidim::Authorization.exists?(other_method_authorization.id)).to be(true)
    end
  end

  context "when revoking impersonated authorizations before a picked date" do
    let!(:regular_authorization) { create(:authorization, name: authorization_name, user: regular_user, created_at: Date.new(2020, 1, 1)) }
    let!(:managed_authorization) { create(:authorization, name: authorization_name, user: managed_user, created_at: Date.new(2020, 1, 1)) }
    let(:recent_managed_user) { create(:user, :confirmed, :managed, organization:) }
    let!(:recent_managed_authorization) { create(:authorization, name: authorization_name, user: recent_managed_user, created_at: Date.new(2024, 6, 1)) }

    it "revokes only the managed authorizations of that method created before the picked date" do
      perform_enqueued_jobs do
        within "[data-revocations='#{authorization_name}']" do
          choose impersonated_option_label
          fill_in_datepicker date_field_locator, with: "15/03/2022"
          find("[data-revocations-date] p", match: :first).click

          expect(page).to have_css("[data-revocations-bar] [type='submit'][data-confirm*='15/03/2022']")
          accept_confirm { click_button t("decidim.admin.menu.authorization_revocation.revoke_button") }
        end

        expect(page).to have_text(I18n.t("decidim.admin.menu.authorization_revocation.revoked.impersonated", count: 1, workflow: workflow_fullname))
      end

      expect(Decidim::Authorization.exists?(managed_authorization.id)).to be(false)
      expect(Decidim::Authorization.exists?(recent_managed_authorization.id)).to be(true)
      expect(Decidim::Authorization.exists?(regular_authorization.id)).to be(true)
      expect(Decidim::Authorization.exists?(other_method_authorization.id)).to be(true)
    end
  end

  context "when revoking authorizations for one organization" do
    let(:other_organization) { create(:organization, available_authorizations: [authorization_name]) }
    let(:other_organization_user) { create(:user, :confirmed, organization: other_organization) }
    let!(:other_organization_authorization) { create(:authorization, name: authorization_name, user: other_organization_user) }

    it "does not revoke authorizations belonging to a different organization" do
      perform_enqueued_jobs do
        within "[data-revocations='#{authorization_name}']" do
          choose total_option_label
          accept_confirm { click_button t("decidim.admin.menu.authorization_revocation.revoke_button") }
        end

        expect(page).to have_text(I18n.t("decidim.admin.menu.authorization_revocation.revoked.total", count: 2, workflow: workflow_fullname))
      end

      expect(Decidim::Authorization.exists?(other_organization_authorization.id)).to be(true)
    end
  end
end
