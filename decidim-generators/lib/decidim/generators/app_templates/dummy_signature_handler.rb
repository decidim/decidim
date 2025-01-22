# frozen_string_literal: true

# An example signature handler used so that users can be verified against
# third party systems.
#
# You should probably rename this class and file to match your needs.
#
# If you need a custom form to be rendered, you can create a file matching the
# class name named "_form".
#
# Example:
#
#   A handler named Decidim::CensusSignatureHandler would look for its partial in:
#   decidim/initiatives/initiative_signatures/census_signature/form
#
# See Decidim::Initiatives::SignatureHandler for more documentation.
class DummySignatureHandler < Decidim::Initiatives::SignatureHandler
  # i18n-tasks-use t("decidim.initiatives.initiative_signatures.dummy_signature.form.fields.gender.options.man")
  # i18n-tasks-use t("decidim.initiatives.initiative_signatures.dummy_signature.form.fields.gender.options.non_binary")
  # i18n-tasks-use t("decidim.initiatives.initiative_signatures.dummy_signature.form.fields.gender.options.woman")
  AVAILABLE_GENDERS = %w(man woman non_binary).freeze

  # Define the attributes you need for this signature handler. Attributes
  # are defined using Decidim::AttributeObject.
  #
  attribute :name_and_surname, String
  attribute :document_type, String
  attribute :document_number, String
  attribute :gender, String
  attribute :postal_code, String
  attribute :date_of_birth, Date
  attribute :scope_id, Integer

  # signature_scope_id is used by the base handler to define the user signature
  # scope
  alias signature_scope_id scope_id

  # You can (and should) also define validations on each attribute:
  #
  validates :name_and_surname, :document_type, :document_number, :gender, :postal_code, :date_of_birth, :scope_id, presence: true

  validates :document_type,
            inclusion: { in: :document_types },
            presence: true

  validates :gender,
            inclusion: { in: :available_genders },
            allow_blank: true

  def date_of_birth=(date)
    date = nil if date.is_a?(Hash) && date.values.any?(&:blank?)

    super
  end

  def document_types_for_select
    document_types.map do |type|
      [
        I18n.t(type.downcase, scope: "decidim.verifications.id_documents"),
        type
      ]
    end
  end

  def genders_for_select
    available_genders.map do |gender|
      [
        I18n.t(gender, scope: "decidim.initiatives.initiative_signatures.dummy_signature.form.fields.gender.options", default: gender.humanize),
        gender
      ]
    end
  end

  # The only method that needs to be implemented for a signature handler.
  # Here you can add your business logic to check if the signature should
  # be created or not based on the provided data, you should return a
  # Boolean value.
  #
  # Note that if you set some validations and overwrite this method, then the
  # validations will not run, so it is easier to remove this method and rewrite
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

  # Any data that the developer would like to inject to the `metadata` field
  # of a vote when it is created. Can be useful if some of the params the
  # user sent with the signature form want to be persisted for future use.
  #
  # Returns a Hash.
  def metadata
    super.merge(name_and_surname:, document_type:, document_number:, gender:, date_of_birth:, postal_code:)
  end

  # Params to be passed to the authorization handler if defined in the workflow.
  def authorization_handler_params
    super.merge(scope_id:)
  end

  class DummySignatureActionAuthorizer < Decidim::Initiatives::DefaultSignatureAuthorizer; end

  private

  def document_types
    Decidim::Verifications.document_types
  end

  def available_genders
    AVAILABLE_GENDERS
  end
end
