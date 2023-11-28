// `escape-html` provided by the graphiql package
import escapeHTML from "escape-html";

const dropzoneLocales = {
  error: "error",
  filename: "Filename",
  remove: "Remove",
  title: "Title",
  uploaded: "Uploaded",
  validating: "Validating...",
  "title_required": "Title is required!",
  "file_size_too_large": "File size is too large! Maximun file size: 10MB",
  "validation_error": "Validation error!"
};

export default {
  redesign: `
    <div id="upload_dialog" data-dialog="upload_dialog">
      <div id="upload_dialog-content" class="upload-modal">
        <button type="button" data-dialog-close="upload_dialog" data-dialog-closable="" aria-label="Close modal">&times</button>
        <div data-dialog-container>
          <h2 id="dialog-title-upload_dialog" tabindex="-1" data-dialog-title data-addlabel="Add image" data-editlabel="Edit image">Add image</h2>
          <div>
            <div data-name="file" class="upload-modal__dropzone-container" data-dropzone>
              <input id="files-upload_dialog" hidden="hidden" type="file" name="editor_image[file]" />
              <ul class="upload-modal__dropzone" hidden="hidden" data-dropzone-items="" data-locales="${escapeHTML(JSON.stringify(dropzoneLocales))}"></ul>
              <div data-dropzone-no-items="" class="upload-modal__dropzone">
                <div class="upload-modal__dropzone-placeholder">
                  <span>Drop files here or click the button to upload</span>
                  <label class="button button__sm button__secondary" for="files-upload_dialog"><span>Select file</span></label>
                </div>
              </div>
            </div>
            <div class="upload-modal__text">
              <p>Here is where the upload help would normally be.</p>
            </div>
          </div>
        </div>
        <div data-dialog-actions>
          <button type="button" class="button button__sm md:button__lg button__transparent-secondary" data-dropzone-cancel data-dialog-close="upload_dialog">
            Cancel
          </button>
          <button type="button" class="button button__sm md:button__lg button__secondary" data-dropzone-save data-dialog-close="upload_dialog" disabled>
            Next
          </button>
        </div>
      </div>
    </div>
  `
};
