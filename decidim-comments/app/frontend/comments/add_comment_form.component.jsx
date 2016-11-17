const AddCommentForm = () => (
  <div className="add-comment">
    <h5 className="section-heading">Deixa el teu comentari</h5>
    <div className="opinion-toggle button-group">
      <button className="button small button--muted opinion-toggle--ok">
        Estic a favor
      </button>
      <button className="button small button--muted opinion-toggle--ko">
        Estic en contra
      </button>
    </div>
    <form>
      <label className="show-for-sr" htmlFor="add-comment">Comentari</label>
      <textarea
        id="add-comment"
        rows="4"
        placeholder="Què opines d'aquesta proposta?"
      />
      <input type="submit" className="button button--sc" value="Enviar" />
    </form>
  </div>
);

export default AddCommentForm;
