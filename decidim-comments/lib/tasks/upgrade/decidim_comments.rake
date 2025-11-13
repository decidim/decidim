# frozen_string_literal: true

namespace :decidim_comments do
  namespace :upgrade do
    desc "Adds participatory_process_id to comments if they are associated with a participatory process"
    task participatory_process_in_comments: :environment do
      puts "Updating comments..."
      ok = errors = 0

      log = ActiveSupport::Logger.new(Rails.root.join("log/update_participatory_process_in_comments.log"))
      Decidim::Comments::Comment.where(participatory_space: nil).find_each do |c|
        c.participatory_space = if c.root_commentable.is_a?(Decidim::Participable)
                                  c.root_commentable
                                else
                                  c.commentable.try(:participatory_space)
                                end
        c.save(validate: false)
        ok += 1
      rescue StandardError => e
        errors += 1
        log.info "Error updating comment ##{c.id}: #{e.message}"
      end

      puts "#{ok} comments updated."
      puts "#{errors} errors found. Check the file 'log/update_participatory_process_in_comments.log' for more information." if errors.positive?
    end

    desc "Updates GlobalIDs from UserGroups to Users"
    task update_user_group_references: :environment do
      puts "Starting comment body updates..."

      updated_count = 0
      skipped_count = 0
      error_count = 0

      Decidim::Comments::Comment.find_each do |comment|
        next if comment.body.blank?

        body_changed = false
        updated_body = {}

        # Process each locale in the body hash
        comment.body.each do |locale, text|
          if locale == "machine_translations" && text.is_a?(Hash)
            # Handle machine_translations nested hash
            updated_translations = {}
            text.each do |translation_locale, translation_text|
              next if translation_text.blank?

              updated_translation = translation_text.gsub(
                %r{gid://([^/]+)/Decidim::UserGroup/(\d+)},
                'gid://\1/Decidim::User/\2'
              )

              updated_translations[translation_locale] = updated_translation
              body_changed = true if updated_translation != translation_text
            end
            updated_body[locale] = updated_translations
          else
            # Handle regular locale strings
            next if text.blank?

            updated_text = text.gsub(
              %r{gid://([^/]+)/Decidim::UserGroup/(\d+)},
              'gid://\1/Decidim::User/\2'
            )

            updated_body[locale] = updated_text
            body_changed = true if updated_text != text
          end
        end

        if body_changed
          comment.update_column(:body, updated_body) # rubocop:disable Rails/SkipsModelValidations
          updated_count += 1
          puts "✓ Updated comment ##{comment.id}"
        else
          skipped_count += 1
        end
      rescue StandardError => e
        error_count += 1
        puts "✗ Error updating comment ##{comment.id}: #{e.message}"
      end

      puts "=" * 50
      puts "Comment body update completed!"
      puts "=" * 50
      puts "Updated: #{updated_count}"
      puts "Skipped: #{skipped_count}"
      puts "Errors: #{error_count}"
      puts "=" * 50
    end
  end
end
