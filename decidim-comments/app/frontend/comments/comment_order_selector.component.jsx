const CommentOrderSelector = () => (
  <div className="order-by__dropdown order-by__dropdown--right">
    <span className="order-by__text">Ordenar per:</span>
    <ul className="dropdown menu" data-dropdown-menu>
      <li>
        <a>Més votats</a>
        <ul className="menu">
          <li><a>Més votats</a></li>
          <li><a>Més nous</a></li>
          <li><a>Més antics</a></li>
        </ul>
      </li>
    </ul>
  </div>
);

export default CommentOrderSelector;
