# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::QuestionsController, type: :controller do
  routes { Decidim::Consultations::Engine.routes }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:question) { create(:question, consultation: consultation) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  context "when there's a question" do
    it "can access it" do
      get :show, params: { slug: question.slug }

      expect(subject).to render_template(:show)
      expect(flash[:alert]).to be_blank
      expect(controller.send(:current_participatory_space)).to eq question
    end
  end

  context "when there isn't a question" do
    it "returns 404" do
      expect { get :show, params: { slug: "invalid-question" } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
