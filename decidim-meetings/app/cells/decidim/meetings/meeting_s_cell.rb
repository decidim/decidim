# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the Small (:s) meeting card
    # for an given instance of a Meeting
    class MeetingSCell < MeetingMCell
      delegate :title, to: :presenter

      def meeting_path
        resource_locator(model).path
      end

      def participatory_space_class_name
        model.component.participatory_space.class.model_name.human
      end

      def participatory_space_title
        translated_attribute model.component.participatory_space.title
      end

      def participatory_space_path
        resource_locator(model.component.participatory_space).path
      end

      def presenter
        @presenter ||= Decidim::Meetings::MeetingPresenter.new(model)
      end

      private

      def cache_hash
        hash = []
        hash << I18n.locale.to_s
        hash << model.cache_key_with_version
        hash << Digest::MD5.hexdigest(model.component.cache_key_with_version)
        hash << Digest::MD5.hexdigest(resource_image_path) if resource_image_path
        hash << model.comments_count
        hash << model.follows_count
        hash << render_space? ? 1 : 0

        if current_user
          hash << current_user.cache_key_with_version
          hash << current_user.follows?(model) ? 1 : 0
        end
        hash << Digest::MD5.hexdigest(model.author.cache_key_with_version)
        hash << (model.must_render_translation?(current_organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)

        hash.join(Decidim.cache_key_separator)
      end
    end
  end
end
