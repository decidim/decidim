# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe RemindersController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let!(:component) { create(:budgets_component, participatory_space: participatory_process, manifest_name: "dummy") }
      let(:step) { create(:participatory_process_step, participatory_process:, start_date: nil, end_date: nil) }
      #let(:step) { create(:participatory_process_step, participatory_process:, start_date: "2025-04-15 10:44:51.617", end_date: "2025-06-15 10:44:51.617") }

      let(:params) do
        {
          component_id: component.id,
          participatory_process_slug: component.participatory_space.slug
        }
      end

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component

        participatory_process.update!(active_step: step)
        sign_in user, scope: :user
        #allow(controller).to receive(:current_participatory_space).and_return(participatory_process)
      end

      describe "GET new" do
        it "does not assign the form if step dates are invalid" do
          #step.update!(start_date: nil, end_date: nil)

          get :new, params: { component_id: component.id, name: "test_reminder" }

          expect(assigns(:form)).to be_nil
        end

        it "renders the new template" do
          #step.update!(start_date: (Date.today - 7), end_date: (Date.today - 3))
          get :new, params: { component_id: component.id, name: "test_reminder" }
          expect(response).to render_template("new")
        end

        it "assigns a new form instance" do
          get :new, params: { component_id: component.id, name: component.manifest_name }

          form = assigns(:form)
          #byebug
          expect(form).to be_a(Decidim::Budgets::Admin::OrderReminderForm)
          expect(form.id).to be_nil
        end

        it "breadcrumbs are set" do
          get :new
          expect(controller.helpers.breadcrumb_items).to eq([
                                                              { label: "Reminders", url: "/admin#{reminders_path}" },
                                                              { label: "New reminder", url: "/admin#{new_reminder_path}" }
                                                            ])
        end
      end
    end
  end
end

