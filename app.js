const STORAGE_KEY = "dcg_reports_v2";
const USER_KEY = "dcg_demo_user";

const fallbackAlerts = [
  {
    id: "seed-1",
    name: "Proctor Office",
    contact: "+8801713493050",
    role: "Safety team",
    category: "Security",
    location: "Main Campus Gate",
    priority: "High",
    status: "triage",
    details: "Crowd movement reported near the front gate. Campus response team is monitoring.",
    createdAt: new Date(Date.now() - 8 * 60 * 1000).toISOString()
  },
  {
    id: "seed-2",
    name: "Transport Desk",
    contact: "+8801811110001",
    role: "Staff",
    category: "Transport",
    location: "Bus Stand",
    priority: "Medium",
    status: "open",
    details: "Route 4 is delayed due to traffic. Students are advised to use Route 2 temporarily.",
    createdAt: new Date(Date.now() - 24 * 60 * 1000).toISOString()
  },
  {
    id: "seed-3",
    name: "Medical Center",
    contact: "+8801847334655",
    role: "Staff",
    category: "Medical",
    location: "Knowledge Tower",
    priority: "Low",
    status: "resolved",
    details: "First-aid support is available on level 2 until 9:00 PM.",
    createdAt: new Date(Date.now() - 53 * 60 * 1000).toISOString()
  }
];

const contacts = [
  { label: "Proctor Office", detail: "Campus discipline and response", phone: "+8801713493050" },
  { label: "Medical Center", detail: "First aid and ambulance support", phone: "+8801847334655" },
  { label: "Security Control", detail: "Gate, building, and night patrol", phone: "+8801912400700" },
  { label: "Transport Desk", detail: "Campus transport and route help", phone: "+8801811110001" },
  { label: "Counseling Support", detail: "Student mental health support", phone: "+8801811110002" },
  { label: "IT Help Desk", detail: "Account and app access support", phone: "+8801811110003" }
];

const state = {
  app: null,
  auth: null,
  db: null,
  user: loadUser(),
  firebaseReady: false,
  firebaseFns: null,
  alerts: loadStoredReports(),
  filters: { search: "", status: "all", priority: "all" }
};

const els = {
  alertList: document.querySelector("#alertList"),
  caseBoard: document.querySelector("#caseBoard"),
  clock: document.querySelector("#clock"),
  closeSosButton: document.querySelector("#closeSosButton"),
  contactGrid: document.querySelector("#contactGrid"),
  exportButton: document.querySelector("#exportButton"),
  firebaseStatus: document.querySelector("#firebaseStatus"),
  form: document.querySelector("#report"),
  openCases: document.querySelector("#openCases"),
  priorityFilter: document.querySelector("#priorityFilter"),
  refreshButton: document.querySelector("#refreshButton"),
  resolvedCases: document.querySelector("#resolvedCases"),
  searchInput: document.querySelector("#searchInput"),
  signInButton: document.querySelector("#signInButton"),
  sosButton: document.querySelector("#sosButton"),
  sosModal: document.querySelector("#sosModal"),
  statusFilter: document.querySelector("#statusFilter"),
  themeToggle: document.querySelector("#themeToggle"),
  toast: document.querySelector("#toast"),
  userStatus: document.querySelector("#userStatus")
};

function loadStoredReports() {
  try {
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY) || "null");
    return Array.isArray(stored) && stored.length ? stored : [...fallbackAlerts];
  } catch {
    return [...fallbackAlerts];
  }
}

function loadUser() {
  try {
    return JSON.parse(localStorage.getItem(USER_KEY) || "null");
  } catch {
    return null;
  }
}

function persistReports() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.alerts));
}

function persistUser() {
  if (state.user) {
    localStorage.setItem(USER_KEY, JSON.stringify(state.user));
  } else {
    localStorage.removeItem(USER_KEY);
  }
}

function hasFirebaseConfig(config) {
  return config && Object.values(config).every((value) => value && !String(value).startsWith("PASTE_"));
}

async function initFirebase() {
  const config = window.DCG_FIREBASE_CONFIG;

  if (!hasFirebaseConfig(config)) {
    updateFirebaseStatus(false, "Local demo mode");
    updateUserStatus();
    return;
  }

  try {
    const [appModule, authModule, firestoreModule] = await Promise.all([
      import("https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js"),
      import("https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js"),
      import("https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js")
    ]);

    state.firebaseFns = { ...authModule, ...firestoreModule };
    state.app = appModule.initializeApp(config);
    state.auth = authModule.getAuth(state.app);
    state.db = firestoreModule.getFirestore(state.app);
    state.firebaseReady = true;
    updateFirebaseStatus(true, "Firebase connected");

    authModule.onAuthStateChanged(state.auth, (user) => {
      state.user = user ? { name: user.displayName || "Firebase responder", uid: user.uid } : loadUser();
      updateUserStatus();
      updateSignInButton();
    });

    await loadAlerts();
  } catch (error) {
    updateFirebaseStatus(false, "Firebase config error");
    showToast(error.message);
  }
}

function updateFirebaseStatus(connected, label) {
  els.firebaseStatus.classList.toggle("connected", connected);
  els.firebaseStatus.innerHTML = `<i data-lucide="${connected ? "cloud-check" : "database"}"></i>${label}`;
  createIcons();
}

function updateUserStatus() {
  els.userStatus.textContent = state.user ? `${state.user.name} active` : "Guest responder";
}

function updateSignInButton() {
  els.signInButton.innerHTML = state.user
    ? '<i data-lucide="log-out"></i>Sign out'
    : '<i data-lucide="log-in"></i>Sign in';
  createIcons();
}

function formatTime(date) {
  return new Intl.DateTimeFormat("en", { hour: "numeric", minute: "2-digit" }).format(date);
}

function relativeTime(date) {
  const minutes = Math.max(1, Math.round((Date.now() - date.getTime()) / 60000));
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.round(hours / 24)}d ago`;
}

function getDate(value) {
  if (value?.toDate) return value.toDate();
  return new Date(value || Date.now());
}

function getFilteredAlerts() {
  const search = state.filters.search.trim().toLowerCase();
  return state.alerts.filter((alert) => {
    const matchesStatus = state.filters.status === "all" || alert.status === state.filters.status;
    const matchesPriority =
      state.filters.priority === "all" || String(alert.priority).toLowerCase() === state.filters.priority;
    const haystack = [alert.name, alert.role, alert.category, alert.location, alert.priority, alert.status, alert.details]
      .join(" ")
      .toLowerCase();
    return matchesStatus && matchesPriority && (!search || haystack.includes(search));
  });
}

function renderAlerts() {
  const alerts = getFilteredAlerts().slice(0, 8);

  els.alertList.innerHTML = alerts.length
    ? alerts.map(renderAlertItem).join("")
    : `<div class="empty-state"><i data-lucide="search-x"></i>No matching reports found.</div>`;

  const open = state.alerts.filter((alert) => alert.status !== "resolved").length;
  const resolved = state.alerts.filter((alert) => alert.status === "resolved").length;
  els.openCases.textContent = String(open);
  els.resolvedCases.textContent = String(resolved);
  renderCaseBoard();
  createIcons();
}

function renderAlertItem(alert) {
  const createdAt = getDate(alert.createdAt);
  return `
    <article class="alert-item">
      <div class="alert-top">
        <strong>${escapeHtml(alert.location || "Campus")}</strong>
        <span class="badge ${String(alert.priority).toLowerCase()}">${escapeHtml(alert.priority || "Medium")}</span>
      </div>
      <p>${escapeHtml(alert.details || "No details provided.")}</p>
      <div class="meta-row">
        <span><i data-lucide="user-round"></i>${escapeHtml(alert.role || "Reporter")} - ${escapeHtml(alert.name || "Anonymous")}</span>
        <span><i data-lucide="clock-3"></i>${relativeTime(createdAt)}</span>
      </div>
      <div class="meta-row">
        <span><i data-lucide="tag"></i>${escapeHtml(alert.category || "Other")}</span>
        <span class="status-dot ${escapeHtml(alert.status || "open")}">${escapeHtml(alert.status || "open")}</span>
      </div>
      <div class="alert-actions">
        <button class="secondary-button" type="button" data-copy="${escapeHtml(alert.contact || "")}">
          <i data-lucide="phone"></i>Copy contact
        </button>
        <button class="ghost-button compact" type="button" data-status-id="${escapeHtml(alert.id)}" data-next-status="triage">Triage</button>
        <button class="ghost-button compact" type="button" data-status-id="${escapeHtml(alert.id)}" data-next-status="resolved">Resolve</button>
      </div>
    </article>
  `;
}

function renderCaseBoard() {
  const columns = [
    { key: "open", label: "Open" },
    { key: "triage", label: "Triage" },
    { key: "resolved", label: "Resolved" }
  ];

  els.caseBoard.innerHTML = columns
    .map((column) => {
      const items = state.alerts.filter((alert) => (alert.status || "open") === column.key);
      return `
        <div class="case-column">
          <div class="case-column-head">
            <strong>${column.label}</strong>
            <span class="badge">${items.length}</span>
          </div>
          ${
            items.length
              ? items.slice(0, 5).map(renderCaseItem).join("")
              : '<div class="empty-state small">Nothing here</div>'
          }
        </div>
      `;
    })
    .join("");
}

function renderCaseItem(alert) {
  return `
    <article class="case-item">
      <strong>${escapeHtml(alert.location)}</strong>
      <span>${escapeHtml(alert.category)} - ${escapeHtml(alert.priority)}</span>
      <p>${escapeHtml(alert.details)}</p>
      <div class="alert-actions">
        <button class="ghost-button compact" type="button" data-status-id="${escapeHtml(alert.id)}" data-next-status="open">Open</button>
        <button class="ghost-button compact" type="button" data-status-id="${escapeHtml(alert.id)}" data-next-status="triage">Triage</button>
        <button class="ghost-button compact" type="button" data-status-id="${escapeHtml(alert.id)}" data-next-status="resolved">Done</button>
      </div>
    </article>
  `;
}

function renderContacts() {
  els.contactGrid.innerHTML = contacts
    .map(
      (contact) => `
      <article class="contact-item">
        <div class="contact-top">
          <strong>${contact.label}</strong>
          <span class="badge">24/7</span>
        </div>
        <p>${contact.detail}</p>
        <button class="secondary-button" type="button" data-copy="${contact.phone}">
          <i data-lucide="copy"></i>${contact.phone}
        </button>
      </article>
    `
    )
    .join("");
}

async function loadAlerts() {
  if (!state.firebaseReady) {
    renderAlerts();
    return;
  }

  try {
    const { collection, getDocs, limit, orderBy, query } = state.firebaseFns;
    const q = query(collection(state.db, "reports"), orderBy("createdAt", "desc"), limit(30));
    const snapshot = await getDocs(q);
    const firebaseAlerts = snapshot.docs.map((doc) => normalizeReport({ id: doc.id, ...doc.data() }));

    if (firebaseAlerts.length) {
      state.alerts = firebaseAlerts;
      persistReports();
    }

    renderAlerts();
  } catch (error) {
    showToast(`Could not load Firebase alerts: ${error.message}`);
    renderAlerts();
  }
}

async function submitReport(event) {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  const report = normalizeReport({
    id: crypto.randomUUID(),
    name: form.get("anonymous") ? "Anonymous" : String(form.get("name")).trim(),
    contact: String(form.get("contact")).trim(),
    role: String(form.get("role")).trim(),
    category: String(form.get("category")).trim(),
    location: String(form.get("location")).trim(),
    priority: String(form.get("priority")).trim(),
    details: String(form.get("details")).trim(),
    anonymous: Boolean(form.get("anonymous")),
    status: "open",
    createdAt: new Date().toISOString()
  });

  const saved = await saveReport(report);
  if (saved) {
    event.currentTarget.reset();
    showToast("Report submitted.");
  }
}

async function saveReport(report) {
  if (state.firebaseReady) {
    try {
      const { addDoc, collection, serverTimestamp, signInAnonymously } = state.firebaseFns;
      if (!state.user && state.auth) await signInAnonymously(state.auth);
      const docRef = await addDoc(collection(state.db, "reports"), {
        ...report,
        createdAt: serverTimestamp(),
        createdBy: state.auth?.currentUser?.uid || state.user?.uid || "local"
      });
      state.alerts.unshift({ ...report, id: docRef.id });
      persistReports();
      renderAlerts();
      return true;
    } catch (error) {
      showToast(`Firebase submit failed: ${error.message}`);
    }
  }

  state.alerts.unshift(report);
  persistReports();
  renderAlerts();
  return true;
}

async function updateReportStatus(id, status) {
  const report = state.alerts.find((item) => item.id === id);
  if (!report) return;

  report.status = status;
  report.updatedAt = new Date().toISOString();
  report.updatedBy = state.user?.name || "Guest responder";

  if (state.firebaseReady && !id.startsWith("seed-")) {
    try {
      const { doc, updateDoc } = state.firebaseFns;
      await updateDoc(doc(state.db, "reports", id), {
        status,
        updatedAt: new Date().toISOString(),
        updatedBy: state.user?.name || "Firebase responder"
      });
    } catch (error) {
      showToast(`Firebase update failed: ${error.message}`);
    }
  }

  persistReports();
  renderAlerts();
  showToast(`Marked as ${status}.`);
}

function normalizeReport(report) {
  return {
    id: report.id || crypto.randomUUID(),
    name: report.name || "Anonymous",
    contact: report.contact || "",
    role: report.role || "Reporter",
    category: report.category || "Other",
    location: report.location || "Campus",
    priority: report.priority || "Medium",
    status: report.status || "open",
    details: report.details || "No details provided.",
    anonymous: Boolean(report.anonymous),
    createdAt: report.createdAt?.toDate ? report.createdAt.toDate().toISOString() : report.createdAt || new Date().toISOString()
  };
}

async function handleSignIn() {
  if (state.user) {
    if (state.firebaseReady && state.auth?.currentUser) {
      await state.firebaseFns.signOut(state.auth);
    }
    state.user = null;
    persistUser();
    updateUserStatus();
    updateSignInButton();
    showToast("Signed out.");
    return;
  }

  if (state.firebaseReady) {
    try {
      await state.firebaseFns.signInWithPopup(state.auth, new state.firebaseFns.GoogleAuthProvider());
      showToast("Signed in with Google.");
      return;
    } catch (error) {
      showToast(error.message);
    }
  }

  state.user = { name: "Campus Responder", uid: "local-responder" };
  persistUser();
  updateUserStatus();
  updateSignInButton();
  showToast("Demo responder signed in.");
}

function openSosModal() {
  els.sosModal.classList.add("show");
  els.sosModal.setAttribute("aria-hidden", "false");
}

function closeSosModal() {
  els.sosModal.classList.remove("show");
  els.sosModal.setAttribute("aria-hidden", "true");
}

async function createSosReport(location) {
  await saveReport(
    normalizeReport({
      id: crypto.randomUUID(),
      name: state.user?.name || "Emergency trigger",
      contact: "+8801713493050",
      role: "Responder",
      category: "Security",
      location,
      priority: "Critical",
      status: "open",
      details: `SOS triggered for ${location}. Dispatch security and proctor response immediately.`,
      createdAt: new Date().toISOString()
    })
  );
  closeSosModal();
  locationHash("#alerts");
}

function exportReports() {
  const blob = new Blob([JSON.stringify(state.alerts, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `dcg-reports-${new Date().toISOString().slice(0, 10)}.json`;
  a.click();
  URL.revokeObjectURL(url);
  showToast("Reports exported.");
}

function showToast(message) {
  els.toast.textContent = message;
  els.toast.classList.add("show");
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => els.toast.classList.remove("show"), 3200);
}

function copyValue(value) {
  if (!value) {
    showToast("No contact number available.");
    return;
  }
  navigator.clipboard?.writeText(value).then(() => showToast("Copied to clipboard.")).catch(() => showToast(value));
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (char) => {
    return {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#039;"
    }[char];
  });
}

function tickClock() {
  els.clock.textContent = formatTime(new Date());
}

function locationHash(hash) {
  window.location.hash = hash;
}

function bindEvents() {
  els.form.addEventListener("submit", submitReport);
  els.refreshButton.addEventListener("click", loadAlerts);
  els.exportButton.addEventListener("click", exportReports);
  els.signInButton.addEventListener("click", handleSignIn);
  els.sosButton.addEventListener("click", openSosModal);
  els.closeSosButton.addEventListener("click", closeSosModal);
  els.sosModal.addEventListener("click", (event) => {
    if (event.target === els.sosModal) closeSosModal();
  });

  els.searchInput.addEventListener("input", (event) => {
    state.filters.search = event.target.value;
    renderAlerts();
  });
  els.statusFilter.addEventListener("change", (event) => {
    state.filters.status = event.target.value;
    renderAlerts();
  });
  els.priorityFilter.addEventListener("change", (event) => {
    state.filters.priority = event.target.value;
    renderAlerts();
  });

  els.themeToggle.addEventListener("click", () => {
    const isDark = document.documentElement.dataset.theme === "dark";
    document.documentElement.dataset.theme = isDark ? "light" : "dark";
    els.themeToggle.innerHTML = `<i data-lucide="${isDark ? "moon" : "sun"}"></i>`;
    createIcons();
  });

  document.addEventListener("click", (event) => {
    const copyTarget = event.target.closest("[data-copy]");
    if (copyTarget) copyValue(copyTarget.dataset.copy);

    const statusTarget = event.target.closest("[data-status-id]");
    if (statusTarget) updateReportStatus(statusTarget.dataset.statusId, statusTarget.dataset.nextStatus);

    const sosTarget = event.target.closest("[data-sos]");
    if (sosTarget) createSosReport(sosTarget.dataset.sos);
  });
}

function createIcons() {
  if (window.lucide?.createIcons) {
    window.lucide.createIcons();
  }
}

if ("serviceWorker" in navigator && location.protocol.startsWith("http")) {
  navigator.serviceWorker.register("./sw.js").catch(() => {});
}

createIcons();
renderContacts();
renderAlerts();
bindEvents();
updateUserStatus();
updateSignInButton();
initFirebase();
tickClock();
window.setInterval(tickClock, 30000);
