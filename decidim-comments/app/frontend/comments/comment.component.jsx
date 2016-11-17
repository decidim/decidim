// comment--nested
// comment--nested--alt
// comment--highlight
const Comment = () => (
  <article className="comment">
    <div className="comment__header">
      <div className="author-data">
        <div className="author-data__main">
          <div className="author author--inline">
            <a className="author__avatar">
              <img src="/images/demo-avatar.jpg" alt="" />
            </a>
            <a className="author__name">
              Marc Serres
            </a>
            <time dateTime="2016-08-01T19:47Z">1-08-2016 21:47</time>
          </div>
        </div>
        <div className="author-data__extra">
          <a>
            Flag
          </a>
        </div>
      </div>
    </div>
    <div className="comment__content">
      <p>
        <span className="success label">A favor</span>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
      </p>
    </div>
    <div className="comment__footer">
      <button className="comment__reply muted-link" data-toggle="comment1-reply" />
      <div className="comment__votes">
        <a className="comment__votes--up">
          257
        </a>
        <a className="comment__votes--down">
          257
        </a>
      </div>
    </div>
    <div 
      className="add-comment add-comment--reply"
      id="comment1-reply"
      data-toggler=".is-active"
    >
      <form>
        <label className="show-for-sr" htmlFor="add-comment-1">Resposta</label>
        <textarea
          id="add-comment-1"
          placeholder="Respon a aquest comentari"
        />
        <input type="submit" className="button small hollow" value="Enviar" />
      </form>
    </div>
  </article>
);

export default Comment;
