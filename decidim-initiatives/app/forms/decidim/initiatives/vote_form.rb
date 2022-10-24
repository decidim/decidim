# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the data for a new initiative.
    class VoteForm < Form
      include TranslatableAttributes

      mimic :initiatives_vote

      attribute :name_and_surname, String
      attribute :document_number, String
      attribute :date_of_birth, Date

      attribute :postal_code, String
      attribute :encrypted_metadata, String
      attribute :hash_id, String

      attribute :initiative, Decidim::Initiative
      attribute :signer, Decidim::User

      validates :initiative, :signer, presence: true

      validates :authorized_scopes, presence: true

      with_options if: :required_personal_data? do
        validates :name_and_surname, :document_number, :date_of_birth, :postal_code, :encrypted_metadata, :hash_id, presence: true
        validate :document_number_authorized?
        validate :already_voted?
      end

      delegate :scope, to: :initiative

      def encrypted_metadata
        return unless required_personal_data?

        @encrypted_metadata ||= encryptor.encrypt(metadata)
      end

      # Public: The hash to uniquely identify an initiative vote. It uses the
      # initiative scope as a default.
      #
      # Returns a String.
      def hash_id
        return unless initiative && (document_number || signer)

        @hash_id ||= Digest::MD5.hexdigest(
          [
            initiative.id,
            document_number || signer.id,
            Rails.application.secrets.secret_key_base
          ].compact.join("-")
        )
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
            initiative_type_scope.scope == user_authorized_scope ||
            initiative_type_scope.scope.ancestor_of?(user_authorized_scope)
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
      def user_authorized_scope
        return scope if handler_name.blank?
        return unless authorized?
        return if authorization.metadata.blank?

        @user_authorized_scope ||= authorized_scope_candidates.find do |scope|
          scope&.id == authorization.metadata.symbolize_keys[:scope_id]
        end
      end

      # Public: Builds a list of Decidim::Scopes where the user could have a
      # valid authorization.
      #
      # If the intiative is set with a global scope (meaning the scope is nil),
      # all the scopes in the organizaton are valid.
      #
      # Returns an array of Decidim::Scopes.
      def authorized_scope_candidates
        authorized_scope_candidates = [initiative.scope]
        authorized_scope_candidates += if initiative.scope.present?
                                         initiative.scope.descendants
                                       else
                                         initiative.organization.scopes
                                       end
        authorized_scope_candidates.uniq
      end

      def metadata
        {
          name_and_surname:,
          document_number:,
          date_of_birth:,
          postal_code:
        }
      end

      protected

      # Private: Whether the personal data given when signing the initiative should
      # be stored together with the vote or not.
      #
      # Returns a Boolean.
      def required_personal_data?
        @required_personal_data ||= initiative&.type&.collect_user_extra_fields?
      end

      # Private: Checks that the unique hash computed from the authorization
      # and the user provided data match.
      #
      # This prevents users that know partial data from another user to sign
      # initiatives with someone elses identity.
      def document_number_authorized?
        return if initiative.document_number_authorization_handler.blank?

        errors.add(:document_number, :invalid) unless authorized? && authorization_handler && authorization.unique_id == authorization_handler.unique_id
      end

      # Private: Checks if there's any existing vote that matches the user's data.
      def already_voted?
        errors.add(:document_number, :taken) if initiative.votes.exists?(hash_id:, scope:)
      end

      def author
        @author ||= current_organization.users.find_by(id: author_id)
      end

      # Private: Finds an authorization for the user signing the initiative and
      # the configured handler.
      def authorization
        return unless signer && handler_name

        @authorization ||= Verifications::Authorizations.new(
          organization: signer.organization,
          user: signer,
          name: handler_name
        ).first
      end

      # Private: Checks if the authorization hasn't expired or is invalid.
      def authorized?
        authorization_status&.first == :ok
      end

      # Private: Builds an authorization handler with the data the user provided
      # when signing the initiative.
      #
      # This is currently tied to authorization handlers that have, at least, these attributes:
      #   * document_number
      #   * name_and_surname
      #   * date_of_birth
      #   * postal_code
      #
      # Once we have the authorization handler we can use is to compute the
      # unique_id and compare it to an existing authorization.
      #
      # Returns a Decidim::AuthorizationHandler.
      def authorization_handler
        return unless document_number && handler_name

        @authorization_handler ||= Decidim::AuthorizationHandler.handler_for(handler_name,
                                                                             document_number:,
                                                                             name_and_surname:,
                                                                             date_of_birth:,
                                                                             postal_code:)
      end

      # Private: The AuthorizationHandler name used to verify the user's
      # document number.
      #
      # Returns a String.
      def handler_name
        initiative.document_number_authorization_handler
      end

      def authorization_status
        return unless authorization

        Decidim::Verifications::Adapter.from_element(handler_name).authorize(authorization, {}, nil, nil)
      end

      def encryptor
        @encryptor ||= DataEncryptor.new(secret: "personal user metadata")
      end
    end
  end
end
