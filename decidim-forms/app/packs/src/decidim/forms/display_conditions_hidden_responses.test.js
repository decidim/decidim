/* eslint-disable no-relative-import-paths/no-relative-import-paths, id-length */
//
// Covers what happens to a hidden question's response, for the two question types
// the display-conditions component cannot clear by hand: `files` (its response
// lives in UploadModal's markup) and `sorting` (hidden fields only).
//
// On the clearAnswers() implementation, the three cases about an already-saved
// attachment fail: its preview and hidden add_attachments field are removed, and
// showQuestion() never puts them back. The other two pass there as well, and show
// why the selector was inconsistent: a file uploaded in the current session, and a
// sorting question, were never cleared at all.
//
// The fixture reproduces the markup actually rendered to participants:
//   decidim-core/app/cells/decidim/upload_modal/files.erb
//   decidim-core/app/cells/decidim/upload_modal/modal.erb
//   decidim-forms/app/views/decidim/forms/questionnaires/responses/_files.html.erb
//   decidim-forms/app/views/decidim/forms/questionnaires/responses/_sorting.html.erb
// and drives it through the real initializeUploadFields() and
// createDisplayConditions(), so no behaviour is stubbed.
//
// Run with: npx jest decidim-forms/app/packs/src/decidim/forms/display_conditions_hidden_responses.test.js
//

import $ from "jquery";
import createDisplayConditions from "./display_conditions.component";
import { initializeUploadFields } from "src/decidim/direct_uploads/upload_field";

const MODAL_ID = "modal-qfile";
// Raw JSON because the keys are the snake_case ones upload_modal/modal.erb emits.
const LOCALES = `{
  "error": "error", "title_required": "title required", "filename": "filename",
  "file_size_too_large": "too large", "remove": "remove", "title": "title",
  "uploaded": "uploaded", "validating": "validating", "validation_error": "validation error"
}`;
const UPLOAD_OPTS = JSON.stringify({
  addAttribute: "add_attachments",
  resourceName: "questionnaire",
  resourceClass: "Decidim::Forms::Questionnaire",
  required: false,
  maxFileSize: 10485760,
  multiple: true,
  titled: false,
  formObjectClass: "Decidim::Forms::QuestionnaireForm"
});

const radioCollection = (qid, options) => `
  <div class="js-radio-button-collection">
    ${options.map((opt) => `
      <div class="js-collection-input">
        <input name="questionnaire[responses][${qid}][body]" type="radio" value="${opt.value}" />
        <input name="questionnaire[responses][${qid}][custom_body]" type="text" />
        <input name="questionnaire[responses][${qid}][response_option_id]" type="hidden" value="${opt.optionId}" />
      </div>
    `).join("")}
  </div>
`;

const conditionTag = (data) =>
  `<div class="display-condition" ${Object.entries(data).map(([key, val]) => `data-${key}='${val}'`).join(" ")}></div>`;

// Mirrors upload_modal/files.erb for one already-persisted, non-image attachment.
const uploadMarkup = () => `
  <div class="upload-modal__files-container upload-container-for-add_attachments">
    <div>
      <div class="upload-modal__files" data-active-uploads="${MODAL_ID}">
        <div class="attachment-details" data-attachment-id="99" data-title="doc.pdf" data-filename="doc.pdf" data-state="uploaded" data-hidden-field="signed-id-abc">
          <a href="/rails/active_storage/blobs/doc.pdf">doc.pdf</a>
          <input type="hidden" name="questionnaire[responses][QFILE][add_attachments]" value="99" id="hidden_add_attachments_99" />
        </div>
      </div>
    </div>
    <button id="button-${MODAL_ID}" name="add_attachments" type="button" data-dialog-open="${MODAL_ID}" data-upload='${UPLOAD_OPTS}'>Add file</button>
  </div>
  <div id="${MODAL_ID}" data-dialog="${MODAL_ID}">
    <div id="${MODAL_ID}-content" class="upload-modal">
      <div data-dialog-container>
        <h2 data-dialog-title data-addlabel="Add file" data-editlabel="Edit file">Add file</h2>
        <div data-name="add_attachments" data-dropzone>
          <input id="files-${MODAL_ID}" type="file" multiple hidden />
          <ul hidden data-dropzone-items="" data-locales='${LOCALES}'></ul>
          <div data-dropzone-no-items="">
            <label for="files-${MODAL_ID}"><span>Select file</span></label>
          </div>
        </div>
      </div>
      <div data-dialog-actions>
        <button type="button" data-dropzone-cancel data-dialog-close="${MODAL_ID}">Cancel</button>
        <button type="button" data-dropzone-save data-dialog-close="${MODAL_ID}" disabled>Save</button>
      </div>
    </div>
  </div>
`;

// Mirrors responses/_sorting.html.erb
const sortingMarkup = (qid) => `
  <div class="response-questionnaire__sorting-container js-sortable-check-box-collection">
    ${[["10", "1"], ["11", "2"], ["12", "3"]].map(([optId, pos], idx) => `
      <div class="response-questionnaire__sorting js-collection-input" role="button">
        <input type="hidden" name="questionnaire[responses][${qid}][choices][${idx}][position]" value="${pos}" />
        <input type="hidden" name="questionnaire[responses][${qid}][choices][${idx}][body]" value="opt${optId}" />
        <input type="hidden" name="questionnaire[responses][${qid}][choices][${idx}][response_option_id]" value="${optId}" />
      </div>
    `).join("")}
  </div>
`;

const page = () => `
  <form class="response-questionnaire" data-safe-path="/f">
    <div class="question" data-question-id="Q0" data-conditioned="false">
      ${radioCollection("Q0", [{ optionId: "optA", value: "A" }, { optionId: "optC", value: "C" }])}
    </div>
    <div class="question" data-question-id="QFILE" data-conditioned="true">
      ${conditionTag({ id: "dcFile", type: "equal", condition: "Q0", option: "optC", mandatory: false })}
      ${uploadMarkup()}
      <input type="hidden" name="questionnaire[responses][QFILE][question_id]" value="QFILE" />
    </div>
    <div class="question" data-question-id="QSORT" data-conditioned="true">
      ${conditionTag({ id: "dcSort", type: "equal", condition: "Q0", option: "optC", mandatory: false })}
      ${sortingMarkup("QSORT")}
      <input type="hidden" name="questionnaire[responses][QSORT][question_id]" value="QSORT" />
    </div>
  </form>
`;

const initUploads = () => initializeUploadFields(document.querySelectorAll("button[data-upload]"));
const initConditions = () =>
  $(".response-questionnaire .question[data-conditioned='true']").each((idx, el) =>
    createDisplayConditions({ wrapperField: $(el) })
  );

const wrapper = (qid) => $(`.question[data-question-id='${qid}']`);
const selectOption = (qid, value) => {
  const $input = wrapper(qid).find(`input[name$='[body]'][value='${value}']`);
  $input.prop("checked", true);
  $input.trigger("change");
};
// What the browser would actually submit: enabled fields only.
const submitted = () =>
  Array.from(document.querySelectorAll("form input:not([disabled])")).
    filter((el) => el.name && (!["radio", "checkbox"].includes(el.type) || el.checked)).
    map((el) => `${el.name}=${el.value}`);
// Any preview node holding the hidden add_attachments field, whether server
// rendered (.attachment-details) or re-rendered by updateActiveUploads (no class).
const previews = () => document.querySelectorAll(`[data-active-uploads='${MODAL_ID}'] > *`).length;
const serverRenderedPreviews = () => document.querySelectorAll(`[data-active-uploads='${MODAL_ID}'] .attachment-details`).length;
const modalItems = () => document.querySelectorAll(`#${MODAL_ID} [data-dropzone-items] > *`).length;
const buttonLabel = () => document.getElementById(`button-${MODAL_ID}`).innerHTML;
const positions = () =>
  Array.from(document.querySelectorAll("[data-question-id='QSORT'] input[name$='[position]']")).map((el) => el.value);

describe("hidden questions and their responses", () => {
  beforeEach(() => {
    // UploadModal renders icons through window.Decidim.config
    window.Decidim = { config: { get: () => "/icons.svg" } };
    document.body.innerHTML = page();
  });

  describe("a file question hidden on page load", () => {
    it("keeps the attachment and UploadModal in sync, whichever initializes first", () => {
      initUploads();
      initConditions();

      expect(previews()).toBe(1);
      expect(serverRenderedPreviews()).toBe(1);
      expect(modalItems()).toBe(1);
      expect(buttonLabel()).toBe("Add file");
      // kept, but disabled, so it is not submitted while the question is hidden
      expect(submitted().filter((field) => field.includes("add_attachments"))).toEqual([]);
    });

    it("behaves the same when the display conditions initialize first", () => {
      initConditions();
      initUploads();

      expect(previews()).toBe(1);
      expect(modalItems()).toBe(1);
      expect(submitted().filter((field) => field.includes("add_attachments"))).toEqual([]);
    });
  });

  describe("a file question hidden and shown again", () => {
    it("submits the attachment it already had", () => {
      initUploads();
      initConditions();

      selectOption("Q0", "C");

      expect(previews()).toBe(1);
      expect(submitted()).toContain("questionnaire[responses][QFILE][add_attachments]=99");
    });

    it("submits a file uploaded in this session, whose preview carries no attachment-details class", () => {
      initUploads();
      initConditions();
      selectOption("Q0", "C");

      // saving the modal makes updateActiveUploads() re-render the preview
      document.getElementById(`button-${MODAL_ID}`).click();
      document.querySelector(`#${MODAL_ID} [data-dropzone-save]`).click();
      expect(serverRenderedPreviews()).toBe(0);

      selectOption("Q0", "A");
      selectOption("Q0", "C");

      expect(previews()).toBe(1);
      expect(submitted().filter((field) => field.includes("add_attachments"))).not.toEqual([]);
    });
  });

  describe("a sorting question", () => {
    it("keeps its order out of the submission while hidden, and restores it when shown", () => {
      initUploads();
      initConditions();

      expect(positions()).toEqual(["1", "2", "3"]);
      expect(submitted().filter((field) => field.includes("QSORT"))).toEqual([]);

      selectOption("Q0", "C");

      expect(positions()).toEqual(["1", "2", "3"]);
      expect(submitted()).toContain("questionnaire[responses][QSORT][choices][0][position]=1");
    });
  });
});
