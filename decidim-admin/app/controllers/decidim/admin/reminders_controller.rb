# frozen_string_literal: true

module Decidim
  module Admin
    class RemindersController < Admin::ApplicationController
      include Decidim::ComponentPathHelper

      helper_method :reminder_manifest

      def new
        enforce_permission_to :create, :reminder

        step = current_component.participatory_space.active_step # TODO participatory_space que sea proceso si no se comprueba
        if step.start_date.nil? || step.end_date.nil?
          flash[:alert] = "Algo fué mal en el formulario"
          redirect_to request.referer || manage_component_path(current_component) and return
        end

        #byebug
        @form = reminder_form_from_params(name: reminder_manifest.name) # manifest.nam del componenet
        render :new
      end

      def create
        enforce_permission_to :create, :reminder

        @form = reminder_form_from_params(params)

        command_class.call(@form) do
          on(:ok) do |reminders_queued|
            flash[:notice] = t("decidim.admin.reminders.create.success", count: reminders_queued)
            redirect_to manage_component_path(current_component)
          end

          on(:invalid) do
            flash.now[:alert] = t("decidim.admin.reminders.create.error")
            render :new
          end
        end
      end

      private

      def reminder_form_from_params(params)
        form(reminder_manifest.form_class).from_params(
          params,
          current_component:
        )
      end

      def reminder_manifest
        @reminder_manifest ||= Decidim.reminders_registry.for(reminder_name)
      end

      def reminder_name
        params[:name]
      end

      def command_class
        reminder_manifest.command_class
      end

      def current_component
        @current_component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end
