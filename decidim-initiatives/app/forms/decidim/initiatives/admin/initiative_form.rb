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
        translatable_attribute :description, Decidim::Attributes::RichText
        attribute :type_id, Integer
        attribute :decidim_scope_id, Integer
        attribute :area_id, Integer
        attribute :signature_type, String
        attribute :signature_start_date, Decidim::Attributes::LocalizedDate
        attribute :signature_end_date, Decidim::Attributes::LocalizedDate
        attribute :offline_votes, Hash
        attribute :state, String
        attribute :attachment, AttachmentForm

        validates :title, :description, translatable_presence: true
        validates :area, presence: true, if: ->(form) { form.area_id.present? }
        validates :signature_type, presence: true, if: :signature_type_updatable?
        validates :signature_start_date, presence: true, if: ->(form) { form.context.initiative.published? }
        validates :signature_end_date, presence: true, if: ->(form) { form.context.initiative.published? }
        validates :signature_end_date, date: { after: :signature_start_date }, if: lambda { |form|
          form.signature_start_date.present? && form.signature_end_date.present?
        }
        validates :signature_end_date, date: { after: Date.current }, if: lambda { |form|
          form.signature_start_date.blank? && form.signature_end_date.present?
        }

        validate :notify_missing_attachment_if_errored
        validate :area_is_not_removed

        def map_model(model)
          self.type_id = model.type.id
          self.decidim_scope_id = model.scope&.id
          self.offline_votes = offline_votes.empty? ? zero_offline_votes_with_scopes_names(model) : offline_votes_with_scopes_names(model)
        end

        def signature_type_updatable?
          @signature_type_updatable ||= begin
            state ||= context.initiative.state
            (state == "validating" && context.current_user.admin?) || state == "created"
          end
        end

        def state_updatable?
          false
        end

        def area_updatable?
          @area_updatable ||= current_user.admin? || context.initiative.created?
        end

        def scoped_type_id
          return unless type && decidim_scope_id

          type.scopes.find_by(decidim_scopes_id: decidim_scope_id.presence).id
        end

        def area
          @area ||= current_organization.areas.find_by(id: area_id)
        end

        private

        # Private: set the in-person signatures to zero for every scope
        def zero_offline_votes_with_scopes_names(model)
          model.votable_initiative_type_scopes.each_with_object({}) do |initiative_scope_type, all_votes|
            all_votes[initiative_scope_type.decidim_scopes_id || "global"] = [0, initiative_scope_type.scope_name]
          end
        end

        # Private: set the in-person signatures for every scope
        def offline_votes_with_scopes_names(model)
          model.offline_votes.delete("total")
          model.offline_votes.each_with_object({}) do |(decidim_scope_id, votes), all_votes|
            scope_name = model.votable_initiative_type_scopes.find do |initiative_scope_type|
              (initiative_scope_type.global_scope? && decidim_scope_id == "global") ||
                initiative_scope_type.decidim_scopes_id == decidim_scope_id.to_i
            end.scope_name

            all_votes[decidim_scope_id || "global"] = [votes, scope_name]
          end
        end

        def type
          @type ||= type_id ? Decidim::InitiativesType.find(type_id) : context.initiative.type
        end

        # This method will add an error to the `attachment` field only if there is
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
        end

        def area_is_not_removed
          return if context.initiative.decidim_area_id.blank? || context.initiative.created?

          errors.add(:area_id, :blank) if area_id.blank?
        end
      end
    end
  end
end
