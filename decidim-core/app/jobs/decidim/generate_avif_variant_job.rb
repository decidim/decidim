# frozen_string_literal: true

module Decidim
  class GenerateAvifVariantJob < ApplicationJob
    queue_as { ::ActiveStorage.queues[:transform] }
    def perform(model_class, model_id, mounted_as, variant_key)
      model = model_class.constantize.find_by(id: model_id)
      return unless model

      uploader = model.attached_uploader(mounted_as)
      return unless uploader.attached?

      uploader.avif_variant(variant_key)
    rescue StandardError => e
      Rails.logger.warn "[AVIF] Failed to generate variant for #{model_class}##{model_id}.#{mounted_as} (#{variant_key}): #{e.message}"
    end
  end
end
