# frozen_string_literal: true

module Decidim
  module Blogs
    # This class holds a Form to update pages from Decidim's admin panel.
    class PostForm < Decidim::Form
      include TranslatableAttributes
      include Decidim::HasTaxonomyFormAttributes
      include Decidim::AttachmentAttributes
      include Decidim::HasUploadValidations

      translatable_attribute :title, String
      translatable_attribute :body, Decidim::Attributes::RichText

      attribute :decidim_author_id, Integer

      attachments_attribute :documents

      validates :body, translatable_presence: true
      validates :title, translatable_presence: true

      validate :can_set_author

      alias component current_component

      def map_model(model)
        presenter = PostPresenter.new(model)

        self.title = presenter.title
        self.body = presenter.body
        self.documents = model.attachments
      end

      def author
        @author ||= Decidim::UserBaseEntity.find_by(
          organization: current_organization,
          id: decidim_author_id
        )
      end

      private

      def can_set_author
        return if author == current_user
        return if author == post&.author

        errors.add(:decidim_author_id, :invalid)
      end

      def post
        @post ||= Post.find_by(id: id)
      end

      def participatory_space_manifest
        @participatory_space_manifest ||= current_component.participatory_space.manifest.name
      end
    end
  end
end
