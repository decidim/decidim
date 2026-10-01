# frozen_string_literal: true

require "spec_helper"

describe Decidim::Templates::Admin::QuestionnaireTemplatesController do
  routes { Decidim::Templates::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }

  let(:other_org) { create(:organization) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user, scope: :user
  end

  describe "GET index" do
    let!(:own_template) { create(:questionnaire_template, organization:) }
    let!(:other_template) { create(:questionnaire_template, organization: other_org) }

    it "includes only templates from the current organization" do
      get :index
      expect(assigns(:templates)).to include(own_template)
      expect(assigns(:templates)).not_to include(other_template)
    end
  end

  describe "private template method" do
    let!(:own_template) { create(:questionnaire_template, organization:) }
    let!(:other_template) { create(:questionnaire_template, organization: other_org) }

    it "finds own template by id" do
      controller.params = { id: own_template.id }
      expect(controller.send(:template)).to eq(own_template)
    end

    it "raises RecordNotFound for a cross-org template id" do
      controller.params = { id: other_template.id }
      expect { controller.send(:template) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
