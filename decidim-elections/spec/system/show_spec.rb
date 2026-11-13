# frozen_string_literal: true

require "spec_helper"

describe "show" do
  include_context "with a component"

  let(:manifest_name) { "elections" }
  let!(:election) { create(:election, :published, :with_internal_users_census, component:) }
  let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }

  before do
    visit election_path
  end

  context "when there is a component announcement" do
    let(:announcement) { { en: "Important announcement" } }

    context "with the component's settings" do
      before do
        component.update!(settings: { announcement: })
        visit election_path
      end

      it "shows the announcement" do
        expect(page).to have_text("Important announcement")
      end
    end

    context "with the step's settings" do
      before do
        component.update!(
          phase_settings: {
            component.participatory_space.active_phase.id => { announcement: }
          }
        )
        visit election_path
      end

      it "shows the announcement" do
        expect(page).to have_text("Important announcement")
      end
    end
  end
end
