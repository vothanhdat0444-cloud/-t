(() => {
  const cfg = window.MECI_ONLINE_CONFIG || {};
  const publicMode = new URLSearchParams(location.search).get('public') === '1';
  const hasConfig = Boolean(cfg.supabaseUrl && cfg.supabaseAnonKey && window.supabase);
  const dot = document.getElementById('cloudDot');
  const statusEl = document.getElementById('cloudStatus');
  const updatedEl = document.getElementById('cloudUpdated');
  const roleEl = document.getElementById('onlineRole');
  const helpEl = document.getElementById('onlineHelp');
  let client = null, session = null, saveTimer = null, syncing = false;

  function setStatus(text, kind='') {
    statusEl.textContent = text;
    dot.className = 'cloudDot ' + kind;
  }
  function setViewer(on) {
    document.body.classList.toggle('viewerMode', on);
    if (on && !document.querySelector('.viewerBanner')) {
      const b = document.createElement('div');
      b.className='viewerBanner';
      b.textContent='Chế độ xem công khai – không hiển thị thông tin nội bộ và không cho chỉnh sửa';
      document.querySelector('main').prepend(b);
    }
    roleEl.textContent = on ? 'Khách xem' : 'Quản trị';
  }
  function sanitizeForPublic(source) {
    const cleanProject = p => ({id:p.id,name:p.name,customer:p.customer,location:p.location,description:p.description,status:p.status,progress:p.progress,start:p.start,due:p.due,goals:p.goals});
    const cleanTask = t => ({id:t.id,projectId:t.projectId,title:t.title,category:t.category,status:t.status,progress:t.progress,start:t.start,due:t.due,description:t.description});
    const cleanSchedule = s => ({id:s.id,projectId:s.projectId,date:s.date,category:s.category,work:s.work,area:s.area,appointment:s.appointment,result:s.result});
    return {version:10,projects:(source.projects||[]).map(cleanProject),tasks:(source.tasks||[]).map(cleanTask),schedules:(source.schedules||[]).map(cleanSchedule),equipment:[],logs:[]};
  }
  function applyCloud(payload) {
    if (!payload || typeof payload !== 'object') return;
    data = migrate(payload);
    localStorage.setItem(KEY, JSON.stringify(data));
    renderAll();
  }
  async function fetchCloud() {
    if (!client) return;
    setStatus('Đang tải dữ liệu...', 'syncing');
    const table = session && !publicMode ? 'meci_private_state' : 'meci_public_state';
    const {data:rows,error} = await client.from(table).select('payload,updated_at').eq('id',1).maybeSingle();
    if (error) throw error;
    if (rows?.payload) applyCloud(rows.payload);
    updatedEl.textContent = rows?.updated_at ? 'Cập nhật: '+new Date(rows.updated_at).toLocaleString('vi-VN') : 'Chưa có dữ liệu Online';
    setStatus(navigator.onLine ? 'Đã kết nối Online' : 'Đang dùng dữ liệu ngoại tuyến', navigator.onLine?'online':'offline');
  }
  async function pushCloud(showMessage=false) {
    if (!client || !session || publicMode || syncing) return;
    syncing=true; setStatus('Đang đồng bộ...', 'syncing');
    try {
      const now=new Date().toISOString();
      const privateRow={id:1,payload:data,updated_at:now,updated_by:session.user.id};
      const publicRow={id:1,payload:sanitizeForPublic(data),updated_at:now};
      let r=await client.from('meci_private_state').upsert(privateRow);
      if(r.error) throw r.error;
      r=await client.from('meci_public_state').upsert(publicRow);
      if(r.error) throw r.error;
      updatedEl.textContent='Cập nhật: '+new Date(now).toLocaleString('vi-VN');
      setStatus('Đã đồng bộ Online','online');
      if(showMessage) alert('Đã đồng bộ dữ liệu lên hệ thống Online.');
    } catch(e) {
      console.error(e); setStatus('Lỗi đồng bộ – dữ liệu vẫn được giữ trên máy','offline');
      if(showMessage) alert('Chưa đồng bộ được: '+(e.message||e));
    } finally { syncing=false; }
  }
  function schedulePush(){ clearTimeout(saveTimer); saveTimer=setTimeout(()=>pushCloud(false),800); }

  // Giữ nguyên cơ chế lưu V9, sau đó đồng bộ Online khi có quyền quản trị.
  const originalSave = save;
  save = function(){ originalSave(); if(session && !publicMode) schedulePush(); };

  async function refreshSession(){
    const {data:s}=await client.auth.getSession(); session=s.session;
    document.getElementById('accountLoggedOut').hidden=!!session;
    document.getElementById('accountLoggedIn').hidden=!session;
    document.getElementById('accountEmail').textContent=session?.user?.email||'';
    setViewer(publicMode || !session);
    helpEl.textContent=session?'Đang đồng bộ tự động. Dữ liệu cục bộ vẫn được giữ làm bản dự phòng.':'Đăng nhập quản trị để chỉnh sửa; người không đăng nhập chỉ xem dữ liệu công khai.';
    await fetchCloud();
  }

  document.getElementById('openAccount').onclick=()=>document.getElementById('accountDialog').showModal();
  document.getElementById('loginBtn').onclick=async()=>{
    const email=document.getElementById('loginEmail').value.trim();
    const password=document.getElementById('loginPassword').value;
    if(!email||!password)return alert('Nhập email và mật khẩu.');
    const {error}=await client.auth.signInWithPassword({email,password});
    if(error)return alert('Đăng nhập thất bại: '+error.message);
    document.getElementById('accountDialog').close(); await refreshSession();
  };
  document.getElementById('logoutBtn').onclick=async()=>{await client.auth.signOut();document.getElementById('accountDialog').close();await refreshSession();};
  document.getElementById('syncNow').onclick=()=>pushCloud(true);
  document.getElementById('uploadV9').onclick=()=>{if(confirm('Đưa toàn bộ dữ liệu đang mở lên hệ thống Online?'))pushCloud(true)};
  document.getElementById('downloadCloud').onclick=()=>fetchCloud().catch(e=>alert('Không tải được dữ liệu: '+e.message));
  document.getElementById('copyPublicLink').onclick=async()=>{const base=cfg.publicBaseUrl||location.href.split('?')[0];await navigator.clipboard.writeText(base+'?public=1');alert('Đã sao chép link công khai.');};
  document.getElementById('publicLink').href=(cfg.publicBaseUrl||location.href.split('?')[0])+'?public=1';

  window.addEventListener('online',()=>fetchCloud().catch(()=>setStatus('Lỗi kết nối','offline')));
  window.addEventListener('offline',()=>setStatus('Ngoại tuyến – dữ liệu vẫn lưu trên máy','offline'));

  if(!hasConfig){
    setViewer(false);
    setStatus('Chưa cấu hình Supabase – đang chạy như V9 ngoại tuyến','offline');
    updatedEl.textContent='Xem README_ONLINE.txt để kích hoạt web Online';
    roleEl.textContent='Ngoại tuyến';
    ['syncNow','uploadV9','downloadCloud','copyPublicLink'].forEach(id=>{const e=document.getElementById(id);if(e)e.disabled=true});
    return;
  }
  client=window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseAnonKey,{auth:{persistSession:true,autoRefreshToken:true}});
  client.auth.onAuthStateChange(()=>setTimeout(refreshSession,0));
  refreshSession().catch(e=>{console.error(e);setStatus('Không kết nối được Supabase','offline')});
})();
