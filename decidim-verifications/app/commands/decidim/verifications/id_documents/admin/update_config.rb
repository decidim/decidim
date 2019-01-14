# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        class UpdateConfig < Rectify::Command
          def initialize(form)
            @form = form
          end

          def call
            return broadcast(:invalid) if form.invalid?

            update_config

            broadcast(:ok)
          end

          private

          attr_reader :form

          def update_config
            Decidim.traceability.perform_action!(
              :update_id_documents_config,
              form.current_organization,
              form.current_user
            ) do
              form.current_organization.id_documents_methods = form.selected_methods
              form.current_organization.id_documents_explanation_text = form.offline_explanation
              form.current_organization.save!
            end
          end
        end
      end
    end
  end
end
