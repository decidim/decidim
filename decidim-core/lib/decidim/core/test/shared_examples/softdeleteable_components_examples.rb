# frozen_string_literal: true

require "spec_helper"

shared_examples "a soft-deletable resource" do |resource_name:, resource_path:, trash_path:|
  let(:deletable_resource) { send(resource_name) }
  let(:route_params) { defined?(additional_params) ? additional_params : {} }
  let(:resource_params) { { id: deletable_resource.id }.merge(route_params) }

  describe "PATCH soft_delete" do
    it "soft deletes the #{resource_name}" do
      expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(deletable_resource, current_user).and_call_original

      patch :soft_delete, params: resource_params

      expect(response).to redirect_to Decidim::EngineRouter.admin_proxy(deletable_resource.component).send(resource_path, *route_params.values)
      expect(flash[:notice]).to be_present
      expect(deletable_resource.reload.deleted_at).not_to be_nil
    end
  end

  describe "PATCH restore" do
    before { deletable_resource.destroy! }

    it "restores the #{resource_name}" do
      expect(Decidim::Commands::RestoreResource).to receive(:call).with(deletable_resource, current_user).and_call_original

      patch :restore, params: resource_params

      expect(response).to redirect_to Decidim::EngineRouter.admin_proxy(deletable_resource.component).send(trash_path, *route_params.values)
      expect(flash[:notice]).to be_present
      expect(deletable_resource.reload.deleted_at).to be_nil
    end
  end

  describe "GET manage_trash" do
    let!(:active_resource) { create(resource_name, component:) }
    let(:deleted_items) { controller.view_context.trashable_deleted_collection }

    before do
      deletable_resource.destroy!
    end

    it "lists only deleted #{resource_name.to_s.pluralize}" do
      get :manage_trash, params: route_params

      expect(response).to have_http_status(:ok)
      expect(deleted_items).to include(deletable_resource)
      expect(deleted_items).not_to include(active_resource)
    end

    it "renders the deleted #{resource_name.to_s.pluralize} template" do
      get :manage_trash, params: route_params

      expect(response).to render_template(:manage_trash)
    end
  end
end

shared_examples "a soft-deletable component" do |component_name:, space_name:, component_path:, trash_path:|
  let(:soft_deletable_component) { send(component_name) }
  let(:space) { send(space_name) }
  let(:component_params) { { "#{space_name}_slug" => space.slug, :id => soft_deletable_component.id } }

  before do
    allow(controller).to receive(:current_participatory_process).and_return(space_name)
  end

  describe "PATCH soft_delete" do
    it "soft deletes the #{component_name}" do
      expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(soft_deletable_component, current_user).and_call_original

      patch :soft_delete, params: component_params

      expect(response).to redirect_to send(component_path)
      expect(flash[:notice]).to be_present
      expect(soft_deletable_component.reload.deleted_at).not_to be_nil
    end
  end

  describe "PATCH restore" do
    before { soft_deletable_component.update!(deleted_at: Time.current) }

    it "restores the #{component_name}" do
      expect(Decidim::Commands::RestoreResource).to receive(:call).with(soft_deletable_component, current_user).and_call_original

      patch :restore, params: component_params

      expect(response).to redirect_to send(trash_path)
      expect(flash[:notice]).to be_present
      expect(soft_deletable_component.reload.deleted_at).to be_nil
    end
  end

  describe "GET manage_trash" do
    let!(:deleted_component) { create(component_name, participatory_space: space, deleted_at: Time.current) }
    let!(:active_component) { create(component_name, participatory_space: space) }
    let(:deleted_items) { controller.view_context.trashable_deleted_collection }

    it "lists only deleted #{component_name.to_s.pluralize}" do
      get :manage_trash, params: component_params.except(:id)

      expect(response).to have_http_status(:ok)
      expect(deleted_items).to include(deleted_component)
      expect(deleted_items).not_to include(active_component)
    end

    it "renders the deleted #{component_name.to_s.pluralize} template" do
      get :manage_trash, params: component_params.except(:id)

      expect(response).to render_template(:manage_trash)
    end
  end
end

shared_examples "a soft-deletable space" do |space_name:, space_path:, trash_path:|
  let(:soft_deletable_space) { send(space_name) }
  let(:deletion_params) { { slug: soft_deletable_space.slug } }

  before do
    request.env["decidim.current_organization"] = soft_deletable_space.organization
  end

  describe "PATCH soft_delete" do
    it "soft deletes the #{space_name}" do
      expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(soft_deletable_space, current_user).and_call_original

      patch :soft_delete, params: deletion_params

      expect(response).to redirect_to send(space_path)
      expect(flash[:notice]).to be_present
      expect(soft_deletable_space.reload.deleted_at).not_to be_nil
    end
  end

  describe "PATCH restore" do
    before { soft_deletable_space.destroy! }

    it "restores the #{space_name}" do
      expect(Decidim::Commands::RestoreResource).to receive(:call).with(soft_deletable_space, current_user).and_call_original

      patch :restore, params: deletion_params

      expect(response).to redirect_to send(trash_path)
      expect(flash[:notice]).to be_present
      expect(soft_deletable_space.reload.deleted_at).to be_nil
    end
  end

  describe "GET manage_trash" do
    let!(:deleted_space) { create(space_name, organization: soft_deletable_space.organization, deleted_at: Time.current) }
    let!(:active_space) { create(space_name, organization: soft_deletable_space.organization) }
    let(:deleted_items) { controller.view_context.trashable_deleted_collection }

    before do
      request.env["decidim.current_participatory_process"] = soft_deletable_space
    end

    it "lists only deleted #{space_name.to_s.pluralize}" do
      get :manage_trash

      expect(response).to have_http_status(:ok)
      expect(deleted_items).to include(deleted_space)
      expect(deleted_items).not_to include(active_space)
    end

    it "renders the deleted #{space_name.to_s.pluralize} template" do
      get :manage_trash

      expect(response).to render_template(:manage_trash)
    end
  end
end
