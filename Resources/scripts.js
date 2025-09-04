document.addEventListener("DOMContentLoaded", function () {
  // Find both patterns
  const roots = document.querySelectorAll(
    '.callout-cell.collapsible, .cells[collapse="true"], .cells[data-collapse="true"], .cells.collapsible'
  );

  roots.forEach(root => {
    if (root.dataset.collapsibleInit === "1") return; // avoid double init
    root.dataset.collapsibleInit = "1";

    // 1) Find or create a header (prefer a direct child heading)
    let header =
      root.querySelector(':scope > .callout-header, :scope > .cells-header, :scope > h1, :scope > h2, :scope > h3, :scope > h4, :scope > h5, :scope > h6');

    if (!header) {
      // fallback: use first element as header if available
      header = root.firstElementChild;
      if (!header) return; // nothing to do
    }

    // Normalize header class based on container type
    const isCells = root.classList.contains('cells');
    header.classList.add(isCells ? 'cells-header' : 'callout-header');

    // 2) Find or build the content wrapper
    let content = root.querySelector(':scope > .callout-content, :scope > .cells-container');
    if (!content) {
      content = document.createElement('div');
      content.className = isCells ? 'cells-container' : 'callout-content';
      // Move all siblings after header into content
      let sib = header.nextSibling;
      while (sib) {
        const next = sib.nextSibling;
        content.appendChild(sib);
        sib = next;
      }
      root.appendChild(content);
    }

    // 3) A11y + initial state
    header.setAttribute('role', 'button');
    header.setAttribute('tabindex', '0');

    const startsOpen =
      root.classList.contains('open') ||
      root.getAttribute('open') === 'true' ||
      root.getAttribute('data-open') === 'true';

    const setOpen = (open) => {
      content.style.display = open ? '' : 'none';
      root.classList.toggle('open', open);
      header.setAttribute('aria-expanded', String(open));
    };

    setOpen(!!startsOpen);

    // 4) Toggle handlers (click + keyboard)
    const toggle = () => setOpen(content.style.display === 'none');

    header.addEventListener('click', toggle);
    header.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        toggle();
      }
    });
  });
});
