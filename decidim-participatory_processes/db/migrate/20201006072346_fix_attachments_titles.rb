# frozen_string_literal: true

class FixAttachmentsTitles < ActiveRecord::Migration[5.2]
  def up
    reset_column_information

    PaperTrail.request(enabled: false) do
      Decidim::Attachment.find_each do |attachment|
        next if attachment.title.is_a?(Hash) && attachment.description.is_a?(Hash)

        attached_to = attachment.attached_to
        locale = attached_to.try(:locale).presence ||
                 attached_to.try(:default_locale).presence ||
                 attached_to.try(:organization).try(:default_locale).presence ||
                 Decidim.default_locale

        # rubocop:disable Rails/SkipsModelValidations
        attachment.update_columns(
          title: {
            locale => attachment.title
          },
          description: {
            locale => attachment.description
          }
        )
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    reset_column_information
  end

  def down; end

  def reset_column_information
    Decidim::Attachment.reset_column_information
  end
end
