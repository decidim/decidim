# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::RegistrationsController, type: :controller do
  routes { Decidim::Meetings::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: }
  let(:participatory_process) { create :participatory_process, organization: }
  let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
  let(:meeting) { create(:meeting, :published, component: meeting_component) }

  let(:available_slots) { 0 }
  let(:reserved_slots) { 0 }

  let(:params) do
    {
      meeting_id: meeting.id,
      registrations_enabled: true,
      registration_form_enabled: false,
      available_slots:,
      reserved_slots:,
      registration_terms: {}
    }
  end

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_process"] = participatory_process
    request.env["decidim.current_component"] = meeting_component
    sign_in user
  end

  describe "#update" do
    context "when available_slots is blank" do
      let(:available_slots) { nil }

      it "renders the form again with alert message" do
        put :update, params: params

        expect(subject).to render_template(:edit)
        expect(flash[:alert]).not_to be_empty
      end
    end

    context "when reserved_slots is blank" do
      let(:reserved_slots) { nil }

      it "renders the index view" do
        put :update, params: params

        expect(subject).to render_template(:edit)
        expect(flash[:alert]).not_to be_empty
      end
    end
  end
end
