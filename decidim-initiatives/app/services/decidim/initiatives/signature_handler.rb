# frozen_string_literal: true

module Decidim
  module Initiatives
    # This is the base class for signature handlers, all implementations
    # should inherit from it.
    # Each SignatureHandler is a form that will be used to check if the
    # signature is valid or not. When it is valid the initiatives votes
    # defined by the initiative type will be created for the user.
    #
    # Feel free to use validations to assert fields against a remote API,
    # local database, or whatever.
    #
    # It also sets two default attributes, `user` and `initiative`.
    class SignatureHandler < Form
      include ValidatableAuthorizations

      mimic :initiatives_vote

      # The user that is trying to sign, it is initialized with the
      # `current_user` from the controller.
      attribute :user, Decidim::User

      # The initiative to be signed
      attribute :initiative, Decidim::Initiative

      attribute :tos_agreement, if: :ephemeral_tos_pending?
      validates :tos_agreement, presence: true, if: :ephemeral_tos_pending?
      validate :tos_agreement_acceptance, if: :ephemeral_tos_pending?

      attribute :transfer_status

      validates :initiative, :user, presence: true
      validate :uniqueness
      validate :valid_metadata
      validate :valid_authorized_scopes

      delegate :promote_authorization_validation_errors, :authorization_handler_form_class, :ephemeral?, to: :workflow_manifest
      delegate :scope, to: :initiative

      # A unique ID to be implemented by the signature handler that ensures
      # no duplicates are created.
      def unique_id
        nil
      end

      def encrypted_metadata
        return if metadata.blank?

        @encrypted_metadata ||= encryptor.encrypt(metadata)
      end

      # Public: Builds the list of scopes where the user is authorized to vote in. This is used when
      # the initiative allows also voting on child scopes, not only the main scope.
      #
      # Instead of just listing the children of the main scope, we just want to select the ones that
      # have been added to the InitiativeType with its voting settings.
      #
      def authorized_scopes
        initiative.votable_initiative_type_scopes.select do |initiative_type_scope|
          initiative_type_scope.global_scope? ||
            initiative_type_scope.scope == user_signature_scope ||
            initiative_type_scope.scope.ancestor_of?(user_signature_scope)
        end.flat_map(&:scope)
      end

      # Public: Finds the scope the user has an authorization for, this way the user can vote
      # on that scope and its parents.
      #
      # This is can be used to allow users that are authorized with a children
      # scope to sign an initiative with a parent scope.
      #
      # As an example: A city (global scope) has many districts (scopes with
      # parent nil), and each district has different neighbourhoods (with its
      # parent as a district). If we setup the authorization handler to match
      # a neighbourhood, the same authorization can be used to participate
      # in district, neighbourhoods or city initiatives.
      #
      # Returns a Decidim::Scope.
      def user_signature_scope
        return if signature_scope_id.blank?

        @user_signature_scope ||= signature_scope_candidates.find do |scope_candidate|
          scope_candidate&.id == signature_scope_id
        end
      end

      # Public: Builds a list of Decidim::Scopes where the user could have a
      # valid authorization.
      #
      # If the initiative is set with a global scope (meaning the scope is nil),
      # all the scopes in the organization are valid.
      #
      # Returns an array of Decidim::Scopes.
      def signature_scope_candidates
        signature_scope_candidates = [initiative.scope]
        signature_scope_candidates += if initiative.scope.present?
                                        initiative.scope.descendants
                                      else
                                        initiative.organization.scopes
                                      end
        signature_scope_candidates.uniq
      end

      # Any data that the developer would like to inject to the `metadata` field
      # of a vote when it is created. Can be useful if some of the params the
      # user sent with the signature form want to be persisted for future use.
      #
      # Returns a Hash.
      def metadata
        {}
      end

      # Params to be sent to the authorization handler. By default consists on
      # the metadata hash including the signer user
      def authorization_handler_params
        params = metadata.merge(user:)
        params = params.merge(tos_agreement:) if ephemeral_tos_pending?
        params
      end

      # The signature_scope_id can be defined in the signature workflow to be
      # used by the author scope feature
      def signature_scope_id
        scope.id
      end

      def authorization_handler
        return if authorization_handler_form_class.blank?

        @authorization_handler ||= authorization_handler_form_class.from_params(authorization_handler_params)
      end

      def signature_workflow_name
        @signature_workflow_name ||= initiative&.type&.document_number_authorization_handler
      end

      def hash_id
        return unless initiative && (unique_id || user)

        @hash_id ||= Digest::SHA256.hexdigest(
          [
            initiative.id,
            unique_id || user.id,
            Rails.application.secret_key_base
          ].compact.join("-")
        )
      end

      # The attributes of the handler that should be exposed as form input when
      # rendering the handler in a form.
      #
      # Returns an Array of Strings.
      def form_attributes
        attributes.except("id", "user", "initiative", "tos_agreement", "transfer_status").keys
      end

      # The String partial path so Rails can render the handler as a form. This
      # is useful if you want to have a custom view to render the form instead of
      # the default view.
      #
      # Example:
      #
      #   A handler named Decidim::CensusHandler would look for its partial in:
      #   decidim/census/form
      #
      # Returns a String.
      def to_partial_path
        "decidim/initiatives/initiative_signatures/#{signature_workflow_name.sub(/_handler$/, "")}/form"
      end

      def self.requires_extra_attributes?
        new.form_attributes.present?
      end

      def already_voted?
        Decidim::InitiativesVote.exists?(author: user, initiative:)
      end

      private

      # It is expected to validate that no other user has voted with the same
      # unique_id and scope. The unique_id should be defined by the classes
      # inherited from this taking a personal data attribute like a document
      # number. If not defined the user id is used
      def uniqueness
        add_invalid_base_error if Decidim::InitiativesVote.exists?(scope:, hash_id:)
      end

      def valid_metadata
        return if authorization_handler_errors.blank?

        keys = attributes.except("tos_agreement").keys.map(&:to_sym) & authorization_handler_errors.attribute_names

        return if keys.blank? && authorization_handler_errors[:base].blank?

        # Promote errors
        if promote_authorization_validation_errors
          keys.each do |attribute|
            errors.add(attribute, authorization_handler_errors[attribute])
          end
        end

        add_invalid_base_error
      end

      def tos_agreement_acceptance
        return if (error_message = authorization_handler_errors[:tos_agreement]).blank?

        errors.add(:tos_agreement, error_message)
      end

      def valid_authorized_scopes
        return if authorized_scopes.present?

        add_invalid_base_error
      end

      def add_invalid_base_error
        errors.delete(:base)
        errors.add(:base, I18n.t("invalid_data", scope: "decidim.initiatives.initiative_signatures.fill_personal_data"))
      end

      def encryptor
        @encryptor ||= Decidim::AttributeEncryptor.new(secret: Decidim::Initiatives.signature_handler_encryption_secret)
      end

      def workflow_manifest
        @workflow_manifest ||= Decidim::Initiatives::Signatures.find_workflow_manifest(signature_workflow_name) || Decidim::Initiatives::SignatureWorkflowManifest.new
      end

      def ephemeral_tos_pending?
        return unless ephemeral? && user.ephemeral?

        !user.tos_accepted?
      end

      def authorization_handler_errors
        @authorization_handler_errors ||= if authorization_handler.blank?
                                            ActiveModel::Errors.new(nil)
                                          else
                                            authorization_handler.validate
                                            authorization_handler.errors
                                          end
      end
    end
  end
end
