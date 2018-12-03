# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # A form object to be used as the base for identity document verification
      module Admin
        class ConfigForm < Decidim::Form
          include TranslatableAttributes
          mimic :config

          attribute :offline, Boolean
          attribute :online, Boolean
          translatable_attribute :offline_explanation, String

          validates :offline_explanation, translatable_presence: true, if: :offline
          validate :has_some_method_selected?

          def map_model(model)
            self.online = model.id_documents_methods.include?("online")
            self.offline = model.id_documents_methods.include?("offline")
            self.offline_explanation = model.id_documents_explanation_text
          end

          def has_some_method_selected?
            return if online || offline

            errors.add(:online, :invalid)
            errors.add(:offline, :invalid)
          end

          def selected_methods
            methods = []
            methods << "offline" if offline
            methods << "online" if online
            methods
          end
        end
      end
    end
  end
end
