# frozen_string_literal: true

namespace :decidim do
  namespace :editor do
    desc "Migrates inline images to ActiveStorage editor_image attachments"
    task :migrate_inline_images_to_active_storage, [:admin_email] => :environment do |_t, args|
      user = Decidim::User.find_by(email: args[:admin_email])

      raise "Invalid admin. Please, provide the email of an admin with permissions to create editor images" unless user&.admin? && user&.admin_terms_accepted?

      Decidim::ContentParsers::InlineImagesParser::AVAILABLE_ATTRIBUTES.each do |model, attributes|
        puts "=== Updating model #{model.name} (attributes: #{attributes.join(", ")})..."
        model.all.each do |item|
          attributes.each do |attribute|
            item.update(attribute => rewrite_value(item.send(attribute), user))
          end
        end
        puts "=== Finished update of model #{model.name}\n\n"
      end
    end

    def rewrite_value(value, user)
      if value.is_a?(Hash)
        value.transform_values do |nested_value|
          rewrite_value(nested_value, user)
        end
      else
        parser = Decidim::ContentParsers::InlineImagesParser.new(value, user: user)
        parser.rewrite
      end
    end
  end
end
