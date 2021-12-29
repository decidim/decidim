# frozen_string_literal: true

module Decidim
  # A module to deal with attributes associated with attachments allowing
  # deletions with remove_attribute_name
  module AttachmentAttributesMethods
    private

    # This method set the attributes to assign. The attribute is included if a
    # value exists in the form or remove_[attribute_name] is true in the form
    # (in this case the value is nil)
    def attachment_attributes(*attrs)
      attrs.each_with_object({}) do |attribute, attributes|
        attributes[attribute] = form.send(attribute) if form.try("remove_#{attribute}") || form.send(attribute).present?
      end
    end
  end
end
