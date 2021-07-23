# frozen_string_literal: true

# Validates that the associated record is always within an organization in
# order to pass the organization specific settings for the file upload
# checks (e.g. file extension, mime type, etc.).
class OrganizationPresentValidator < ActiveModel::Validations::FileContentTypeValidator
  def validate_each(record, attribute, _value)
    return if record.is_a?(Decidim::Organization)
    return if record.respond_to?(:organization) && record.organization.is_a?(Decidim::Organization)

    record.errors.add attribute, I18n.t("carrierwave.errors.not_inside_organization")
  end

  def check_validity!; end
end
