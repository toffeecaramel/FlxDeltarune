// ===== Tiny Router & Enhancements =====
const $ = (q,root=document) => root.querySelector(q);
const $$ = (q,root=document) => Array.from(root.querySelectorAll(q));

const routes = new Set($$('section[data-route]')).add($('section[data-route="home"]'));

// Search enhancement with Fuse.js
let fuse;

function buildSearchIndex() {
  const docs = [];
  $$('section[data-route]').forEach(section => {
    const route = section.getAttribute('data-route');
    const sectionTitle = $(`nav a[href="#${route}"]`)?.textContent.trim() || route;
    Array.from(section.querySelectorAll('h1, h2, h3, p')).forEach(el => {
      docs.push({
        title: el.textContent.trim(),
        content: el.textContent.trim(),
        route: route,
        id: el.id || '',
        section: sectionTitle
      });
    });
  });
  fuse = new Fuse(docs, {
    keys: ['title', 'content'],
    threshold: 0.3,
    includeScore: true
  });
}

function showSearchResults(query) {
  const resultsDiv = $('#search-results');
  if (!query || query.length < 2) {
    resultsDiv.style.display = 'none';
    return;
  }
  const results = fuse.search(query).slice(0, 5);
  resultsDiv.innerHTML = results.map(r => {
    const item = r.item;
    const displayTitle = item.title.length > 50 ? item.title.substring(0, 50) + '...' : item.title;
    return `<a href="#${item.route}${item.id ? '#' + item.id : ''}">${item.section}: ${displayTitle}</a>`;
  }).join('') || '<div style="padding:8px;color:var(--dim);">No results found.</div>';
  resultsDiv.style.display = results.length ? 'block' : 'none';
}

// Changelog fetch
async function loadChangelog() {
  const contentDiv = $('#changelog-content');
  try {
    const response = await fetch('https://raw.githubusercontent.com/toffeecaramel/FlxDeltarune/main/docs/CHANGELOG.md');
    if (!response.ok) throw new Error('File not found');
    const markdown = await response.text();
    contentDiv.innerHTML = marked.parse(markdown);
  } catch (e) {
    contentDiv.innerHTML = '<ul><li><strong>0.0.0</strong> · Working on it! (File not added yet)</li></ul>';
  }
}

function setActive(route){
  // sections
  $$('section[data-route]').forEach(s=>s.classList.remove('active'));
  const sec = $(`section[data-route="${route}"]`) || $('section[data-route="home"]');
  sec.classList.add('active');
  // nav
  $$('nav a[data-link]').forEach(a=>a.classList.toggle('active', a.getAttribute('href') === '#' + route));
  // crumbs
  const label = ($(`nav a[href="#${route}"]`)?.textContent || 'Home').trim();
  $('#crumbs').textContent = `FlxDeltarune ▸ ${label}`;
  $('#routeBadge').textContent = route;
  // focus top
  window.scrollTo({top:0,behavior:'instant'});
  // update TOC for the section
  buildTOC(sec);

  // Load changelog if active
  if (route === 'changelog') {
    loadChangelog();
  }
}

function onHash(){ setActive(location.hash.replace('#','') || 'home'); }
window.addEventListener('hashchange', onHash);
window.addEventListener('DOMContentLoaded', () => {
  onHash();
  $('#year').textContent = new Date().getFullYear();
  // keyboard: / to search
  window.addEventListener('keydown', (e)=>{
    if(e.key === '/' && document.activeElement.tagName !== 'INPUT'){
      e.preventDefault(); $('#search').focus();
    }
  });
  // nav filter by search (legacy, now enhanced)
  const searchInput = $('#search');
  searchInput.addEventListener('input', (e)=>{
    const q = e.target.value.toLowerCase();
    // Hide nav filter for full search
    $$('nav a[data-link]').forEach(a=>{
      a.style.display = '';
    });
    showSearchResults(q);
  });
  // Click outside to hide results
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.search')) {
      $('#search-results').style.display = 'none';
    }
  });
  // copy buttons
  $$('pre .copy').forEach(btn=>{
    btn.addEventListener('click',()=>{
      const code = btn.nextElementSibling.innerText;
      navigator.clipboard.writeText(code).then(()=>{
        const t = btn.textContent;
        btn.textContent = 'Copied!';
        setTimeout(()=>btn.textContent=t,900);
      });
    });
  });
  // initial TOC
  document.querySelectorAll('section[data-route]').forEach(s => buildTOC(s));
  // Build search index
  buildSearchIndex();

  // If logo image is missing, collapse the image to keep layout tidy
  // Removed since no img

  // Syntax highlighting
  hljs.highlightAll();
});

function slugify(text){
  return text.toString().toLowerCase().trim()
    .replace(/[^a-z0-9]+/g,'-')
    .replace(/^-+|-+$/g,'');
}

function buildTOC(section){
  if(!section) return;
  const toc = section.querySelector('.toc');
  if(!toc) return;  // Only build if placeholder exists

  // find headings inside this section
  const headings = Array.from(section.querySelectorAll('h2, h3'));
  if(headings.length === 0){
    toc.style.display = 'none';
    toc.innerHTML = '';
    return;
  }

  toc.style.display = '';
  toc.innerHTML = '<strong>On this page</strong>';

  const list = document.createElement('div');

  headings.forEach(h=>{
    // ensure unique id
    let base = h.id ? h.id : slugify(h.textContent || 'heading');
    let uid = base;
    let idx = 1;
    while(document.getElementById(uid)){
      uid = base + '-' + (idx++);
    }
    h.id = uid;

    const a = document.createElement('a');
    a.textContent = '* ' + h.textContent;
    a.href = '#' + h.id;
    a.addEventListener('click', e=>{
      e.preventDefault();
      // update URL without triggering a full navigation
      history.replaceState(null, '', '#' + h.id);
      document.getElementById(h.id).scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
    list.appendChild(a);
  });

  toc.appendChild(list);
}