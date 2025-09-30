// ===== Tiny Router & Enhancements =====
const $ = (q,root=document) => root.querySelector(q);
const $$ = (q,root=document) => Array.from(root.querySelectorAll(q));

const routes = new Set($$('section[data-route]')).add($('section[data-route="home"]'));

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
  // nav filter by search
  $('#search').addEventListener('input', (e)=>{
    const q = e.target.value.toLowerCase();
    $$('nav a[data-link]').forEach(a=>{
      const show = a.textContent.toLowerCase().includes(q);
      a.style.display = show ? '' : 'none';
    });
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

  // If logo image is missing, collapse the image to keep layout tidy
  const logoImg = document.getElementById('logoImg');
  logoImg.addEventListener('error', ()=>{ logoImg.style.display = 'none'; });
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