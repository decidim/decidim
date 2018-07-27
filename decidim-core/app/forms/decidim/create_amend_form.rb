# frozen_string_literal: true

module Decidim
  # A form object to be used when users want to amend a amendable resource.
  class CreateAmendForm < Decidim::Form
    mimic :amend

    attribute :amendable_gid, String
    attribute :title, String
    attribute :body, String

    validates :amendable_gid, :amendable_type, :amender, presence: true

    def amendable
      @amendable ||= GlobalID::Locator.locate_signed amendable_gid
    end

    def amendable_type
      amendable.resource_manifest.model_class_name
    end

    def amender
      current_user
    end

    # def title
    #   amendable.title
    # end
    #
    # def body
    #   amendable.body
    # end
  end
end
