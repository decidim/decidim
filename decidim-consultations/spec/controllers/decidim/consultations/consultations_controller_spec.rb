# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::ConsultationsController, type: :controller do
  routes { Decidim::Consultations::Engine.routes }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  context "when there's a consultation" do
    it "can access it" do
      get :show, params: { slug: consultation.slug }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
      expect(controller.send(:current_participatory_space)).to eq consultation
    end
  end

  context "when there isn't a consultation" do
    it "returns 404" do
      expect { get :show, params: { slug: "invalid-consultation" } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
