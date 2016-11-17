// comment--nested
// comment--nested--alt
// comment--highlight
const Comment = () => (
  <article className="comment">
    <div className="comment__header">
      <div className="author-data">
        <div className="author-data__main">
          <div className="author author--inline">
            <a href="#" className="author__avatar">
              <img src="/images/demo-avatar.jpg" alt="" />
            </a>
            <a href="#" className="author__name">
              Marc Serres
            </a>
            <time dateTime="2016-08-01T19:47Z">1-08-2016 21:47</time>
          </div>
        </div>
        <div className="author-data__extra">
          <a href="#">
            Flag
          </a>
        </div>
      </div>
    </div>
    <div className="comment__content">
      <p>
        <span className="success label">A favor</span>
        Quan sento parlar de contaminació acústica, penso que no hi ha veïns
        en tota la ciutat més perjudicats que nosaltres, els que vivim al Pg
        de la Vall d'Hebron des del 198 al 208. Per no parlar de la
        contaminació atmosfèrica, els tubs d'escapament dels vehicles gairabé
        s'evacuarien directament al nostre menjador si no fos que mantenim les
        finestres i terrasses tencades de manera permanent.</p>
    </div>
    <div className="comment__footer">
      <button className="comment__reply muted-link" data-toggle="comment1-reply">
        Responder</button>
      <div className="comment__votes">
        <a href="" className="comment__votes--up">
          257
        </a>
        <a href="" className="comment__votes--down">
          257
        </a>
      </div>
    </div>
    <div className="add-comment add-comment--reply" id="comment1-reply"
        data-toggler=".is-active">
      <form>
        <label className="show-for-sr" htmlFor="add-comment-1">Resposta</label>
        <textarea id="add-comment-1"
          placeholder="Respon a aquest comentari"></textarea>
        <input type="submit" className="button small hollow" value="Enviar" />
      </form>
    </div>
  </article>
);
