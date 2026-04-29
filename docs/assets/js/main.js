// -------------------------------------------
// hey, you made it to the javascript.
// there's not much here. that's the point.
// -------------------------------------------

(function () {
  var btn = document.querySelector('.theme-toggle');
  var root = document.documentElement;
  var key = 'theme-preference';

  var modes = ['auto', 'dark', 'light'];
  var saved = localStorage.getItem(key);
  var current = modes.indexOf(saved) !== -1 ? saved : 'auto';

  function apply(mode) {
    if (mode === 'auto') {
      root.removeAttribute('data-theme');
    } else {
      root.setAttribute('data-theme', mode);
    }
    btn.textContent = mode;
    localStorage.setItem(key, mode);
    current = mode;
  }

  function cycle() {
    apply(modes[(modes.indexOf(current) + 1) % modes.length]);
  }

  apply(current);
  btn.addEventListener('click', cycle);

  // 't' to cycle theme. ignore when typing in inputs/contenteditable.
  document.addEventListener('keydown', function (e) {
    if (e.key !== 't' || e.metaKey || e.ctrlKey || e.altKey) return;
    var t = e.target;
    if (t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.isContentEditable)) return;
    cycle();
  });
})();
