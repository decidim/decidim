import $ from "jquery"; // eslint-disable-line id-length

// Relative import: the forms pack is not in jest's moduleDirectories, so it
// cannot be resolved through the absolute "src/..." path used elsewhere.
import createDisplayConditions from "./display_conditions.component"; // eslint-disable-line no-relative-import-paths/no-relative-import-paths

describe("DisplayConditionsComponent", () => {
  // Renders a single-choice (radio) question with the DOM structure the
  // component expects (js-collection-input wrapping body/custom_body/option_id).
  const radioCollection = (qid, options) => `
    <div class="js-radio-button-collection">
      ${options.map((opt) => `
        <div class="js-collection-input">
          <input name="resp[${qid}][body]" type="radio" value="${opt.value}" />
          <input name="resp[${qid}][custom_body]" type="text" />
          <input name="resp[${qid}][response_option_id]" type="hidden" value="${opt.optionId}" />
        </div>
      `).join("")}
    </div>
  `;

  const conditionTag = (data) => {
    const attrs = Object.entries(data).map(([key, val]) => `data-${key}='${val}'`).join(" ");
    return `<div class="display-condition" ${attrs}></div>`;
  };

  // Q0 (A/B/C) --C--> Q3 (0/1) --0--> FINAL0
  //                            \--1--> FINAL1
  const content = `
    <div class="answer-questionnaire">
      <div class="question" data-question-id="Q0" data-conditioned="false">
        ${radioCollection("Q0", [{ optionId: "optA", value: "A" }, { optionId: "optB", value: "B" }, { optionId: "optC", value: "C" }])}
      </div>
      <div class="question" data-question-id="Q3" data-conditioned="true">
        ${conditionTag({ id: "dcQ3", type: "equal", condition: "Q0", option: "optC", mandatory: false })}
        ${radioCollection("Q3", [{ optionId: "opt0", value: "0" }, { optionId: "opt1", value: "1" }])}
      </div>
      <div class="question" data-question-id="FINAL0" data-conditioned="true">
        ${conditionTag({ id: "dcF0", type: "equal", condition: "Q3", option: "opt0", mandatory: false })}
        ${radioCollection("FINAL0", [{ optionId: "f0opt", value: "yes" }])}
      </div>
      <div class="question" data-question-id="FINAL1" data-conditioned="true">
        ${conditionTag({ id: "dcF1", type: "equal", condition: "Q3", option: "opt1", mandatory: false })}
        ${radioCollection("FINAL1", [{ optionId: "f1opt", value: "yes" }])}
      </div>
    </div>
  `;

  const wrapper = (qid) => $(`.question[data-question-id='${qid}']`);
  // The component enables inputs when a question is shown and disables them when
  // hidden, so the disabled state is a reliable proxy for visibility in jsdom.
  const isVisible = (qid) => !wrapper(qid).find("input[name$='[body]']").first().prop("disabled");
  const selectOption = (qid, value) => {
    const $input = wrapper(qid).find(`input[name$='[body]'][value='${value}']`);
    $input.prop("checked", true);
    $input.trigger("change");
  };

  beforeEach(() => {
    document.body.innerHTML = content;
    $(".answer-questionnaire .question[data-conditioned='true']").each((idx, el) => {
      createDisplayConditions({ wrapperField: $(el) });
    });
  });

  it("keeps conditioned questions hidden until their trigger is fulfilled", () => {
    expect(isVisible("Q3")).toBe(false);
    expect(isVisible("FINAL0")).toBe(false);
    expect(isVisible("FINAL1")).toBe(false);
  });

  it("shows only the directly conditioned question when its trigger is met", () => {
    selectOption("Q0", "C");

    expect(isVisible("Q3")).toBe(true);
    // Q3 is not answered yet, so neither final must appear
    expect(isVisible("FINAL0")).toBe(false);
    expect(isVisible("FINAL1")).toBe(false);
  });

  it("shows the matching final once the intermediate question is answered", () => {
    selectOption("Q0", "C");
    selectOption("Q3", "1");

    expect(isVisible("FINAL1")).toBe(true);
    expect(isVisible("FINAL0")).toBe(false);
  });

  it("cascades hiding down the chain when an ancestor trigger stops being fulfilled", () => {
    selectOption("Q0", "C");
    selectOption("Q3", "1");
    expect(isVisible("FINAL1")).toBe(true);

    // Move Q0 away from C: Q3 hides, its stale answer is cleared and the change
    // propagates so FINAL1 hides too instead of lingering.
    selectOption("Q0", "A");

    expect(isVisible("Q3")).toBe(false);
    expect(wrapper("Q3").find("input[value='1']").prop("checked")).toBe(false);
    expect(isVisible("FINAL1")).toBe(false);
  });

  it("clears file upload responses of a hidden question", () => {
    document.body.innerHTML = `
      <div class="answer-questionnaire">
        <div class="question" data-question-id="Q0" data-conditioned="false">
          ${radioCollection("Q0", [{ optionId: "optA", value: "A" }, { optionId: "optC", value: "C" }])}
        </div>
        <div class="question" data-question-id="QFILE" data-conditioned="true">
          ${conditionTag({ id: "dcFile", type: "equal", condition: "Q0", option: "optC", mandatory: false })}
          <div class="upload-modal__files" data-active-uploads="QFILE">
            <div class="attachment-details" data-filename="doc.pdf" data-state="uploaded">
              <input name="resp[QFILE][add_attachments]" type="hidden" value="signed-id-123" />
            </div>
          </div>
        </div>
      </div>
    `;
    $(".answer-questionnaire .question[data-conditioned='true']").each((idx, el) => {
      createDisplayConditions({ wrapperField: $(el) });
    });

    // Q0 is not "C", so QFILE is hidden: its attachment preview and the hidden
    // field carrying the upload must be gone so nothing stale is submitted.
    expect(wrapper("QFILE").find(".attachment-details").length).toBe(0);
    expect(wrapper("QFILE").find("input[name='resp[QFILE][add_attachments]']").length).toBe(0);
  });
});
