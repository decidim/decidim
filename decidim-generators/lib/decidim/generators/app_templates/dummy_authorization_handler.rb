# frozen_string_literal: true

# An example authorization handler used so that users can be verified against
# third party systems.
#
# You should probably rename this class and file to match your needs.
#
# If you need a custom form to be rendered, you can create a file matching the
# class name named "_form".
#
# Example:
#
#   A handler named Decidim::CensusHandler would look for its partial in:
#   decidim/census/form
#
# When testing your authorization handler, add this line to be sure it has a
# valid public api:
#
#   it_behaves_like "an authorization handler"
#
# See Decidim::AuthorizationHandler for more documentation.
class DummyAuthorizationHandler < Decidim::AuthorizationHandler
  # Define the attributes you need for this authorization handler. Attributes
  # are defined using Decidim::AttributeObject.
  #
  attribute :name_and_surname, String
  attribute :document_number, String
  attribute :postal_code, String
  attribute :birthday, Decidim::Attributes::LocalizedDate
  attribute :scope_id, Integer

  # You can (and should) also define validations on each attribute:
  #
  validates :document_number, presence: true

  # You can also define custom validations:
  #
  validate :valid_document_number
  validate :valid_scope_id

  # The only method that needs to be implemented for an authorization handler.
  # Here you can add your business logic to check if the authorization should
  # be created or not, you should return a Boolean value.
  #
  # Note that if you set some validations and overwrite this method, then the
  # validations will not run, so it's easier to remove this method and rewrite
  # your logic using ActiveModel validations.
  #
  # def valid?
  #   raise NotImplementedError
  # end

  # If set, enforces the handler to validate the uniqueness of the field
  #
  def unique_id
    document_number
  end

  # The user scope
  #
  def scope
    user.organization.scopes.find_by(id: scope_id) if scope_id
  end

  # If you need to store any of the defined attributes in the authorization you
  # can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata
  #
  def metadata
    super.merge(document_number:, postal_code:, scope_id:)
  end

  private

  def valid_document_number
    errors.add(:document_number, :invalid) unless document_number.to_s.end_with?("X")
  end

  def valid_scope_id
    errors.add(:scope_id, :invalid) if scope_id && !scope
  end

  # If you need custom authorization logic, you can implement your own action
  # authorizer. In this case, it allows to set a list of valid postal codes for
  # an authorization.
  class DummyActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
    attr_reader :allowed_postal_codes, :allowed_scope_id

    # Overrides the parent class method, but it still uses it to keep the base behavior
    def authorize
      # Remove the additional setting from the options hash to avoid to be considered missing.
      @allowed_postal_codes ||= options.delete("allowed_postal_codes")&.split(/[\W,;]+/)
      @allowed_scope_id ||= options.delete("allowed_scope_id")&.to_i

      status_code, data = *super

      extra_explanations = []
      if allowed_postal_codes.present?
        # Does not authorize users with different postal codes
        status_code = :unauthorized if status_code == :ok && disallowed_user_postal_code

        # Adds an extra message for inform the user the additional restriction for this authorization
        if disallowed_user_postal_code
          if user_postal_code
            i18n_postal_codes_key = "extra_explanation.user_postal_codes"
            user_postal_code_params = { user_postal_code: }
          else
            i18n_postal_codes_key = "extra_explanation.postal_codes"
            user_postal_code_params = {}
          end

          extra_explanations << { key: i18n_postal_codes_key,
                                  params: { scope: "decidim.verifications.dummy_authorization",
                                            count: allowed_postal_codes.count,
                                            postal_codes: allowed_postal_codes.join(", ") }.merge(user_postal_code_params) }
        end
      end

      if allowed_scope.present?
        # Does not authorize users with different scope
        status_code = :unauthorized if status_code == :ok && disallowed_user_user_scope

        # Adds an extra message to inform the user about additional restrictions for this authorization
        if disallowed_user_user_scope
          if user_scope_id
            i18n_scope_key = "extra_explanation.user_scope"
            user_scope_params = { user_scope_name: }
          else
            i18n_scope_key = "extra_explanation.scope"
            user_scope_params = {}
          end

          extra_explanations << { key: i18n_scope_key,
                                  params: { scope: "decidim.verifications.dummy_authorization",
                                            scope_name: allowed_scope.name[I18n.locale.to_s] }.merge(user_scope_params) }
        end
      end

      data[:extra_explanation] = extra_explanations if extra_explanations.any?

      [status_code, data]
    end

    # Adds the list of allowed postal codes and scope to the redirect URL, to allow forms to inform about it
    def redirect_params
      { postal_codes: allowed_postal_codes&.join(","), scope: allowed_scope_id }.merge(user_metadata_params)
    end

    private

    def allowed_scope
      @allowed_scope ||= Decidim::Scope.find(allowed_scope_id) if allowed_scope_id
    end

    def user_scope
      @user_scope ||= Decidim::Scope.find(user_scope_id) if user_scope_id
    end

    def user_scope_id
      return unless authorization

      @user_scope_id ||= authorization.metadata["scope_id"]&.to_i
    end

    def user_scope_name
      @user_scope_name ||= user_scope.name[I18n.locale.to_s] if authorization && user_scope
    end

    def disallowed_user_user_scope
      return unless user_scope || allowed_scope.present?

      allowed_scope_id != user_scope_id
    end

    def user_postal_code
      @user_postal_code ||= authorization.metadata["postal_code"] if authorization && authorization.metadata
    end

    def disallowed_user_postal_code
      return unless user_postal_code || allowed_postal_codes.present?

      !allowed_postal_codes.member?(user_postal_code)
    end

    def user_metadata_params
      return {} unless authorization

      @user_metadata_params ||= begin
        user_metadata_params = {}
        user_metadata_params[:user_scope_name] = user_scope.name[I18n.locale.to_s] if user_scope

        user_metadata_params[:user_postal_code] = authorization.metadata["postal_code"] if authorization.metadata["postal_code"].present?

        user_metadata_params
      end
    end
  end
end
