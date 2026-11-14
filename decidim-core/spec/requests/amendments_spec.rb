# frozen_string_literal: true

require "spec_helper"

describe "Amendments" do
  let(:participatory_process) { create(:participatory_process, :with_steps, :published) }
  let(:organization) { participatory_process.organization }
  let(:component) do
    create(
      :component,
      :published,
      participatory_space: participatory_process,
      settings: { amendments_enabled: true },
      step_settings: { participatory_process.active_step.id => { amendment_promotion_enabled: true } }
    )
  end
  let(:amendable) { create(:dummy_resource, component:) }
  let(:emendation) { create(:dummy_resource, component:) }
  let(:amendment) { create(:amendment, amendable:, emendation:, state: "evaluating") }

  before do
    host! organization.host
    login_as amendment.amender, scope: :user
  end

  describe "POST promote" do
    context "when the amendment has not been rejected" do
      it "shows the alert on the emendation page" do
        post(decidim.promote_amend_path(amendment))

        expect(response).to redirect_to(Decidim::ResourceLocatorPresenter.new(emendation).path)
        follow_redirect!

        expect(response.body).to include(I18n.t("promoted.error", scope: "decidim.amendments"))
      end
    end
  end
end
