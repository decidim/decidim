# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to show the initiative data in the administration
      # panel.
      class InitiativeForm < Form
        include TranslatableAttributes

        mimic :initiative

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :type_id, Integer
        attribute :decidim_scope_id, Integer
        attribute :signature_type, String
        attribute :signature_start_date, Decidim::Attributes::LocalizedDate
        attribute :signature_end_date, Decidim::Attributes::LocalizedDate
        attribute :hashtag, String
        attribute :offline_votes, Hash
        attribute :state, String

        validates :title, :description, presence: true
        validates :signature_type, presence: true, if: :signature_type_updatable?
        validates :signature_start_date, presence: true, if: ->(form) { form.context.initiative.published? }
        validates :signature_end_date, presence: true, if: ->(form) { form.context.initiative.published? }
        validates :signature_end_date, date: { after: :signature_start_date }, if: lambda { |form|
          form.signature_start_date.present? && form.signature_end_date.present?
        }

        # TODO: Update this
        #validates :offline_votes, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true

        def map_model(model)
          self.type_id = model.type.id
          self.decidim_scope_id = model.scope&.id
          self.offline_votes = model.offline_votes

          if offline_votes.empty?
            self.offline_votes = model.votable_initiative_type_scopes.each_with_object({}) do |initiative_scope_type, all_votes|
              all_votes[initiative_scope_type.decidim_scopes_id || "global"] = [0, initiative_scope_type.scope_name]
            end
          else
            offline_votes.delete("total")
            self.offline_votes = offline_votes.each_with_object({}) do |(decidim_scope_id, votes), all_votes|
              scope_name = model.votable_initiative_type_scopes.find do |initiative_scope_type|
                initiative_scope_type.global_scope? && decidim_scope_id == "global" ||
                  initiative_scope_type.decidim_scopes_id == decidim_scope_id.to_i
              end.scope_name

              all_votes[decidim_scope_id || "global"] = [votes, scope_name]
            end
          end
        end

        def signature_type_updatable?
          @signature_type_updatable ||= begin
                                          state ||= context.initiative.state
                                          state == "validating" && context.current_user.admin? || state == "created"
                                        end
        end

        def state_updatable?
          false
        end

        def scoped_type_id
          return unless type && decidim_scope_id

          type.scopes.find_by(decidim_scopes_id: decidim_scope_id.presence).id
        end

        private

        def type
          @type ||= type_id ? Decidim::InitiativesType.find(type_id) : context.initiative.type
        end
      end
    end
  end
end
