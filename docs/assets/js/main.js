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

  apply(current);

  btn.addEventListener('click', function () {
    var next = modes[(modes.indexOf(current) + 1) % modes.length];
    apply(next);
  });
})();
