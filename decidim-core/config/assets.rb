# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_core: "#{base_path}/app/packs/entrypoints/decidim_core.js",
  decidim_sw: "#{base_path}/app/packs/entrypoints/decidim_sw.js",
  redesigned_decidim_core: "#{base_path}/app/packs/entrypoints/redesigned_decidim_core.js",
  decidim_conference_diploma: "#{base_path}/app/packs/entrypoints/decidim_conference_diploma.js",
  decidim_editor: "#{base_path}/app/packs/entrypoints/decidim_editor.js",
  decidim_emojibase_da: "#{base_path}/app/packs/entrypoints/decidim_emojibase_de.js",
  decidim_emojibase_de: "#{base_path}/app/packs/entrypoints/decidim_emojibase_de.js",
  decidim_emojibase_en: "#{base_path}/app/packs/entrypoints/decidim_emojibase_en.js",
  decidim_emojibase_en_gb: "#{base_path}/app/packs/entrypoints/decidim_emojibase_en_gb.js",
  decidim_emojibase_es: "#{base_path}/app/packs/entrypoints/decidim_emojibase_es.js",
  decidim_emojibase_es_mx: "#{base_path}/app/packs/entrypoints/decidim_emojibase_es_mx.js",
  decidim_emojibase_et: "#{base_path}/app/packs/entrypoints/decidim_emojibase_et.js",
  decidim_emojibase_fi: "#{base_path}/app/packs/entrypoints/decidim_emojibase_fi.js",
  decidim_emojibase_fr: "#{base_path}/app/packs/entrypoints/decidim_emojibase_fr.js",
  decidim_emojibase_hu: "#{base_path}/app/packs/entrypoints/decidim_emojibase_hu.js",
  decidim_emojibase_it: "#{base_path}/app/packs/entrypoints/decidim_emojibase_it.js",
  decidim_emojibase_ja: "#{base_path}/app/packs/entrypoints/decidim_emojibase_ja.js",
  decidim_emojibase_ko: "#{base_path}/app/packs/entrypoints/decidim_emojibase_ko.js",
  decidim_emojibase_lt: "#{base_path}/app/packs/entrypoints/decidim_emojibase_lt.js",
  decidim_emojibase_ms: "#{base_path}/app/packs/entrypoints/decidim_emojibase_ms.js",
  decidim_emojibase_nb: "#{base_path}/app/packs/entrypoints/decidim_emojibase_nb.js",
  decidim_emojibase_nl: "#{base_path}/app/packs/entrypoints/decidim_emojibase_nl.js",
  decidim_emojibase_pl: "#{base_path}/app/packs/entrypoints/decidim_emojibase_pl.js",
  decidim_emojibase_pt: "#{base_path}/app/packs/entrypoints/decidim_emojibase_pt.js",
  decidim_emojibase_ru: "#{base_path}/app/packs/entrypoints/decidim_emojibase_ru.js",
  decidim_emojibase_sv: "#{base_path}/app/packs/entrypoints/decidim_emojibase_sv.js",
  decidim_emojibase_th: "#{base_path}/app/packs/entrypoints/decidim_emojibase_th.js",
  decidim_emojibase_uk: "#{base_path}/app/packs/entrypoints/decidim_emojibase_uk.js",
  decidim_emojibase_zh: "#{base_path}/app/packs/entrypoints/decidim_emojibase_zh.js",
  decidim_emojibase_zh_hant: "#{base_path}/app/packs/entrypoints/decidim_emojibase_zh_hant.js",
  decidim_email: "#{base_path}/app/packs/entrypoints/decidim_email.js",
  decidim_map: "#{base_path}/app/packs/entrypoints/decidim_map.js",
  decidim_geocoding_provider_photon: "#{base_path}/app/packs/entrypoints/decidim_geocoding_provider_photon.js",
  decidim_geocoding_provider_here: "#{base_path}/app/packs/entrypoints/decidim_geocoding_provider_here.js",
  decidim_map_provider_default: "#{base_path}/app/packs/entrypoints/decidim_map_provider_default.js",
  decidim_map_provider_here: "#{base_path}/app/packs/entrypoints/decidim_map_provider_here.js",
  decidim_widget: "#{base_path}/app/packs/entrypoints/decidim_widget.js"
)
