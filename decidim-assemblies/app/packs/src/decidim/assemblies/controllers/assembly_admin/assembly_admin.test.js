/* eslint max-lines: ["error", 1100] */

import { Application } from "@hotwired/stimulus"
import Controller from "src/decidim/assemblies/controllers/assembly_admin/controller"

describe("AssemblyAdminController", () => {
  let application = null;
  let controller = null;
  let element = null;

  beforeEach(async () => {
    // Set up DOM structure that matches the actual form
    document.body.innerHTML = `
  <div class="item__edit-form">
    <form data-controller="assembly-admin form-validator" data-live-validate="true" data-validate-on-blur="true" class="form-defaults form new_assembly assembly_form_admin" id="new_assembly" novalidate="novalidate" enctype="multipart/form-data" action="/admin/assemblies" accept-charset="UTF-8" method="post" data-form-validator="true">
      <input type="hidden" name="authenticity_token" value="GWgZVFN6v7DJo-hJWE1D_l47XiGxbXTwbOKj3wwOdAz1nH4F7ags0BeLLCFbuk8ER0XUjlxlTz494ebp1V6lSA" autocomplete="off" id="input-dummy-1">
      <div class="form__wrapper">
        <div class="card" data-controller="accordion" id="accordion-title" data-component="accordion" role="presentation">
          <div class="card-divider">
            <button class="card-divider-button" data-open="true" data-controls="panel-title" type="button" role="button" tabindex="0" aria-controls="panel-title" aria-expanded="true" aria-disabled="false">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-s-line"></use>
              </svg>
              <h2 class="card-title" id="title"> General Information </h2>
            </button>
          </div>
          <div id="panel-title" class="card-section" role="region" tabindex="-1" aria-labelledby="" aria-hidden="false" data-accessibility-violation="true">
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_title">Title <span class="inline-block" data-controller="tooltip" data-tooltip-tooltip-value="&lt;p class=&quot;top&quot; role=&quot;tooltip&quot; aria-hidden=&quot;true&quot;&gt;Required field&lt;/p&gt;">
                    <span class="label-required">
                      <span aria-hidden="true">*</span>
                      <span class="sr-only">Required field</span>
                    </span>
                  </span>
                </label>
                <ul class="tabs tabs--lang" id="assembly-title-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-title-tabs-title-panel-0" role="tab" aria-controls="assembly-title-tabs-title-panel-0" aria-selected="true" id="assembly-title-tabs-title-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-title-tabs-title-panel-1" role="tab" aria-controls="assembly-title-tabs-title-panel-1" aria-selected="false" id="assembly-title-tabs-title-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-title-tabs-title-panel-2" role="tab" aria-controls="assembly-title-tabs-title-panel-2" aria-selected="false" id="assembly-title-tabs-title-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-title-tabs">
                <div class="tabs-panel is-active" id="assembly-title-tabs-title-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-title-tabs-title-panel-0-label">
                  <input autofocus="autofocus" aria-label="title" type="text" name="assembly[title_en]" id="assembly_title_en">
                </div>
                <div class="tabs-panel" id="assembly-title-tabs-title-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-title-tabs-title-panel-1-label">
                  <input autofocus="autofocus" aria-label="title" type="text" name="assembly[title_es]" id="assembly_title_es">
                </div>
                <div class="tabs-panel" id="assembly-title-tabs-title-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-title-tabs-title-panel-2-label">
                  <input autofocus="autofocus" aria-label="title" type="text" name="assembly[title_ca]" id="assembly_title_ca">
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_subtitle">Subtitle <span class="inline-block" data-controller="tooltip" data-tooltip-tooltip-value="&lt;p class=&quot;top&quot; role=&quot;tooltip&quot; aria-hidden=&quot;true&quot;&gt;Required field&lt;/p&gt;">
                    <span class="label-required">
                      <span aria-hidden="true">*</span>
                      <span class="sr-only">Required field</span>
                    </span>
                  </span>
                </label>
                <ul class="tabs tabs--lang" id="assembly-subtitle-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-subtitle-tabs-subtitle-panel-0" role="tab" aria-controls="assembly-subtitle-tabs-subtitle-panel-0" aria-selected="true" id="assembly-subtitle-tabs-subtitle-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-subtitle-tabs-subtitle-panel-1" role="tab" aria-controls="assembly-subtitle-tabs-subtitle-panel-1" aria-selected="false" id="assembly-subtitle-tabs-subtitle-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-subtitle-tabs-subtitle-panel-2" role="tab" aria-controls="assembly-subtitle-tabs-subtitle-panel-2" aria-selected="false" id="assembly-subtitle-tabs-subtitle-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-subtitle-tabs">
                <div class="tabs-panel is-active" id="assembly-subtitle-tabs-subtitle-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-subtitle-tabs-subtitle-panel-0-label">
                  <input aria-label="subtitle" type="text" name="assembly[subtitle_en]" id="assembly_subtitle_en">
                </div>
                <div class="tabs-panel" id="assembly-subtitle-tabs-subtitle-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-subtitle-tabs-subtitle-panel-1-label">
                  <input aria-label="subtitle" type="text" name="assembly[subtitle_es]" id="assembly_subtitle_es">
                </div>
                <div class="tabs-panel" id="assembly-subtitle-tabs-subtitle-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-subtitle-tabs-subtitle-panel-2-label">
                  <input aria-label="subtitle" type="text" name="assembly[subtitle_ca]" id="assembly_subtitle_ca">
                </div>
              </div>
            </div>
            <div class="row column">
              <label for="assembly_weight">Order position <span class="inline-block" data-controller="tooltip" data-tooltip-tooltip-value="&lt;p class=&quot;top&quot; role=&quot;tooltip&quot; aria-hidden=&quot;true&quot;&gt;Required field&lt;/p&gt;" aria-describedby="tooltip-v06j2">
                  <span class="label-required">
                    <span aria-hidden="true">*</span>
                    <span class="sr-only">Required field</span>
                  </span>
                </span>
                <input required="required" type="number" value="0" name="assembly[weight]" id="assembly_weight">
                <span class="form-error" role="alert">There is an error in this field.</span>
              </label>
            </div>
            <div class="row">
              <div class="columns slug">
                <label for="assembly_slug">URL slug <span class="inline-block" data-controller="tooltip" data-tooltip-tooltip-value="&lt;p class=&quot;top&quot; role=&quot;tooltip&quot; aria-hidden=&quot;true&quot;&gt;Required field&lt;/p&gt;">
                    <span class="label-required">
                      <span aria-hidden="true">*</span>
                      <span class="sr-only">Required field</span>
                    </span>
                  </span>
                  <span class="help-text">URL slugs are used to generate the URLs that point to this assembly. Only accepts letters, numbers and dashes, and must start with a letter. Example: <span class="slug-url">http://alecslupu.go.ro:3000/assemblies/ <span class="slug-url-value"></span>
                    </span>
                  </span>
                  <input required="required" type="text" name="assembly[slug]" id="assembly_slug">
                  <span class="form-error" role="alert">There is an error in this field.</span>
                </label>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_short_description">Short description <span class="inline-block" data-controller="tooltip" data-tooltip-tooltip-value="&lt;p class=&quot;top&quot; role=&quot;tooltip&quot; aria-hidden=&quot;true&quot;&gt;Required field&lt;/p&gt;">
                    <span class="label-required">
                      <span aria-hidden="true">*</span>
                      <span class="sr-only">Required field</span>
                    </span>
                  </span>
                </label>
                <ul class="tabs tabs--lang" id="assembly-short_description-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-short_description-tabs-short_description-panel-0" role="tab" aria-controls="assembly-short_description-tabs-short_description-panel-0" aria-selected="true" id="assembly-short_description-tabs-short_description-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-short_description-tabs-short_description-panel-1" role="tab" aria-controls="assembly-short_description-tabs-short_description-panel-1" aria-selected="false" id="assembly-short_description-tabs-short_description-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-short_description-tabs-short_description-panel-2" role="tab" aria-controls="assembly-short_description-tabs-short_description-panel-2" aria-selected="false" id="assembly-short_description-tabs-short_description-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-short_description-tabs">
                <div class="tabs-panel is-active" id="assembly-short_description-tabs-short_description-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-short_description-tabs-short_description-panel-0-label">
                  <div class="editor" id="assembly_short_description_en">
                    <input aria-label="short_description" label="false" autocomplete="off" type="hidden" name="assembly[short_description_en]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-short_description-tabs-short_description-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-short_description-tabs-short_description-panel-1-label">
                  <div class="editor" id="assembly_short_description_es">
                    <input aria-label="short_description" label="false" autocomplete="off" type="hidden" name="assembly[short_description_es]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-short_description-tabs-short_description-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-short_description-tabs-short_description-panel-2-label">
                  <div class="editor" id="assembly_short_description_ca">
                    <input aria-label="short_description" label="false" autocomplete="off" type="hidden" name="assembly[short_description_ca]">
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_description">Description <span class="inline-block" data-controller="tooltip" data-tooltip-tooltip-value="&lt;p class=&quot;top&quot; role=&quot;tooltip&quot; aria-hidden=&quot;true&quot;&gt;Required field&lt;/p&gt;">
                    <span class="label-required">
                      <span aria-hidden="true">*</span>
                      <span class="sr-only">Required field</span>
                    </span>
                  </span>
                </label>
                <ul class="tabs tabs--lang" id="assembly-description-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-description-tabs-description-panel-0" role="tab" aria-controls="assembly-description-tabs-description-panel-0" aria-selected="true" id="assembly-description-tabs-description-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-description-tabs-description-panel-1" role="tab" aria-controls="assembly-description-tabs-description-panel-1" aria-selected="false" id="assembly-description-tabs-description-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-description-tabs-description-panel-2" role="tab" aria-controls="assembly-description-tabs-description-panel-2" aria-selected="false" id="assembly-description-tabs-description-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-description-tabs">
                <div class="tabs-panel is-active" id="assembly-description-tabs-description-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-description-tabs-description-panel-0-label">
                  <div class="editor" id="assembly_description_en">
                    <input aria-label="description" label="false" autocomplete="off" type="hidden" name="assembly[description_en]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-description-tabs-description-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-description-tabs-description-panel-1-label">
                  <div class="editor" id="assembly_description_es">
                    <input aria-label="description" label="false" autocomplete="off" type="hidden" name="assembly[description_es]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-description-tabs-description-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-description-tabs-description-panel-2-label">
                  <div class="editor" id="assembly_description_ca">
                    <input aria-label="description" label="false" autocomplete="off" type="hidden" name="assembly[description_ca]">
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_purpose_of_action">Purpose of action</label>
                <ul class="tabs tabs--lang" id="assembly-purpose_of_action-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-purpose_of_action-tabs-purpose_of_action-panel-0" role="tab" aria-controls="assembly-purpose_of_action-tabs-purpose_of_action-panel-0" aria-selected="true" id="assembly-purpose_of_action-tabs-purpose_of_action-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-purpose_of_action-tabs-purpose_of_action-panel-1" role="tab" aria-controls="assembly-purpose_of_action-tabs-purpose_of_action-panel-1" aria-selected="false" id="assembly-purpose_of_action-tabs-purpose_of_action-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-purpose_of_action-tabs-purpose_of_action-panel-2" role="tab" aria-controls="assembly-purpose_of_action-tabs-purpose_of_action-panel-2" aria-selected="false" id="assembly-purpose_of_action-tabs-purpose_of_action-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-purpose_of_action-tabs">
                <div class="tabs-panel is-active" id="assembly-purpose_of_action-tabs-purpose_of_action-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-purpose_of_action-tabs-purpose_of_action-panel-0-label">
                  <div class="editor" id="assembly_purpose_of_action_en">
                    <input aria-label="purpose_of_action" label="false" autocomplete="off" type="hidden" name="assembly[purpose_of_action_en]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-purpose_of_action-tabs-purpose_of_action-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-purpose_of_action-tabs-purpose_of_action-panel-1-label">
                  <div class="editor" id="assembly_purpose_of_action_es">
                    <input aria-label="purpose_of_action" label="false" autocomplete="off" type="hidden" name="assembly[purpose_of_action_es]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-purpose_of_action-tabs-purpose_of_action-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-purpose_of_action-tabs-purpose_of_action-panel-2-label">
                  <div class="editor" id="assembly_purpose_of_action_ca">
                    <input aria-label="purpose_of_action" label="false" autocomplete="off" type="hidden" name="assembly[purpose_of_action_ca]">
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_composition">Composition</label>
                <ul class="tabs tabs--lang" id="assembly-composition-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-composition-tabs-composition-panel-0" role="tab" aria-controls="assembly-composition-tabs-composition-panel-0" aria-selected="true" id="assembly-composition-tabs-composition-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-composition-tabs-composition-panel-1" role="tab" aria-controls="assembly-composition-tabs-composition-panel-1" aria-selected="false" id="assembly-composition-tabs-composition-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-composition-tabs-composition-panel-2" role="tab" aria-controls="assembly-composition-tabs-composition-panel-2" aria-selected="false" id="assembly-composition-tabs-composition-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-composition-tabs">
                <div class="tabs-panel is-active" id="assembly-composition-tabs-composition-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-composition-tabs-composition-panel-0-label">
                  <div class="editor" id="assembly_composition_en">
                    <input aria-label="composition" label="false" autocomplete="off" type="hidden" name="assembly[composition_en]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-composition-tabs-composition-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-composition-tabs-composition-panel-1-label">
                  <div class="editor" id="assembly_composition_es">
                    <input aria-label="composition" label="false" autocomplete="off" type="hidden" name="assembly[composition_es]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-composition-tabs-composition-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-composition-tabs-composition-panel-2-label">
                  <div class="editor" id="assembly_composition_ca">
                    <input aria-label="composition" label="false" autocomplete="off" type="hidden" name="assembly[composition_ca]">
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_internal_organisation">Internal organization</label>
                <ul class="tabs tabs--lang" id="assembly-internal_organisation-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-internal_organisation-tabs-internal_organisation-panel-0" role="tab" aria-controls="assembly-internal_organisation-tabs-internal_organisation-panel-0" aria-selected="true" id="assembly-internal_organisation-tabs-internal_organisation-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-internal_organisation-tabs-internal_organisation-panel-1" role="tab" aria-controls="assembly-internal_organisation-tabs-internal_organisation-panel-1" aria-selected="false" id="assembly-internal_organisation-tabs-internal_organisation-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-internal_organisation-tabs-internal_organisation-panel-2" role="tab" aria-controls="assembly-internal_organisation-tabs-internal_organisation-panel-2" aria-selected="false" id="assembly-internal_organisation-tabs-internal_organisation-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-internal_organisation-tabs">
                <div class="tabs-panel is-active" id="assembly-internal_organisation-tabs-internal_organisation-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-internal_organisation-tabs-internal_organisation-panel-0-label">
                  <div class="editor" id="assembly_internal_organisation_en">
                    <input aria-label="internal_organisation" label="false" autocomplete="off" type="hidden" name="assembly[internal_organisation_en]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-internal_organisation-tabs-internal_organisation-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-internal_organisation-tabs-internal_organisation-panel-1-label">
                  <div class="editor" id="assembly_internal_organisation_es">
                    <input aria-label="internal_organisation" label="false" autocomplete="off" type="hidden" name="assembly[internal_organisation_es]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-internal_organisation-tabs-internal_organisation-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-internal_organisation-tabs-internal_organisation-panel-2-label">
                  <div class="editor" id="assembly_internal_organisation_ca">
                    <input aria-label="internal_organisation" label="false" autocomplete="off" type="hidden" name="assembly[internal_organisation_ca]">
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_announcement">Announcement</label>
                <ul class="tabs tabs--lang" id="assembly-announcement-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-announcement-tabs-announcement-panel-0" role="tab" aria-controls="assembly-announcement-tabs-announcement-panel-0" aria-selected="true" id="assembly-announcement-tabs-announcement-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-announcement-tabs-announcement-panel-1" role="tab" aria-controls="assembly-announcement-tabs-announcement-panel-1" aria-selected="false" id="assembly-announcement-tabs-announcement-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-announcement-tabs-announcement-panel-2" role="tab" aria-controls="assembly-announcement-tabs-announcement-panel-2" aria-selected="false" id="assembly-announcement-tabs-announcement-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-announcement-tabs">
                <div class="tabs-panel is-active" id="assembly-announcement-tabs-announcement-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-announcement-tabs-announcement-panel-0-label">
                  <div class="editor" id="assembly_announcement_en">
                    <input label="false" autocomplete="off" type="hidden" name="assembly[announcement_en]">
                    <span class="help-text">The text you enter here will be shown to the user right below the assembly information.</span>
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-announcement-tabs-announcement-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-announcement-tabs-announcement-panel-1-label">
                  <div class="editor" id="assembly_announcement_es">
                    <input label="false" autocomplete="off" type="hidden" name="assembly[announcement_es]">
                    <span class="help-text">The text you enter here will be shown to the user right below the assembly information.</span>
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-announcement-tabs-announcement-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-announcement-tabs-announcement-panel-2-label">
                  <div class="editor" id="assembly_announcement_ca">
                    <input label="false" autocomplete="off" type="hidden" name="assembly[announcement_ca]">
                    <span class="help-text">The text you enter here will be shown to the user right below the assembly information.</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="card" data-controller="accordion" id="accordion-duration" data-component="accordion" role="presentation">
          <div class="card-divider">
            <button class="card-divider-button" data-open="true" data-controls="panel-duration" type="button" role="button" tabindex="0" aria-controls="panel-duration" aria-expanded="true" aria-disabled="false">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-s-line"></use>
              </svg>
              <h2 class="card-title" id="duration"> Duration </h2>
            </button>
          </div>
          <div id="panel-duration" class="card-section" role="region" tabindex="-1" aria-labelledby="" aria-hidden="false">
            <div class="row column">
              <label for="assembly_creation_date">Date created <input type="date" name="assembly[creation_date]" id="assembly_creation_date" style="display: none;">
              </label>
              <div class="datepicker__help-text-container">
                <span class="help-text datepicker__help-date">Format: dd/mm/yyyy</span>
              </div>
              <div id="assembly_creation_date_datepicker_row" class="datepicker__datepicker-row">
                <div class="datepicker__date-column">
                  <input id="assembly_creation_date_date" type="text" aria-label="undefined">
                  <button class="datepicker__calendar-button" type="button" aria-label="undefined">
                    <svg width="0.75em" height="0.75em" role="img" aria-hidden="true">
                      <title>calendar-line</title>
                      <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-calendar-line"></use>
                    </svg>
                  </button>
                  <div class="datepicker__container" style="display: none;">
                    <wc-datepicker id="assembly_creation_date_date_datepicker" locale="en" class="sc-wc-datepicker-h sc-wc-datepicker-s hydrated">
                      <div aria-disabled="false" aria-label="Choose date" class="wc-datepicker sc-wc-datepicker" role="group">
                      </div>
                    </wc-datepicker>
                    <button class="datepicker__close-calendar button button__transparent-secondary button__xs" type="button">Close</button>
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <label for="assembly_included_at">Included at <span class="help-text">Select the date when this assembly was added to the platform. It does not necessarily have to be the same as the creation date.</span>
                <input type="date" name="assembly[included_at]" id="assembly_included_at" style="display: none;">
              </label>
              <div class="datepicker__help-text-container">
                <span class="help-text datepicker__help-date">Format: dd/mm/yyyy</span>
              </div>
              <div id="assembly_included_at_datepicker_row" class="datepicker__datepicker-row">
                <div class="datepicker__date-column">
                  <input id="assembly_included_at_date" type="text" aria-label="undefined">
                  <button class="datepicker__calendar-button" type="button" aria-label="undefined">
                    <svg width="0.75em" height="0.75em" role="img" aria-hidden="true">
                      <title>calendar-line</title>
                      <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-calendar-line"></use>
                    </svg>
                  </button>
                  <div class="datepicker__container" style="display: none;">
                    <wc-datepicker id="assembly_included_at_date_datepicker" locale="en" class="sc-wc-datepicker-h sc-wc-datepicker-s hydrated">
                    </wc-datepicker>
                    <button class="datepicker__close-calendar button button__transparent-secondary button__xs" type="button">Close</button>
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <label for="assembly_duration">Duration <span class="help-text">If the duration of this assembly is limited, select the end date. Otherwise, it will appear as indefinite.</span>
                <input type="date" name="assembly[duration]" id="assembly_duration" style="display: none;">
              </label>
              <div class="datepicker__help-text-container">
                <span class="help-text datepicker__help-date">Format: dd/mm/yyyy</span>
              </div>
              <div id="assembly_duration_datepicker_row" class="datepicker__datepicker-row">
                <div class="datepicker__date-column">
                  <input id="assembly_duration_date" type="text" aria-label="undefined">
                  <button class="datepicker__calendar-button" type="button" aria-label="undefined">
                    <svg width="0.75em" height="0.75em" role="img" aria-hidden="true">
                      <title>calendar-line</title>
                      <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-calendar-line"></use>
                    </svg>
                  </button>
                  <div class="datepicker__container" style="display: none;">
                    <button class="datepicker__close-calendar button button__transparent-secondary button__xs" type="button">Close</button>
                  </div>
                </div>
              </div>
            </div>
            <div class="row column" id="closing_date_div">
              <label for="assembly_closing_date">Closing date <input type="date" name="assembly[closing_date]" id="assembly_closing_date" style="display: none;">
              </label>
              <div class="datepicker__help-text-container">
                <span class="help-text datepicker__help-date">Format: dd/mm/yyyy</span>
              </div>
              <div id="assembly_closing_date_datepicker_row" class="datepicker__datepicker-row">
                <div class="datepicker__date-column">
                  <input id="assembly_closing_date_date" type="text" aria-label="undefined">
                  <button class="datepicker__calendar-button" type="button" aria-label="undefined">
                    <svg width="0.75em" height="0.75em" role="img" aria-hidden="true">
                      <title>calendar-line</title>
                      <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-calendar-line"></use>
                    </svg>
                  </button>
                  <div class="datepicker__container" style="display: none;">
                    <button class="datepicker__close-calendar button button__transparent-secondary button__xs" type="button">Close</button>
                  </div>
                </div>
              </div>
            </div>
            <div class="row column" id="closing_date_reason_div">
              <div class="label--tabs">
                <label for="assembly_closing_date_reason">Closing date reason</label>
                <ul class="tabs tabs--lang" id="assembly-closing_date_reason-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-closing_date_reason-tabs-closing_date_reason-panel-0" role="tab" aria-controls="assembly-closing_date_reason-tabs-closing_date_reason-panel-0" aria-selected="true" id="assembly-closing_date_reason-tabs-closing_date_reason-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-closing_date_reason-tabs-closing_date_reason-panel-1" role="tab" aria-controls="assembly-closing_date_reason-tabs-closing_date_reason-panel-1" aria-selected="false" id="assembly-closing_date_reason-tabs-closing_date_reason-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-closing_date_reason-tabs-closing_date_reason-panel-2" role="tab" aria-controls="assembly-closing_date_reason-tabs-closing_date_reason-panel-2" aria-selected="false" id="assembly-closing_date_reason-tabs-closing_date_reason-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-closing_date_reason-tabs">
                <div class="tabs-panel is-active" id="assembly-closing_date_reason-tabs-closing_date_reason-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-closing_date_reason-tabs-closing_date_reason-panel-0-label">
                  <div class="editor" id="assembly_closing_date_reason_en">
                    <input aria-label="closing_date_reason" label="false" autocomplete="off" type="hidden" name="assembly[closing_date_reason_en]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-closing_date_reason-tabs-closing_date_reason-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-closing_date_reason-tabs-closing_date_reason-panel-1-label">
                  <div class="editor" id="assembly_closing_date_reason_es">
                    <input aria-label="closing_date_reason" label="false" autocomplete="off" type="hidden" name="assembly[closing_date_reason_es]">
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-closing_date_reason-tabs-closing_date_reason-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-closing_date_reason-tabs-closing_date_reason-panel-2-label">
                  <div class="editor" id="assembly_closing_date_reason_ca">
                    <input aria-label="closing_date_reason" label="false" autocomplete="off" type="hidden" name="assembly[closing_date_reason_ca]">
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="card" data-controller="accordion" id="accordion-images" data-component="accordion" role="presentation">
          <div class="card-divider">
            <button class="card-divider-button" data-open="true" data-controls="panel-images" type="button" role="button" tabindex="0" aria-controls="panel-images" aria-expanded="true" aria-disabled="false">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-s-line"></use>
              </svg>
              <h2 class="card-title" id="images"> Images </h2>
            </button>
          </div>
          <div id="panel-images" class="card-section" role="region" tabindex="-1" aria-labelledby="" aria-hidden="false">
            <div class="row">
              <div class="columns">
                <div class="upload-modal__files-container upload-container-for-hero_image ">
                  <div>
                    <label>Home image</label>
                    <div class="upload-modal__files" data-active-uploads="upload_c5515a82-b6d4-4c1c-a957-013c9679b956"></div>
                  </div>
                  <button id="assembly_hero_image_button" name="hero_image" class="button button__sm button__transparent-secondary" type="button" data-dialog-open="upload_c5515a82-b6d4-4c1c-a957-013c9679b956" data-upload="{&quot;addAttribute&quot;:&quot;hero_image&quot;,&quot;resourceName&quot;:&quot;assembly&quot;,&quot;resourceClass&quot;:&quot;Decidim::Assembly&quot;,&quot;required&quot;:false,&quot;maxFileSize&quot;:10485760.0,&quot;multiple&quot;:false,&quot;titled&quot;:false,&quot;formObjectClass&quot;:&quot;Decidim::Assemblies::Admin::AssemblyForm&quot;}" aria-haspopup="dialog">Add image</button>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="card" data-controller="accordion" id="accordion-metadata" data-component="accordion" role="presentation">
          <div class="card-divider">
            <button class="card-divider-button" data-open="true" data-controls="panel-metadata" type="button" role="button" tabindex="0" aria-controls="panel-metadata" aria-expanded="true" aria-disabled="false">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-s-line"></use>
              </svg>
              <h2 class="card-title" id="metadata"> Metadata </h2>
            </button>
          </div>
          <div id="panel-metadata" class="card-section" role="region" tabindex="-1" aria-labelledby="" aria-hidden="false">
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_participatory_scope">What is decided</label>
                <ul class="tabs tabs--lang" id="assembly-participatory_scope-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-participatory_scope-tabs-participatory_scope-panel-0" role="tab" aria-controls="assembly-participatory_scope-tabs-participatory_scope-panel-0" aria-selected="true" id="assembly-participatory_scope-tabs-participatory_scope-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-participatory_scope-tabs-participatory_scope-panel-1" role="tab" aria-controls="assembly-participatory_scope-tabs-participatory_scope-panel-1" aria-selected="false" id="assembly-participatory_scope-tabs-participatory_scope-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-participatory_scope-tabs-participatory_scope-panel-2" role="tab" aria-controls="assembly-participatory_scope-tabs-participatory_scope-panel-2" aria-selected="false" id="assembly-participatory_scope-tabs-participatory_scope-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-participatory_scope-tabs">
                <div class="tabs-panel is-active" id="assembly-participatory_scope-tabs-participatory_scope-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-participatory_scope-tabs-participatory_scope-panel-0-label">
                  <input aria-label="participatory_scope" type="text" name="assembly[participatory_scope_en]" id="assembly_participatory_scope_en">
                </div>
                <div class="tabs-panel" id="assembly-participatory_scope-tabs-participatory_scope-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-participatory_scope-tabs-participatory_scope-panel-1-label">
                  <input aria-label="participatory_scope" type="text" name="assembly[participatory_scope_es]" id="assembly_participatory_scope_es">
                </div>
                <div class="tabs-panel" id="assembly-participatory_scope-tabs-participatory_scope-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-participatory_scope-tabs-participatory_scope-panel-2-label">
                  <input aria-label="participatory_scope" type="text" name="assembly[participatory_scope_ca]" id="assembly_participatory_scope_ca">
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_participatory_structure">How is it decided</label>
                <ul class="tabs tabs--lang" id="assembly-participatory_structure-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-participatory_structure-tabs-participatory_structure-panel-0" role="tab" aria-controls="assembly-participatory_structure-tabs-participatory_structure-panel-0" aria-selected="true" id="assembly-participatory_structure-tabs-participatory_structure-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-participatory_structure-tabs-participatory_structure-panel-1" role="tab" aria-controls="assembly-participatory_structure-tabs-participatory_structure-panel-1" aria-selected="false" id="assembly-participatory_structure-tabs-participatory_structure-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-participatory_structure-tabs-participatory_structure-panel-2" role="tab" aria-controls="assembly-participatory_structure-tabs-participatory_structure-panel-2" aria-selected="false" id="assembly-participatory_structure-tabs-participatory_structure-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-participatory_structure-tabs">
                <div class="tabs-panel is-active" id="assembly-participatory_structure-tabs-participatory_structure-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-participatory_structure-tabs-participatory_structure-panel-0-label">
                  <input aria-label="participatory_structure" type="text" name="assembly[participatory_structure_en]" id="assembly_participatory_structure_en">
                </div>
                <div class="tabs-panel" id="assembly-participatory_structure-tabs-participatory_structure-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-participatory_structure-tabs-participatory_structure-panel-1-label">
                  <input aria-label="participatory_structure" type="text" name="assembly[participatory_structure_es]" id="assembly_participatory_structure_es">
                </div>
                <div class="tabs-panel" id="assembly-participatory_structure-tabs-participatory_structure-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-participatory_structure-tabs-participatory_structure-panel-2-label">
                  <input aria-label="participatory_structure" type="text" name="assembly[participatory_structure_ca]" id="assembly_participatory_structure_ca">
                </div>
              </div>
            </div>
            <div class="row">
              <div class="columns">
                <div class="label--tabs">
                  <label for="assembly_meta_scope">Scope metadata</label>
                  <ul class="tabs tabs--lang" id="assembly-meta_scope-tabs" data-tabs="true" role="tablist">
                    <li class="tabs-title is-active" role="presentation">
                      <a href="#assembly-meta_scope-tabs-meta_scope-panel-0" role="tab" aria-controls="assembly-meta_scope-tabs-meta_scope-panel-0" aria-selected="true" id="assembly-meta_scope-tabs-meta_scope-panel-0-label" tabindex="0">English</a>
                    </li>
                    <li class="tabs-title" role="presentation">
                      <a href="#assembly-meta_scope-tabs-meta_scope-panel-1" role="tab" aria-controls="assembly-meta_scope-tabs-meta_scope-panel-1" aria-selected="false" id="assembly-meta_scope-tabs-meta_scope-panel-1-label" tabindex="-1">Castellano</a>
                    </li>
                    <li class="tabs-title" role="presentation">
                      <a href="#assembly-meta_scope-tabs-meta_scope-panel-2" role="tab" aria-controls="assembly-meta_scope-tabs-meta_scope-panel-2" aria-selected="false" id="assembly-meta_scope-tabs-meta_scope-panel-2-label" tabindex="-1">Català</a>
                    </li>
                  </ul>
                </div>
                <div class="tabs-content" data-tabs-content="assembly-meta_scope-tabs">
                  <div class="tabs-panel is-active" id="assembly-meta_scope-tabs-meta_scope-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-meta_scope-tabs-meta_scope-panel-0-label">
                    <input aria-label="meta_scope" type="text" name="assembly[meta_scope_en]" id="assembly_meta_scope_en">
                  </div>
                  <div class="tabs-panel" id="assembly-meta_scope-tabs-meta_scope-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-meta_scope-tabs-meta_scope-panel-1-label">
                    <input aria-label="meta_scope" type="text" name="assembly[meta_scope_es]" id="assembly_meta_scope_es">
                  </div>
                  <div class="tabs-panel" id="assembly-meta_scope-tabs-meta_scope-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-meta_scope-tabs-meta_scope-panel-2-label">
                    <input aria-label="meta_scope" type="text" name="assembly[meta_scope_ca]" id="assembly_meta_scope_ca">
                  </div>
                </div>
              </div>
            </div>
            <div class="row">
              <div class="columns">
                <div class="label--tabs">
                  <label for="assembly_developer_group">Promoter group</label>
                  <ul class="tabs tabs--lang" id="assembly-developer_group-tabs" data-tabs="true" role="tablist">
                    <li class="tabs-title is-active" role="presentation">
                      <a href="#assembly-developer_group-tabs-developer_group-panel-0" role="tab" aria-controls="assembly-developer_group-tabs-developer_group-panel-0" aria-selected="true" id="assembly-developer_group-tabs-developer_group-panel-0-label" tabindex="0">English</a>
                    </li>
                    <li class="tabs-title" role="presentation">
                      <a href="#assembly-developer_group-tabs-developer_group-panel-1" role="tab" aria-controls="assembly-developer_group-tabs-developer_group-panel-1" aria-selected="false" id="assembly-developer_group-tabs-developer_group-panel-1-label" tabindex="-1">Castellano</a>
                    </li>
                    <li class="tabs-title" role="presentation">
                      <a href="#assembly-developer_group-tabs-developer_group-panel-2" role="tab" aria-controls="assembly-developer_group-tabs-developer_group-panel-2" aria-selected="false" id="assembly-developer_group-tabs-developer_group-panel-2-label" tabindex="-1">Català</a>
                    </li>
                  </ul>
                </div>
                <div class="tabs-content" data-tabs-content="assembly-developer_group-tabs">
                  <div class="tabs-panel is-active" id="assembly-developer_group-tabs-developer_group-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-developer_group-tabs-developer_group-panel-0-label">
                    <input aria-label="developer_group" type="text" name="assembly[developer_group_en]" id="assembly_developer_group_en">
                  </div>
                  <div class="tabs-panel" id="assembly-developer_group-tabs-developer_group-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-developer_group-tabs-developer_group-panel-1-label">
                    <input aria-label="developer_group" type="text" name="assembly[developer_group_es]" id="assembly_developer_group_es">
                  </div>
                  <div class="tabs-panel" id="assembly-developer_group-tabs-developer_group-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-developer_group-tabs-developer_group-panel-2-label">
                    <input aria-label="developer_group" type="text" name="assembly[developer_group_ca]" id="assembly_developer_group_ca">
                  </div>
                </div>
              </div>
              <div class="columns">
                <div class="label--tabs">
                  <label for="assembly_local_area">Organization area</label>
                  <ul class="tabs tabs--lang" id="assembly-local_area-tabs" data-tabs="true" role="tablist">
                    <li class="tabs-title is-active" role="presentation">
                      <a href="#assembly-local_area-tabs-local_area-panel-0" role="tab" aria-controls="assembly-local_area-tabs-local_area-panel-0" aria-selected="true" id="assembly-local_area-tabs-local_area-panel-0-label" tabindex="0">English</a>
                    </li>
                    <li class="tabs-title" role="presentation">
                      <a href="#assembly-local_area-tabs-local_area-panel-1" role="tab" aria-controls="assembly-local_area-tabs-local_area-panel-1" aria-selected="false" id="assembly-local_area-tabs-local_area-panel-1-label" tabindex="-1">Castellano</a>
                    </li>
                    <li class="tabs-title" role="presentation">
                      <a href="#assembly-local_area-tabs-local_area-panel-2" role="tab" aria-controls="assembly-local_area-tabs-local_area-panel-2" aria-selected="false" id="assembly-local_area-tabs-local_area-panel-2-label" tabindex="-1">Català</a>
                    </li>
                  </ul>
                </div>
                <div class="tabs-content" data-tabs-content="assembly-local_area-tabs">
                  <div class="tabs-panel is-active" id="assembly-local_area-tabs-local_area-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-local_area-tabs-local_area-panel-0-label">
                    <input aria-label="local_area" type="text" name="assembly[local_area_en]" id="assembly_local_area_en">
                  </div>
                  <div class="tabs-panel" id="assembly-local_area-tabs-local_area-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-local_area-tabs-local_area-panel-1-label">
                    <input aria-label="local_area" type="text" name="assembly[local_area_es]" id="assembly_local_area_es">
                  </div>
                  <div class="tabs-panel" id="assembly-local_area-tabs-local_area-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-local_area-tabs-local_area-panel-2-label">
                    <input aria-label="local_area" type="text" name="assembly[local_area_ca]" id="assembly_local_area_ca">
                  </div>
                </div>
              </div>
            </div>
            <div class="row column">
              <div class="label--tabs">
                <label for="assembly_target">Who participates</label>
                <ul class="tabs tabs--lang" id="assembly-target-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-target-tabs-target-panel-0" role="tab" aria-controls="assembly-target-tabs-target-panel-0" aria-selected="true" id="assembly-target-tabs-target-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-target-tabs-target-panel-1" role="tab" aria-controls="assembly-target-tabs-target-panel-1" aria-selected="false" id="assembly-target-tabs-target-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-target-tabs-target-panel-2" role="tab" aria-controls="assembly-target-tabs-target-panel-2" aria-selected="false" id="assembly-target-tabs-target-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-target-tabs">
                <div class="tabs-panel is-active" id="assembly-target-tabs-target-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-target-tabs-target-panel-0-label">
                  <input aria-label="target" type="text" name="assembly[target_en]" id="assembly_target_en">
                </div>
                <div class="tabs-panel" id="assembly-target-tabs-target-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-target-tabs-target-panel-1-label">
                  <input aria-label="target" type="text" name="assembly[target_es]" id="assembly_target_es">
                </div>
                <div class="tabs-panel" id="assembly-target-tabs-target-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-target-tabs-target-panel-2-label">
                  <input aria-label="target" type="text" name="assembly[target_ca]" id="assembly_target_ca">
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="card" data-controller="accordion" id="accordion-taxonomies" data-component="accordion" role="presentation">
          <div class="card-divider">
            <button class="card-divider-button" data-open="true" data-controls="panel-taxonomies" type="button" role="button" tabindex="0" aria-controls="panel-taxonomies" aria-expanded="true" aria-disabled="false">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-s-line"></use>
              </svg>
              <h2 class="card-title" id="taxonomies"> Taxonomies </h2>
            </button>
          </div>
          <div id="panel-taxonomies" class="card-section" role="region" tabindex="-1" aria-labelledby="" aria-hidden="false">
            <div class="row column">
              <label for="assembly_taxonomies">Scopes <select name="assembly[taxonomies][]" id="taxonomies-1">
                  <option value="" selected="selected">Please select an option</option>
                  <option value="2"> New York</option>
                  <option value="3"> &nbsp;&nbsp;&nbsp;&nbsp; South Ross</option>
                </select>
              </label>
            </div>
            <div class="row column">
              <label for="assembly_taxonomies">Areas <select name="assembly[taxonomies][]" id="taxonomies-2">
                  <option value="" selected="selected">Please select an option</option>
                  <option value="5"> Territorial</option>
                  <option value="6"> &nbsp;&nbsp;&nbsp;&nbsp; velit</option>
                  <option value="7"> Sectorial</option>
                  <option value="8"> &nbsp;&nbsp;&nbsp;&nbsp; voluptates</option>
                </select>
              </label>
            </div>
            <div class="row column">
              <label for="assembly_taxonomies">Assembly Types <select name="assembly[taxonomies][]" id="taxonomies-5">
                  <option value="" selected="selected">Please select an option</option>
                  <option value="16"> totam</option>
                </select>
              </label>
            </div>
          </div>
        </div>
        <div class="card" data-controller="accordion" id="accordion-visibility" data-component="accordion" role="presentation">
          <div class="card-divider">
            <button class="card-divider-button" data-open="true" data-controls="panel-visibility" type="button" role="button" tabindex="0" aria-controls="panel-visibility" aria-expanded="true" aria-disabled="false">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-s-line"></use>
              </svg>
              <h2 class="card-title" id="visibility"> Visibility </h2>
            </button>
          </div>
          <div id="panel-visibility" class="card-section" role="region" tabindex="-1" aria-labelledby="" aria-hidden="false">
            <div class="row column">
              <label for="assembly_parent_id">Parent assembly <select name="assembly[parent_id]" id="assembly_parent_id">
                  <option value="" selected="selected">Select parent assembly</option>
                  <option value="1"> Optio impedit cupiditate ut culpa.</option>
                  <option value="2">&nbsp;&nbsp;&nbsp;&nbsp; Voluptatum asperiores similique placeat error.</option>
                </select>
              </label>
            </div>
            <div class="row column">
              <label for="assembly_promoted">
                <input name="assembly[promoted]" type="hidden" value="0" autocomplete="off">
                <input type="checkbox" value="1" name="assembly[promoted]" id="assembly_promoted">Highlighted </label>
            </div>
            <div class="row column" id="private_space">
              <label for="assembly_private_space">
                <input name="assembly[private_space]" type="hidden" value="0" autocomplete="off">
                <input type="checkbox" value="1" name="assembly[private_space]" id="assembly_private_space">Private space </label>
              <p class="help-text">You will be able to manage members after setting it as private</p>
            </div>
            <div class="row column" id="is_transparent">
              <label for="assembly_is_transparent">
                <input name="assembly[is_transparent]" type="hidden" value="0" autocomplete="off">
                <input type="checkbox" value="1" name="assembly[is_transparent]" id="assembly_is_transparent" disabled="disabled">Is transparent </label>
            </div>
          </div>
        </div>
        <div class="card" data-controller="accordion" id="accordion-other" data-component="accordion" role="presentation">
          <div class="card-divider">
            <button class="card-divider-button" data-open="true" data-controls="panel-other" type="button" role="button" tabindex="0" aria-controls="panel-other" aria-expanded="true" aria-disabled="false">
              <svg width="1em" height="1em" role="img" aria-hidden="true">
                <use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-arrow-right-s-line"></use>
              </svg>
              <h2 class="card-title" id="other"> Other </h2>
            </button>
          </div>
          <div id="panel-other" class="card-section" role="region" tabindex="-1" aria-labelledby="" aria-hidden="false">
            <div class="row column">
              <label for="assembly_created_by">Created by <select name="assembly[created_by]" id="assembly_created_by">
                  <option value="" selected="selected">Select a created by</option>
                  <option value="city_council">City Council</option>
                  <option value="public">Public</option>
                  <option value="others">Others</option>
                </select>
              </label>
            </div>
            <div class="row column" id="created_by_other" style="display: none;">
              <div class="label--tabs">
                <label for="assembly_created_by_other">Created by other</label>
                <ul class="tabs tabs--lang" id="assembly-created_by_other-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-created_by_other-tabs-created_by_other-panel-0" role="tab" aria-controls="assembly-created_by_other-tabs-created_by_other-panel-0" aria-selected="true" id="assembly-created_by_other-tabs-created_by_other-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-created_by_other-tabs-created_by_other-panel-1" role="tab" aria-controls="assembly-created_by_other-tabs-created_by_other-panel-1" aria-selected="false" id="assembly-created_by_other-tabs-created_by_other-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-created_by_other-tabs-created_by_other-panel-2" role="tab" aria-controls="assembly-created_by_other-tabs-created_by_other-panel-2" aria-selected="false" id="assembly-created_by_other-tabs-created_by_other-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-created_by_other-tabs">
                <div class="tabs-panel is-active" id="assembly-created_by_other-tabs-created_by_other-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-created_by_other-tabs-created_by_other-panel-0-label">
                  <input aria-label="created_by_other" type="text" name="assembly[created_by_other_en]" id="assembly_created_by_other_en">
                </div>
                <div class="tabs-panel" id="assembly-created_by_other-tabs-created_by_other-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-created_by_other-tabs-created_by_other-panel-1-label">
                  <input aria-label="created_by_other" type="text" name="assembly[created_by_other_es]" id="assembly_created_by_other_es">
                </div>
                <div class="tabs-panel" id="assembly-created_by_other-tabs-created_by_other-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-created_by_other-tabs-created_by_other-panel-2-label">
                  <input aria-label="created_by_other" type="text" name="assembly[created_by_other_ca]" id="assembly_created_by_other_ca">
                </div>
              </div>
            </div>
            <div class="row column">
              <label for="assembly_participatory_processes_ids">Related participatory processes <input name="assembly[participatory_processes_ids][]" type="hidden" value="" autocomplete="off">
                <select multiple="multiple" class="chosen-select" name="assembly[participatory_processes_ids][]" id="assembly_participatory_processes_ids">
                  <option value="1">Laboriosam quia qui molestiae veniam.</option>
                </select>
              </label>
            </div>
            <div class="row column" id="special_features" style="display: none;">
              <div class="label--tabs">
                <label for="assembly_special_features">Special features</label>
                <ul class="tabs tabs--lang" id="assembly-special_features-tabs" data-tabs="true" role="tablist">
                  <li class="tabs-title is-active" role="presentation">
                    <a href="#assembly-special_features-tabs-special_features-panel-0" role="tab" aria-controls="assembly-special_features-tabs-special_features-panel-0" aria-selected="true" id="assembly-special_features-tabs-special_features-panel-0-label" tabindex="0">English</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-special_features-tabs-special_features-panel-1" role="tab" aria-controls="assembly-special_features-tabs-special_features-panel-1" aria-selected="false" id="assembly-special_features-tabs-special_features-panel-1-label" tabindex="-1">Castellano</a>
                  </li>
                  <li class="tabs-title" role="presentation">
                    <a href="#assembly-special_features-tabs-special_features-panel-2" role="tab" aria-controls="assembly-special_features-tabs-special_features-panel-2" aria-selected="false" id="assembly-special_features-tabs-special_features-panel-2-label" tabindex="-1">Català</a>
                  </li>
                </ul>
              </div>
              <div class="tabs-content" data-tabs-content="assembly-special_features-tabs">
                <div class="tabs-panel is-active" id="assembly-special_features-tabs-special_features-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-special_features-tabs-special_features-panel-0-label">
                  <div class="editor" id="assembly_special_features_en">
                    <input aria-label="special_features" label="false" autocomplete="off" type="hidden" name="assembly[special_features_en]">undefined<div class="editor-container" data-controller="editor" data-toolbar="full" data-disabled="false" data-options="{&quot;context&quot;:&quot;admin&quot;,&quot;contentTypes&quot;:{&quot;image&quot;:[&quot;image/jpeg&quot;,&quot;image/png&quot;,&quot;image/webp&quot;]},&quot;uploadImagesPath&quot;:&quot;/editor_images&quot;,&quot;dragAndDropHelpText&quot;:&quot;Add images by dragging \u0026 dropping or pasting them.&quot;,&quot;uploadDialogSelector&quot;:&quot;#upload&quot;}">undefined<div class="editor-toolbar">undefined<div class="editor-toolbar-group">undefined<select class="editor-toolbar-control !pr-8" data-editor-type="heading" data-editor-selection-type="heading" aria-label="Text style" title="Text style">undefined<option value="normal" selected="selected">Normal</option>undefined<option value="2">Heading 2</option>undefined<option value="3">Heading 3</option>undefined<option value="4">Heading 4</option>undefined<option value="5">Heading 5</option>undefined<option value="6">Heading 6</option>undefined</select>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="bold" data-editor-selection-type="bold" type="button" aria-label="Bold" title="Bold">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-bold"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="italic" data-editor-selection-type="italic" type="button" aria-label="Italic" title="Italic">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-italic"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="underline" data-editor-selection-type="underline" type="button" aria-label="Underline" title="Underline">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-underline"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="hardBreak" type="button" aria-label="Line break" title="Line break">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-text-wrap"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="orderedList" data-editor-selection-type="orderedList" type="button" aria-label="Ordered list" title="Ordered list">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-list-ordered"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="bulletList" data-editor-selection-type="bulletList" type="button" aria-label="Unordered list" title="Unordered list">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-list-unordered"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="link" data-editor-selection-type="link" type="button" aria-label="Link" title="Link">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-link"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="common:eraseStyles" type="button" aria-label="Erase styles" title="Erase styles">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-eraser-line"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="codeBlock" data-editor-selection-type="codeBlock" type="button" aria-label="Code block" title="Code block">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-code-line"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="blockquote" data-editor-selection-type="blockquote" type="button" aria-label="Blockquote" title="Blockquote">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-double-quotes-l"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="indent:indent" type="button" aria-label="Indent" title="Indent">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-indent-increase"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="indent:outdent" type="button" aria-label="Outdent" title="Outdent">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-indent-decrease"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="videoEmbed" data-editor-selection-type="videoEmbed" type="button" aria-label="Video embed" title="Video embed">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-video-line"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="image" data-editor-selection-type="image" type="button" aria-label="Image" title="Image">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-image-line"></use>undefined</svg>undefined</button>undefined</div>undefined</div>undefined<div class="editor-input" style="height: 8rem">undefined<div contenteditable="true" role="textbox" aria-multiline="true" aria-labelledby="editorlabel-1757589301350-c25b114d9ca25" translate="no" class="tiptap ProseMirror" tabindex="0">undefined<p>undefined<br class="ProseMirror-trailingBreak">undefined</p>undefined</div>undefined</div>undefined</div>undefined
                  </div>
                </div>
                <div class="tabs-panel" id="assembly-special_features-tabs-special_features-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-special_features-tabs-special_features-panel-1-label">undefined<div class="editor" id="assembly_special_features_es">undefined<input aria-label="special_features" label="false" autocomplete="off" type="hidden" name="assembly[special_features_es]">undefined<div class="editor-container" data-controller="editor" data-toolbar="full" data-disabled="false" data-options="{&quot;context&quot;:&quot;admin&quot;,&quot;contentTypes&quot;:{&quot;image&quot;:[&quot;image/jpeg&quot;,&quot;image/png&quot;,&quot;image/webp&quot;]},&quot;uploadImagesPath&quot;:&quot;/editor_images&quot;,&quot;dragAndDropHelpText&quot;:&quot;Add images by dragging \u0026 dropping or pasting them.&quot;,&quot;uploadDialogSelector&quot;:&quot;#upload_2&quot;}">undefined<div class="editor-toolbar">undefined<div class="editor-toolbar-group">undefined<select class="editor-toolbar-control !pr-8" data-editor-type="heading" data-editor-selection-type="heading" aria-label="Text style" title="Text style">undefined<option value="normal" selected="selected">Normal</option>undefined<option value="2">Heading 2</option>undefined<option value="3">Heading 3</option>undefined<option value="4">Heading 4</option>undefined<option value="5">Heading 5</option>undefined<option value="6">Heading 6</option>undefined</select>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="bold" data-editor-selection-type="bold" type="button" aria-label="Bold" title="Bold">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-bold"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="italic" data-editor-selection-type="italic" type="button" aria-label="Italic" title="Italic">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-italic"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="underline" data-editor-selection-type="underline" type="button" aria-label="Underline" title="Underline">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-underline"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="hardBreak" type="button" aria-label="Line break" title="Line break">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-text-wrap"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="orderedList" data-editor-selection-type="orderedList" type="button" aria-label="Ordered list" title="Ordered list">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-list-ordered"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="bulletList" data-editor-selection-type="bulletList" type="button" aria-label="Unordered list" title="Unordered list">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-list-unordered"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="link" data-editor-selection-type="link" type="button" aria-label="Link" title="Link">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-link"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="common:eraseStyles" type="button" aria-label="Erase styles" title="Erase styles">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-eraser-line"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="codeBlock" data-editor-selection-type="codeBlock" type="button" aria-label="Code block" title="Code block">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-code-line"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="blockquote" data-editor-selection-type="blockquote" type="button" aria-label="Blockquote" title="Blockquote">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-double-quotes-l"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="indent:indent" type="button" aria-label="Indent" title="Indent">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-indent-increase"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="indent:outdent" type="button" aria-label="Outdent" title="Outdent">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-indent-decrease"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="videoEmbed" data-editor-selection-type="videoEmbed" type="button" aria-label="Video embed" title="Video embed">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-video-line"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="image" data-editor-selection-type="image" type="button" aria-label="Image" title="Image">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-image-line"></use>undefined</svg>undefined</button>undefined</div>undefined</div>undefined<div class="editor-input" style="height: 8rem">undefined<div contenteditable="true" role="textbox" aria-multiline="true" aria-labelledby="editorlabel-1757589301351-e9d0948dc3741" translate="no" class="tiptap ProseMirror" tabindex="0">undefined<p>undefined<br class="ProseMirror-trailingBreak">undefined</p>undefined</div>undefined</div>undefined</div>undefined</div>undefined</div>undefined<div class="tabs-panel" id="assembly-special_features-tabs-special_features-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-special_features-tabs-special_features-panel-2-label">undefined<div class="editor" id="assembly_special_features_ca">undefined<input aria-label="special_features" label="false" autocomplete="off" type="hidden" name="assembly[special_features_ca]">undefined<div class="editor-container" data-controller="editor" data-toolbar="full" data-disabled="false" data-options="{&quot;context&quot;:&quot;admin&quot;,&quot;contentTypes&quot;:{&quot;image&quot;:[&quot;image/jpeg&quot;,&quot;image/png&quot;,&quot;image/webp&quot;]},&quot;uploadImagesPath&quot;:&quot;/editor_images&quot;,&quot;dragAndDropHelpText&quot;:&quot;Add images by dragging \u0026 dropping or pasting them.&quot;,&quot;uploadDialogSelector&quot;:&quot;#upload_3&quot;}">undefined<div class="editor-toolbar">undefined<div class="editor-toolbar-group">undefined<select class="editor-toolbar-control !pr-8" data-editor-type="heading" data-editor-selection-type="heading" aria-label="Text style" title="Text style">undefined<option value="normal" selected="selected">Normal</option>undefined<option value="2">Heading 2</option>undefined<option value="3">Heading 3</option>undefined<option value="4">Heading 4</option>undefined<option value="5">Heading 5</option>undefined<option value="6">Heading 6</option>undefined</select>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="bold" data-editor-selection-type="bold" type="button" aria-label="Bold" title="Bold">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-bold"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="italic" data-editor-selection-type="italic" type="button" aria-label="Italic" title="Italic">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-italic"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="underline" data-editor-selection-type="underline" type="button" aria-label="Underline" title="Underline">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-underline"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="hardBreak" type="button" aria-label="Line break" title="Line break">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-text-wrap"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="orderedList" data-editor-selection-type="orderedList" type="button" aria-label="Ordered list" title="Ordered list">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-list-ordered"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="bulletList" data-editor-selection-type="bulletList" type="button" aria-label="Unordered list" title="Unordered list">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-list-unordered"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="link" data-editor-selection-type="link" type="button" aria-label="Link" title="Link">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-link"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="common:eraseStyles" type="button" aria-label="Erase styles" title="Erase styles">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-eraser-line"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="codeBlock" data-editor-selection-type="codeBlock" type="button" aria-label="Code block" title="Code block">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-code-line"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="blockquote" data-editor-selection-type="blockquote" type="button" aria-label="Blockquote" title="Blockquote">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-double-quotes-l"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="indent:indent" type="button" aria-label="Indent" title="Indent">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-indent-increase"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="indent:outdent" type="button" aria-label="Outdent" title="Outdent">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-indent-decrease"></use>undefined</svg>undefined</button>undefined</div>undefined<div class="editor-toolbar-group">undefined<button class="editor-toolbar-control" data-editor-type="videoEmbed" data-editor-selection-type="videoEmbed" type="button" aria-label="Video embed" title="Video embed">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-video-line"></use>undefined</svg>undefined</button>undefined<button class="editor-toolbar-control" data-editor-type="image" data-editor-selection-type="image" type="button" aria-label="Image" title="Image">undefined<svg class="editor-toolbar-icon" role="img" aria-hidden="true">undefined<use href="/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg#ri-image-line"></use>undefined</svg>undefined</button>undefined</div>undefined</div>undefined<div class="editor-input" style="height: 8rem">undefined<div contenteditable="true" role="textbox" aria-multiline="true" aria-labelledby="editorlabel-1757589301353-9ef017c6dc32d8" translate="no" class="tiptap ProseMirror" tabindex="0">undefined<p>undefined<br class="ProseMirror-trailingBreak">undefined</p>undefined</div>undefined</div>undefined</div>undefined</div>undefined</div>undefined
              </div>

            </div>
            <div class="row column">undefined<div class="label--tabs">undefined<label for="assembly_social_handlers">Social</label>undefined<ul class="tabs tabs--lang" id="assembly-social_handlers-tabs" data-tabs="true" role="tablist">undefined<li class="tabs-title is-active" role="presentation">undefined<a href="#assembly-social_handlers-tabs-social_handlers-panel-0" role="tab" aria-controls="assembly-social_handlers-tabs-social_handlers-panel-0" aria-selected="true" id="assembly-social_handlers-tabs-social_handlers-panel-0-label" tabindex="0">X</a>undefined</li>undefined<li class="tabs-title" role="presentation">undefined<a href="#assembly-social_handlers-tabs-social_handlers-panel-1" role="tab" aria-controls="assembly-social_handlers-tabs-social_handlers-panel-1" aria-selected="false" id="assembly-social_handlers-tabs-social_handlers-panel-1-label" tabindex="-1">Facebook</a>undefined</li>undefined<li class="tabs-title" role="presentation">undefined<a href="#assembly-social_handlers-tabs-social_handlers-panel-2" role="tab" aria-controls="assembly-social_handlers-tabs-social_handlers-panel-2" aria-selected="false" id="assembly-social_handlers-tabs-social_handlers-panel-2-label" tabindex="-1">Instagram</a>undefined</li>undefined<li class="tabs-title" role="presentation">undefined<a href="#assembly-social_handlers-tabs-social_handlers-panel-3" role="tab" aria-controls="assembly-social_handlers-tabs-social_handlers-panel-3" aria-selected="false" id="assembly-social_handlers-tabs-social_handlers-panel-3-label" tabindex="-1">YouTube</a>undefined</li>undefined<li class="tabs-title" role="presentation">undefined<a href="#assembly-social_handlers-tabs-social_handlers-panel-4" role="tab" aria-controls="assembly-social_handlers-tabs-social_handlers-panel-4" aria-selected="false" id="assembly-social_handlers-tabs-social_handlers-panel-4-label" tabindex="-1">GitHub</a>undefined</li>undefined</ul>undefined</div>undefined<div class="tabs-content" data-tabs-content="assembly-social_handlers-tabs">undefined<div class="tabs-panel is-active" id="assembly-social_handlers-tabs-social_handlers-panel-0" aria-hidden="false" role="tabpanel" aria-labelledby="assembly-social_handlers-tabs-social_handlers-panel-0-label">undefined<input type="text" name="assembly[twitter_handler]" id="assembly_twitter_handler" data-accessibility-violation="true">undefined</div>undefined<div class="tabs-panel" id="assembly-social_handlers-tabs-social_handlers-panel-1" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-social_handlers-tabs-social_handlers-panel-1-label">undefined<input type="text" name="assembly[facebook_handler]" id="assembly_facebook_handler">undefined</div>undefined<div class="tabs-panel" id="assembly-social_handlers-tabs-social_handlers-panel-2" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-social_handlers-tabs-social_handlers-panel-2-label">undefined<input type="text" name="assembly[instagram_handler]" id="assembly_instagram_handler">undefined</div>undefined<div class="tabs-panel" id="assembly-social_handlers-tabs-social_handlers-panel-3" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-social_handlers-tabs-social_handlers-panel-3-label">undefined<input type="text" name="assembly[youtube_handler]" id="assembly_youtube_handler">undefined</div>undefined<div class="tabs-panel" id="assembly-social_handlers-tabs-social_handlers-panel-4" aria-hidden="true" role="tabpanel" aria-labelledby="assembly-social_handlers-tabs-social_handlers-panel-4-label">undefined<input type="text" name="assembly[github_handler]" id="assembly_github_handler">undefined</div>undefined</div>undefined</div>undefined
          </div>

        </div>

      </div>
      <div class="item__edit-sticky">undefined<div class="item__edit-sticky-container">undefined<button type="submit" name="commit" class="button button__sm button__secondary">Create</button>undefined</div>undefined</div>undefined
    </form>

  </div>
    `;

    // Set up Stimulus
    application = Application.start();
    application.register("assembly-admin", Controller);
    element  = document.getElementById("new_assembly");

    // Wait for controller to be initialized
    await new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "assembly-admin");
        resolve();
      }, 10);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  describe("connect", () => {
    it("should initialize the controller and set up event listeners", () => {
      expect(controller).toBeDefined();
      expect(element).toBeDefined();
    });

    it("should call assignBehavior for assembly_type and created_by fields", () => {
      const assemblyType = element.querySelector("#assembly_assembly_type");
      const createdBy = element.querySelector("#assembly_created_by");

      expect(assemblyType).toBeDefined();
      expect(createdBy).toBeDefined();

      // Verify that event listeners are attached by triggering changes
      // const assemblyTypeOther = element.querySelector("#assembly_type_other");
      const createdByOther = element.querySelector("#created_by_other");

      // expect(assemblyTypeOther.style.display).toBe("none");
      expect(createdByOther.style.display).toBe("none");
    });
  });

  describe("assignBehavior", () => {

    it("should set up behavior for created_by field", () => {
      const createdBy = element.querySelector("#assembly_created_by");
      const createdByOther = element.querySelector("#created_by_other");

      // Test initial state
      expect(createdByOther.style.display).toBe("none");

      // Test showing other field when "others" is selected
      createdBy.value = "others";
      createdBy.dispatchEvent(new Event("change"));

      expect(createdByOther.style.display).toBe("block");

      // Test hiding other field when different option is selected
      createdBy.value = "city_council";
      createdBy.dispatchEvent(new Event("change"));

      expect(createdByOther.style.display).toBe("none");
    });
  });

  describe("attachVisibility", () => {
    it("should attach event listener and set initial state", () => {
      const select = element.querySelector("#assembly_created_by");
      const targetDiv = element.querySelector("#created_by_other");

      // Reset to initial state
      targetDiv.style.display = "block";

      controller.attachVisibility(select, targetDiv);

      // Should hide initially if value is not "others"
      expect(targetDiv.style.display).toBe("none");
    });

    it("should handle null elements gracefully", () => {
      expect(() => {
        controller.attachVisibility(null, null);
      }).not.toThrow();

      expect(() => {
        controller.attachVisibility(element.querySelector("#assembly_assembly_type"), null);
      }).not.toThrow();
    });
  });

  describe("toggleDependsOnSelect", () => {
    it("should show div when target value is 'others'", () => {
      const select = element.querySelector("#assembly_created_by");
      const targetDiv = element.querySelector("#created_by_other");

      select.value = "others";
      controller.toggleDependsOnSelect(select, targetDiv);

      expect(targetDiv.style.display).toBe("block");
    });

    it("should hide div when target value is not 'others'", () => {
      const select = element.querySelector("#assembly_created_by");
      const targetDiv = element.querySelector("#created_by_other");

      select.value = "standard";
      controller.toggleDependsOnSelect(select, targetDiv);

      expect(targetDiv.style.display).toBe("none");
    });

    it("should return early if target or showDiv is null", () => {
      const select = element.querySelector("#assembly_assembly_type");

      expect(() => {
        controller.toggleDependsOnSelect(null, null);
      }).not.toThrow();

      expect(() => {
        controller.toggleDependsOnSelect(select, null);
      }).not.toThrow();
    });
  });

  describe("integration tests", () => {
    it("should maintain correct state when toggling between options", () => {
      const assemblyType = element.querySelector("#assembly_created_by");
      const assemblyTypeOther = element.querySelector("#created_by_other");

      // Initially hidden
      expect(assemblyTypeOther.style.display).toBe("none");

      // Show by selecting "others"
      assemblyType.value = "others";
      assemblyType.dispatchEvent(new Event("change"));
      expect(assemblyTypeOther.style.display).toBe("block");

      // Hide by selecting different option
      assemblyType.value = "consultative";
      assemblyType.dispatchEvent(new Event("change"));
      expect(assemblyTypeOther.style.display).toBe("none");

      // Show again by selecting "others"
      assemblyType.value = "others";
      assemblyType.dispatchEvent(new Event("change"));
      expect(assemblyTypeOther.style.display).toBe("block");
    });
  });

});
