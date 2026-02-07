# frozen_string_literal: true

class UpdateUserGroupsReferences < ActiveRecord::Migration[7.2]
  def up
    Rails.logger.info "Starting comment body updates..."

    updated_count = 0
    skipped_count = 0
    error_count = 0

    Decidim::Comments::Comment.find_each do |comment|
      next if comment.body.blank?

      updated_body = process_comment_body(comment.body)
      body_changed = updated_body != comment.body

      if body_changed
        comment.update_column(:body, updated_body) # rubocop:disable Rails/SkipsModelValidations
        updated_count += 1
        Rails.logger.info "✓ Updated comment ##{comment.id}"
      else
        skipped_count += 1
      end
    rescue StandardError => e
      error_count += 1
      Rails.logger.error "✗ Error updating comment ##{comment.id}: #{e.message}"
    end

    log_summary(updated_count, skipped_count, error_count)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def process_comment_body(body)
    updated_body = {}

    body.each do |locale, text|
      updated_body[locale] = if locale == "machine_translations" && text.is_a?(Hash)
                               process_machine_translations(text)
                             else
                               replace_user_group_references(text)
                             end
    end

    updated_body
  end

  def process_machine_translations(translations)
    updated_translations = {}

    translations.each do |translation_locale, translation_text|
      next if translation_text.blank?

      updated_translations[translation_locale] = replace_user_group_references(translation_text)
    end

    updated_translations
  end

  def replace_user_group_references(text)
    return text if text.blank?

    text.gsub(
      %r{gid://([^/]+)/Decidim::UserGroup/(\d+)},
      'gid://\1/Decidim::User/\2'
    )
  end

  def log_summary(updated_count, skipped_count, error_count)
    Rails.logger.info "=" * 50
    Rails.logger.info "Comment body update completed!"
    Rails.logger.info "=" * 50
    Rails.logger.info "Updated: #{updated_count}"
    Rails.logger.info "Skipped: #{skipped_count}"
    Rails.logger.info "Errors: #{error_count}"
    Rails.logger.info "=" * 50
  end
end
