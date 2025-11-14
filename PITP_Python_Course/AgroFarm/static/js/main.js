// Navabar
document.addEventListener('DOMContentLoaded', () => {
  const rightControls = document.getElementById('rightControls');
  const navLinksContainer = document.getElementById('navLinks');
  const navLinks = document.querySelectorAll('.nav-links a') || [];
  const userIcon = document.getElementById('userIcon');
  const menuIcon = document.getElementById('menuIcon');

  let currentUser = localStorage.getItem('currentUser');

  // ============================
  // Render User Icon / Dropdown
  // ============================
  function renderUserIcon() {
    const oldDropdown = document.getElementById('userDropdown');
    if (oldDropdown) oldDropdown.remove();

    if (currentUser) {
      if (userIcon) userIcon.style.display = 'none';

      const dropdown = document.createElement('div');
      dropdown.id = 'userDropdown';
      dropdown.classList.add('user-dropdown');
      dropdown.innerHTML = `
        <span class="username" style="cursor:pointer;">${currentUser}</span>
        <div id="userMenu" class="user-menu" style="display:none;">
          <a href="Profile.html">Profile</a>
          <button id="logoutBtn">Logout</button>
        </div>
      `;
      rightControls.insertBefore(dropdown, menuIcon);

      const usernameEl = dropdown.querySelector('.username');
      const logoutBtn = document.getElementById('logoutBtn');
      const userMenu = document.getElementById('userMenu');

      usernameEl.addEventListener('click', (e) => {
        e.stopPropagation();
        userMenu.style.display = userMenu.style.display === 'block' ? 'none' : 'block';
      });

      logoutBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        localStorage.removeItem('currentUser');
        currentUser = null;
        renderUserIcon();
      });

      document.addEventListener('click', (e) => {
        if (!dropdown.contains(e.target)) userMenu.style.display = 'none';
      });

    } else {
      if (userIcon) {
        userIcon.style.display = 'block';
        userIcon.onclick = openLoginPopup;
      }
    }
  }

  renderUserIcon();
  // ============================
  // Mobile Menu Toggle
  // ============================
  if (menuIcon && navLinksContainer) {
    menuIcon.addEventListener('click', (e) => {
      e.stopPropagation();
      navLinksContainer.classList.toggle('show');
    });

    document.addEventListener('click', (e) => {
      if (!menuIcon.contains(e.target) && !navLinksContainer.contains(e.target)) {
        navLinksContainer.classList.remove('show');
      }
    });
  }

  // ============================
  // Smooth scroll & active link
  // ============================
  function scrollActive() {
    const scrollY = window.pageYOffset + 100;

    navLinks.forEach(link => link.classList.remove('active'));
    for (const link of navLinks) {
      const target = document.querySelector(link.hash);
      if (target) {
        const sectionTop = target.offsetTop;
        const sectionHeight = target.offsetHeight;
        if (scrollY >= sectionTop && scrollY < sectionTop + sectionHeight) {
          link.classList.add('active');
        }
      }
    }

    if (scrollY < 120) {
      const homeLink = document.querySelector('.nav-links a[href="#home"]');
      if (homeLink) homeLink.classList.add('active');
    }
  }

  window.addEventListener('scroll', scrollActive);

  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      if(link.hash) {
        e.preventDefault();
        const targetSection = document.querySelector(link.hash);
        if(targetSection) targetSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
        navLinksContainer.classList.remove('show');
      }
    });
  });

});

// ===============================
// 🌾 HERO IMAGE SLIDESHOW
// ===============================
const heroSection = document.querySelector(".hero-section");
const heroImages = [
  "https://images.pexels.com/photos/162240/bull-calf-heifer-ko-162240.jpeg",
  "https://images.pexels.com/photos/1094544/pexels-photo-1094544.jpeg",
  "https://cdn.pixabay.com/photo/2016/11/08/05/37/agriculture-1807553_1280.jpg",
  "https://cdn.pixabay.com/photo/2022/08/06/06/58/nepalese-farmer-7368037_1280.jpg"
];

let currentImage = 0;

// create two background layers
let bg1 = document.createElement("div");
let bg2 = document.createElement("div");
bg1.classList.add("hero-bg", "visible");
bg2.classList.add("hero-bg");
heroSection.prepend(bg2);
heroSection.prepend(bg1);

// preload all images first (avoids flicker)
heroImages.forEach(src => {
  const img = new Image();
  img.src = src;
});

// set first two images
bg1.style.backgroundImage = `url(${heroImages[0]})`;
bg2.style.backgroundImage = `url(${heroImages[1]})`;

let nextImage = 1;
setInterval(() => {
  bg2.style.backgroundImage = `url(${heroImages[nextImage]})`;

  // fade transition
  bg1.classList.toggle("visible");
  bg2.classList.toggle("visible");

  // swap references
  const temp = bg1;
  bg1 = bg2;
  bg2 = temp;

  nextImage = (nextImage + 1) % heroImages.length;
}, 5000);


// ===============================
// 🌻 ABOUT IMAGE SLIDESHOW
// ===============================
const aboutImageContainer = document.getElementById("aboutImage");
const aboutImages = [
  "https://cdn.pixabay.com/photo/2016/02/15/16/45/work-1201543_1280.jpg",
  "https://media.istockphoto.com/id/1492315484/photo/senior-farmer-driving-a-tractor-on-agricultural-field.jpg?s=612x612&w=0&k=20&c=koXoxGKY9o_QgP6b4udaw7DZ2_HSTP0Rar-y9-zExtI=",
  "https://media.istockphoto.com/id/1176638657/photo/young-men-on-haystack.jpg?s=612x612&w=0&k=20&c=-DN4gg0bH7Qk3Asr5ZHHnIfkpKdX-u0WOVCcr2BCsmM=",
  "https://media.istockphoto.com/id/476747030/photo/farm-equipment.jpg?s=612x612&w=0&k=20&c=RPiiQVqgaLZRYwyoT4Nujv5aKMqCME3kkot6kzANjEw="
];

// Create img elements
aboutImages.forEach((src, i) => {
  const img = document.createElement("img");
  img.src = src;
  if (i === 0) img.classList.add("active");
  aboutImageContainer.appendChild(img);
});

let aboutCurrent = 0;
setInterval(() => {
  const imgs = aboutImageContainer.querySelectorAll("img");
  imgs[aboutCurrent].classList.remove("active");
  aboutCurrent = (aboutCurrent + 1) % imgs.length;
  imgs[aboutCurrent].classList.add("active");
}, 3000);
// About Popup Functionality
document.addEventListener('DOMContentLoaded', function() {
    const readMoreBtn = document.getElementById('readMoreBtn');
    const aboutPopup = document.getElementById('aboutPopup');
    const closePopup = document.getElementById('closePopup');
    
    // Open popup
    readMoreBtn.addEventListener('click', function() {
        aboutPopup.style.display = 'block';
        document.body.style.overflow = 'hidden'; // Prevent scrolling
    });
    
    // Close popup
    closePopup.addEventListener('click', function() {
        aboutPopup.style.display = 'none';
        document.body.style.overflow = 'auto'; // Restore scrolling
    });
    
    // Close popup when clicking outside content
    aboutPopup.addEventListener('click', function(e) {
        if (e.target === aboutPopup) {
            aboutPopup.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    });
    
    // Close popup with Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && aboutPopup.style.display === 'block') {
            aboutPopup.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    });
    
    // Add smooth scroll for the about section link (if needed)
    const aboutLink = document.querySelector('a[href="#about"]');
    if (aboutLink) {
        aboutLink.addEventListener('click', function(e) {
            e.preventDefault();
            document.querySelector('#about').scrollIntoView({
                behavior: 'smooth'
            });
        });
    }
});
// ===============================
// 🔐 LOGIN / REGISTER HANDLERS
// ===============================

document.addEventListener("DOMContentLoaded", () => {

  // -------------------------------
  // ✅ Flash Message System
  // -------------------------------
  const flashMessage = document.createElement("div");
  flashMessage.id = "flashMessage";
  Object.assign(flashMessage.style, {
    position: "fixed",
    top: "30px",
    left: "50%",
    transform: "translateX(-50%)",
    padding: "14px 28px",
    borderRadius: "8px",
    fontWeight: "600",
    fontSize: "1rem",
    zIndex: "9999",
    display: "none",
    color: "#fff",
    boxShadow: "0 4px 15px rgba(0,0,0,0.2)",
  });
  document.body.appendChild(flashMessage);

  function showFlash(msg, type = "danger") {
    flashMessage.textContent = msg;
    flashMessage.style.display = "block";
    flashMessage.style.opacity = "1";

    switch(type){
      case "success":
        flashMessage.style.backgroundColor = "#28a745"; break;
      case "warning":
        flashMessage.style.backgroundColor = "#ffc107"; flashMessage.style.color = "#000"; break;
      default:
        flashMessage.style.backgroundColor = "#dc3545"; flashMessage.style.color = "#fff";
    }

    // Reset transition
    flashMessage.style.transition = "none";
    void flashMessage.offsetWidth; // force reflow
    flashMessage.style.transition = "opacity 0.5s ease";

    setTimeout(() => {
      flashMessage.style.opacity = "0";
      setTimeout(() => flashMessage.style.display = "none", 500);
    }, 2500);
  }

  // -------------------------------
  // 🌿 NAVBAR & USER ICON
  // -------------------------------
  const navbar = document.getElementById("navbar");
  const menuIcon = document.getElementById("menuIcon");
  const navLinks = document.getElementById("navLinks");
  const userIcon = document.getElementById("userIcon");
  const logoutBtn = document.getElementById("logoutBtn");

  window.addEventListener("scroll", () => {
    if (window.scrollY > 60) navbar?.classList.add("scrolled");
    else navbar?.classList.remove("scrolled");
  });

  menuIcon?.addEventListener("click", () => {
    navLinks?.classList.toggle("show");
    menuIcon.classList.toggle("open");
  });

  if (userIcon) {
    let loggedIn = userIcon.dataset.loggedIn === "true";
    const updateUserIcon = () => {
      if (loggedIn) {
        userIcon.classList.remove("bi-person");
        userIcon.classList.add("bi-person-circle");
        userIcon.title = "Profile";
      } else {
        userIcon.classList.remove("bi-person-circle");
        userIcon.classList.add("bi-person");
        userIcon.title = "Login";
      }
    };
    updateUserIcon();
    userIcon.addEventListener("click", () => {
      if (loggedIn) window.location.href = "/profile";
      else window.location.href = "/login";
    });
  }

  logoutBtn?.addEventListener("click", (e) => {
    e.preventDefault();
    window.location.href = "/logout";
  });

  // -------------------------------
  // ❌ REGISTER CLOSE BUTTON
  // -------------------------------
  const registerCloseBtn = document.getElementById("closeForm");
  registerCloseBtn?.addEventListener("click", () => {
    if (document.referrer) window.history.back();
    else window.location.href = "/";
  });

  // -------------------------------
  // 🛡 PASSWORD STRENGTH & CONFIRM
  // -------------------------------
  const passwordInput = document.getElementById("password");
  const confirmPasswordInput = document.getElementById("confirmPassword");
  const passwordStrength = document.getElementById("passwordStrength");
  const passwordMatch = document.getElementById("passwordMatch");

  if(passwordInput && passwordStrength){
    passwordStrength.innerHTML = "";

    const textSpan = document.createElement("span");
    textSpan.textContent = "Strength: Weak";
    textSpan.style.fontWeight = "600";
    textSpan.style.marginRight = "10px";

    const barContainer = document.createElement("div");
    barContainer.style.width = "100%";
    barContainer.style.height = "6px";
    barContainer.style.background = "#e0e0e0";
    barContainer.style.borderRadius = "6px";
    barContainer.style.marginTop = "5px";

    const bar = document.createElement("div");
    bar.style.width = "0%";
    bar.style.height = "100%";
    bar.style.borderRadius = "6px";
    bar.style.background = "#f44336";
    bar.style.transition = "width 0.4s ease, background 0.4s ease";

    barContainer.appendChild(bar);
    passwordStrength.appendChild(textSpan);
    passwordStrength.appendChild(barContainer);

    function updateStrength() {
      const val = passwordInput.value;
      let strength = "Weak", width = "33%", color = "#f44336";

      if (val.length >= 8 && /[A-Z]/.test(val) && /[0-9]/.test(val) && /[\W]/.test(val)) {
        strength = "Strong"; width = "100%"; color = "#4caf50";
      } else if (val.length >= 6) {
        strength = "Medium"; width = "66%"; color = "#ffc107";
      }

      textSpan.textContent = `Strength: ${strength}`;
      bar.style.width = width;
      bar.style.background = color;

      checkMatch();
    }

    function checkMatch() {
      if (!confirmPasswordInput) return;
      if (confirmPasswordInput.value.length === 0) {
        passwordMatch.textContent = "";
        return;
      }
      if (confirmPasswordInput.value !== passwordInput.value) {
        passwordMatch.textContent = "Passwords do not match!";
        passwordMatch.style.color = "red";
      } else {
        passwordMatch.textContent = "Passwords match ✅";
        passwordMatch.style.color = "green";
      }
    }

    passwordInput.addEventListener("input", updateStrength);
    confirmPasswordInput?.addEventListener("input", checkMatch);
  }

  // -------------------------------
  // Form submit validation
  // -------------------------------
  const registerForm = document.getElementById("registerForm");
  registerForm?.addEventListener("submit", async (e) => {
    e.preventDefault();

    const emailInput = document.getElementById("email");
    const passwordVal = passwordInput.value;
    const confirmVal = confirmPasswordInput.value;

    // -------------------------------
    // 1️⃣ Check email with backend via AJAX
    // -------------------------------
    try {
      const response = await fetch(`/check-email?email=${encodeURIComponent(emailInput.value.trim())}`);
      const data = await response.json();
      if (data.exists) {
        showFlash("This email is already registered!", "danger");
        return;
      }
    } catch(err) {
      console.error("Email check failed:", err);
      showFlash("Email check failed. Try again!", "warning");
      return;
    }

    // -------------------------------
    // 2️⃣ Check passwords
    // -------------------------------
    if(passwordVal !== confirmVal){
      showFlash("Passwords do not match!", "danger");
      return;
    }

    // -------------------------------
    // 3️⃣ Submit form if all validations pass
    // -------------------------------
    registerForm.submit();
  });

  // -------------------------------
  // 🧠 AUTO-REDIRECT LOGIC
  // -------------------------------
  const currentPage = window.location.pathname.split("/").pop();
  const isLoggedIn = userIcon ? userIcon.dataset.loggedIn === "true" : false;

  if (isLoggedIn && (currentPage === "login" || currentPage === "login.html")) {
    window.location.href = "/";
  }

  if (!isLoggedIn && (currentPage === "profile" || currentPage === "profile.html")) {
    showFlash("Please log in to access profile!", "warning");
    setTimeout(() => window.location.href = "/login", 1000);
  }

});

// Forum
// 🌱 AgroFarm Discussion Forum JS
// 🌱 AgroFarm Discussion Forum JS

const images = [
  "https://cdn.pixabay.com/photo/2020/04/22/21/00/agriculture-5080044_1280.jpg",
  "https://cdn.pixabay.com/photo/2020/12/15/13/44/portrait-5833683_1280.jpg",
  "https://cdn.pixabay.com/photo/2019/06/23/07/47/women-4293049_1280.jpg",
  "https://cdn.pixabay.com/photo/2016/11/03/03/58/animals-1793409_1280.jpg"
];

let currentIndex = 0;
const imgElement = document.getElementById("rotatingImg");
if (imgElement) {
  setInterval(() => {
    currentIndex = (currentIndex + 1) % images.length;
    imgElement.style.opacity = 0;
    setTimeout(() => {
      imgElement.src = images[currentIndex];
      imgElement.style.opacity = 1;
    }, 400);
  }, 3000);
}

let discussions = [];
let currentSort = 'newest';

// -------------------
// Utility Functions
// -------------------
function showFlash(message, type = 'success') {
  const flash = document.createElement('div');
  flash.className = `flash-message flash-${type}`;
  flash.textContent = message;
  document.body.appendChild(flash);
  
  // Trigger animation
  setTimeout(() => flash.classList.add('show'), 10);
  
  setTimeout(() => {
    flash.classList.remove('show');
    setTimeout(() => flash.remove(), 300);
  }, 3000);
}

function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// -------------------
// Modal Creation
// -------------------
function createEditModal(title = '', content = '', isReply = false) {
  // Remove existing modals
  const existingModal = document.querySelector('.modal-overlay');
  if (existingModal) existingModal.remove();
  
  const existingEditModal = document.querySelector('.edit-modal');
  if (existingEditModal) existingEditModal.remove();

  // Overlay
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';

  // Modal
  const modal = document.createElement('div');
  modal.className = 'edit-modal';
  modal.innerHTML = `
    <h2><i class="bi bi-pencil"></i> ${isReply ? 'Edit Reply' : 'Edit Post'}</h2>
    ${!isReply ? `
      <div class="form-group">
        <input type="text" value="${escapeHtml(title)}" placeholder="Title" maxlength="200" />
        <span class="char-count">${title.length}/200</span>
      </div>
    ` : ''}
    <div class="form-group">
      <textarea rows="6" placeholder="${isReply ? 'Write your reply...' : 'Write your content...'}" 
                maxlength="${isReply ? 1000 : 2000}">${escapeHtml(content)}</textarea>
      <span class="char-count">${content.length}/${isReply ? 1000 : 2000}</span>
    </div>
    <div class="modal-buttons">
      <button class="btn-cancel">Cancel</button>
      <button class="btn-update">Update</button>
    </div>
  `;

  document.body.appendChild(overlay);
  document.body.appendChild(modal);

  // Add character counter functionality
  const textarea = modal.querySelector('textarea');
  const charCount = modal.querySelector('.char-count:last-child');
  textarea.addEventListener('input', () => {
    charCount.textContent = `${textarea.value.length}/${isReply ? 1000 : 2000}`;
  });

  if (!isReply) {
    const titleInput = modal.querySelector('input');
    const titleCharCount = modal.querySelector('.char-count:first-child');
    titleInput.addEventListener('input', () => {
      titleCharCount.textContent = `${titleInput.value.length}/200`;
    });
  }

  // Show with animation
  setTimeout(() => {
    overlay.classList.add('show');
    modal.classList.add('show');
  }, 10);

  return { overlay, modal };
}

// -------------------
// Fetch discussions with sorting and filtering
// -------------------
async function fetchDiscussions(searchQuery = '', category = '', sort = 'newest') {
  try {
    const threadsContainer = document.getElementById('threadsContainer');
    if (threadsContainer) {
      threadsContainer.innerHTML = `
        <div class="loading-indicator">
          <i class="bi bi-arrow-repeat"></i>
          <p>Loading discussions...</p>
        </div>
      `;
    }

    const params = new URLSearchParams();
    if (searchQuery) params.append('q', searchQuery);
    if (category) params.append('category', category);
    if (sort) params.append('sort', sort);
    
    const url = `/api/discussions?${params.toString()}`;
    const res = await fetch(url);
    if (!res.ok) throw new Error('Network error: ' + res.status);
    const data = await res.json();
    discussions = Array.isArray(data) ? data : [];
    renderDiscussions();
    updateForumStats();
  } catch (err) {
    console.error('Error fetching discussions:', err);
    showFlash("Error fetching discussions.", "error");
    const threadsContainer = document.getElementById('threadsContainer');
    if (threadsContainer) {
      threadsContainer.innerHTML = `
        <div class="no-threads">
          <i class="bi bi-exclamation-triangle"></i>
          <h3>Error loading discussions</h3>
          <p>Please try refreshing the page.</p>
        </div>
      `;
    }
  }
}

// -------------------
// Update forum statistics and latest posts
// -------------------
async function updateForumStats() {
  try {
    const res = await fetch('/api/forum/stats');
    if (res.ok) {
      const stats = await res.json();
      
      // Update stats
      const totalDiscussionsEl = document.getElementById('totalDiscussions');
      const totalRepliesEl = document.getElementById('totalReplies');
      const totalUsersEl = document.getElementById('totalUsers');
      
      if (totalDiscussionsEl) totalDiscussionsEl.textContent = stats.total_discussions;
      if (totalRepliesEl) totalRepliesEl.textContent = stats.total_replies;
      if (totalUsersEl) totalUsersEl.textContent = stats.total_users;
      
      // Update latest posts
      const latestPostsEl = document.getElementById('latestPosts');
      if (latestPostsEl && stats.latest_posts) {
        latestPostsEl.innerHTML = stats.latest_posts.map(post => `
          <li><a href="#" class="sidebar-link">${escapeHtml(post.title)}</a></li>
        `).join('');
      }
    }
  } catch (err) {
    console.error('Error fetching stats:', err);
  }
}

// -------------------
// Character counters for forms
// -------------------
function setupCharacterCounters() {
  // New thread form counters
  const titleInput = document.querySelector('.title-input');
  const contentTextarea = document.querySelector('.content-textarea');
  const replyTextareas = document.querySelectorAll('.reply-textarea');

  if (titleInput) {
    const titleCounter = titleInput.parentElement.querySelector('.char-count');
    titleInput.addEventListener('input', () => {
      titleCounter.textContent = `${titleInput.value.length}/200`;
    });
    // Initialize counter
    titleCounter.textContent = `${titleInput.value.length}/200`;
  }

  if (contentTextarea) {
    const contentCounter = contentTextarea.parentElement.querySelector('.char-count');
    contentTextarea.addEventListener('input', () => {
      contentCounter.textContent = `${contentTextarea.value.length}/2000`;
    });
    // Initialize counter
    contentCounter.textContent = `${contentTextarea.value.length}/2000`;
  }

  replyTextareas.forEach(textarea => {
    const counter = textarea.parentElement.querySelector('.char-count');
    textarea.addEventListener('input', () => {
      counter.textContent = `${textarea.value.length}/1000`;
    });
    // Initialize counter
    counter.textContent = `${textarea.value.length}/1000`;
  });
}

// -------------------
// Add new discussion
// -------------------
const newThreadForm = document.getElementById('newThreadForm');
if (newThreadForm) {
  newThreadForm.addEventListener('submit', async e => {
    e.preventDefault();
    
    const title = newThreadForm.querySelector('input[name="title"]').value.trim();
    const category = newThreadForm.querySelector('select[name="category"]').value;
    const content = newThreadForm.querySelector('textarea[name="content"]').value.trim();
    
    if (!title || !category || !content) {
      showFlash('Please fill in all fields', 'error');
      return;
    }

    try {
      const submitBtn = newThreadForm.querySelector('.submit-btn');
      const originalText = submitBtn.innerHTML;
      submitBtn.innerHTML = '<i class="bi bi-arrow-repeat spin"></i> Posting...';
      submitBtn.disabled = true;

      const res = await fetch('/api/discussions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, category, content })
      });
      
      const data = await res.json();
      
      if (data.success) {
        showFlash(data.message || "Discussion posted successfully!", "success");
        newThreadForm.reset();
        setupCharacterCounters(); // Reset counters
        await fetchDiscussions();
      } else {
        showFlash(data.message || 'Error posting discussion', 'error');
      }
    } catch (err) {
      console.error(err);
      showFlash('Error posting discussion', 'error');
    } finally {
      const submitBtn = newThreadForm.querySelector('.submit-btn');
      submitBtn.innerHTML = '<i class="bi bi-send-fill"></i> Post Discussion';
      submitBtn.disabled = false;
    }
  });
}

// -------------------
// Render discussions
// -------------------
function renderDiscussions() {
  const threadsContainer = document.getElementById('threadsContainer');
  if (!threadsContainer) return;

  if (discussions.length === 0) {
    threadsContainer.innerHTML = `
      <div class="no-threads">
        <i class="bi bi-chat-square"></i>
        <h3>No discussions found</h3>
        <p>Try adjusting your search or start a new discussion!</p>
      </div>
    `;
    return;
  }

  threadsContainer.innerHTML = discussions.map(d => `
    <div class="thread" data-id="${d.id}" data-category="${d.category}">
      <div class="thread-header">
        <h3 class="thread-title">${escapeHtml(d.title)}</h3>
        <span class="thread-category">${d.category}</span>
      </div>
      
      <div class="thread-content">
        <div class="author-avatar">
          <i class="bi bi-person-circle"></i>
        </div>
        <div class="content-main">
          <p class="thread-text">${escapeHtml(d.content)}</p>
          <div class="thread-meta">
            <span class="author"><strong>${d.author}</strong></span>
            <span class="post-time">
              <i class="bi bi-clock"></i> ${d.created_at}
            </span>
            ${d.updated_at ? `
            <span class="edited-info">
              | <i class="bi bi-pencil"></i> Edited by: ${d.edited_by || 'Admin'}
            </span>
            ` : ''}
          </div>
        </div>
      </div>

      <div class="thread-actions">
        ${d.is_author || d.is_admin ? `
        <button class="btn btn-edit edit-btn" data-id="${d.id}" 
                data-title="${escapeHtml(d.title)}" data-content="${escapeHtml(d.content)}">
          <i class="bi bi-pencil"></i> Edit
        </button>
        <button class="btn btn-delete delete-btn" data-id="${d.id}">
          <i class="bi bi-trash"></i> Delete
        </button>
        ` : ''}
        <button class="btn btn-reply reply-btn" data-id="${d.id}">
          <i class="bi bi-reply"></i> Reply (${d.reply_count || d.replies.length})
        </button>
      </div>

      <div class="replies">
        ${(d.replies || []).map(r => `
        <div class="reply" data-id="${r.id}">
          <div class="reply-content">
            <div class="reply-author-avatar">
              <i class="bi bi-person-circle"></i>
            </div>
            <div class="reply-main">
              <p class="reply-text">
                <strong>${r.author}:</strong> ${escapeHtml(r.content)}
              </p>
              <div class="reply-meta">
                <span class="reply-time">
                  <i class="bi bi-clock"></i> ${r.created_at}
                </span>
                ${r.updated_at ? `
                <span class="edited-info">
                  | <i class="bi bi-pencil"></i> Edited by: ${r.edited_by || 'Admin'}
                </span>
                ` : ''}
              </div>
            </div>
          </div>
          
          ${r.is_author || r.is_admin ? `
          <div class="reply-actions">
            <button class="btn btn-sm btn-edit edit-reply-btn" 
                    data-id="${r.id}" 
                    data-content="${escapeHtml(r.content)}">
              <i class="bi bi-pencil"></i>
            </button>
            <button class="btn btn-sm btn-delete delete-reply-btn" 
                    data-id="${r.id}">
              <i class="bi bi-trash"></i>
            </button>
          </div>
          ` : ''}
        </div>
        `).join('')}
      </div>

      <div class="reply-form-container" id="replyForm-${d.id}" style="display: none;">
        <form class="reply-form" data-thread="${d.id}">
          <div class="form-group">
            <textarea placeholder="Write your reply..." name="content" required 
                    rows="3" maxlength="1000" class="reply-textarea"></textarea>
            <span class="char-count">0/1000</span>
          </div>
          <div class="form-actions">
            <button type="button" class="btn btn-cancel cancel-reply">Cancel</button>
            <button type="submit" class="btn btn-primary">
              <i class="bi bi-send"></i> Post Reply
            </button>
          </div>
        </form>
      </div>
    </div>
  `).join('');
  
  setupCharacterCounters();
}

// -------------------
// Event Listeners for Thread Actions
// -------------------
document.addEventListener('click', async e => {
  // Delete Discussion
  if (e.target.classList.contains('delete-btn') || e.target.closest('.delete-btn')) {
    const btn = e.target.classList.contains('delete-btn') ? e.target : e.target.closest('.delete-btn');
    const threadId = btn.dataset.id;
    
    if (confirm('Are you sure you want to delete this discussion? This action cannot be undone.')) {
      try {
        const res = await fetch(`/api/discussions/${threadId}`, { 
          method: 'DELETE' 
        });
        const data = await res.json();
        if (data.success) {
          showFlash(data.message || 'Discussion deleted successfully!', 'success');
          await fetchDiscussions();
        } else {
          showFlash(data.message || 'Error deleting discussion', 'error');
        }
      } catch (err) { 
        console.error(err); 
        showFlash('Error deleting discussion', 'error'); 
      }
    }
  }

  // Edit Discussion
  if (e.target.classList.contains('edit-btn') || e.target.closest('.edit-btn')) {
    const btn = e.target.classList.contains('edit-btn') ? e.target : e.target.closest('.edit-btn');
    const threadId = btn.dataset.id;
    const title = btn.dataset.title;
    const content = btn.dataset.content;

    const { overlay, modal } = createEditModal(title, content, false);

    modal.querySelector('.btn-cancel').addEventListener('click', () => {
      overlay.remove();
      modal.remove();
    });

    modal.querySelector('.btn-update').addEventListener('click', async () => {
      const newTitle = modal.querySelector('input').value.trim();
      const newContent = modal.querySelector('textarea').value.trim();
      
      if (!newTitle || !newContent) {
        showFlash('Title and content cannot be empty', 'error');
        return;
      }

      try {
        const res = await fetch(`/api/discussions/${threadId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ 
            title: newTitle, 
            content: newContent
          })
        });
        const data = await res.json();
        if (data.success) {
          showFlash(data.message || 'Discussion updated successfully!', 'success');
          overlay.remove();
          modal.remove();
          await fetchDiscussions();
        } else {
          showFlash(data.message || 'Error updating discussion', 'error');
        }
      } catch (err) { 
        console.error(err); 
        showFlash('Error updating discussion', 'error'); 
      }
    });
  }

  // Reply Button
  if (e.target.classList.contains('reply-btn') || e.target.closest('.reply-btn')) {
    const btn = e.target.classList.contains('reply-btn') ? e.target : e.target.closest('.reply-btn');
    const threadId = btn.dataset.id;
    const replyForm = document.getElementById(`replyForm-${threadId}`);
    
    if (replyForm) {
      // Hide all other reply forms
      document.querySelectorAll('.reply-form-container').forEach(form => {
        if (form.id !== `replyForm-${threadId}`) {
          form.style.display = 'none';
        }
      });
      
      // Toggle current form
      replyForm.style.display = replyForm.style.display === 'none' ? 'block' : 'none';
    }
  }

  // Cancel Reply
  if (e.target.classList.contains('cancel-reply') || e.target.closest('.cancel-reply')) {
    const btn = e.target.classList.contains('cancel-reply') ? e.target : e.target.closest('.cancel-reply');
    const form = btn.closest('.reply-form-container');
    form.style.display = 'none';
    form.querySelector('textarea').value = '';
    setupCharacterCounters();
  }

  // Edit Reply
  if (e.target.classList.contains('edit-reply-btn') || e.target.closest('.edit-reply-btn')) {
    const btn = e.target.classList.contains('edit-reply-btn') ? e.target : e.target.closest('.edit-reply-btn');
    const replyId = btn.dataset.id;
    const content = btn.dataset.content;
    const threadId = btn.closest('.thread').dataset.id;

    const { overlay, modal } = createEditModal('', content, true);

    modal.querySelector('.btn-cancel').addEventListener('click', () => {
      overlay.remove();
      modal.remove();
    });

    modal.querySelector('.btn-update').addEventListener('click', async () => {
      const newContent = modal.querySelector('textarea').value.trim();
      if (!newContent) {
        showFlash('Reply cannot be empty', 'error');
        return;
      }

      try {
        const res = await fetch(`/api/discussions/${threadId}/reply/${replyId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ content: newContent })
        });
        const data = await res.json();
        if (data.success) {
          showFlash(data.message || 'Reply updated successfully!', 'success');
          overlay.remove();
          modal.remove();
          await fetchDiscussions();
        } else {
          showFlash(data.message || 'Error updating reply', 'error');
        }
      } catch (err) { 
        console.error(err); 
        showFlash('Error updating reply', 'error'); 
      }
    });
  }

  // Delete Reply
  if (e.target.classList.contains('delete-reply-btn') || e.target.closest('.delete-reply-btn')) {
    const btn = e.target.classList.contains('delete-reply-btn') ? e.target : e.target.closest('.delete-reply-btn');
    const replyId = btn.dataset.id;
    const threadId = btn.closest('.thread').dataset.id;
    
    if (confirm('Are you sure you want to delete this reply?')) {
      try {
        const res = await fetch(`/api/discussions/${threadId}/reply/${replyId}`, { 
          method: 'DELETE' 
        });
        const data = await res.json();
        if (data.success) {
          showFlash(data.message || 'Reply deleted successfully!', 'success');
          await fetchDiscussions();
        } else {
          showFlash(data.message || 'Error deleting reply', 'error');
        }
      } catch (err) { 
        console.error(err); 
        showFlash('Error deleting reply', 'error'); 
      }
    }
  }

  // Sort buttons
  if (e.target.classList.contains('sort-btn')) {
    const sort = e.target.dataset.sort;
    document.querySelectorAll('.sort-btn').forEach(btn => btn.classList.remove('active'));
    e.target.classList.add('active');
    currentSort = sort;
    await fetchDiscussions('', '', sort);
  }

  // Category cards
  if (e.target.closest('.category-card')) {
    const categoryCard = e.target.closest('.category-card');
    const category = categoryCard.dataset.category;
    document.querySelectorAll('.category-card').forEach(card => {
      card.style.borderColor = '#e8f5e9';
    });
    categoryCard.style.borderColor = '#4caf50';
    await fetchDiscussions('', category, currentSort);
  }
});

// -------------------
// Reply Form Submission
// -------------------
document.addEventListener('submit', async e => {
  if (e.target.classList.contains('reply-form')) {
    e.preventDefault();
    const threadId = e.target.dataset.thread;
    const textarea = e.target.querySelector('.reply-textarea');
    const content = textarea.value.trim();
    
    if (!content) {
      showFlash('Reply cannot be empty', 'error');
      return;
    }

    try {
      const submitBtn = e.target.querySelector('button[type="submit"]');
      const originalText = submitBtn.innerHTML;
      submitBtn.innerHTML = '<i class="bi bi-arrow-repeat spin"></i> Posting...';
      submitBtn.disabled = true;

      const res = await fetch(`/api/discussions/${threadId}/reply`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content })
      });
      
      const data = await res.json();
      
      if (data.success) {
        showFlash(data.message || 'Reply posted successfully!', 'success');
        e.target.reset();
        e.target.closest('.reply-form-container').style.display = 'none';
        setupCharacterCounters();
        await fetchDiscussions();
      } else {
        showFlash(data.message || 'Error posting reply', 'error');
      }
    } catch (err) {
      console.error(err);
      showFlash('Error posting reply', 'error');
    } finally {
      const submitBtn = e.target.querySelector('button[type="submit"]');
      submitBtn.innerHTML = '<i class="bi bi-send"></i> Post Reply';
      submitBtn.disabled = false;
    }
  }
});

// -------------------
// Search functionality
// -------------------
const searchForm = document.getElementById('searchForm');
if (searchForm) {
  const searchInput = searchForm.querySelector('input[name="search"]');
  const debouncedSearch = debounce(async (query) => {
    await fetchDiscussions(query, '', currentSort);
  }, 500);

  searchInput.addEventListener('input', (e) => {
    debouncedSearch(e.target.value.trim());
  });

  searchForm.addEventListener('submit', async e => {
    e.preventDefault();
    const searchQuery = searchInput.value.trim();
    await fetchDiscussions(searchQuery, '', currentSort);
  });
}

// -------------------
// Refresh functionality
// -------------------
const refreshBtn = document.getElementById('refreshThreads');
if (refreshBtn) {
  refreshBtn.addEventListener('click', async () => {
    refreshBtn.classList.add('spin');
    await fetchDiscussions();
    setTimeout(() => refreshBtn.classList.remove('spin'), 500);
  });
}

// -------------------
// Utility function to escape HTML
// -------------------
function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// -------------------
// Initialize forum
// -------------------
document.addEventListener('DOMContentLoaded', function() {
  fetchDiscussions();
  setupCharacterCounters();
  
  // Add CSS for spinning animation
  const style = document.createElement('style');
  style.textContent = `
    .spin { animation: spin 0.5s linear infinite; }
    @keyframes spin { 
      from { transform: rotate(0deg); } 
      to { transform: rotate(360deg); } 
    }
    .threads-container {
      min-height: 200px;
    }
  `;
  document.head.appendChild(style);
});

// Wetehr and crop recommendations
// ======= Weather Section JavaScript =======
// ======= Weather & Crop Management System =======

// Weather data and crop recommendations
const weatherData = {
    current: {
        temp: 25,
        condition: 'Sunny',
        location: 'AgroFarm Main Field',
        windSpeed: 15,
        humidity: 65,
        pressure: 1013,
        visibility: 10,
        icon: 'fa-sun'
    },
    forecast: [
        { day: 'Today', temp: 25, condition: 'Sunny', icon: 'fa-sun' },
        { day: 'Tomorrow', temp: 22, condition: 'Partly Cloudy', icon: 'fa-cloud-sun' },
        { day: 'Wed', temp: 20, condition: 'Rainy', icon: 'fa-cloud-rain' },
        { day: 'Thu', temp: 23, condition: 'Cloudy', icon: 'fa-cloud' },
        { day: 'Fri', temp: 26, condition: 'Sunny', icon: 'fa-sun' }
    ]
};

const cropDatabase = {
    'Sunny': [
        { name: 'Tomatoes', icon: 'fa-apple-alt', temp: '20-30°C', duration: '75-90 days', status: 'optimal', type: 'vegetable' },
        { name: 'Peppers', icon: 'fa-pepper-hot', temp: '18-27°C', duration: '60-90 days', status: 'optimal', type: 'vegetable' },
        { name: 'Corn', icon: 'fa-seedling', temp: '21-30°C', duration: '60-100 days', status: 'good', type: 'grain' },
        { name: 'Cucumbers', icon: 'fa-leaf', temp: '18-27°C', duration: '50-70 days', status: 'optimal', type: 'vegetable' },
        { name: 'Watermelon', icon: 'fa-water', temp: '22-30°C', duration: '70-85 days', status: 'good', type: 'fruit' },
        { name: 'Strawberries', icon: 'fa-apple-alt', temp: '15-25°C', duration: '60-90 days', status: 'optimal', type: 'fruit' }
    ],
    'Rainy': [
        { name: 'Rice', icon: 'fa-tint', temp: '20-35°C', duration: '90-120 days', status: 'optimal', type: 'grain' },
        { name: 'Spinach', icon: 'fa-leaf', temp: '15-20°C', duration: '40-50 days', status: 'good', type: 'vegetable' },
        { name: 'Broccoli', icon: 'fa-tree', temp: '18-23°C', duration: '60-90 days', status: 'optimal', type: 'vegetable' },
        { name: 'Cabbage', icon: 'fa-seedling', temp: '15-20°C', duration: '80-180 days', status: 'moderate', type: 'vegetable' }
    ],
    'Cloudy': [
        { name: 'Lettuce', icon: 'fa-leaf', temp: '15-20°C', duration: '45-55 days', status: 'optimal', type: 'vegetable' },
        { name: 'Carrots', icon: 'fa-carrot', temp: '15-20°C', duration: '70-80 days', status: 'good', type: 'vegetable' },
        { name: 'Cauliflower', icon: 'fa-seedling', temp: '15-20°C', duration: '55-100 days', status: 'moderate', type: 'vegetable' },
        { name: 'Kale', icon: 'fa-leaf', temp: '13-24°C', duration: '55-75 days', status: 'good', type: 'vegetable' }
    ],
    'Partly Cloudy': [
        { name: 'Beans', icon: 'fa-seedling', temp: '18-27°C', duration: '50-60 days', status: 'optimal', type: 'vegetable' },
        { name: 'Peas', icon: 'fa-seedling', temp: '13-18°C', duration: '60-70 days', status: 'good', type: 'vegetable' },
        { name: 'Potatoes', icon: 'fa-seedling', temp: '15-20°C', duration: '70-120 days', status: 'moderate', type: 'vegetable' }
    ]
};

// Current farm crops storage
let farmCrops = JSON.parse(localStorage.getItem('farmCrops')) || [];

// Initialize weather section when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Check if weather section exists on the page
    if (document.getElementById('weather-forecast')) {
        updateWeatherDisplay();
        updateCropRecommendations();
        updateCurrentCropsDisplay();
        startLiveUpdates();
        
        // Add event listeners for modal close buttons
        document.querySelectorAll('.close').forEach(closeBtn => {
            closeBtn.addEventListener('click', closeModal);
        });
    }
});

// Update weather display
function updateWeatherDisplay() {
    const current = weatherData.current;
    
    // Update current weather
    document.getElementById('current-temp').textContent = `${current.temp}°C`;
    document.getElementById('current-condition').textContent = current.condition;
    document.getElementById('current-location').textContent = current.location;
    document.getElementById('current-weather-icon').className = `fas ${current.icon}`;
    document.getElementById('wind-speed').textContent = `${current.windSpeed} km/h`;
    document.getElementById('humidity').textContent = `${current.humidity}%`;
    document.getElementById('pressure').textContent = `${current.pressure} hPa`;
    document.getElementById('visibility').textContent = `${current.visibility} km`;

    // Update forecast
    const forecastContainer = document.getElementById('forecast-container');
    forecastContainer.innerHTML = '';
    
    weatherData.forecast.forEach(day => {
        const forecastCard = document.createElement('div');
        forecastCard.className = 'forecast-card';
        forecastCard.innerHTML = `
            <div class="forecast-day">${day.day}</div>
            <div class="forecast-icon"><i class="fas ${day.icon}"></i></div>
            <div class="forecast-temp">${day.temp}°C</div>
            <div class="forecast-condition">${day.condition}</div>
        `;
        forecastContainer.appendChild(forecastCard);
    });
}

// Update current crops display
function updateCurrentCropsDisplay() {
    const container = document.getElementById('current-crops-container');
    const totalCrops = document.getElementById('total-crops');
    const readyCrops = document.getElementById('ready-crops');
    const growthProgress = document.getElementById('growth-progress');
    
    // Update stats
    totalCrops.textContent = farmCrops.length;
    const readyCount = farmCrops.filter(crop => crop.progress >= 100).length;
    readyCrops.textContent = readyCount;
    
    // Calculate average growth progress
    const avgProgress = farmCrops.length > 0 
        ? Math.round(farmCrops.reduce((sum, crop) => sum + crop.progress, 0) / farmCrops.length)
        : 0;
    growthProgress.textContent = `${avgProgress}%`;
    
    // Update crops display
    if (farmCrops.length === 0) {
        container.innerHTML = `
            <div class="no-crops-message">
                <i class="fas fa-seedling"></i>
                <p>No crops planted yet. Add some crops to get started!</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = '';
    
    farmCrops.forEach((crop, index) => {
        const isReady = crop.progress >= 100;
        const daysRemaining = Math.max(0, crop.totalDays - crop.currentDay);
        const progressPercent = Math.min(100, (crop.currentDay / crop.totalDays) * 100);
        
        const cropCard = document.createElement('div');
        cropCard.className = `current-crop-card ${isReady ? 'ready' : 'growing'}`;
        cropCard.innerHTML = `
            <div class="crop-header">
                <div class="crop-title">
                    <i class="fas ${crop.icon}"></i>
                    <div>
                        <div class="crop-name">${crop.name}</div>
                        <div class="crop-type">${crop.type}</div>
                    </div>
                </div>
            </div>
            
            <div class="crop-progress">
                <div class="progress-info">
                    <span>Growth Progress</span>
                    <span>${Math.round(progressPercent)}%</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${progressPercent}%"></div>
                </div>
                <div class="crop-days">
                    <span>Day ${crop.currentDay} of ${crop.totalDays}</span>
                    <span>${daysRemaining} days left</span>
                </div>
            </div>
            
            <div class="crop-actions">
                <button class="crop-btn view" onclick="viewCropDetails(${index})">
                    <i class="fas fa-info-circle"></i> Details
                </button>
                ${isReady ? `
                    <button class="crop-btn harvest" onclick="harvestSingleCrop(${index})">
                        <i class="fas fa-harvest"></i> Harvest
                    </button>
                ` : `
                    <button class="crop-btn remove" onclick="removeCrop(${index})">
                        <i class="fas fa-trash"></i> Remove
                    </button>
                `}
            </div>
        `;
        container.appendChild(cropCard);
    });
}

// Update crop recommendations based on current weather
function updateCropRecommendations() {
    const cropsContainer = document.getElementById('crops-container');
    cropsContainer.innerHTML = '';
    
    const currentCondition = weatherData.current.condition;
    const recommendedCrops = cropDatabase[currentCondition] || cropDatabase['Sunny'];
    
    recommendedCrops.forEach((crop, index) => {
        const cropCard = document.createElement('div');
        cropCard.className = 'crop-card';
        cropCard.innerHTML = `
            <div class="crop-icon"><i class="fas ${crop.icon}"></i></div>
            <div class="crop-name">${crop.name}</div>
            <div class="crop-details">Optimal Temperature: ${crop.temp}</div>
            <div class="crop-details">Growth Duration: ${crop.duration}</div>
            <div class="crop-details">Type: ${crop.type.charAt(0).toUpperCase() + crop.type.slice(1)}</div>
            <div class="crop-status status-${crop.status}">
                ${crop.status.charAt(0).toUpperCase() + crop.status.slice(1)} Conditions
            </div>
        `;
        cropsContainer.appendChild(cropCard);
    });
}

// Simulate live weather updates
function startLiveUpdates() {
    setInterval(() => {
        // Simulate small temperature changes
        const tempChange = (Math.random() - 0.5) * 2;
        weatherData.current.temp = Math.round((weatherData.current.temp + tempChange) * 10) / 10;
        
        // Simulate occasional weather changes (5% chance)
        if (Math.random() < 0.05) {
            const conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy'];
            const newCondition = conditions[Math.floor(Math.random() * conditions.length)];
            weatherData.current.condition = newCondition;
            
            // Update icon based on condition
            const iconMap = {
                'Sunny': 'fa-sun',
                'Partly Cloudy': 'fa-cloud-sun',
                'Cloudy': 'fa-cloud',
                'Rainy': 'fa-cloud-rain'
            };
            weatherData.current.icon = iconMap[newCondition];
            
            updateCropRecommendations();
        }
        
        // Update crop progress
        updateCropProgress();
        
        updateWeatherDisplay();
    }, 30000); // Update every 30 seconds
}

// Update crop progress
function updateCropProgress() {
    let needsUpdate = false;
    
    farmCrops.forEach(crop => {
        if (crop.progress < 100) {
            // Simulate growth (1-3% per update)
            const growth = 1 + Math.random() * 2;
            crop.progress = Math.min(100, crop.progress + growth);
            crop.currentDay = Math.min(crop.totalDays, Math.floor((crop.progress / 100) * crop.totalDays));
            needsUpdate = true;
        }
    });
    
    if (needsUpdate) {
        saveCropsToStorage();
        updateCurrentCropsDisplay();
    }
}

// Refresh weather manually
function refreshWeather() {
    const refreshBtn = event.target;
    const originalText = refreshBtn.innerHTML;
    
    // Show loading state
    refreshBtn.innerHTML = '<span class="loading"></span> Refreshing...';
    refreshBtn.disabled = true;
    
    // Simulate API call delay
    setTimeout(() => {
        // Simulate weather data update
        weatherData.current.temp = Math.round((20 + Math.random() * 10) * 10) / 10;
        
        const conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy'];
        const newCondition = conditions[Math.floor(Math.random() * conditions.length)];
        weatherData.current.condition = newCondition;
        
        const iconMap = {
            'Sunny': 'fa-sun',
            'Partly Cloudy': 'fa-cloud-sun',
            'Cloudy': 'fa-cloud',
            'Rainy': 'fa-cloud-rain'
        };
        weatherData.current.icon = iconMap[newCondition];
        
        updateWeatherDisplay();
        updateCropRecommendations();
        
        // Restore button
        refreshBtn.innerHTML = originalText;
        refreshBtn.disabled = false;
        
        // Show success message
        showNotification('Weather data updated successfully!', 'success');
    }, 1500);
}

// Add crops function
function addCrops() {
    const modal = document.getElementById('addCropsModal');
    const cropSelection = document.getElementById('crop-selection');
    
    const currentCondition = weatherData.current.condition;
    const recommendedCrops = cropDatabase[currentCondition] || cropDatabase['Sunny'];
    
    cropSelection.innerHTML = '';
    recommendedCrops.forEach((crop, index) => {
        const cropOption = document.createElement('div');
        cropOption.className = 'crop-option';
        cropOption.innerHTML = `
            <input type="checkbox" id="crop-${index}" name="crops" value="${crop.name}" data-crop='${JSON.stringify(crop)}'>
            <label for="crop-${index}">
                <i class="fas ${crop.icon}"></i> 
                <span>${crop.name} - ${crop.temp} (${crop.duration}) - ${crop.type}</span>
            </label>
        `;
        cropSelection.appendChild(cropOption);
    });
    
    modal.style.display = 'block';
}

// Confirm add crops
function confirmAddCrops() {
    const selectedCrops = [];
    document.querySelectorAll('input[name="crops"]:checked').forEach(checkbox => {
        const cropData = JSON.parse(checkbox.dataset.crop);
        selectedCrops.push(cropData);
    });
    
    if (selectedCrops.length === 0) {
        showNotification('Please select at least one crop to add.', 'error');
        return;
    }
    
    const addBtn = document.querySelector('#addCropsModal .btn-primary');
    const originalText = addBtn.innerHTML;
    
    // Show loading state
    addBtn.innerHTML = '<span class="loading"></span> Adding...';
    addBtn.disabled = true;
    
    // Simulate API call
    setTimeout(() => {
        selectedCrops.forEach(crop => {
            const totalDays = parseInt(crop.duration);
            const newCrop = {
                id: Date.now() + Math.random(),
                name: crop.name,
                icon: crop.icon,
                type: crop.type,
                temp: crop.temp,
                duration: crop.duration,
                totalDays: totalDays,
                currentDay: 0,
                progress: 0,
                plantedDate: new Date().toISOString(),
                status: 'growing'
            };
            farmCrops.push(newCrop);
        });
        
        saveCropsToStorage();
        updateCurrentCropsDisplay();
        closeModal();
        
        // Restore button
        addBtn.innerHTML = originalText;
        addBtn.disabled = false;
        
        showNotification(`Successfully added ${selectedCrops.length} crops to your farm!`, 'success');
    }, 1000);
}

// Harvest crops function
function harvestCrops() {
    const readyCrops = farmCrops.filter(crop => crop.progress >= 100);
    
    if (readyCrops.length === 0) {
        showNotification('No crops are ready for harvest yet!', 'error');
        return;
    }
    
    const modal = document.getElementById('harvestModal');
    const message = document.getElementById('harvest-message');
    message.textContent = `Are you sure you want to harvest ${readyCrops.length} ready crops?`;
    modal.style.display = 'block';
}

// Confirm harvest
function confirmHarvest() {
    const harvestBtn = document.querySelector('#harvestModal .btn-success');
    const originalText = harvestBtn.innerHTML;
    
    // Show loading state
    harvestBtn.innerHTML = '<span class="loading"></span> Harvesting...';
    harvestBtn.disabled = true;
    
    // Simulate API call
    setTimeout(() => {
        const harvestedCrops = farmCrops.filter(crop => crop.progress >= 100);
        farmCrops = farmCrops.filter(crop => crop.progress < 100);
        
        saveCropsToStorage();
        updateCurrentCropsDisplay();
        closeModal();
        
        // Restore button
        harvestBtn.innerHTML = originalText;
        harvestBtn.disabled = false;
        
        showNotification(`Harvested ${harvestedCrops.length} crops successfully!`, 'success');
    }, 1500);
}

// Harvest single crop
function harvestSingleCrop(index) {
    const crop = farmCrops[index];
    
    farmCrops.splice(index, 1);
    saveCropsToStorage();
    updateCurrentCropsDisplay();
    
    showNotification(`Harvested ${crop.name} successfully!`, 'success');
}

// Remove crop
function removeCrop(index) {
    const crop = farmCrops[index];
    
    if (confirm(`Are you sure you want to remove ${crop.name} from your farm?`)) {
        farmCrops.splice(index, 1);
        saveCropsToStorage();
        updateCurrentCropsDisplay();
        
        showNotification(`Removed ${crop.name} from your farm.`, 'success');
    }
}

// View crop details
function viewCropDetails(index) {
    const crop = farmCrops[index];
    const modal = document.getElementById('cropDetailsModal');
    const content = document.getElementById('crop-details-content');
    
    const daysRemaining = Math.max(0, crop.totalDays - crop.currentDay);
    const progressPercent = Math.min(100, (crop.currentDay / crop.totalDays) * 100);
    
    content.innerHTML = `
        <div class="crop-details-content">
            <div style="text-align: center; margin-bottom: 1.5rem;">
                <i class="fas ${crop.icon}" style="font-size: 3rem; color: #4CAF50;"></i>
                <h4 style="margin: 0.5rem 0; color: #2d5016;">${crop.name}</h4>
                <div class="crop-type" style="display: inline-block;">${crop.type}</div>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Planted On:</span>
                <span class="detail-value">${new Date(crop.plantedDate).toLocaleDateString()}</span>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Optimal Temperature:</span>
                <span class="detail-value">${crop.temp}</span>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Total Duration:</span>
                <span class="detail-value">${crop.duration}</span>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Current Progress:</span>
                <span class="detail-value">${Math.round(progressPercent)}%</span>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Days Completed:</span>
                <span class="detail-value">${crop.currentDay} of ${crop.totalDays}</span>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Days Remaining:</span>
                <span class="detail-value">${daysRemaining} days</span>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value" style="color: ${crop.progress >= 100 ? '#4CAF50' : '#FFA000'}">
                    ${crop.progress >= 100 ? 'Ready for Harvest' : 'Growing'}
                </span>
            </div>
            
            <div style="margin-top: 1.5rem; padding: 1rem; background: #f8fff8; border-radius: 8px;">
                <strong>Growth Progress:</strong>
                <div class="progress-bar" style="margin-top: 0.5rem;">
                    <div class="progress-fill" style="width: ${progressPercent}%"></div>
                </div>
                <div style="display: flex; justify-content: space-between; margin-top: 0.5rem; font-size: 0.9rem; color: #666;">
                    <span>Day ${crop.currentDay}</span>
                    <span>Day ${crop.totalDays}</span>
                </div>
            </div>
        </div>
    `;
    
    modal.style.display = 'block';
}

// Close modal
function closeModal() {
    document.querySelectorAll('.modal').forEach(modal => {
        modal.style.display = 'none';
    });
}

// Save crops to localStorage
function saveCropsToStorage() {
    localStorage.setItem('farmCrops', JSON.stringify(farmCrops));
}

// Show notification
function showNotification(message, type) {
    // Remove existing notification
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i>
            <span>${message}</span>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        notification.remove();
    }, 5000);
}

// Close modal when clicking outside
window.addEventListener('click', function(event) {
    document.querySelectorAll('.modal').forEach(modal => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
});
// Store
// Agriculture Marketplace - Complete JavaScript
class AgricultureMarketplace {
    constructor() {
        this.currentUserRole = 'user'; // 'admin', 'user', 'seller'
        this.products = [];
        this.categories = [];
        this.farmers = [];
        this.orders = [];
        this.customers = [];
        this.cart = [];
        this.sellers = [];
        this.pendingSellers = [];
        this.currentEditingId = null;
        this.isSellerApproved = false;
        this.currentUser = null;
        
        this.init();
    }

    async init() {
        await this.checkUserStatus();
        this.loadSampleData();
        this.initializeEventListeners();
        this.updateUI();
        this.showNotification('Marketplace initialized successfully!', 'success');
    }

    // Check user status and role
    async checkUserStatus() {
        try {
            const userResponse = await fetch('/api/user/status', { 
                credentials: 'same-origin' 
            });
            
            if (userResponse.ok) {
                const userData = await userResponse.json();
                this.currentUser = userData;
                this.currentUserRole = userData.is_admin ? 'admin' : 'user';
                this.isSellerApproved = userData.is_seller || false;
                
                await this.checkSellerStatus();
            } else {
                this.currentUserRole = 'user';
                console.log('Using default user role');
            }
        } catch (error) {
            console.log('User status check failed:', error);
            this.currentUserRole = 'user';
        }
    }

    // Check seller application status
    async checkSellerStatus() {
        try {
            const response = await fetch('/api/marketplace/seller/status', {
                credentials: 'same-origin'
            });
            
            if (response.ok) {
                const data = await response.json();
                if (data.has_pending_application) {
                    this.showNotification('Your seller application is pending approval', 'info');
                }
                this.isSellerApproved = data.is_approved || false;
            }
        } catch (error) {
            console.log('Seller status check failed:', error);
        }
    }

    // Sample Data
    loadSampleData() {
        // Categories
        this.categories = [
            { id: 1, name: 'Vegetables', description: 'Fresh organic vegetables', image: '', product_count: 3 },
            { id: 2, name: 'Fruits', description: 'Seasonal fresh fruits', image: '', product_count: 2 },
            { id: 3, name: 'Grains', description: 'Organic grains and cereals', image: '', product_count: 1 },
            { id: 4, name: 'Dairy', description: 'Fresh dairy products', image: '', product_count: 0 },
            { id: 5, name: 'Poultry', description: 'Farm fresh poultry', image: '', product_count: 0 }
        ];

        // Products
        this.products = [
            {
                id: 1,
                name: 'Organic Tomatoes',
                description: 'Fresh organic tomatoes from local farms, rich in flavor and nutrients.',
                price: 2.99,
                category: 'Vegetables',
                category_id: 1,
                stock: 50,
                image: '',
                status: 'active',
                farmer: 'Green Valley Farms',
                farmer_id: 1,
                rating: 4.5,
                reviews: 23,
                created_at: new Date().toISOString()
            },
            {
                id: 2,
                name: 'Fresh Apples',
                description: 'Sweet red apples, perfect for snacks and baking.',
                price: 1.99,
                category: 'Fruits',
                category_id: 2,
                stock: 30,
                image: '',
                status: 'active',
                farmer: 'Sunrise Orchards',
                farmer_id: 2,
                rating: 4.2,
                reviews: 15,
                created_at: new Date().toISOString()
            },
            {
                id: 3,
                name: 'Wheat Grains',
                description: 'Premium quality wheat grains for healthy meals.',
                price: 4.99,
                category: 'Grains',
                category_id: 3,
                stock: 20,
                image: '',
                status: 'active',
                farmer: 'Golden Fields',
                farmer_id: 3,
                rating: 4.7,
                reviews: 8,
                created_at: new Date().toISOString()
            },
            {
                id: 4,
                name: 'Carrots',
                description: 'Fresh crunchy carrots, rich in vitamins.',
                price: 1.49,
                category: 'Vegetables',
                category_id: 1,
                stock: 40,
                image: '',
                status: 'active',
                farmer: 'Green Valley Farms',
                farmer_id: 1,
                rating: 4.3,
                reviews: 12,
                created_at: new Date().toISOString()
            },
            {
                id: 5,
                name: 'Bananas',
                description: 'Sweet ripe bananas, perfect for smoothies.',
                price: 0.99,
                category: 'Fruits',
                category_id: 2,
                stock: 60,
                image: '',
                status: 'active',
                farmer: 'Tropical Delights',
                farmer_id: 4,
                rating: 4.1,
                reviews: 18,
                created_at: new Date().toISOString()
            }
        ];

        // Farmers/Sellers
        this.farmers = [
            {
                id: 1,
                name: 'Green Valley Farms',
                phone: '+1-555-0101',
                address: '123 Farm Road, Countryside, CA 90210',
                work: 'Vegetable Farming',
                email: 'contact@greenvalleyfarms.com',
                status: 'active',
                product_count: 2,
                joined_at: new Date('2023-01-15').toISOString()
            },
            {
                id: 2,
                name: 'Sunrise Orchards',
                phone: '+1-555-0102',
                address: '456 Orchard Lane, Green Valley, CA 90211',
                work: 'Fruit Farming',
                email: 'info@sunriseorchards.com',
                status: 'active',
                product_count: 1,
                joined_at: new Date('2023-02-20').toISOString()
            },
            {
                id: 3,
                name: 'Golden Fields',
                phone: '+1-555-0103',
                address: '789 Grain Street, Wheatland, CA 90212',
                work: 'Grain Farming',
                email: 'hello@goldenfields.com',
                status: 'active',
                product_count: 1,
                joined_at: new Date('2023-03-10').toISOString()
            }
        ];

        // Orders
        this.orders = [
            {
                id: 1001,
                order_number: 'ORD001',
                customerName: 'Alice Johnson',
                customerEmail: 'alice@email.com',
                customerPhone: '+1-555-0123',
                products: [
                    { id: 1, name: 'Organic Tomatoes', price: 2.99, quantity: 2 },
                    { id: 4, name: 'Carrots', price: 1.49, quantity: 1 }
                ],
                total: 7.47,
                status: 'pending',
                paymentMethod: 'cod',
                shippingAddress: '789 City Street, Urban City, CA 90213',
                orderDate: new Date().toISOString()
            },
            {
                id: 1002,
                order_number: 'ORD002',
                customerName: 'Bob Smith',
                customerEmail: 'bob@email.com',
                customerPhone: '+1-555-0124',
                products: [
                    { id: 2, name: 'Fresh Apples', price: 1.99, quantity: 3 },
                    { id: 5, name: 'Bananas', price: 0.99, quantity: 2 }
                ],
                total: 7.95,
                status: 'confirmed',
                paymentMethod: 'card',
                shippingAddress: '321 Town Avenue, Small Town, CA 90214',
                orderDate: new Date(Date.now() - 86400000).toISOString()
            }
        ];

        // Customers
        this.customers = [
            {
                id: 1,
                name: 'Alice Johnson',
                email: 'alice@email.com',
                phone: '+1-555-0123',
                orders: 1,
                status: 'active',
                joined_date: new Date('2023-05-01').toISOString()
            },
            {
                id: 2,
                name: 'Bob Smith',
                email: 'bob@email.com',
                phone: '+1-555-0124',
                orders: 1,
                status: 'active',
                joined_date: new Date('2023-05-02').toISOString()
            }
        ];

        // Pending seller applications
        this.pendingSellers = [
            {
                id: 1,
                user_id: 101,
                store_name: 'Fresh Dairy Co.',
                store_category: 'Dairy',
                phone: '+1-555-0201',
                address: '555 Dairy Lane, Milk Town, CA 90215',
                description: 'Fresh dairy products from happy cows',
                applied_at: new Date().toISOString(),
                status: 'pending'
            }
        ];
    }

    // Event Listeners
    initializeEventListeners() {
        // Navigation
        document.querySelectorAll('.sidebar-menu li').forEach(item => {
            item.addEventListener('click', (e) => {
                this.switchSection(e.currentTarget.dataset.section);
            });
        });

        // Search
        document.getElementById('searchBtn').addEventListener('click', () => this.handleSearch());
        document.getElementById('searchInput').addEventListener('input', (e) => {
            if (e.target.value.length > 2 || e.target.value.length === 0) {
                this.handleSearch();
            }
        });

        // Product Management
        document.getElementById('addProductBtn')?.addEventListener('click', () => this.openProductModal());
        document.getElementById('categoryFilter')?.addEventListener('change', () => this.renderProducts());
        document.getElementById('statusFilter')?.addEventListener('change', () => this.renderProducts());

        // Category Management
        document.getElementById('addCategoryBtn')?.addEventListener('click', () => this.openCategoryModal());

        // Farmer Management
        document.getElementById('addFarmerBtn')?.addEventListener('click', () => this.openFarmerModal());

        // Order Management
        document.getElementById('orderStatusFilter')?.addEventListener('change', () => this.renderOrders());

        // Cart
        document.getElementById('cartBtn')?.addEventListener('click', () => this.switchSection('cart'));
        document.getElementById('placeOrderFromCart')?.addEventListener('click', () => this.openOrderModal());

        // Seller Registration
        document.getElementById('becomeSellerBtn')?.addEventListener('click', () => this.openSellerModal());

        // Modals
        document.querySelectorAll('.close-modal, .btn-cancel').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                this.closeAllModals();
            });
        });

        // Forms
        document.getElementById('productForm')?.addEventListener('submit', (e) => this.handleProductSubmit(e));
        document.getElementById('categoryForm')?.addEventListener('submit', (e) => this.handleCategorySubmit(e));
        document.getElementById('farmerForm')?.addEventListener('submit', (e) => this.handleFarmerSubmit(e));
        document.getElementById('orderForm')?.addEventListener('submit', (e) => this.handleOrderSubmit(e));
        document.getElementById('sellerForm')?.addEventListener('submit', (e) => this.handleSellerSubmit(e));

        // User Role Toggle
        document.getElementById('toggleUserRole')?.addEventListener('click', () => this.toggleUserRole());

        // Quick Stats Click
        document.querySelectorAll('.stat-card, .dashboard-card').forEach(card => {
            card.addEventListener('click', (e) => {
                const type = e.currentTarget.dataset.type;
                this.switchSection(type + 's');
            });
        });

        // Close modals on outside click
        document.querySelectorAll('.modal').forEach(modal => {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeAllModals();
                }
            });
        });

        // Logout
        document.getElementById('logoutBtn')?.addEventListener('click', () => this.handleLogout());
    }

    // UI Updates
    updateUI() {
        this.updateStats();
        this.renderProducts();
        this.renderCategories();
        this.renderFarmers();
        this.renderOrders();
        this.renderCustomers();
        this.updateCartUI();
        this.updateRoleBasedUI();
    }

    updateStats() {
        // Update header stats
        document.getElementById('totalProducts').textContent = this.products.length;
        document.getElementById('totalOrders').textContent = this.orders.length;
        document.getElementById('totalFarmers').textContent = this.farmers.length;
        document.getElementById('totalCustomers').textContent = this.customers.length;

        // Update dashboard stats
        document.getElementById('dashProducts').textContent = this.products.length;
        document.getElementById('dashOrders').textContent = this.orders.length;
        document.getElementById('dashFarmers').textContent = this.farmers.length;
        document.getElementById('dashCustomers').textContent = this.customers.length;

        // Update customer count
        document.getElementById('totalCustomersCount').textContent = this.customers.length;
    }

    updateRoleBasedUI() {
        const isAdmin = this.currentUserRole === 'admin';
        const isSeller = this.currentUserRole === 'seller' || this.isSellerApproved;
        
        // Update user info
        document.getElementById('userName').textContent = isAdmin ? 'Admin User' : 
                                                         isSeller ? 'Seller User' : 'Customer User';
        document.getElementById('userRole').textContent = isAdmin ? 'Administrator' : 
                                                          isSeller ? 'Verified Seller' : 'Customer';

        // Show/hide admin-only elements
        const adminElements = ['addCategoryBtn', 'addFarmerBtn', 'customersMenuItem', 
                              'analyticsMenuItem', 'reportsMenuItem', 'settingsMenuItem'];
        
        adminElements.forEach(elementId => {
            const element = document.getElementById(elementId);
            if (element) {
                element.style.display = isAdmin ? 'block' : 'none';
            }
        });

        // Show/hide seller elements
        const addProductBtn = document.getElementById('addProductBtn');
        if (addProductBtn) {
            addProductBtn.style.display = (isAdmin || isSeller) ? 'block' : 'none';
        }

        // Show/hide cart for users
        const cartBtn = document.getElementById('cartBtn');
        const cartMenuItem = document.getElementById('cartMenuItem');
        if (cartBtn && cartMenuItem) {
            cartBtn.style.display = (isAdmin || isSeller) ? 'none' : 'block';
            cartMenuItem.style.display = (isAdmin || isSeller) ? 'none' : 'block';
        }

        // Update role toggle button
        const toggleBtn = document.getElementById('toggleUserRole');
        if (toggleBtn) {
            toggleBtn.innerHTML = isAdmin ? 
                '<i class="bi bi-person-badge"></i> Switch to User View' : 
                '<i class="bi bi-person-gear"></i> Switch to Admin View';
            toggleBtn.style.display = isAdmin ? 'block' : 'none';
        }

        // Show/hide become seller button
        const sellerBtn = document.getElementById('becomeSellerBtn');
        if (sellerBtn) {
            sellerBtn.style.display = (!isAdmin && !isSeller) ? 'block' : 'none';
        }

        // Re-render content based on role
        this.renderProducts();
    }

    toggleUserRole() {
        if (this.currentUserRole === 'admin') {
            this.currentUserRole = 'user';
        } else {
            this.currentUserRole = 'admin';
        }
        this.updateRoleBasedUI();
        this.showNotification(`Switched to ${this.currentUserRole} view`, 'success');
    }

    // Section Navigation
    switchSection(sectionName) {
        // Hide all sections
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });

        // Remove active class from all menu items
        document.querySelectorAll('.sidebar-menu li').forEach(item => {
            item.classList.remove('active');
        });

        // Show target section
        const targetSection = document.getElementById(sectionName);
        if (targetSection) {
            targetSection.classList.add('active');
            
            // Add active class to menu item
            const menuItem = document.querySelector(`[data-section="${sectionName}"]`);
            if (menuItem) {
                menuItem.classList.add('active');
            }
        }

        // Special handling for sections
        if (sectionName === 'cart') {
            this.renderCart();
        } else if (sectionName === 'dashboard') {
            this.updateStats();
        }
    }

    // Search Functionality
    handleSearch() {
        const searchTerm = document.getElementById('searchInput').value.toLowerCase();
        
        if (searchTerm.length === 0) {
            this.renderProducts();
            this.renderFarmers();
            this.renderOrders();
            return;
        }

        // Search products
        const filteredProducts = this.products.filter(product => 
            product.name.toLowerCase().includes(searchTerm) ||
            product.description.toLowerCase().includes(searchTerm) ||
            product.category.toLowerCase().includes(searchTerm) ||
            product.farmer.toLowerCase().includes(searchTerm)
        );

        // Search farmers
        const filteredFarmers = this.farmers.filter(farmer =>
            farmer.name.toLowerCase().includes(searchTerm) ||
            farmer.work.toLowerCase().includes(searchTerm) ||
            farmer.address.toLowerCase().includes(searchTerm)
        );

        // Search orders
        const filteredOrders = this.orders.filter(order =>
            order.customerName.toLowerCase().includes(searchTerm) ||
            order.customerEmail.toLowerCase().includes(searchTerm) ||
            order.status.toLowerCase().includes(searchTerm) ||
            order.order_number.toLowerCase().includes(searchTerm)
        );

        // Render filtered results
        this.renderProducts(filteredProducts);
        this.renderFarmers(filteredFarmers);
        this.renderOrders(filteredOrders);

        const totalResults = filteredProducts.length + filteredFarmers.length + filteredOrders.length;
        if (totalResults > 0) {
            this.showNotification(`Found ${totalResults} results for "${searchTerm}"`, 'info');
        } else {
            this.showNotification(`No results found for "${searchTerm}"`, 'warning');
        }
    }

    // Product Management
    renderProducts(productsToRender = null) {
        const products = productsToRender || this.products;
        const productGrid = document.getElementById('productGrid');
        const categoryFilter = document.getElementById('categoryFilter');
        const statusFilter = document.getElementById('statusFilter');

        if (!productGrid) return;

        // Update category filter
        this.updateCategoryFilter();

        // Filter products
        let filteredProducts = products;
        const categoryValue = categoryFilter?.value;
        const statusValue = statusFilter?.value;

        if (categoryValue) {
            filteredProducts = filteredProducts.filter(product => product.category === categoryValue);
        }

        if (statusValue && statusValue !== 'all') {
            filteredProducts = filteredProducts.filter(product => product.status === statusValue);
        }

        // Render products
        productGrid.innerHTML = '';

        if (filteredProducts.length === 0) {
            productGrid.innerHTML = '<div class="no-products">No products found</div>';
            return;
        }

        filteredProducts.forEach(product => {
            const productCard = this.createProductCard(product);
            productGrid.appendChild(productCard);
        });
    }

    createProductCard(product) {
        const card = document.createElement('div');
        card.className = 'product-card';
        card.innerHTML = `
            <div class="product-image">
                ${product.image ? `<img src="${product.image}" alt="${product.name}" onerror="this.style.display='none'">` : 
                `<i class="bi bi-basket"></i>`}
            </div>
            <div class="product-info">
                <h3 class="product-name">${product.name}</h3>
                <p class="product-description">${product.description}</p>
                <div class="product-meta">
                    <span class="product-price">$${product.price.toFixed(2)}</span>
                    <span class="product-stock">${product.stock} in stock</span>
                </div>
                <div class="product-rating">
                    <i class="bi bi-star-fill"></i>
                    <span>${product.rating} (${product.reviews} reviews)</span>
                </div>
                <div class="product-seller">
                    <small>Sold by: ${product.farmer}</small>
                </div>
                <div class="product-actions">
                    ${this.getProductActions(product)}
                </div>
            </div>
        `;

        return card;
    }

    getProductActions(product) {
        const isAdmin = this.currentUserRole === 'admin';
        const isSeller = this.currentUserRole === 'seller' || this.isSellerApproved;
        const isInCart = this.cart.some(item => item.id === product.id);

        if (isAdmin || isSeller) {
            return `
                <button class="btn btn-edit" onclick="marketplace.editProduct(${product.id})">
                    <i class="bi bi-pencil"></i> Edit
                </button>
                <button class="btn btn-delete" onclick="marketplace.deleteProduct(${product.id})">
                    <i class="bi bi-trash"></i> Delete
                </button>
                <button class="btn btn-status" onclick="marketplace.toggleProductStatus(${product.id})">
                    <i class="bi bi-power"></i> ${product.status === 'active' ? 'Deactivate' : 'Activate'}
                </button>
            `;
        } else {
            return `
                <button class="btn btn-add-cart ${isInCart ? 'added' : ''}" 
                        onclick="marketplace.addToCart(${product.id})" 
                        ${isInCart ? 'disabled' : ''}>
                    <i class="bi bi-cart-${isInCart ? 'check' : 'plus'}"></i>
                    ${isInCart ? 'Added to Cart' : 'Add to Cart'}
                </button>
                <button class="btn btn-place-order" onclick="marketplace.placeOrderFromProduct(${product.id})">
                    <i class="bi bi-bag-check"></i> Buy Now
                </button>
            `;
        }
    }

    openProductModal(product = null) {
        // Check if user is authorized to add products
        if (this.currentUserRole !== 'admin' && !this.isSellerApproved) {
            this.showNotification('You need to be an approved seller to add products', 'warning');
            return;
        }

        this.currentEditingId = product ? product.id : null;
        const modal = document.getElementById('productModal');
        const title = document.getElementById('productModalTitle');
        const form = document.getElementById('productForm');

        if (!modal || !title || !form) return;

        title.textContent = product ? 'Edit Product' : 'Add New Product';
        
        if (product) {
            document.getElementById('productName').value = product.name;
            document.getElementById('productPrice').value = product.price;
            document.getElementById('productCategory').value = product.category_id;
            document.getElementById('productStock').value = product.stock;
            document.getElementById('productDescription').value = product.description;
            document.getElementById('productImage').value = product.image;
            document.getElementById('productStatus').checked = product.status === 'active';
        } else {
            form.reset();
        }

        this.updateCategoryDropdown();
        modal.classList.add('active');
    }

    async handleProductSubmit(e) {
        e.preventDefault();
        const formData = new FormData(e.target);
        
        const productData = {
            name: formData.get('productName'),
            price: parseFloat(formData.get('productPrice')),
            category_id: parseInt(formData.get('productCategory')),
            stock_quantity: parseInt(formData.get('productStock')),
            description: formData.get('productDescription'),
            image: formData.get('productImage'),
            status: formData.get('productStatus') ? 'active' : 'inactive'
        };

        try {
            let response;
            if (this.currentEditingId) {
                // Update existing product
                response = await fetch(`/api/marketplace/products/${this.currentEditingId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'same-origin',
                    body: JSON.stringify(productData)
                });
            } else {
                // Add new product
                response = await fetch('/api/marketplace/products', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'same-origin',
                    body: JSON.stringify(productData)
                });
            }

            const data = await response.json();
            
            if (data.success) {
                this.showNotification(data.message, 'success');
                this.closeAllModals();
                await this.loadProducts();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Operation failed', 'danger');
            }
        } catch (error) {
            console.error('Error saving product:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    async loadProducts() {
        try {
            const response = await fetch('/api/marketplace/products', {
                credentials: 'same-origin'
            });
            const data = await response.json();
            
            if (data.success) {
                this.products = data.products;
            }
        } catch (error) {
            console.error('Error loading products:', error);
        }
    }

    editProduct(id) {
        const product = this.products.find(p => p.id === id);
        if (product) {
            this.openProductModal(product);
        }
    }

    async deleteProduct(id) {
        if (!confirm('Are you sure you want to delete this product?')) return;

        try {
            const response = await fetch(`/api/marketplace/products/${id}`, {
                method: 'DELETE',
                credentials: 'same-origin'
            });
            const data = await response.json();
            
            if (data.success) {
                this.showNotification('Product deleted successfully!', 'success');
                await this.loadProducts();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Delete failed', 'danger');
            }
        } catch (error) {
            console.error('Error deleting product:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    async toggleProductStatus(id) {
        const product = this.products.find(p => p.id === id);
        if (!product) return;

        const newStatus = product.status === 'active' ? 'inactive' : 'active';
        
        try {
            const response = await fetch(`/api/marketplace/products/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ status: newStatus })
            });
            const data = await response.json();
            
            if (data.success) {
                this.showNotification(`Product ${newStatus === 'active' ? 'activated' : 'deactivated'}!`, 'success');
                await this.loadProducts();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Operation failed', 'danger');
            }
        } catch (error) {
            console.error('Error updating product status:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    // Category Management
    renderCategories() {
        const categoriesGrid = document.getElementById('categoriesGrid');
        if (!categoriesGrid) return;

        categoriesGrid.innerHTML = '';

        if (this.categories.length === 0) {
            categoriesGrid.innerHTML = '<div class="no-categories">No categories found</div>';
            return;
        }

        this.categories.forEach(category => {
            const categoryCard = document.createElement('div');
            categoryCard.className = 'product-card';
            categoryCard.innerHTML = `
                <div class="product-info">
                    <h3 class="product-name">${category.name}</h3>
                    <p class="product-description">${category.description}</p>
                    <div class="product-meta">
                        <span class="product-stock">${category.product_count} products</span>
                    </div>
                    <div class="product-actions">
                        <button class="btn btn-edit" onclick="marketplace.editCategory(${category.id})">
                            <i class="bi bi-pencil"></i> Edit
                        </button>
                        <button class="btn btn-delete" onclick="marketplace.deleteCategory(${category.id})">
                            <i class="bi bi-trash"></i> Delete
                        </button>
                    </div>
                </div>
            `;
            categoriesGrid.appendChild(categoryCard);
        });
    }

    openCategoryModal(category = null) {
        this.currentEditingId = category ? category.id : null;
        const modal = document.getElementById('categoryModal');
        const title = document.getElementById('categoryModalTitle');
        const form = document.getElementById('categoryForm');

        if (!modal || !title || !form) return;

        title.textContent = category ? 'Edit Category' : 'Add New Category';
        
        if (category) {
            document.getElementById('categoryName').value = category.name;
            document.getElementById('categoryDescription').value = category.description;
            document.getElementById('categoryImage').value = category.image;
        } else {
            form.reset();
        }

        modal.classList.add('active');
    }

    async handleCategorySubmit(e) {
        e.preventDefault();
        const formData = new FormData(e.target);
        
        const categoryData = {
            name: formData.get('categoryName'),
            description: formData.get('categoryDescription'),
            image: formData.get('categoryImage')
        };

        try {
            let response;
            if (this.currentEditingId) {
                response = await fetch(`/api/marketplace/categories/${this.currentEditingId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'same-origin',
                    body: JSON.stringify(categoryData)
                });
            } else {
                response = await fetch('/api/marketplace/categories', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'same-origin',
                    body: JSON.stringify(categoryData)
                });
            }

            const data = await response.json();
            
            if (data.success) {
                this.showNotification(data.message, 'success');
                this.closeAllModals();
                await this.loadCategories();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Operation failed', 'danger');
            }
        } catch (error) {
            console.error('Error saving category:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    async loadCategories() {
        try {
            const response = await fetch('/api/marketplace/categories', {
                credentials: 'same-origin'
            });
            const data = await response.json();
            
            if (data.success) {
                this.categories = data.categories;
            }
        } catch (error) {
            console.error('Error loading categories:', error);
        }
    }

    editCategory(id) {
        const category = this.categories.find(c => c.id === id);
        if (category) {
            this.openCategoryModal(category);
        }
    }

    async deleteCategory(id) {
        if (!confirm('Are you sure you want to delete this category?')) return;

        try {
            const response = await fetch(`/api/marketplace/categories/${id}`, {
                method: 'DELETE',
                credentials: 'same-origin'
            });
            const data = await response.json();
            
            if (data.success) {
                this.showNotification('Category deleted successfully!', 'success');
                await this.loadCategories();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Delete failed', 'danger');
            }
        } catch (error) {
            console.error('Error deleting category:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    // Farmer Management
    renderFarmers(farmersToRender = null) {
        const farmers = farmersToRender || this.farmers;
        const farmersGrid = document.getElementById('farmersGrid');
        if (!farmersGrid) return;

        farmersGrid.innerHTML = '';

        if (farmers.length === 0) {
            farmersGrid.innerHTML = '<div class="no-farmers">No farmers found</div>';
            return;
        }

        farmers.forEach(farmer => {
            const farmerCard = document.createElement('div');
            farmerCard.className = 'product-card';
            farmerCard.innerHTML = `
                <div class="product-info">
                    <h3 class="product-name">${farmer.name}</h3>
                    <p class="product-description">
                        <strong>Work:</strong> ${farmer.work}<br>
                        <strong>Email:</strong> ${farmer.email}<br>
                        <strong>Phone:</strong> ${farmer.phone}<br>
                        <strong>Address:</strong> ${farmer.address}<br>
                        <strong>Products:</strong> ${farmer.product_count}<br>
                        <strong>Joined:</strong> ${new Date(farmer.joined_at).toLocaleDateString()}
                    </p>
                    <div class="product-actions">
                        <button class="btn btn-edit" onclick="marketplace.editFarmer(${farmer.id})">
                            <i class="bi bi-pencil"></i> Edit
                        </button>
                        <button class="btn btn-delete" onclick="marketplace.deleteFarmer(${farmer.id})">
                            <i class="bi bi-trash"></i> Delete
                        </button>
                    </div>
                </div>
            `;
            farmersGrid.appendChild(farmerCard);
        });
    }

    openFarmerModal(farmer = null) {
        this.currentEditingId = farmer ? farmer.id : null;
        const modal = document.getElementById('farmerModal');
        const title = document.getElementById('farmerModalTitle');
        const form = document.getElementById('farmerForm');

        if (!modal || !title || !form) return;

        title.textContent = farmer ? 'Edit Farmer' : 'Add New Farmer';
        
        if (farmer) {
            document.getElementById('farmerName').value = farmer.name;
            document.getElementById('farmerPhone').value = farmer.phone;
            document.getElementById('farmerAddress').value = farmer.address;
            document.getElementById('farmerWork').value = farmer.work;
            document.getElementById('farmerSalary').value = farmer.salary || '';
            document.getElementById('farmerExperience').value = farmer.experience || '';
        } else {
            form.reset();
        }

        modal.classList.add('active');
    }

    async handleFarmerSubmit(e) {
        e.preventDefault();
        const formData = new FormData(e.target);
        
        const farmerData = {
            name: formData.get('farmerName'),
            phone: formData.get('farmerPhone'),
            address: formData.get('farmerAddress'),
            work: formData.get('farmerWork'),
            salary: parseFloat(formData.get('farmerSalary')) || 0,
            experience: parseInt(formData.get('farmerExperience')) || 0
        };

        try {
            let response;
            if (this.currentEditingId) {
                response = await fetch(`/api/marketplace/farmers/${this.currentEditingId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'same-origin',
                    body: JSON.stringify(farmerData)
                });
            } else {
                response = await fetch('/api/marketplace/farmers', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'same-origin',
                    body: JSON.stringify(farmerData)
                });
            }

            const data = await response.json();
            
            if (data.success) {
                this.showNotification(data.message, 'success');
                this.closeAllModals();
                await this.loadFarmers();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Operation failed', 'danger');
            }
        } catch (error) {
            console.error('Error saving farmer:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    async loadFarmers() {
        try {
            const response = await fetch('/api/marketplace/farmers', {
                credentials: 'same-origin'
            });
            const data = await response.json();
            
            if (data.success) {
                this.farmers = data.farmers;
            }
        } catch (error) {
            console.error('Error loading farmers:', error);
        }
    }

    editFarmer(id) {
        const farmer = this.farmers.find(f => f.id === id);
        if (farmer) {
            this.openFarmerModal(farmer);
        }
    }

    async deleteFarmer(id) {
        if (!confirm('Are you sure you want to delete this farmer?')) return;

        try {
            const response = await fetch(`/api/marketplace/farmers/${id}`, {
                method: 'DELETE',
                credentials: 'same-origin'
            });
            const data = await response.json();
            
            if (data.success) {
                this.showNotification('Farmer deleted successfully!', 'success');
                await this.loadFarmers();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Delete failed', 'danger');
            }
        } catch (error) {
            console.error('Error deleting farmer:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    // Cart Management
    addToCart(productId) {
        const product = this.products.find(p => p.id === productId);
        if (!product) {
            this.showNotification('Product not found', 'danger');
            return;
        }

        if (product.stock < 1) {
            this.showNotification('Product is out of stock', 'warning');
            return;
        }

        const existingItem = this.cart.find(item => item.id === productId);
        
        if (existingItem) {
            if (existingItem.quantity >= product.stock) {
                this.showNotification('Cannot add more than available stock', 'warning');
                return;
            }
            existingItem.quantity += 1;
        } else {
            this.cart.push({
                ...product,
                quantity: 1
            });
        }

        this.updateCartUI();
        this.showNotification(`${product.name} added to cart!`, 'success');
    }

    removeFromCart(productId) {
        this.cart = this.cart.filter(item => item.id !== productId);
        this.updateCartUI();
        this.showNotification('Item removed from cart!', 'success');
    }

    updateCartQuantity(productId, newQuantity) {
        if (newQuantity < 1) {
            this.removeFromCart(productId);
            return;
        }

        const item = this.cart.find(item => item.id === productId);
        const product = this.products.find(p => p.id === productId);
        
        if (item && product) {
            if (newQuantity > product.stock) {
                this.showNotification(`Only ${product.stock} items available in stock`, 'warning');
                return;
            }
            item.quantity = newQuantity;
            this.updateCartUI();
        }
    }

    renderCart() {
        const cartItems = document.getElementById('cartItems');
        const emptyCart = document.getElementById('emptyCart');
        
        if (!cartItems || !emptyCart) return;

        if (this.cart.length === 0) {
            emptyCart.style.display = 'block';
            cartItems.innerHTML = '';
            return;
        }

        emptyCart.style.display = 'none';
        cartItems.innerHTML = '';

        this.cart.forEach(item => {
            const cartItem = document.createElement('div');
            cartItem.className = 'cart-item';
            cartItem.innerHTML = `
                <div class="cart-item-image">
                    ${item.image ? `<img src="${item.image}" alt="${item.name}" onerror="this.style.display='none'">` : 
                    `<i class="bi bi-basket"></i>`}
                </div>
                <div class="cart-item-details">
                    <h4 class="cart-item-name">${item.name}</h4>
                    <p class="cart-item-price">$${item.price.toFixed(2)} each</p>
                    <p class="cart-item-seller">Sold by: ${item.farmer}</p>
                </div>
                <div class="cart-item-controls">
                    <div class="quantity-controls">
                        <button class="quantity-btn" onclick="marketplace.updateCartQuantity(${item.id}, ${item.quantity - 1})">
                            <i class="bi bi-dash"></i>
                        </button>
                        <span class="quantity">${item.quantity}</span>
                        <button class="quantity-btn" onclick="marketplace.updateCartQuantity(${item.id}, ${item.quantity + 1})">
                            <i class="bi bi-plus"></i>
                        </button>
                    </div>
                    <div class="cart-item-total">
                        $${(item.price * item.quantity).toFixed(2)}
                    </div>
                    <button class="btn-remove" onclick="marketplace.removeFromCart(${item.id})">
                        <i class="bi bi-trash"></i> Remove
                    </button>
                </div>
            `;
            cartItems.appendChild(cartItem);
        });
    }

    updateCartUI() {
        this.renderCart();
        this.updateCartSummary();
        this.updateCartBadge();
        this.renderProducts(); // Update product buttons
    }

    updateCartSummary() {
        const subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const shipping = 5.00;
        const total = subtotal + shipping;

        // Update cart summary elements
        const elements = {
            'cartSubtotal': `$${subtotal.toFixed(2)}`,
            'cartShipping': `$${shipping.toFixed(2)}`,
            'cartFinalTotal': `$${total.toFixed(2)}`,
            'cartItemCount': `${this.cart.length} items`,
            'cartTotalAmount': `Total: $${total.toFixed(2)}`
        };

        Object.entries(elements).forEach(([id, value]) => {
            const element = document.getElementById(id);
            if (element) element.textContent = value;
        });
    }

    updateCartBadge() {
        const cartBadge = document.getElementById('cartBadge');
        if (!cartBadge) return;

        const totalItems = this.cart.reduce((sum, item) => sum + item.quantity, 0);
        cartBadge.textContent = totalItems;
        
        if (totalItems > 0) {
            cartBadge.style.display = 'flex';
        } else {
            cartBadge.style.display = 'none';
        }
    }

    // Order Management
    placeOrderFromProduct(productId) {
        const product = this.products.find(p => p.id === productId);
        if (!product) return;

        this.openOrderModal([{ ...product, quantity: 1 }]);
    }

    openOrderModal(products = null) {
        const orderProducts = products || this.cart;
        if (orderProducts.length === 0) {
            this.showNotification('Please add items to cart first!', 'warning');
            return;
        }

        const modal = document.getElementById('orderModal');
        const orderSummary = document.getElementById('orderSummaryDetails');
        
        if (!modal || !orderSummary) return;
        
        // Calculate order summary
        const subtotal = orderProducts.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const shipping = 5.00;
        const total = subtotal + shipping;

        orderSummary.innerHTML = `
            ${orderProducts.map(item => `
                <div class="summary-row">
                    <span>${item.name} x${item.quantity}</span>
                    <span>$${(item.price * item.quantity).toFixed(2)}</span>
                </div>
            `).join('')}
            <div class="summary-row">
                <span>Subtotal:</span>
                <span>$${subtotal.toFixed(2)}</span>
            </div>
            <div class="summary-row">
                <span>Shipping:</span>
                <span>$${shipping.toFixed(2)}</span>
            </div>
            <div class="summary-row total">
                <span>Total:</span>
                <span>$${total.toFixed(2)}</span>
            </div>
        `;

        modal.classList.add('active');
    }

    async handleOrderSubmit(e) {
        e.preventDefault();
        const formData = new FormData(e.target);
        
        const orderData = {
            customer_name: formData.get('customerName'),
            customer_email: formData.get('customerEmail'),
            customer_phone: formData.get('customerPhone'),
            shipping_address: formData.get('shippingAddress'),
            payment_method: formData.get('paymentMethod'),
            total_amount: this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0) + 5.00,
            items: this.cart.map(item => ({
                product_id: item.id,
                quantity: item.quantity,
                price: item.price
            }))
        };

        try {
            const response = await fetch('/api/marketplace/orders', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify(orderData)
            });

            const data = await response.json();
            
            if (data.success) {
                // Clear cart after successful order
                this.cart = [];
                this.updateCartUI();
                
                this.closeAllModals();
                this.showSuccessNotification('Order placed successfully!');
                await this.loadOrders();
                this.updateUI();
                
                // Add to customers if new
                this.addCustomer(orderData);
            } else {
                this.showNotification(data.error || 'Order failed', 'danger');
            }
        } catch (error) {
            console.error('Error placing order:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    renderOrders(ordersToRender = null) {
        const orders = ordersToRender || this.orders;
        const ordersContainer = document.getElementById('ordersContainer');
        const statusFilter = document.getElementById('orderStatusFilter');
        
        if (!ordersContainer) return;

        let filteredOrders = orders;
        if (statusFilter && statusFilter.value !== 'all') {
            filteredOrders = orders.filter(order => order.status === statusFilter.value);
        }

        ordersContainer.innerHTML = '';

        if (filteredOrders.length === 0) {
            ordersContainer.innerHTML = '<div class="no-orders">No orders found</div>';
            return;
        }

        filteredOrders.forEach(order => {
            const orderCard = document.createElement('div');
            orderCard.className = 'product-card';
            orderCard.innerHTML = `
                <div class="product-info">
                    <h3 class="product-name">Order #${order.order_number}</h3>
                    <p class="product-description">
                        <strong>Customer:</strong> ${order.customerName}<br>
                        <strong>Email:</strong> ${order.customerEmail}<br>
                        <strong>Phone:</strong> ${order.customerPhone}<br>
                        <strong>Total:</strong> $${order.total.toFixed(2)}<br>
                        <strong>Status:</strong> <span class="status-badge status-${order.status}">${order.status}</span><br>
                        <strong>Payment:</strong> ${order.paymentMethod.toUpperCase()}<br>
                        <strong>Address:</strong> ${order.shippingAddress}<br>
                        <strong>Order Date:</strong> ${new Date(order.orderDate).toLocaleDateString()}
                    </p>
                    <div class="product-items">
                        ${order.products.map(product => 
                            `<span class="product-tag">${product.name} x${product.quantity}</span>`
                        ).join('')}
                    </div>
                    <div class="product-actions">
                        ${this.getOrderActions(order)}
                    </div>
                </div>
            `;
            ordersContainer.appendChild(orderCard);
        });
    }

    getOrderActions(order) {
        const isAdmin = this.currentUserRole === 'admin';
        
        if (!isAdmin) return '';

        const actions = {
            'pending': `
                <button class="btn btn-edit" onclick="marketplace.updateOrderStatus('${order.id}', 'confirmed')">
                    <i class="bi bi-check"></i> Confirm
                </button>
                <button class="btn btn-delete" onclick="marketplace.updateOrderStatus('${order.id}', 'cancelled')">
                    <i class="bi bi-x"></i> Cancel
                </button>
            `,
            'confirmed': `
                <button class="btn btn-status" onclick="marketplace.updateOrderStatus('${order.id}', 'shipped')">
                    <i class="bi bi-truck"></i> Ship
                </button>
            `,
            'shipped': `
                <button class="btn btn-edit" onclick="marketplace.updateOrderStatus('${order.id}', 'delivered')">
                    <i class="bi bi-check-circle"></i> Mark Delivered
                </button>
            `,
            'delivered': `
                <span class="completed-order">Order Completed</span>
            `,
            'cancelled': `
                <span class="cancelled-order">Order Cancelled</span>
            `
        };

        return actions[order.status] || '';
    }

    async updateOrderStatus(orderId, newStatus) {
        try {
            const response = await fetch(`/api/marketplace/orders/${orderId}/status`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ status: newStatus })
            });

            const data = await response.json();
            
            if (data.success) {
                this.showNotification(`Order status updated to ${newStatus}`, 'success');
                await this.loadOrders();
                this.updateUI();
            } else {
                this.showNotification(data.error || 'Status update failed', 'danger');
            }
        } catch (error) {
            console.error('Error updating order status:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    async loadOrders() {
        try {
            const response = await fetch('/api/marketplace/orders', {
                credentials: 'same-origin'
            });
            const data = await response.json();
            
            if (data.success) {
                this.orders = data.orders;
            }
        } catch (error) {
            console.error('Error loading orders:', error);
        }
    }

    // Customer Management
    addCustomer(orderData) {
        // Check if customer already exists
        const existingCustomer = this.customers.find(c => c.email === orderData.customer_email);
        
        if (!existingCustomer) {
            this.customers.push({
                id: Date.now(),
                name: orderData.customer_name,
                email: orderData.customer_email,
                phone: orderData.customer_phone,
                orders: 1,
                status: 'active',
                joined_date: new Date().toISOString()
            });
        } else {
            existingCustomer.orders += 1;
        }
    }

    renderCustomers() {
        const tableBody = document.getElementById('customersTableBody');
        if (!tableBody) return;

        tableBody.innerHTML = '';

        if (this.customers.length === 0) {
            tableBody.innerHTML = `
                <tr>
                    <td colspan="7" class="no-data">No customers found</td>
                </tr>
            `;
            return;
        }

        this.customers.forEach(customer => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${customer.id}</td>
                <td>${customer.name}</td>
                <td>${customer.email}</td>
                <td>${customer.phone}</td>
                <td>${customer.orders}</td>
                <td><span class="status-badge status-active">${customer.status}</span></td>
                <td>
                    <button class="btn btn-edit" onclick="marketplace.viewCustomer(${customer.id})">
                        <i class="bi bi-eye"></i> View
                    </button>
                </td>
            `;
            tableBody.appendChild(row);
        });
    }

    viewCustomer(customerId) {
        const customer = this.customers.find(c => c.id === customerId);
        if (customer) {
            alert(`Customer Details:\nName: ${customer.name}\nEmail: ${customer.email}\nPhone: ${customer.phone}\nTotal Orders: ${customer.orders}\nJoined: ${new Date(customer.joined_date).toLocaleDateString()}`);
        }
    }

    // Seller Registration
    openSellerModal() {
        const modal = document.getElementById('sellerModal');
        if (modal) {
            modal.classList.add('active');
        }
    }

    async handleSellerSubmit(e) {
        e.preventDefault();
        const formData = new FormData(e.target);
        
        const sellerData = {
            store_name: formData.get('storeName'),
            store_category: formData.get('storeCategory'),
            phone: formData.get('storePhone'),
            address: formData.get('storeAddress'),
            description: formData.get('storeDescription')
        };

        try {
            const response = await fetch('/api/marketplace/seller/apply', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify(sellerData)
            });

            const data = await response.json();
            
            if (data.success) {
                this.showNotification('Seller application submitted successfully! It will be reviewed by admin.', 'success');
                this.closeAllModals();
                // Hide become seller button
                const sellerBtn = document.getElementById('becomeSellerBtn');
                if (sellerBtn) sellerBtn.style.display = 'none';
            } else {
                this.showNotification(data.error || 'Application failed', 'danger');
            }
        } catch (error) {
            console.error('Error submitting seller application:', error);
            this.showNotification('Network error. Please try again.', 'danger');
        }
    }

    // Utility Methods
    closeAllModals() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.remove('active');
        });
        this.currentEditingId = null;
    }

    showNotification(message, type = 'info') {
        // Create or update notification element
        let notification = document.getElementById('marketplaceNotification');
        if (!notification) {
            notification = document.createElement('div');
            notification.id = 'marketplaceNotification';
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 1rem 1.5rem;
                border-radius: 8px;
                color: white;
                font-weight: 600;
                z-index: 10000;
                max-width: 400px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                transform: translateX(400px);
                transition: transform 0.3s ease;
            `;
            document.body.appendChild(notification);
        }

        // Set background color based on type
        const colors = {
            success: '#4CAF50',
            danger: '#f44336',
            warning: '#ff9800',
            info: '#2196F3'
        };
        notification.style.backgroundColor = colors[type] || colors.info;
        notification.textContent = message;

        // Show notification
        notification.style.transform = 'translateX(0)';
        
        // Auto hide after 5 seconds
        setTimeout(() => {
            notification.style.transform = 'translateX(400px)';
        }, 5000);
    }

    showSuccessNotification(message = 'Operation completed successfully!') {
        const notification = document.getElementById('successNotification');
        const messageElement = document.getElementById('successMessage');
        
        if (notification && messageElement) {
            messageElement.textContent = message;
            notification.classList.add('show');
            
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }
    }

    updateCategoryFilter() {
        const categoryFilter = document.getElementById('categoryFilter');
        if (!categoryFilter) return;

        const currentValue = categoryFilter.value;
        
        categoryFilter.innerHTML = '<option value="">All Categories</option>';
        this.categories.forEach(category => {
            const option = document.createElement('option');
            option.value = category.name;
            option.textContent = category.name;
            categoryFilter.appendChild(option);
        });
        
        // Restore previous selection
        categoryFilter.value = currentValue;
    }

    updateCategoryDropdown() {
        const categoryDropdown = document.getElementById('productCategory');
        if (!categoryDropdown) return;

        categoryDropdown.innerHTML = '<option value="">Select Category</option>';
        this.categories.forEach(category => {
            const option = document.createElement('option');
            option.value = category.id;
            option.textContent = category.name;
            categoryDropdown.appendChild(option);
        });
    }

    handleLogout() {
        if (confirm('Are you sure you want to logout?')) {
            window.location.href = '/logout';
        }
    }

    // Analytics and Reports (stub methods for now)
    renderAnalytics() {
        console.log('Rendering analytics...');
        // Implement analytics charts and graphs
    }

    renderReports() {
        console.log('Rendering reports...');
        // Implement reports generation
    }
}

// Initialize the marketplace when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.marketplace = new AgricultureMarketplace();
});

// Make marketplace available globally for onclick handlers
window.AgricultureMarketplace = AgricultureMarketplace;
// Profile JS
// ==================================
// Profile Page JS — Logout Flash
// ==================================
document.addEventListener("DOMContentLoaded", () => {

  // Create flash message container
  const flashMessage = document.createElement("div");
  Object.assign(flashMessage.style, {
    position: "fixed",
    top: "30px",
    left: "50%",
    transform: "translateX(-50%)",
    padding: "14px 28px",
    borderRadius: "8px",
    fontWeight: "600",
    fontSize: "1rem",
    zIndex: "9999",
    display: "none",
    color: "#fff",
    boxShadow: "0 4px 10px rgba(0,0,0,0.15)",
  });
  document.body.appendChild(flashMessage);

  function showFlash(msg, type = "danger") {
    flashMessage.textContent = msg;
    flashMessage.style.display = "block";
    flashMessage.style.opacity = "1";
    switch (type) {
      case "success":
        flashMessage.style.backgroundColor = "#28a745";
        break;
      case "warning":
        flashMessage.style.backgroundColor = "#ffc107";
        flashMessage.style.color = "#000";
        break;
      default:
        flashMessage.style.backgroundColor = "#dc3545";
    }
    setTimeout(() => {
      flashMessage.style.transition = "opacity 0.5s";
      flashMessage.style.opacity = "0";
      setTimeout(() => (flashMessage.style.display = "none"), 500);
    }, 2000);
  }

  // Logout form handling
  const logoutForm = document.getElementById("logoutForm");
  if (logoutForm) {
    logoutForm.addEventListener("submit", (e) => {
      e.preventDefault();
      fetch(logoutForm.action, { method: "GET" }) // or POST if you change Flask
        .then(() => {
          showFlash("You have been logged out!", "warning");
          setTimeout(() => {
            window.location.href = "/";
          }, 1200);
        })
        .catch(() => showFlash("Logout failed!", "danger"));
    });
  }

});
// Blog
// Knowledge Base Blog JS - Complete Working Version
document.addEventListener("DOMContentLoaded", () => {
  // DOM Elements
  const kbForm = document.getElementById("kbBlogForm");
  const kbBlogList = document.getElementById("kbBlogList");
  const kbSubmitBtn = document.getElementById("kbSubmitBtn");
  const kbCancelEdit = document.getElementById("kbCancelEdit");
  const kbMediaInput = document.getElementById("kbMediaInput");
  const kbMediaUrlInput = document.getElementById("kbMediaUrlInput");
  const kbFileName = document.getElementById("kbFileName");
  const kbFilePreview = document.getElementById("kbFilePreview");
  const uploadTypeFile = document.getElementById("uploadTypeFile");
  const uploadTypeUrl = document.getElementById("uploadTypeUrl");
  
  // Category elements
  const kbCategorySelect = document.getElementById("kbCategorySelect");
  const kbCategoriesList = document.getElementById("kbCategories");
  const kbCategoryForm = document.getElementById("kbCategoryForm");
  const kbNewCategory = document.getElementById("kbNewCategory");
  const kbCategoryList = document.getElementById("kbCategoryList");
  
  // Modal elements
  const kbBlogModal = document.getElementById("kbBlogModal");
  const kbModalTitle = document.getElementById("kbModalTitle");
  const kbModalMediaContainer = document.getElementById("kbModalMediaContainer");
  const kbModalCategory = document.getElementById("kbModalCategory");
  const kbModalDate = document.getElementById("kbModalDate");
  const kbModalAuthor = document.getElementById("kbModalAuthor");
  const kbModalDescription = document.getElementById("kbModalDescription");
  const kbModalLikeBtn = document.getElementById("kbModalLikeBtn");
  const kbLikeCount = document.getElementById("kbLikeCount");
  const kbCommentCount = document.getElementById("kbCommentCount");
  const kbCommentsList = document.getElementById("kbCommentsList");
  const kbCommentForm = document.getElementById("kbCommentForm");
  
  // Close buttons
  const kbModalClose = document.getElementById("kbModalClose");
  const kbModalCloseBtn = document.getElementById("kbModalCloseBtn");
  
  let editingBlogId = null;
  let currentBlogId = null;
  const wrapper = document.querySelector(".kb-wrapper");
  const isAdmin = wrapper ? wrapper.dataset.isAdmin === "true" : false;

  console.log('Knowledge Base initialized. Admin:', isAdmin);

  // Initialize everything
  initializeKnowledgeBase();

  async function initializeKnowledgeBase() {
    await loadCategories();
    await loadBlogs();
    setupEventListeners();
  }

  // ----------------------
  // Setup Event Listeners
  // ----------------------
  function setupEventListeners() {
    // File upload handling
    if (kbMediaInput) {
      kbMediaInput.addEventListener("change", handleFileSelect);
    }
    
    // Upload type toggle
    if (uploadTypeFile && uploadTypeUrl) {
      uploadTypeFile.addEventListener("change", toggleUploadType);
      uploadTypeUrl.addEventListener("change", toggleUploadType);
    }
    
    // URL input changes
    if (kbMediaUrlInput) {
      kbMediaUrlInput.addEventListener("input", handleUrlInput);
    }
    
    // Form submission
    if (kbForm) {
      kbForm.addEventListener("submit", handleFormSubmit);
    }
    
    // Cancel edit
    if (kbCancelEdit) {
      kbCancelEdit.addEventListener("click", resetForm);
    }
    
    // Modal close events
    if (kbModalClose) {
      kbModalClose.addEventListener("click", closeBlogModal);
    }
    if (kbModalCloseBtn) {
      kbModalCloseBtn.addEventListener("click", closeBlogModal);
    }
    
    // Modal overlay click to close
    if (kbBlogModal) {
      kbBlogModal.addEventListener("click", (e) => {
        if (e.target === kbBlogModal) closeBlogModal();
      });
    }
    
    // Comment form submission
    if (kbCommentForm) {
      kbCommentForm.addEventListener("submit", handleCommentSubmit);
    }
    
    // Like button
    if (kbModalLikeBtn) {
      kbModalLikeBtn.addEventListener("click", handleLike);
    }
  }

  // ----------------------
  // Category Management
  // ----------------------
  async function loadCategories() {
    try {
      console.log('Loading categories...');
      const response = await fetch('/api/kb_categories');
      if (!response.ok) throw new Error('Failed to load categories');
      const categories = await response.json();
      console.log('Categories loaded:', categories);
      updateCategoryUI(categories);
    } catch (error) {
      console.error('Error loading categories:', error);
      showToast('Error loading categories', 'error');
    }
  }

  function updateCategoryUI(categories) {
    // Update category select dropdown
    if (kbCategorySelect) {
      kbCategorySelect.innerHTML = '<option value="">Select Category</option>';
      categories.forEach(category => {
        const option = document.createElement('option');
        option.value = category.name;
        option.textContent = category.name;
        kbCategorySelect.appendChild(option);
      });
    }

    // Update sidebar categories list
    if (kbCategoriesList) {
      kbCategoriesList.innerHTML = '';
      categories.forEach(category => {
        const li = document.createElement('li');
        li.textContent = category.name;
        li.addEventListener('click', () => filterByCategory(category.name));
        kbCategoriesList.appendChild(li);
      });
    }

    // Update admin category management
    if (kbCategoryList && isAdmin) {
      updateAdminCategoryList(categories);
    }
  }

  function updateAdminCategoryList(categories) {
    kbCategoryList.innerHTML = '';
    categories.forEach(category => {
      const categoryItem = document.createElement('div');
      categoryItem.className = 'kb-category-item';
      categoryItem.innerHTML = `
        <span class="kb-category-name">${category.name}</span>
        <button class="kb-category-delete" data-category-id="${category.id}" data-category-name="${category.name}">
          <i class="bi bi-trash"></i> Delete
        </button>
      `;
      kbCategoryList.appendChild(categoryItem);
    });

    // Add delete event listeners
    document.querySelectorAll('.kb-category-delete').forEach(btn => {
      btn.addEventListener('click', handleCategoryDelete);
    });
  }

  async function handleCategoryDelete(e) {
    const btn = e.target.closest('.kb-category-delete');
    const categoryId = btn.dataset.categoryId;
    const categoryName = btn.dataset.categoryName;
    
    if (!confirm(`Are you sure you want to delete "${categoryName}"?`)) return;

    try {
      const response = await fetch(`/api/kb_categories/${categoryId}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' }
      });
      
      const data = await response.json();
      
      if (data.success) {
        showToast(`Category "${categoryName}" deleted!`, 'success');
        loadCategories();
      } else {
        showToast(data.error || 'Failed to delete category', 'error');
      }
    } catch (error) {
      console.error('Error deleting category:', error);
      showToast('Error deleting category', 'error');
    }
  }

  function filterByCategory(category) {
    showToast(`Filtering by: ${category}`, 'info');
    const blogCards = document.querySelectorAll('.kb-blog-card');
    blogCards.forEach(card => {
      const cardCategory = card.dataset.category;
      card.style.display = cardCategory === category ? 'block' : 'none';
    });
  }

  // ----------------------
  // Blog Management
  // ----------------------
  async function loadBlogs() {
    try {
      console.log('Loading blogs...');
      const response = await fetch('/api/blogs');
      const data = await response.json();
      
      if (data.success) {
        console.log('Blogs loaded successfully:', data.blogs.length);
        renderBlogs(data.blogs);
      } else {
        showToast('Failed to load blogs', 'error');
        renderBlogs([]);
      }
    } catch (error) {
      console.error('Error loading blogs:', error);
      showToast('Error loading blogs', 'error');
      renderBlogs([]);
    }
  }

  function renderBlogs(blogs) {
    if (!kbBlogList) return;
    
    if (blogs.length === 0) {
      kbBlogList.innerHTML = '<p class="kb-no-blogs">No blogs available yet. Be the first to share knowledge!</p>';
      return;
    }

    kbBlogList.innerHTML = blogs.map(blog => `
      <div class="kb-blog-card fade-in" data-blog-id="${blog.id}" data-category="${blog.category}">
        <div class="kb-content-preview">
          ${getMediaPreviewHTML(blog)}
        </div>
        <h3><i class="bi bi-bookmark"></i> ${escapeHtml(blog.title)}</h3>
        <p>${escapeHtml(blog.content.length > 150 ? blog.content.substring(0, 150) + '...' : blog.content)}</p>
        <div class="kb-blog-meta">
          <span><i class="bi bi-calendar"></i> ${blog.created_at}</span>
          <span><i class="bi bi-person"></i> ${escapeHtml(blog.author)}</span>
          <span><i class="bi bi-heart"></i> ${blog.like_count}</span>
          <span><i class="bi bi-chat"></i> ${blog.comment_count}</span>
        </div>
        <div class="kb-blog-actions">
          <button class="kb-read-btn" data-blog-id="${blog.id}">Read More</button>
          ${(blog.can_edit || blog.can_delete) ? `
            ${blog.can_edit ? `<button class="kb-edit-btn" data-id="${blog.id}">Edit</button>` : ''}
            ${blog.can_delete ? `<button class="kb-delete-btn" data-id="${blog.id}">Delete</button>` : ''}
          ` : ''}
        </div>
      </div>
    `).join('');

    // Add event listeners to blog cards
    addBlogEventListeners();
  }

  function getMediaPreviewHTML(blog) {
    if (!blog.media_url) {
      return '<div class="kb-file-icon generic"><i class="bi bi-file-earmark"></i></div>';
    }
    
    const icons = {
      image: 'bi-image',
      pdf: 'bi-file-earmark-pdf',
      video: 'bi-play-circle',
      audio: 'bi-mic',
      presentation: 'bi-easel'
    };
    
    const iconClass = icons[blog.media_type] || 'bi-file-earmark';
    const typeClass = blog.media_type || 'generic';
    
    if (blog.media_type === 'image') {
      return `<img src="${blog.media_url}" alt="${blog.title}" onerror="this.style.display='none'">`;
    } else {
      return `<div class="kb-file-icon ${typeClass}"><i class="bi ${iconClass}"></i></div>`;
    }
  }

  function addBlogEventListeners() {
    // Read More buttons
    document.querySelectorAll('.kb-read-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const blogId = btn.dataset.blogId;
        openBlogModal(blogId);
      });
    });

    // Edit buttons
    document.querySelectorAll('.kb-edit-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const blogId = btn.dataset.id;
        editBlog(blogId);
      });
    });

    // Delete buttons
    document.querySelectorAll('.kb-delete-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const blogId = btn.dataset.id;
        deleteBlog(blogId);
      });
    });

    // Click on blog card (opens modal)
    document.querySelectorAll('.kb-blog-card').forEach(card => {
      card.addEventListener('click', (e) => {
        // Only open modal if not clicking on action buttons
        if (!e.target.closest('.kb-blog-actions')) {
          const blogId = card.dataset.blogId;
          openBlogModal(blogId);
        }
      });
    });
  }

  // ----------------------
  // Blog Modal Functions
  // ----------------------
  async function openBlogModal(blogId) {
    try {
      console.log('Opening blog modal for ID:', blogId);
      const response = await fetch(`/api/blogs/${blogId}`);
      const data = await response.json();
      
      if (data.success) {
        currentBlogId = blogId;
        setupBlogModal(data.blog);
        openModal();
      } else {
        showToast('Failed to load blog', 'error');
      }
    } catch (error) {
      console.error('Error opening blog modal:', error);
      showToast('Error loading blog', 'error');
    }
  }

  function setupBlogModal(blog) {
    console.log('Setting up modal for blog:', blog);
    
    // Set basic info
    kbModalTitle.textContent = blog.title;
    kbModalCategory.innerHTML = `<i class="bi bi-tag"></i> ${blog.category}`;
    kbModalDate.innerHTML = `<i class="bi bi-calendar"></i> ${blog.created_at}`;
    kbModalAuthor.innerHTML = `<i class="bi bi-person"></i> ${blog.author}`;
    kbModalDescription.textContent = blog.content;
    
    // Set media content
    kbModalMediaContainer.innerHTML = getMediaContentHTML(blog);
    
    // Update like button
    updateLikeButton(blog);
    
    // Update comment count
    kbCommentCount.textContent = blog.comment_count;
    
    // Load comments
    loadComments(blog.id);
  }

  function getMediaContentHTML(blog) {
    if (!blog.media_url) {
      return '<div class="kb-no-media"><p>No media content available</p></div>';
    }
    
    switch (blog.media_type) {
      case 'image':
        return `
          <div class="kb-modal-media">
            <img src="${blog.media_url}" alt="${blog.title}" onerror="this.style.display='none'">
          </div>
        `;
      
      case 'pdf':
        return `
          <div class="kb-modal-media">
            <div class="kb-pdf-viewer">
              <iframe src="${blog.media_url}" frameborder="0"></iframe>
            </div>
            <div class="kb-download-section">
              <a href="${blog.media_url}" target="_blank" class="kb-download-btn">
                <i class="bi bi-download"></i> Download PDF
              </a>
            </div>
          </div>
        `;
      
      case 'video':
        return `
          <div class="kb-modal-media">
            <video controls style="width: 100%; max-height: 400px;">
              <source src="${blog.media_url}" type="video/mp4">
              Your browser does not support the video tag.
            </video>
          </div>
        `;
      
      case 'audio':
        return `
          <div class="kb-modal-media">
            <audio controls style="width: 100%;">
              <source src="${blog.media_url}" type="audio/mpeg">
              Your browser does not support the audio element.
            </audio>
          </div>
        `;
      
      case 'presentation':
        return `
          <div class="kb-modal-media">
            <div class="kb-presentation-viewer">
              <iframe src="https://view.officeapps.live.com/op/embed.aspx?src=${encodeURIComponent(blog.media_url)}" frameborder="0"></iframe>
            </div>
            <div class="kb-download-section">
              <a href="${blog.media_url}" target="_blank" class="kb-download-btn">
                <i class="bi bi-download"></i> Download Presentation
              </a>
            </div>
          </div>
        `;
      
      default:
        return `
          <div class="kb-modal-media">
            <div class="kb-generic-file" style="text-align: center; padding: 2rem;">
              <i class="bi bi-file-earmark" style="font-size: 3rem; color: #2e7d32;"></i>
              <p>File: ${blog.media_url.split('/').pop()}</p>
              <a href="${blog.media_url}" target="_blank" class="kb-download-btn">
                <i class="bi bi-download"></i> Download File
              </a>
            </div>
          </div>
        `;
    }
  }

  function updateLikeButton(blog) {
    if (kbModalLikeBtn && kbLikeCount) {
      kbLikeCount.textContent = blog.like_count;
      
      if (blog.has_liked) {
        kbModalLikeBtn.classList.add('liked');
        kbModalLikeBtn.innerHTML = `<i class="bi bi-heart-fill"></i> <span id="kbLikeCount">${blog.like_count}</span>`;
      } else {
        kbModalLikeBtn.classList.remove('liked');
        kbModalLikeBtn.innerHTML = `<i class="bi bi-heart"></i> <span id="kbLikeCount">${blog.like_count}</span>`;
      }
    }
  }

  function openModal() {
    if (kbBlogModal) {
      kbBlogModal.classList.add('active');
      document.body.style.overflow = 'hidden';
    }
  }

  function closeBlogModal() {
    if (kbBlogModal) {
      kbBlogModal.classList.remove('active');
      document.body.style.overflow = 'auto';
      currentBlogId = null;
    }
  }

  // ----------------------
  // Like/Comment Functions
  // ----------------------
  async function handleLike(e) {
    if (!currentBlogId) return;
    
    try {
      const response = await fetch(`/api/blogs/${currentBlogId}/like`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      
      const data = await response.json();
      
      if (data.success) {
        // Update like count immediately
        const currentCount = parseInt(kbLikeCount.textContent);
        if (data.action === 'liked') {
          kbModalLikeBtn.classList.add('liked');
          kbModalLikeBtn.innerHTML = `<i class="bi bi-heart-fill"></i> <span id="kbLikeCount">${data.like_count}</span>`;
          showToast('Liked!', 'success');
        } else {
          kbModalLikeBtn.classList.remove('liked');
          kbModalLikeBtn.innerHTML = `<i class="bi bi-heart"></i> <span id="kbLikeCount">${data.like_count}</span>`;
          showToast('Like removed', 'info');
        }
        
        // Reload the blog to get updated data
        const blogResponse = await fetch(`/api/blogs/${currentBlogId}`);
        const blogData = await blogResponse.json();
        if (blogData.success) {
          updateLikeButton(blogData.blog);
        }
      }
    } catch (error) {
      console.error('Error toggling like:', error);
      showToast('Error updating like', 'error');
    }
  }

  async function loadComments(blogId) {
    try {
      const response = await fetch(`/api/blogs/${blogId}/comments`);
      const comments = await response.json();
      renderComments(comments);
    } catch (error) {
      console.error('Error loading comments:', error);
      renderComments([]);
    }
  }

  function renderComments(comments) {
    if (!kbCommentsList) return;
    
    if (comments.length === 0) {
      kbCommentsList.innerHTML = '<p class="kb-no-comments">No comments yet. Be the first to comment!</p>';
      return;
    }

    kbCommentsList.innerHTML = comments.map(comment => `
      <div class="kb-comment-item" data-comment-id="${comment.id}">
        <div class="kb-comment-header">
          <span class="kb-comment-author">${escapeHtml(comment.author.username)}</span>
          <span class="kb-comment-date">${comment.created_at}</span>
          ${comment.can_edit || isAdmin ? `
            <div class="kb-comment-actions">
              ${comment.can_edit ? `<button class="kb-edit-comment-btn" data-comment-id="${comment.id}">Edit</button>` : ''}
              ${isAdmin ? `<button class="kb-delete-comment-btn" data-comment-id="${comment.id}">Delete</button>` : ''}
            </div>
          ` : ''}
        </div>
        <div class="kb-comment-text">${escapeHtml(comment.text)}</div>
      </div>
    `).join('');
    
    // Add comment event listeners
    setupCommentEventListeners();
  }

  function setupCommentEventListeners() {
    // Edit comment buttons
    document.querySelectorAll('.kb-edit-comment-btn').forEach(btn => {
      btn.addEventListener('click', handleEditComment);
    });
    
    // Delete comment buttons
    document.querySelectorAll('.kb-delete-comment-btn').forEach(btn => {
      btn.addEventListener('click', handleDeleteComment);
    });
  }

  async function handleCommentSubmit(e) {
    e.preventDefault();
    if (!currentBlogId) return;
    
    const textarea = e.target.querySelector('textarea');
    const text = textarea.value.trim();
    
    if (!text) {
      showToast('Comment cannot be empty', 'error');
      return;
    }
    
    try {
      const response = await fetch(`/api/blogs/${currentBlogId}/comments`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: text })
      });
      
      const data = await response.json();
      
      if (data.success) {
        textarea.value = '';
        showToast('Comment posted successfully', 'success');
        loadComments(currentBlogId);
        // Update comment count
        const blogResponse = await fetch(`/api/blogs/${currentBlogId}`);
        const blogData = await blogResponse.json();
        if (blogData.success) {
          kbCommentCount.textContent = blogData.blog.comment_count;
        }
      } else {
        showToast(data.error || 'Failed to post comment', 'error');
      }
    } catch (error) {
      console.error('Error posting comment:', error);
      showToast('Error posting comment', 'error');
    }
  }

  async function handleEditComment(e) {
    const commentId = e.target.dataset.commentId;
    const commentItem = e.target.closest('.kb-comment-item');
    const commentText = commentItem.querySelector('.kb-comment-text');
    
    const newText = prompt('Edit your comment:', commentText.textContent);
    if (newText === null || newText.trim() === '') return;
    
    try {
      const response = await fetch(`/api/comments/${commentId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: newText.trim() })
      });
      
      const data = await response.json();
      
      if (data.success) {
        showToast('Comment updated successfully', 'success');
        loadComments(currentBlogId);
      } else {
        showToast(data.error || 'Failed to update comment', 'error');
      }
    } catch (error) {
      console.error('Error updating comment:', error);
      showToast('Error updating comment', 'error');
    }
  }

  async function handleDeleteComment(e) {
    const commentId = e.target.dataset.commentId;
    
    if (!confirm('Are you sure you want to delete this comment?')) return;
    
    try {
      const response = await fetch(`/api/comments/${commentId}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' }
      });
      
      const data = await response.json();
      
      if (data.success) {
        showToast('Comment deleted successfully', 'success');
        loadComments(currentBlogId);
        // Update comment count
        const blogResponse = await fetch(`/api/blogs/${currentBlogId}`);
        const blogData = await blogResponse.json();
        if (blogData.success) {
          kbCommentCount.textContent = blogData.blog.comment_count;
        }
      } else {
        showToast(data.error || 'Failed to delete comment', 'error');
      }
    } catch (error) {
      console.error('Error deleting comment:', error);
      showToast('Error deleting comment', 'error');
    }
  }

  // ----------------------
  // Blog CRUD Operations
  // ----------------------
  async function editBlog(blogId) {
    try {
      const response = await fetch(`/api/blogs/${blogId}`);
      const data = await response.json();
      
      if (data.success) {
        const blog = data.blog;
        populateEditForm(blog);
      } else {
        showToast('Failed to load blog for editing', 'error');
      }
    } catch (error) {
      console.error('Error loading blog for edit:', error);
      showToast('Error loading blog', 'error');
    }
  }

  function populateEditForm(blog) {
    // Fill form fields
    document.getElementById('kbBlogTitle').value = blog.title;
    document.getElementById('kbCategorySelect').value = blog.category;
    document.getElementById('kbBlogContent').value = blog.content;
    
    // Handle media
    if (blog.media_url) {
      kbMediaUrlInput.value = blog.media_url;
      uploadTypeUrl.checked = true;
      toggleUploadType();
      previewUrl(blog.media_url);
    } else {
      uploadTypeFile.checked = true;
      toggleUploadType();
    }
    
    // Update UI for editing
    editingBlogId = blog.id;
    kbSubmitBtn.textContent = "Update Blog";
    kbCancelEdit.style.display = "inline-block";
    
    // Scroll to form
    kbForm.scrollIntoView({ behavior: "smooth", block: "center" });
    showToast("Editing blog post...", "info");
  }

  async function deleteBlog(blogId) {
    if (!confirm('Are you sure you want to delete this blog? This action cannot be undone.')) return;
    
    try {
      const response = await fetch(`/knowledge_base/delete/${blogId}`, {
        method: 'POST'
      });
      
      const data = await response.json();
      
      if (data.success) {
        showToast('Blog deleted successfully', 'success');
        loadBlogs(); // Reload the blog list
      } else {
        showToast(data.error || 'Failed to delete blog', 'error');
      }
    } catch (error) {
      console.error('Error deleting blog:', error);
      showToast('Error deleting blog', 'error');
    }
  }

  // ----------------------
  // Form Handling
  // ----------------------
  async function handleFormSubmit(e) {
    e.preventDefault();
    
    const title = document.getElementById('kbBlogTitle').value.trim();
    const category = document.getElementById('kbCategorySelect').value;
    const content = document.getElementById('kbBlogContent').value.trim();
    
    if (!title || !category || !content) {
      showToast('Please fill all required fields', 'error');
      return;
    }
    
    const formData = new FormData();
    formData.append('title', title);
    formData.append('category', category);
    formData.append('content', content);
    
    // Handle media
    if (uploadTypeFile.checked && kbMediaInput.files.length > 0) {
      formData.append('media_file', kbMediaInput.files[0]);
    } else if (uploadTypeUrl.checked && kbMediaUrlInput.value.trim()) {
      formData.append('media_url', kbMediaUrlInput.value.trim());
    }
    
    const url = editingBlogId 
      ? `/knowledge_base/edit/${editingBlogId}`
      : '/knowledge_base/post';
    
    try {
      kbSubmitBtn.disabled = true;
      kbSubmitBtn.textContent = editingBlogId ? 'Updating...' : 'Posting...';
      
      const response = await fetch(url, {
        method: 'POST',
        body: formData
      });
      
      const data = await response.json();
      
      if (data.success) {
        showToast(editingBlogId ? 'Blog updated successfully!' : 'Blog posted successfully!', 'success');
        resetForm();
        loadBlogs(); // Reload blogs to show the new/updated one
      } else {
        throw new Error(data.error || 'Operation failed');
      }
    } catch (error) {
      console.error('Error submitting blog:', error);
      showToast(error.message || 'Server error occurred', 'error');
    } finally {
      kbSubmitBtn.disabled = false;
      kbSubmitBtn.textContent = editingBlogId ? 'Update Blog' : (isAdmin ? 'Post Blog' : 'Share Knowledge');
    }
  }

  function resetForm() {
    if (kbForm) kbForm.reset();
    if (kbSubmitBtn) {
      kbSubmitBtn.textContent = isAdmin ? 'Post Blog' : 'Share Knowledge';
    }
    if (kbCancelEdit) kbCancelEdit.style.display = 'none';
    if (kbFilePreview) kbFilePreview.innerHTML = '';
    if (kbFileName) kbFileName.textContent = 'No file selected';
    editingBlogId = null;
    toggleUploadType();
  }

  // ----------------------
  // File Upload Handling
  // ----------------------
  function handleFileSelect() {
    if (kbMediaInput.files.length > 0) {
      const file = kbMediaInput.files[0];
      kbFileName.textContent = file.name;
      previewFile(file);
    } else {
      kbFileName.textContent = "No file selected";
      kbFilePreview.innerHTML = "";
    }
  }

  function handleUrlInput() {
    const url = kbMediaUrlInput.value.trim();
    if (url) {
      previewUrl(url);
    } else {
      kbFilePreview.innerHTML = "";
    }
  }

  function toggleUploadType() {
    const fileInputContainer = document.querySelector('.kb-file-input-container');
    
    if (uploadTypeFile.checked) {
      fileInputContainer.style.display = 'flex';
      kbMediaUrlInput.style.display = 'none';
      kbMediaUrlInput.disabled = true;
      kbMediaInput.disabled = false;
      kbFilePreview.innerHTML = "";
      kbFileName.textContent = "No file selected";
    } else {
      fileInputContainer.style.display = 'none';
      kbMediaUrlInput.style.display = 'block';
      kbMediaUrlInput.disabled = false;
      kbMediaInput.disabled = true;
      kbFilePreview.innerHTML = "";
      kbFileName.textContent = "No URL provided";
      
      if (kbMediaUrlInput.value.trim()) {
        previewUrl(kbMediaUrlInput.value.trim());
      }
    }
  }

  function previewFile(file) {
    kbFilePreview.innerHTML = "";
    
    if (file.type.startsWith("image/")) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const img = document.createElement("img");
        img.src = e.target.result;
        kbFilePreview.appendChild(img);
      };
      reader.readAsDataURL(file);
    } else {
      showFileInfo(file);
    }
  }

  function previewUrl(url) {
    kbFilePreview.innerHTML = "";
    
    if (url.match(/\.(jpg|jpeg|png|gif|bmp|webp)$/i)) {
      const img = document.createElement("img");
      img.src = url;
      img.onerror = () => showUrlInfo(url);
      kbFilePreview.appendChild(img);
    } else {
      showUrlInfo(url);
    }
  }

  function showFileInfo(file) {
    const iconClass = getFileIconClass(file.type, file.name);
    kbFilePreview.innerHTML = `
      <div class="kb-preview-info">
        <i class="bi ${iconClass}"></i>
        <p>${file.name}</p>
        <small>${(file.size / 1024 / 1024).toFixed(2)} MB</small>
      </div>
    `;
  }

  function showUrlInfo(url) {
    const iconClass = getFileIconClass('', url);
    const fileName = url.split('/').pop() || 'External File';
    kbFilePreview.innerHTML = `
      <div class="kb-preview-info">
        <i class="bi ${iconClass}"></i>
        <p>${fileName}</p>
        <small>${url}</small>
      </div>
    `;
  }

  function getFileIconClass(fileType, fileName) {
    if (fileType.startsWith('image/')) return 'bi-image';
    if (fileType === 'application/pdf') return 'bi-file-earmark-pdf';
    if (fileType.includes('presentation') || /\.(ppt|pptx)$/i.test(fileName)) return 'bi-easel';
    if (fileType.startsWith('video/')) return 'bi-play-circle';
    if (fileType.startsWith('audio/')) return 'bi-mic';
    return 'bi-file-earmark';
  }

  // ----------------------
  // Utility Functions
  // ----------------------
  function showToast(message, type = "success") {
    // Remove existing toasts
    document.querySelectorAll('.kb-toast').forEach(toast => toast.remove());
    
    const toast = document.createElement("div");
    toast.className = `kb-toast ${type}`;
    toast.innerHTML = `
      <i class="bi ${type === 'success' ? 'bi-check-circle' : type === 'error' ? 'bi-exclamation-circle' : 'bi-info-circle'}"></i>
      <span>${message}</span>
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => toast.classList.add("show"), 50);
    setTimeout(() => {
      toast.classList.remove("show");
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // Initialize upload type
  if (uploadTypeFile && uploadTypeUrl) {
    toggleUploadType();
  }
});
// Consulty Service
// Consultancy Service
document.addEventListener('DOMContentLoaded', () => {
    const consultantList = document.getElementById('consultantList');
    const latestConsultants = document.getElementById('latestConsultants');
    const searchInput = document.getElementById('consultancySearchInput');
    const consultantForm = document.getElementById('consultantForm');
    const adminPanelButton = document.getElementById('adminPanelButton');
    const adminPanel = document.getElementById('adminPanel');
    const toggleAdminPanel = document.getElementById('toggleAdminPanel');
    const refreshAdminData = document.getElementById('refreshAdminData');
    const categorySelect = document.getElementById('consultantCategorySelect');
    const categoryStats = document.getElementById('categoryStats');
    const statsContent = document.getElementById('statsContent');
    const pendingApplications = document.getElementById('pendingApplications');
    const categoriesList = document.getElementById('categoriesList');
    const newCategoryName = document.getElementById('newCategoryName');
    const addCategoryBtn = document.getElementById('addCategoryBtn');
    const reviewModal = document.getElementById('reviewModal');
    const reviewCategorySelect = document.getElementById('reviewCategorySelect');
    const declineReason = document.getElementById('declineReason');
    const approveBtn = document.getElementById('approveBtn');
    const declineBtn = document.getElementById('declineBtn');
    const applicationStatus = document.getElementById('applicationStatus');
    const consultantCount = document.getElementById('consultantCount');

    let currentReviewConsultantId = null;
    let isAdmin = false;

    // Toast container
    const toastContainer = document.createElement('div');
    toastContainer.id = 'toastContainer';
    toastContainer.style.cssText = `
        position: fixed;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
        z-index: 9999;
    `;
    document.body.appendChild(toastContainer);

    const showAlert = (msg, type='info') => {
        const toast = document.createElement('div');
        toast.innerHTML = msg;
        toast.style.cssText = `
            padding: 14px 20px;
            border-radius: 8px;
            color: #fff;
            font-family: Arial, sans-serif;
            font-size: 14px;
            min-width: 280px;
            max-width: 400px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.25);
            opacity: 0;
            transform: translateY(-20px);
            transition: all 0.4s ease;
        `;
        switch(type) {
            case 'success': toast.style.backgroundColor = '#4CAF50'; break;
            case 'danger': toast.style.backgroundColor = '#f44336'; break;
            case 'warning': toast.style.backgroundColor = '#ff9800'; break;
            default: toast.style.backgroundColor = '#2196F3';
        }
        toastContainer.appendChild(toast);
        requestAnimationFrame(() => {
            toast.style.opacity = '1';
            toast.style.transform = 'translateY(0)';
        });
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(-20px)';
            setTimeout(() => toast.remove(), 400);
        }, 4000);
    };

    // Debug function to test categories API
    const debugCategoriesAPI = async () => {
        try {
            console.log('🔍 Testing categories API endpoint...');
            console.log('📡 Making request to:', '/api/categories/all');
            
            const res = await fetch('/api/categories/all', { 
                credentials: 'same-origin',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });
            
            console.log('📡 Response status:', res.status, res.statusText);
            console.log('📡 Response OK:', res.ok);
            
            if (!res.ok) {
                throw new Error(`HTTP ${res.status}: ${res.statusText}`);
            }
            
            const text = await res.text();
            console.log('📡 Raw response text:', text);
            
            if (!text) {
                throw new Error('Empty response from server');
            }
            
            let data;
            try {
                data = JSON.parse(text);
                console.log('📡 Parsed JSON data:', data);
            } catch (parseError) {
                console.error('❌ JSON parse error:', parseError);
                throw new Error('Invalid JSON response from server');
            }
            
            return data;
        } catch (error) {
            console.error('❌ Categories API test failed:', error);
            return { success: false, message: error.message };
        }
    };

    // Load categories for dropdowns - ENHANCED VERSION
    const loadCategories = async () => {
        try {
            console.log('🔄 Starting categories load...');
            
            // Test the API first
            const debugData = await debugCategoriesAPI();
            
            if (!debugData) {
                throw new Error('No response from categories API');
            }
            
            if (debugData.success && debugData.categories) {
                const categories = debugData.categories;
                console.log(`✅ Successfully loaded ${categories.length} categories:`, categories);
                
                if (categories.length === 0) {
                    console.warn('⚠️ Categories array is empty');
                    showAlert('No categories found in system. Please contact administrator.', 'warning');
                }
                
                // Populate registration form dropdown
                if (categorySelect) {
                    const options = categories.map(cat => 
                        `<option value="${cat.id}">${cat.name}</option>`
                    ).join('');
                    categorySelect.innerHTML = '<option value="">Select Category</option>' + options;
                    console.log('✅ Registration dropdown updated with', categories.length, 'categories');
                } else {
                    console.error('❌ categorySelect element not found');
                }
                
                // Populate admin review modal dropdown
                if (reviewCategorySelect) {
                    const options = categories.map(cat => 
                        `<option value="${cat.id}">${cat.name}</option>`
                    ).join('');
                    reviewCategorySelect.innerHTML = '<option value="">Keep original category</option>' + options;
                    console.log('✅ Review modal dropdown updated with', categories.length, 'categories');
                } else {
                    console.error('❌ reviewCategorySelect element not found');
                }
                
                // Populate sidebar categories
                const categoriesSidebar = document.getElementById('consultancyCategories');
                if (categoriesSidebar) {
                    categoriesSidebar.innerHTML = categories.map(cat => 
                        `<li>${cat.name} (${cat.consultant_count || 0})</li>`
                    ).join('') || '<li>No categories available</li>';
                    console.log('✅ Sidebar categories updated');
                } else {
                    console.error('❌ consultancyCategories element not found');
                }
                
                showAlert(`✅ Loaded ${categories.length} categories successfully`, 'success');
                return categories;
                
            } else {
                const errorMsg = debugData.message || 'Unknown API error';
                console.error('❌ API returned error:', errorMsg);
                throw new Error(`Categories API error: ${errorMsg}`);
            }
            
        } catch (error) {
            console.error('❌ Critical error in loadCategories:', error);
            
            // Show detailed error to user
            let userMessage = 'Failed to load categories. ';
            if (error.message.includes('HTTP 404')) {
                userMessage += 'Categories API endpoint not found. ';
            } else if (error.message.includes('HTTP 500')) {
                userMessage += 'Server error. ';
            } else if (error.message.includes('JSON')) {
                userMessage += 'Invalid server response. ';
            } else if (error.message.includes('Network')) {
                userMessage += 'Network connection failed. ';
            }
            userMessage += 'Please check console for details.';
            
            showAlert(userMessage, 'danger');
            
            // Set fallback content
            const fallbackOption = '<option value="">No categories available - Please refresh page</option>';
            
            if (categorySelect) {
                categorySelect.innerHTML = fallbackOption;
            }
            if (reviewCategorySelect) {
                reviewCategorySelect.innerHTML = fallbackOption;
            }
            
            const categoriesSidebar = document.getElementById('consultancyCategories');
            if (categoriesSidebar) {
                categoriesSidebar.innerHTML = '<li>Error loading categories - Refresh page</li>';
            }
            
            return [];
        }
    };

    // Manual refresh function for debugging
    window.manualRefreshCategories = async () => {
        console.log('🔄 Manual categories refresh triggered');
        await loadCategories();
    };

    // Initialize app
    const initializeApp = async () => {
        console.log('🚀 Initializing consultancy app...');
        try {
            await checkAdminStatus();
            console.log('✅ Admin status checked');
            
            await loadCategories();
            console.log('✅ Categories loaded');
            
            await fetchConsultants();
            console.log('✅ Consultants fetched');
            
            console.log('🎉 App initialization complete');
        } catch (error) {
            console.error('❌ App initialization failed:', error);
            showAlert('App initialization failed. Please refresh the page.', 'danger');
        }
    };

    // Check if user is admin
    const checkAdminStatus = async () => {
        try {
            console.log('🔍 Checking admin status...');
            const userResponse = await fetch('/api/user/status', { credentials: 'same-origin' });
            
            if (userResponse.ok) {
                const userData = await userResponse.json();
                isAdmin = userData.is_admin || false;
                console.log('👤 User admin status:', isAdmin);
                
                if (isAdmin) {
                    adminPanelButton.style.display = 'block';
                    categoryStats.style.display = 'block';
                    await loadAdminData();
                    
                    // Hide registration form for admin
                    document.getElementById('userRegistrationSection').style.display = 'none';
                    console.log('✅ Admin panel activated');
                }
            } else {
                console.warn('⚠️ User status check failed:', userResponse.status);
            }
        } catch (error) {
            console.log('Admin check failed:', error);
            isAdmin = false;
        }
    };

    // Fetch consultants
    const fetchConsultants = async (search='') => {
        try {
            console.log('🔍 Fetching consultants, search:', search);
            const res = await fetch(`/api/consultants?q=${encodeURIComponent(search)}`, {
                credentials: 'same-origin'
            });
            
            if (!res.ok) throw new Error(`Server returned ${res.status}`);
            
            const data = await res.json();
            if (!data.success) throw new Error(data.message || 'Failed to fetch consultants');

            const consultants = data.consultants || [];
            console.log(`✅ Loaded ${consultants.length} consultants`);

            // Update consultant count
            consultantCount.textContent = `${consultants.length} consultants`;

            // Update consultant list
            consultantList.innerHTML = consultants.length > 0 ? 
                consultants.map(c => `
                    <div class="consultant-card">
                        <h4>${c.name}</h4>
                        <p><strong>Expertise:</strong> ${c.expertise}</p>
                        <p><strong>Experience:</strong> ${c.experience}</p>
                        <p><strong>Category:</strong> ${c.category}</p>
                    </div>
                `).join('') : '<p>No consultants found.</p>';

            // Update latest consultants
            latestConsultants.innerHTML = consultants.length > 0 ? 
                consultants.slice(0,5).map(c => `
                    <li>${c.name} (${c.category})</li>
                `).join('') : '<li>No consultants found.</li>';

        } catch(err) {
            console.error('❌ Error fetching consultants:', err);
            showAlert('🌐 Error fetching consultants', 'danger');
            consultantList.innerHTML = '<p>Error loading consultants.</p>';
            latestConsultants.innerHTML = '<li>Error loading consultants.</li>';
        }
    };

    // Load admin data
    const loadAdminData = async () => {
        if (!isAdmin) return;
        
        console.log('👨‍💼 Loading admin data...');
        try {
            await loadCategories();
            await loadPendingApplications();
            await loadCategoryStats();
            await loadCategoriesForManagement();
            console.log('✅ Admin data loaded successfully');
        } catch (error) {
            console.error('❌ Error loading admin data:', error);
        }
    };

    // Load category stats
    const loadCategoryStats = async () => {
        try {
            const res = await fetch('/api/categories/all', { credentials: 'same-origin' });
            const data = await res.json();
            
            if (data.success) {
                statsContent.innerHTML = data.categories.map(cat => `
                    <div style="margin: 5px 0; padding: 5px; background: white; border-radius: 4px;">
                        <strong>${cat.name}</strong>
                        <div style="font-size: 0.8em; color: #666;">
                            Approved: ${cat.consultant_count} | Pending: ${cat.pending_count}
                        </div>
                    </div>
                `).join('');
            }
        } catch (error) {
            console.error('Error loading stats:', error);
        }
    };

    // Load pending applications
    const loadPendingApplications = async () => {
        try {
            const res = await fetch('/api/consultants/pending', { credentials: 'same-origin' });
            const data = await res.json();
            
            if (data.success) {
                const applications = data.pending_consultants || [];
                console.log(`📋 Loaded ${applications.length} pending applications`);
                
                pendingApplications.innerHTML = applications.length > 0 ? 
                    applications.map(app => `
                        <div class="pending-application" data-id="${app.id}" style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 15px;">
                            <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 10px;">
                                <div>
                                    <h4 style="margin: 0;">${app.name}</h4>
                                    <p style="margin: 0; color: #666;">${app.email}</p>
                                </div>
                                <span style="background: #6c757d; color: white; padding: 4px 8px; border-radius: 12px; font-size: 0.8em;">${app.category}</span>
                            </div>
                            <div>
                                <p><strong>Expertise:</strong> ${app.expertise}</p>
                                <p><strong>Experience:</strong> ${app.experience}</p>
                                <p><strong>Applied:</strong> ${app.created_at}</p>
                            </div>
                            <div style="text-align: right; margin-top: 10px;">
                                <button class="btn-review" onclick="openReviewModal(${app.id})" style="background: #007bff; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">
                                    Review
                                </button>
                            </div>
                        </div>
                    `).join('') : '<p>No pending applications</p>';
            }
        } catch (error) {
            console.error('Error loading pending applications:', error);
            pendingApplications.innerHTML = '<p>Error loading applications</p>';
        }
    };

    // Load categories for management
    const loadCategoriesForManagement = async () => {
        try {
            const res = await fetch('/api/categories/all', { credentials: 'same-origin' });
            const data = await res.json();
            
            if (data.success) {
                const categories = data.categories || [];
                console.log(`🏷️ Loaded ${categories.length} categories for management`);
                
                categoriesList.innerHTML = categories.length > 0 ? 
                    categories.map(cat => `
                        <div class="category-item" style="display: flex; justify-content: space-between; align-items: center; padding: 10px; border: 1px solid #ddd; border-radius: 4px; margin-bottom: 8px;">
                            <div>
                                <strong>${cat.name}</strong>
                                <div style="font-size: 0.8em; color: #666;">
                                    Approved: ${cat.consultant_count} | Pending: ${cat.pending_count}
                                </div>
                            </div>
                            <div>
                                <button onclick="editCategory(${cat.id}, '${cat.name}')" style="background: #ffc107; color: black; border: none; padding: 5px 10px; border-radius: 4px; margin-right: 5px; cursor: pointer;">Edit</button>
                                <button onclick="deleteCategory(${cat.id})" style="background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;" ${cat.total_consultants > 0 ? 'disabled' : ''}>Delete</button>
                            </div>
                        </div>
                    `).join('') : '<p>No categories available</p>';
            }
        } catch (error) {
            console.error('Error loading categories for management:', error);
            categoriesList.innerHTML = '<p>Error loading categories</p>';
        }
    };

    // Open review modal
    window.openReviewModal = (consultantId) => {
        console.log('📝 Opening review modal for consultant:', consultantId);
        currentReviewConsultantId = consultantId;
        const application = document.querySelector(`.pending-application[data-id="${consultantId}"]`);
        const applicantInfo = document.getElementById('applicantInfo');
        
        if (application) {
            applicantInfo.innerHTML = application.innerHTML;
        }
        
        reviewModal.style.display = 'block';
        declineReason.value = '';
        reviewCategorySelect.value = '';
    };

    // Close modal
    reviewModal.querySelector('.close').addEventListener('click', () => {
        reviewModal.style.display = 'none';
    });

    // Approve consultant
    approveBtn.addEventListener('click', async () => {
        if (!currentReviewConsultantId) return;

        const newCategoryId = reviewCategorySelect.value || null;
        console.log('✅ Approving consultant:', currentReviewConsultantId, 'with category:', newCategoryId);
        
        try {
            const res = await fetch(`/api/consultants/${currentReviewConsultantId}/review`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ action: 'approve', new_category_id: newCategoryId })
            });

            const data = await res.json();
            if (data.success) {
                showAlert(data.message, 'success');
                reviewModal.style.display = 'none';
                await loadAdminData();
                await fetchConsultants();
            } else {
                showAlert(data.message, 'danger');
            }
        } catch (error) {
            console.error('Error approving consultant:', error);
            showAlert('Error approving consultant', 'danger');
        }
    });

    // Decline consultant
    declineBtn.addEventListener('click', async () => {
        if (!currentReviewConsultantId) return;

        const reason = declineReason.value;
        console.log('❌ Declining consultant:', currentReviewConsultantId, 'reason:', reason);
        
        try {
            const res = await fetch(`/api/consultants/${currentReviewConsultantId}/review`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ action: 'decline', decline_reason: reason })
            });

            const data = await res.json();
            if (data.success) {
                showAlert(data.message, 'success');
                reviewModal.style.display = 'none';
                await loadAdminData();
            } else {
                showAlert(data.message, 'danger');
            }
        } catch (error) {
            console.error('Error declining consultant:', error);
            showAlert('Error declining consultant', 'danger');
        }
    });

    // Add new category
    addCategoryBtn.addEventListener('click', async () => {
        const name = newCategoryName.value.trim();
        if (!name) {
            showAlert('Please enter category name', 'warning');
            return;
        }

        console.log('➕ Adding new category:', name);
        
        try {
            const res = await fetch('/api/categories', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ name })
            });

            const data = await res.json();
            if (data.success) {
                showAlert(data.message, 'success');
                newCategoryName.value = '';
                await loadCategories();
                await loadCategoriesForManagement();
                await loadCategoryStats();
            } else {
                showAlert(data.message, 'danger');
            }
        } catch (error) {
            console.error('Error adding category:', error);
            showAlert('Error adding category', 'danger');
        }
    });

    // Edit category
    window.editCategory = (id, currentName) => {
        const newName = prompt('Enter new category name:', currentName);
        if (newName && newName !== currentName) {
            console.log('✏️ Editing category:', id, 'from', currentName, 'to', newName);
            
            fetch(`/api/categories/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ name: newName })
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showAlert(data.message, 'success');
                    loadCategories();
                    loadCategoriesForManagement();
                    loadCategoryStats();
                } else {
                    showAlert(data.message, 'danger');
                }
            })
            .catch(error => {
                console.error('Error updating category:', error);
                showAlert('Error updating category', 'danger');
            });
        }
    };

    // Delete category
    window.deleteCategory = (id) => {
        if (confirm('Are you sure you want to delete this category?')) {
            console.log('🗑️ Deleting category:', id);
            
            fetch(`/api/categories/${id}`, {
                method: 'DELETE',
                credentials: 'same-origin'
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showAlert(data.message, 'success');
                    loadCategories();
                    loadCategoriesForManagement();
                    loadCategoryStats();
                } else {
                    showAlert(data.message, 'danger');
                }
            })
            .catch(error => {
                console.error('Error deleting category:', error);
                showAlert('Error deleting category', 'danger');
            });
        }
    };

    // Toggle admin panel
    toggleAdminPanel.addEventListener('click', () => {
        const isVisible = adminPanel.style.display === 'block';
        adminPanel.style.display = isVisible ? 'none' : 'block';
        console.log('👨‍💼 Admin panel toggled:', adminPanel.style.display);
    });

    // Refresh admin data
    refreshAdminData.addEventListener('click', async () => {
        console.log('🔄 Refreshing admin data...');
        await loadCategories();
        await loadAdminData();
        showAlert('Admin data refreshed', 'success');
    });

    // Registration form
    consultantForm.addEventListener('submit', async e => {
        e.preventDefault();

        // Prevent admin from registering
        if (isAdmin) {
            showAlert('Administrators cannot register as consultants.', 'warning');
            return;
        }

        const expertise = document.getElementById('consultantExpertise').value.trim();
        const experience = document.getElementById('consultantExperience').value.trim();
        const category_id = document.getElementById('consultantCategorySelect').value;

        console.log('📝 Form submission - Expertise:', expertise, 'Category:', category_id);

        if (!expertise || !experience || !category_id) {
            showAlert('⚠️ All fields are required', 'warning');
            return;
        }

        const submitBtn = consultantForm.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.textContent = 'Submitting...';

        try {
            const res = await fetch('/api/consultants/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'same-origin',
                body: JSON.stringify({ expertise, experience, category_id })
            });

            const data = await res.json();
            if (data.success) {
                showAlert(data.message || '✅ Application submitted for approval!', 'success');
                consultantForm.reset();
                await fetchConsultants();
            } else {
                showAlert(data.message || '❌ Failed to register consultant.', 'danger');
            }

        } catch(err) {
            console.error('❌ Registration error:', err);
            showAlert('🌐 Network error. Try again.', 'danger');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Register';
        }
    });

    // Search functionality
    searchInput.addEventListener('input', () => {
        console.log('🔍 Search input:', searchInput.value);
        fetchConsultants(searchInput.value);
    });

    // Close modal when clicking outside
    window.addEventListener('click', (e) => {
        if (e.target === reviewModal) {
            reviewModal.style.display = 'none';
        }
    });

    // Add temporary debug button to HTML for testing
    const addDebugButton = () => {
        const debugBtn = document.createElement('button');
        debugBtn.textContent = '🔄 Debug Categories';
        debugBtn.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #ff9800;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            z-index: 10000;
            font-size: 12px;
        `;
        debugBtn.onclick = manualRefreshCategories;
        document.body.appendChild(debugBtn);
    };

    // Add debug button for testing
    addDebugButton();

    // Initialize the application
    initializeApp();
});
// Ai powerd Plant Doctor
// Premium AI Plant Doctor JavaScript
class AIPlantDoctor {
    constructor() {
        this.chatHistory = JSON.parse(localStorage.getItem('plantDoctorChats')) || [];
        this.currentChatId = null;
        this.isAnalyzing = false;
        this.currentImage = null;
        
        this.initializeEventListeners();
        this.loadChatHistory();
        this.startNewChat();
        this.createScrollToBottomButton();
    }

    initializeEventListeners() {
        // File upload
        const plantImageInput = document.getElementById('plantImage');
        plantImageInput.addEventListener('change', (e) => this.handleImageUpload(e));
        
        // Attachment button
        document.getElementById('attachmentBtn').addEventListener('click', () => {
            plantImageInput.click();
        });
        
        // Chat input
        const chatInput = document.getElementById('chatInput');
        const sendButton = document.getElementById('sendButton');
        
        chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });
        
        sendButton.addEventListener('click', () => this.sendMessage());
        
        // Enable send button when typing
        chatInput.addEventListener('input', () => {
            sendButton.disabled = !chatInput.value.trim();
        });
        
        // Chat actions
        document.getElementById('newChat').addEventListener('click', () => this.startNewChat());
        document.getElementById('refreshHistory').addEventListener('click', () => this.loadChatHistory());
        document.getElementById('clearAllHistory').addEventListener('click', () => this.clearAllHistory());
        
        // Scroll events
        const chatMessages = document.getElementById('chatMessages');
        chatMessages.addEventListener('scroll', () => this.handleScroll());
    }

    createScrollToBottomButton() {
        const button = document.createElement('button');
        button.className = 'scroll-to-bottom';
        button.innerHTML = '<i class="fas fa-chevron-down"></i>';
        button.title = 'Scroll to bottom';
        button.onclick = () => this.scrollToBottom();
        
        const chatMain = document.querySelector('.chat-main');
        chatMain.style.position = 'relative';
        chatMain.appendChild(button);
        
        this.scrollButton = button;
    }

    handleScroll() {
        const chatMessages = document.getElementById('chatMessages');
        const scrollTop = chatMessages.scrollTop;
        const scrollHeight = chatMessages.scrollHeight;
        const clientHeight = chatMessages.clientHeight;
        
        // Show scroll button if not at bottom
        if (scrollHeight - scrollTop - clientHeight > 100) {
            this.scrollButton.classList.add('show');
        } else {
            this.scrollButton.classList.remove('show');
        }
    }

    triggerImageUpload() {
        document.getElementById('plantImage').click();
    }

    handleImageUpload(event) {
        const file = event.target.files[0];
        if (!file) return;
        
        if (!this.validateImage(file)) return;
        
        this.showImagePreview(file);
    }

    validateImage(file) {
        const validTypes = ['image/jpeg', 'image/png', 'image/webp'];
        const maxSize = 5 * 1024 * 1024;

        if (!validTypes.includes(file.type)) {
            this.showNotification('Please upload a valid image (JPG, PNG, WebP)', 'error');
            return false;
        }

        if (file.size > maxSize) {
            this.showNotification('Image size should be less than 5MB', 'error');
            return false;
        }

        return true;
    }

    showImagePreview(file) {
        const reader = new FileReader();
        
        reader.onload = (e) => {
            this.currentImage = file;
            document.getElementById('previewImage').src = e.target.result;
            document.getElementById('uploadPreviewSection').style.display = 'block';
            this.scrollToBottom();
        };
        
        reader.readAsDataURL(file);
    }

    removeUploadedImage() {
        this.currentImage = null;
        document.getElementById('plantImage').value = '';
        document.getElementById('uploadPreviewSection').style.display = 'none';
        this.showNotification('Image removed', 'info');
    }

    cancelUpload() {
        this.removeUploadedImage();
    }

    async analyzeUploadedImage() {
        if (!this.currentImage || this.isAnalyzing) return;
        
        this.isAnalyzing = true;
        this.addUserMessage('📸 Plant photo uploaded for analysis', true);
        
        // Hide upload section
        document.getElementById('uploadPreviewSection').style.display = 'none';
        
        // Show typing indicator
        const typingId = this.showTypingIndicator();
        
        try {
            // Simulate API call
            const result = await this.simulateAIAnalysis(this.currentImage);
            
            // Remove typing and show results
            this.removeMessage(typingId);
            this.showAnalysisResults(result);
            
            // Save to history
            this.saveToHistory('Image Analysis', `Analyzed ${result.plantName}`);
            
        } catch (error) {
            this.removeMessage(typingId);
            this.addBotMessage('❌ Sorry, I encountered an error while analyzing your image. Please try again.');
            console.error('Analysis error:', error);
        }
        
        this.isAnalyzing = false;
        this.currentImage = null;
    }

    async simulateAIAnalysis(file) {
        // Simulate API processing time
        await new Promise(resolve => setTimeout(resolve, 3000));
        
        // Mock AI response with realistic data
        const mockDiseases = [
            {
                name: "Tomato Early Blight",
                confidence: 87,
                type: "fungal",
                treatment: [
                    "Remove and destroy infected leaves immediately",
                    "Apply copper-based fungicide every 7-10 days",
                    "Use chlorothalonil or mancozeb sprays",
                    "Improve air circulation around plants",
                    "Water at the base to keep leaves dry"
                ],
                prevention: [
                    "Rotate crops annually (3-4 year cycle)",
                    "Use disease-resistant tomato varieties",
                    "Space plants properly for good air flow",
                    "Stake plants to keep leaves off ground",
                    "Apply mulch to prevent soil splashing"
                ],
                symptoms: [
                    "Dark brown spots with concentric rings",
                    "Yellowing around the spots",
                    "Lower leaves affected first",
                    "Spots may have yellow halos"
                ]
            }
        ];
        
        return {
            plantName: "Tomato Plant",
            diseases: mockDiseases,
            overallHealth: "Needs Attention",
            healthScore: 6.2,
            recommendations: "Immediate treatment recommended for Early Blight. Start fungicide application within 2-3 days."
        };
    }

    showAnalysisResults(result) {
        let message = `
            <h4><i class="fas fa-diagnoses"></i> AI Analysis Complete</h4>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 15px 0;">
                <div style="background: #e6fffa; padding: 15px; border-radius: 10px; border-left: 4px solid #38b2ac;">
                    <strong><i class="fas fa-seedling"></i> Plant Identified</strong>
                    <p style="margin: 8px 0 0 0; font-size: 1.1rem;">${result.plantName}</p>
                </div>
                <div style="background: #fff5f5; padding: 15px; border-radius: 10px; border-left: 4px solid #fc8181;">
                    <strong><i class="fas fa-heartbeat"></i> Health Status</strong>
                    <p style="margin: 8px 0 0 0; font-size: 1.1rem;">${result.overallHealth}</p>
                </div>
            </div>
            <p><strong>Recommendation:</strong> ${result.recommendations}</p>
        `;
        
        result.diseases.forEach(disease => {
            message += `
                <div class="treatment-card">
                    <h5><i class="fas fa-bug"></i> ${disease.name} (${disease.confidence}% confidence)</h5>
                    
                    <div style="margin-top: 15px;">
                        <strong><i class="fas fa-stethoscope"></i> Symptoms:</strong>
                        <ul style="margin-top: 8px;">
                            ${disease.symptoms.map(s => `<li>${s}</li>`).join('')}
                        </ul>
                    </div>
                    
                    <div style="margin-top: 15px;">
                        <strong><i class="fas fa-prescription-bottle"></i> Treatment:</strong>
                        <ul style="margin-top: 8px;">
                            ${disease.treatment.map(t => `<li>${t}</li>`).join('')}
                        </ul>
                    </div>
                    
                    <div style="margin-top: 15px;">
                        <strong><i class="fas fa-shield-alt"></i> Prevention:</strong>
                        <ul style="margin-top: 8px;">
                            ${disease.prevention.map(p => `<li>${p}</li>`).join('')}
                        </ul>
                    </div>
                </div>
            `;
        });
        
        this.addBotMessage(message);
    }

    sendMessage() {
        const chatInput = document.getElementById('chatInput');
        const message = chatInput.value.trim();
        
        if (!message) return;
        
        this.addUserMessage(message);
        chatInput.value = '';
        document.getElementById('sendButton').disabled = true;
        
        // Generate AI response
        this.generateAIResponse(message);
    }

    async generateAIResponse(userMessage) {
        // Show typing indicator
        const typingId = this.showTypingIndicator();
        
        // Simulate AI processing
        await new Promise(resolve => setTimeout(resolve, 1500 + Math.random() * 1000));
        
        this.removeMessage(typingId);
        
        // Enhanced response logic
        const responses = {
            'hello': 'Hello! I\'m AgroBot, your AI plant doctor. How can I assist with your plants today? You can upload a photo or describe the issue.',
            'hi': 'Hi there! I\'m ready to help diagnose plant issues and provide treatment recommendations. What\'s concerning you about your plants?',
            'help': 'I can help you with:\n• Plant disease identification from photos\n• Treatment recommendations\n• Prevention strategies\n• General plant care advice\n\nJust upload a clear photo for the best diagnosis or describe your plant\'s symptoms!',
            'disease': 'For accurate disease identification, please upload a clear photo showing:\n• The affected leaves/plant parts\n• The overall plant condition\n• Any unusual spots, discoloration, or growths\n\nI\'ll analyze it and provide specific treatment advice.',
            'treatment': 'I can recommend specific treatments once I analyze your plant photos. Treatment depends on the disease type, severity, and plant species. Please upload an image for personalized advice.',
            'prevention': 'Prevention is key! I can provide specific prevention tips based on your plants. General strategies include crop rotation, proper spacing, and good watering practices.',
            'upload': 'Great! Click the attachment icon (<i class="fas fa-image"></i>) or use the "Upload Photo" button to share an image. I\'ll analyze it and provide a detailed diagnosis.',
            'thanks': 'You\'re welcome! I\'m here to help your plants thrive. Feel free to ask more questions or upload additional photos anytime! 🪴',
            'default': 'I understand you\'re concerned about your plant\'s health. For the most accurate diagnosis and treatment recommendations, please upload a clear photo showing the affected areas. Alternatively, you can describe the symptoms in detail, and I\'ll do my best to help!'
        };
        
        const lowerMessage = userMessage.toLowerCase();
        let response = responses['default'];
        
        for (const [key, value] of Object.entries(responses)) {
            if (lowerMessage.includes(key)) {
                response = value;
                break;
            }
        }
        
        this.addBotMessage(response);
        this.saveToHistory('Chat', userMessage.substring(0, 30) + '...');
    }

    showCommonDiseases() {
        const diseases = `
            <h4><i class="fas fa-bug"></i> Common Plant Diseases</h4>
            <div style="display: grid; gap: 12px; margin-top: 15px;">
                <div style="padding: 15px; background: #fff5f5; border-radius: 10px; border-left: 4px solid #fc8181;">
                    <strong><i class="fas fa-leaf"></i> Early Blight</strong>
                    <p style="margin: 8px 0 0 0; color: #666;">Dark spots with concentric rings on leaves</p>
                </div>
                <div style="padding: 15px; background: #f0fff4; border-radius: 10px; border-left: 4px solid #48bb78;">
                    <strong><i class="fas fa-leaf"></i> Powdery Mildew</strong>
                    <p style="margin: 8px 0 0 0; color: #666;">White powdery coating on leaves and stems</p>
                </div>
                <div style="padding: 15px; background: #e6fffa; border-radius: 10px; border-left: 4px solid #38b2ac;">
                    <strong><i class="fas fa-leaf"></i> Late Blight</strong>
                    <p style="margin: 8px 0 0 0; color: #666;">Water-soaked lesions that turn brown and papery</p>
                </div>
            </div>
            <p style="margin-top: 15px; text-align: center;"><i class="fas fa-camera"></i> Upload a photo for specific diagnosis and treatment recommendations!</p>
        `;
        
        this.addBotMessage(diseases);
        this.saveToHistory('Common Diseases', 'Viewed common plant diseases');
    }

    showPreventionTips() {
        const tips = `
            <h4><i class="fas fa-shield-alt"></i> Plant Disease Prevention</h4>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 15px;">
                <div style="padding: 12px; background: #f0fff4; border-radius: 8px;">
                    <strong><i class="fas fa-sync-alt"></i> Crop Rotation</strong>
                    <p style="margin: 5px 0 0 0; font-size: 0.9rem;">Change planting locations annually to prevent soil-borne diseases</p>
                </div>
                <div style="padding: 12px; background: #e6fffa; border-radius: 8px;">
                    <strong><i class="fas fa-arrows-alt-h"></i> Proper Spacing</strong>
                    <p style="margin: 5px 0 0 0; font-size: 0.9rem;">Ensure good air circulation between plants</p>
                </div>
                <div style="padding: 12px; background: #f0fff4; border-radius: 8px;">
                    <strong><i class="fas fa-tint"></i> Water Management</strong>
                    <p style="margin: 5px 0 0 0; font-size: 0.9rem;">Water at plant base, avoid wetting leaves</p>
                </div>
                <div style="padding: 12px; background: #e6fffa; border-radius: 8px;">
                    <strong><i class="fas fa-tools"></i> Clean Tools</strong>
                    <p style="margin: 5px 0 0 0; font-size: 0.9rem;">Disinfect gardening tools regularly</p>
                </div>
            </div>
        `;
        
        this.addBotMessage(tips);
        this.saveToHistory('Prevention Tips', 'Viewed prevention strategies');
    }

    addUserMessage(text, isImage = false) {
        const messageId = 'msg-' + Date.now();
        const messageHTML = `
            <div class="message user-message" id="${messageId}">
                <div class="message-avatar">
                    <i class="fas fa-user"></i>
                </div>
                <div class="message-content">
                    <div class="message-text">
                        <p>${this.escapeHtml(text)}</p>
                    </div>
                    <div class="message-time">${this.getCurrentTime()}</div>
                </div>
            </div>
        `;
        
        document.getElementById('chatMessages').insertAdjacentHTML('beforeend', messageHTML);
        this.scrollToBottom();
    }

    addBotMessage(html) {
        const messageId = 'msg-' + Date.now();
        const messageHTML = `
            <div class="message bot-message" id="${messageId}">
                <div class="message-avatar">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                    <div class="message-text">
                        ${html}
                    </div>
                    <div class="message-time">${this.getCurrentTime()}</div>
                </div>
            </div>
        `;
        
        document.getElementById('chatMessages').insertAdjacentHTML('beforeend', messageHTML);
        this.scrollToBottom();
        return messageId;
    }

    showTypingIndicator() {
        const messageId = 'typing-' + Date.now();
        const messageHTML = `
            <div class="message bot-message" id="${messageId}">
                <div class="message-avatar">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                    <div class="message-text">
                        <p>AgroBot is typing...</p>
                        <div class="typing-indicator">
                            <div class="typing-dot"></div>
                            <div class="typing-dot"></div>
                            <div class="typing-dot"></div>
                        </div>
                    </div>
                </div>
            </div>
        `;
        
        document.getElementById('chatMessages').insertAdjacentHTML('beforeend', messageHTML);
        this.scrollToBottom();
        return messageId;
    }

    removeMessage(messageId) {
        const element = document.getElementById(messageId);
        if (element) {
            element.remove();
        }
    }

    showNotification(text, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'error' ? '#fc8181' : '#48bb78'};
            color: white;
            padding: 15px 25px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            z-index: 10000;
            animation: slideInRight 0.3s ease;
            font-weight: 600;
        `;
        notification.textContent = text;
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }

    scrollToBottom() {
        const container = document.getElementById('chatMessages');
        setTimeout(() => {
            container.scrollTop = container.scrollHeight;
            this.scrollButton.classList.remove('show');
        }, 100);
    }

    getCurrentTime() {
        return new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Chat History Management
    startNewChat() {
        this.currentChatId = 'chat-' + Date.now();
        document.getElementById('chatMessages').innerHTML = `
            <div class="message bot-message">
                <div class="message-avatar">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                    <div class="message-text">
                        <p>Hello! I'm AgroBot, your AI plant doctor 🌱</p>
                        <p>I can help you identify plant diseases and provide treatment recommendations. You can:</p>
                        <ul>
                            <li><i class="fas fa-camera"></i> Upload photos of diseased plants</li>
                            <li><i class="fas fa-search"></i> Get instant AI diagnosis</li>
                            <li><i class="fas fa-pills"></i> Receive treatment plans</li>
                            <li><i class="fas fa-history"></i> Save chat history</li>
                        </ul>
                        <p><strong>Upload a photo or describe your plant issue to get started!</strong></p>
                    </div>
                    <div class="message-time">Just now</div>
                </div>
            </div>
        `;
        
        this.removeUploadedImage();
        this.saveToHistory('New Chat', 'Started new conversation');
        this.showNotification('New chat started!', 'success');
    }

    saveToHistory(title, preview) {
        const chatItem = {
            id: this.currentChatId,
            title: title,
            preview: preview,
            timestamp: new Date().toISOString(),
            date: new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        };
        
        // Remove existing chat with same ID
        this.chatHistory = this.chatHistory.filter(chat => chat.id !== this.currentChatId);
        
        // Add to beginning of history
        this.chatHistory.unshift(chatItem);
        
        // Keep only last 50 chats
        this.chatHistory = this.chatHistory.slice(0, 50);
        
        this.saveHistory();
        this.loadChatHistory();
    }

    loadChatHistory() {
        const historyList = document.getElementById('historyList');
        
        if (this.chatHistory.length === 0) {
            historyList.innerHTML = `
                <div class="empty-history">
                    <i class="fas fa-comments"></i>
                    <p>No recent chats</p>
                    <span>Start a conversation to see history</span>
                </div>
            `;
            return;
        }
        
        historyList.innerHTML = this.chatHistory.map(chat => `
            <div class="history-item ${chat.id === this.currentChatId ? 'active' : ''}" 
                 onclick="plantDoctor.loadChat('${chat.id}')">
                <div class="history-title">
                    <i class="fas fa-comment"></i> ${this.escapeHtml(chat.title)}
                </div>
                <div class="history-preview">${this.escapeHtml(chat.preview)}</div>
                <div class="history-time"><i class="fas fa-clock"></i> ${chat.date}</div>
            </div>
        `).join('');
    }

    loadChat(chatId) {
        // For demo purposes, just start a new chat and show message
        this.startNewChat();
        this.addBotMessage('Chat history loaded! In a real application, this would restore your previous conversation with all messages, images, and analysis results.');
        this.showNotification('Chat history loaded', 'info');
    }

    clearAllHistory() {
        if (confirm('Are you sure you want to clear all chat history? This action cannot be undone.')) {
            this.chatHistory = [];
            this.saveHistory();
            this.loadChatHistory();
            this.showNotification('All chat history cleared', 'success');
        }
    }

    saveHistory() {
        localStorage.setItem('plantDoctorChats', JSON.stringify(this.chatHistory));
    }
}

// Initialize the AI Plant Doctor when page loads
let plantDoctor;

document.addEventListener('DOMContentLoaded', function() {
    plantDoctor = new AIPlantDoctor();
    
    // Add notification animations
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        @keyframes slideOutRight {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);
});


// Audio / Video Chatting 
// Enhanced Video Consultation JavaScript - Complete Implementation
class VideoConsultation {
    constructor() {
        this.localStream = null;
        this.remoteStream = null;
        this.peerConnection = null;
        this.isCallActive = false;
        this.isVideoEnabled = true;
        this.isAudioEnabled = true;
        this.currentConsultant = null;
        this.pendingRequests = [];
        this.isExpert = false;
        this.isAdmin = false;
        this.callStartTime = null;
        this.callTimer = null;
        this.currentCallRequestId = null;
        
        this.init();
    }

    init() {
        console.log('Initializing Enhanced Video Consultation System...');
        this.setupEventListeners();
        this.loadAvailableExperts();
        this.updateStats();
        this.checkUserRole();
        this.loadPendingRequests();
        this.showRequestsCard();
        this.loadAdminPanel();
        this.loadConsultationHistory();
        this.loadAdminRecords();
        
        // Initialize demo user
        if (!localStorage.getItem('userName')) {
            localStorage.setItem('userName', 'Demo User');
        }
        
        console.log('Enhanced Video Consultation System initialized successfully');
    }

    setupEventListeners() {
        // Modal close buttons
        document.querySelectorAll('.close').forEach(closeBtn => {
            closeBtn.addEventListener('click', () => this.closeModal());
        });

        // Click outside modal to close
        window.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeModal();
            }
        });

        // Chat input enter key
        const chatInput = document.getElementById('chatInput');
        if (chatInput) {
            chatInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    this.sendMessage();
                }
            });
        }
    }

    checkUserRole() {
        const urlParams = new URLSearchParams(window.location.search);
        this.isExpert = urlParams.get('expert') === 'true' || localStorage.getItem('userRole') === 'expert';
        this.isAdmin = urlParams.get('admin') === 'true' || localStorage.getItem('userRole') === 'admin';
        
        console.log('User Role:', {
            isExpert: this.isExpert,
            isAdmin: this.isAdmin
        });
        
        if (this.isExpert) {
            const pendingSection = document.getElementById('pendingRequestsSection');
            const expertControls = document.getElementById('expertControlsSection');
            const acceptedSection = document.getElementById('acceptedRequestsSection');
            
            if (pendingSection) pendingSection.style.display = 'block';
            if (expertControls) expertControls.style.display = 'block';
            if (acceptedSection) acceptedSection.style.display = 'block';
        }
        
        if (this.isAdmin) {
            const adminSection = document.getElementById('adminPanelSection');
            const adminRecords = document.getElementById('adminRecordsSection');
            
            if (adminSection) adminSection.style.display = 'block';
            if (adminRecords) adminRecords.style.display = 'block';
            this.loadAdminStatistics();
        }
        
        // Show user requests section for all non-admin users
        if (!this.isAdmin) {
            this.showRequestsCard();
            this.loadConsultationHistory();
        }
    }

    // ========== ENHANCED VIDEO CALL FUNCTIONS ==========
    async startCall() {
        try {
            console.log('Starting video call...');
            this.showNotification('Starting consultation call...', 'info');

            // Get user media
            this.localStream = await navigator.mediaDevices.getUserMedia({
                video: true,
                audio: true
            });

            const localVideo = document.getElementById('localVideo');
            if (localVideo) {
                localVideo.srcObject = this.localStream;
            }

            // Update UI
            document.querySelector('.btn-call-start').style.display = 'none';
            document.querySelector('.btn-call-end').style.display = 'flex';
            
            this.isCallActive = true;
            this.callStartTime = new Date();
            
            // Start call timer
            this.startCallTimer();
            
            // Simulate connecting to expert
            setTimeout(() => {
                this.showRemoteVideo();
            }, 2000);

            this.addSystemMessage('Connecting to agricultural expert...');

        } catch (error) {
            console.error('Error starting call:', error);
            this.addSystemMessage('Error accessing camera/microphone. Please check permissions.');
            this.showNotification('Failed to start call. Please check camera/microphone permissions.', 'error');
        }
    }

    async startScheduledCall(requestId) {
        this.currentCallRequestId = requestId;
        this.showNotification('Starting consultation now!', 'success');
        await this.startCall();
    }

    async endCall() {
        console.log('Ending video call...');
        
        if (this.localStream) {
            this.localStream.getTracks().forEach(track => track.stop());
        }
        
        // Calculate call duration
        const callDuration = this.getCallDuration();
        
        // Reset UI
        document.querySelector('.btn-call-start').style.display = 'flex';
        document.querySelector('.btn-call-end').style.display = 'none';
        
        const localVideo = document.getElementById('localVideo');
        if (localVideo) {
            localVideo.srcObject = null;
        }
        
        this.hideRemoteVideo();
        this.isCallActive = false;
        
        // Stop call timer
        this.stopCallTimer();
        
        // Save call record if it was a real consultation
        if (this.callStartTime && callDuration > 10) { // Minimum 10 seconds to count as consultation
            this.saveConsultationRecord(callDuration);
        }
        
        // Update request status if this was a scheduled call
        if (this.currentCallRequestId) {
            this.markRequestAsCompleted(this.currentCallRequestId, callDuration);
        }
        
        this.addSystemMessage(`Call ended. Duration: ${this.formatDuration(callDuration)}`);
        this.showNotification(`Call ended successfully (${this.formatDuration(callDuration)})`, 'info');
        this.currentCallRequestId = null;
    }

    startCallTimer() {
        // Create duration display if it doesn't exist
        let durationDisplay = document.querySelector('.call-duration-display');
        if (!durationDisplay) {
            durationDisplay = document.createElement('div');
            durationDisplay.className = 'call-duration-display';
            durationDisplay.style.cssText = `
                position: absolute;
                top: 10px;
                left: 10px;
                background: rgba(0,0,0,0.7);
                color: white;
                padding: 5px 10px;
                border-radius: 15px;
                font-size: 0.8rem;
                z-index: 10;
            `;
            document.querySelector('.video-container').appendChild(durationDisplay);
        }
        
        this.callTimer = setInterval(() => {
            if (this.callStartTime) {
                const duration = Math.floor((new Date() - this.callStartTime) / 1000);
                durationDisplay.textContent = this.formatDuration(duration);
            }
        }, 1000);
    }

    stopCallTimer() {
        if (this.callTimer) {
            clearInterval(this.callTimer);
            this.callTimer = null;
        }
        const durationDisplay = document.querySelector('.call-duration-display');
        if (durationDisplay) {
            durationDisplay.remove();
        }
    }

    getCallDuration() {
        if (!this.callStartTime) return 0;
        return Math.floor((new Date() - this.callStartTime) / 1000);
    }

    formatDuration(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }

    showRemoteVideo() {
        document.getElementById('remotePlaceholder').style.display = 'none';
        document.getElementById('remoteVideo').style.display = 'block';
        document.querySelector('.remote-overlay').style.display = 'flex';
        
        this.addSystemMessage('Connected to agricultural expert');
        this.showNotification('Connected to expert successfully!', 'success');
        
        setTimeout(() => {
            this.addExpertMessage("Hello! I'm here to help with your crops. What seems to be the problem?");
        }, 1000);
    }

    hideRemoteVideo() {
        document.getElementById('remotePlaceholder').style.display = 'flex';
        document.getElementById('remoteVideo').style.display = 'none';
        document.querySelector('.remote-overlay').style.display = 'none';
    }

    // ========== VIDEO CONTROLS ==========
    async toggleVideo() {
        this.isVideoEnabled = !this.isVideoEnabled;
        const videoBtn = document.querySelector('.video-btn');
        const videoIcon = document.querySelector('.video-local .fa-video');
        
        if (this.localStream) {
            const videoTrack = this.localStream.getVideoTracks()[0];
            if (videoTrack) {
                videoTrack.enabled = this.isVideoEnabled;
            }
        }
        
        videoBtn.classList.toggle('active', this.isVideoEnabled);
        videoIcon.classList.toggle('status-on', this.isVideoEnabled);
        videoIcon.classList.toggle('status-off', !this.isVideoEnabled);
        
        this.showNotification(`Video ${this.isVideoEnabled ? 'enabled' : 'disabled'}`, 'info');
    }

    async toggleAudio() {
        this.isAudioEnabled = !this.isAudioEnabled;
        const audioBtn = document.querySelector('.audio-btn');
        const audioIcon = document.querySelector('.video-local .fa-microphone');
        
        if (this.localStream) {
            const audioTrack = this.localStream.getAudioTracks()[0];
            if (audioTrack) {
                audioTrack.enabled = this.isAudioEnabled;
            }
        }
        
        audioBtn.classList.toggle('active', this.isAudioEnabled);
        audioIcon.classList.toggle('status-on', this.isAudioEnabled);
        audioIcon.classList.toggle('status-off', !this.isAudioEnabled);
        
        this.showNotification(`Audio ${this.isAudioEnabled ? 'enabled' : 'disabled'}`, 'info');
    }

    async toggleScreenShare() {
        this.showNotification('Screen sharing feature would be implemented here', 'info');
    }

    // ========== REQUEST MANAGEMENT ==========
    requestConsultant() {
        console.log('Opening request specialist modal...');
        this.showCallRequestModal();
    }

    showCallRequestModal() {
        document.getElementById('callRequestModal').style.display = 'block';
    }

    submitRequest() {
        const issueType = document.getElementById('issueType').value;
        const description = document.getElementById('issueDescription').value;
        const urgency = document.querySelector('input[name="urgency"]:checked').value;
        
        if (!description.trim()) {
            this.showNotification('Please describe your issue', 'error');
            return;
        }

        const requestData = {
            id: 'req_' + Date.now(),
            issueType: issueType,
            description: description.trim(),
            urgency: urgency,
            userName: this.getCurrentUserName(),
            timestamp: new Date().toISOString(),
            status: 'pending',
            expertAssigned: null,
            scheduledTime: null,
            expertAccepted: false,
            callDuration: null,
            completedAt: null
        };
        
        // Save to localStorage
        this.saveRequest(requestData);
        
        this.closeModal();
        this.showNotification('Consultation request submitted successfully! Experts will review it soon.', 'success');
        this.addSystemMessage('Your consultation request has been submitted. Experts will review it shortly.');
        
        // Clear form
        document.getElementById('issueDescription').value = '';
        
        // Reload requests display
        this.showRequestsCard();
        if (this.isExpert) this.loadPendingRequests();
        if (this.isAdmin) this.loadAdminPanel();
    }

    quickConnect(issueType) {
        console.log('Quick connect:', issueType);
        this.showCallRequestModal();
        document.getElementById('issueType').value = issueType;
    }

    saveRequest(requestData) {
        let existingRequests = this.getAllRequests();
        existingRequests.push(requestData);
        this.saveAllRequests(existingRequests);
    }

    markRequestAsCompleted(requestId, duration) {
        const requests = this.getAllRequests();
        const requestIndex = requests.findIndex(req => req.id === requestId);
        
        if (requestIndex !== -1) {
            requests[requestIndex].status = 'completed';
            requests[requestIndex].callDuration = duration;
            requests[requestIndex].completedAt = new Date().toISOString();
            this.saveAllRequests(requests);
            
            // Reload displays
            this.loadExpertAcceptedRequests();
            this.showRequestsCard();
            if (this.isAdmin) this.loadAdminPanel();
        }
    }

    // ========== ENHANCED USER REQUESTS CARD ==========
    showRequestsCard() {
        if (this.isAdmin) return;
        
        const requests = this.getAllRequests();
        const userRequests = requests.filter(req => req.userName === this.getCurrentUserName());
        
        let requestsCardSection = document.getElementById('userRequestsSection');
        if (!requestsCardSection) {
            requestsCardSection = document.createElement('div');
            requestsCardSection.id = 'userRequestsSection';
            requestsCardSection.className = 'user-requests-section';
            requestsCardSection.innerHTML = `
                <h3><i class="fas fa-history"></i> My Consultation Requests</h3>
                <div class="user-requests-grid" id="userRequestsGrid"></div>
            `;
            const quickActions = document.querySelector('.quick-actions');
            quickActions.parentNode.insertBefore(requestsCardSection, quickActions.nextSibling);
        }

        const userRequestsGrid = document.getElementById('userRequestsGrid');
        userRequestsGrid.innerHTML = '';

        if (userRequests.length === 0) {
            userRequestsGrid.innerHTML = `
                <div class="no-requests">
                    <i class="fas fa-inbox"></i>
                    <p>No consultation requests yet</p>
                    <small>Submit a request to see it here</small>
                </div>
            `;
            return;
        }

        userRequests.forEach(request => {
            const requestCard = document.createElement('div');
            requestCard.className = `user-request-card ${request.status}`;
            
            let durationInfo = '';
            let expertInfo = '';
            let statusInfo = '';
            
            if (request.status === 'completed' && request.callDuration) {
                durationInfo = `<div class="call-duration">
                    <i class="fas fa-clock"></i> Duration: ${this.formatDuration(request.callDuration)}
                </div>`;
            }
            
            if (request.expertAssigned) {
                expertInfo = `<div class="expert-assigned">
                    <i class="fas fa-user-tie"></i> ${request.expertAssigned}
                </div>`;
            }
            
            if (request.status === 'accepted' && request.expertAccepted) {
                statusInfo = `<div class="expert-assigned success">
                    <i class="fas fa-check-circle"></i> Expert accepted - Ready for call
                </div>`;
            } else if (request.status === 'accepted') {
                statusInfo = `<div class="expert-assigned">
                    <i class="fas fa-clock"></i> Waiting for expert confirmation
                </div>`;
            } else if (request.status === 'rejected') {
                statusInfo = `<div class="expert-assigned rejected">
                    <i class="fas fa-times-circle"></i> Request declined by expert
                </div>`;
            }
            
            requestCard.innerHTML = `
                <div class="request-header">
                    <div class="request-type">${this.getIssueTypeText(request.issueType)}</div>
                    <div class="request-status status-${request.status}">
                        ${request.status.charAt(0).toUpperCase() + request.status.slice(1)}
                    </div>
                </div>
                <div class="request-description">${this.escapeHtml(request.description)}</div>
                <div class="request-meta">
                    <div class="request-urgency urgency-${request.urgency}">
                        <i class="fas fa-clock"></i> ${request.urgency.toUpperCase()} Priority
                    </div>
                    <div class="request-time">
                        <i class="fas fa-calendar"></i> ${this.formatDate(request.timestamp)}
                    </div>
                </div>
                ${durationInfo}
                ${expertInfo}
                ${statusInfo}
                ${request.scheduledTime ? `
                    <div class="scheduled-info">
                        <i class="fas fa-video"></i> Scheduled for ${this.formatDateTime(request.scheduledTime)}
                    </div>
                ` : ''}
            `;
            userRequestsGrid.appendChild(requestCard);
        });
    }

    // ========== ENHANCED EXPERT FUNCTIONS ==========
    loadPendingRequests() {
        if (!this.isExpert) return;
        
        const requests = this.getAllRequests();
        const pendingRequests = requests.filter(req => req.status === 'pending');
        
        const requestsGrid = document.getElementById('requestsGrid');
        requestsGrid.innerHTML = '';
        
        if (pendingRequests.length === 0) {
            requestsGrid.innerHTML = `
                <div class="no-requests">
                    <i class="fas fa-check-circle"></i>
                    <p>No pending requests</p>
                    <small>All requests have been processed</small>
                </div>
            `;
            return;
        }
        
        pendingRequests.forEach(request => {
            const requestCard = document.createElement('div');
            requestCard.className = `request-card ${request.urgency}`;
            requestCard.innerHTML = `
                <div class="request-header">
                    <div class="request-user">
                        <i class="fas fa-user"></i> ${request.userName}
                    </div>
                    <div class="request-urgency urgency-${request.urgency}">
                        ${request.urgency.toUpperCase()}
                    </div>
                </div>
                <div class="request-issue">
                    <strong>Issue:</strong> ${this.getIssueTypeText(request.issueType)}
                </div>
                <div class="request-description">
                    ${this.escapeHtml(request.description)}
                </div>
                <div class="request-meta">
                    <small><i class="fas fa-clock"></i> Submitted: ${this.formatDateTime(request.timestamp)}</small>
                </div>
                <div class="request-actions">
                    <button class="btn-accept" onclick="consultation.expertAcceptRequest('${request.id}')">
                        <i class="fas fa-check"></i> Accept Request
                    </button>
                    <button class="btn-reject" onclick="consultation.expertRejectRequest('${request.id}')">
                        <i class="fas fa-times"></i> Decline
                    </button>
                </div>
            `;
            requestsGrid.appendChild(requestCard);
        });
    }

    expertAcceptRequest(requestId) {
        const requests = this.getAllRequests();
        const requestIndex = requests.findIndex(req => req.id === requestId);
        
        if (requestIndex !== -1) {
            requests[requestIndex].status = 'accepted';
            requests[requestIndex].expertAssigned = this.getCurrentExpertName();
            requests[requestIndex].expertAccepted = true;
            requests[requestIndex].scheduledTime = new Date(Date.now() + 15 * 60 * 1000).toISOString();
            
            this.saveAllRequests(requests);
            
            this.showNotification(
                `Request accepted! Consultation scheduled.`, 
                'success'
            );
            
            this.loadPendingRequests();
            this.showRequestsCard();
            this.loadExpertAcceptedRequests();
        }
    }

    expertRejectRequest(requestId) {
        const requests = this.getAllRequests();
        const requestIndex = requests.findIndex(req => req.id === requestId);
        
        if (requestIndex !== -1) {
            requests[requestIndex].status = 'rejected';
            requests[requestIndex].expertAssigned = this.getCurrentExpertName() + ' (Rejected)';
            this.saveAllRequests(requests);
            
            this.showNotification('Request declined', 'info');
            this.loadPendingRequests();
            this.showRequestsCard();
        }
    }

    // ========== BULK ACTIONS FOR EXPERTS ==========
    acceptAllRequests() {
        const requests = this.getAllRequests();
        const pendingRequests = requests.filter(req => req.status === 'pending');
        
        if (pendingRequests.length === 0) {
            this.showNotification('No pending requests to accept', 'info');
            return;
        }
        
        pendingRequests.forEach(request => {
            request.status = 'accepted';
            request.expertAssigned = this.getCurrentExpertName();
            request.expertAccepted = true;
            request.scheduledTime = new Date(Date.now() + 15 * 60 * 1000).toISOString();
        });
        
        this.saveAllRequests(requests);
        this.showNotification(`Accepted ${pendingRequests.length} requests`, 'success');
        this.loadPendingRequests();
        this.showRequestsCard();
        this.loadExpertAcceptedRequests();
    }

    declineAllRequests() {
        const requests = this.getAllRequests();
        const pendingRequests = requests.filter(req => req.status === 'pending');
        
        if (pendingRequests.length === 0) {
            this.showNotification('No pending requests to decline', 'info');
            return;
        }
        
        pendingRequests.forEach(request => {
            request.status = 'rejected';
            request.expertAssigned = this.getCurrentExpertName() + ' (Rejected)';
        });
        
        this.saveAllRequests(requests);
        this.showNotification(`Declined ${pendingRequests.length} requests`, 'info');
        this.loadPendingRequests();
        this.showRequestsCard();
    }

    // ========== URGENCY FILTER FOR EXPERTS ==========
    filterRequests() {
        if (!this.isExpert) return;
        
        const selectedUrgencies = Array.from(document.querySelectorAll('input[name="urgencyFilter"]:checked'))
            .map(input => input.value);
        
        const requests = this.getAllRequests();
        const pendingRequests = requests.filter(req => 
            req.status === 'pending' && selectedUrgencies.includes(req.urgency)
        );
        
        const requestsGrid = document.getElementById('requestsGrid');
        requestsGrid.innerHTML = '';
        
        if (pendingRequests.length === 0) {
            requestsGrid.innerHTML = `
                <div class="no-requests">
                    <i class="fas fa-filter"></i>
                    <p>No requests match the selected filters</p>
                    <small>Try adjusting your urgency filters</small>
                </div>
            `;
            return;
        }
        
        pendingRequests.forEach(request => {
            const requestCard = document.createElement('div');
            requestCard.className = `request-card ${request.urgency}`;
            requestCard.innerHTML = `
                <div class="request-header">
                    <div class="request-user">
                        <i class="fas fa-user"></i> ${request.userName}
                    </div>
                    <div class="request-urgency urgency-${request.urgency}">
                        ${request.urgency.toUpperCase()}
                    </div>
                </div>
                <div class="request-issue">
                    <strong>Issue:</strong> ${this.getIssueTypeText(request.issueType)}
                </div>
                <div class="request-description">
                    ${this.escapeHtml(request.description)}
                </div>
                <div class="request-meta">
                    <small><i class="fas fa-clock"></i> Submitted: ${this.formatDateTime(request.timestamp)}</small>
                </div>
                <div class="request-actions">
                    <button class="btn-accept" onclick="consultation.expertAcceptRequest('${request.id}')">
                        <i class="fas fa-check"></i> Accept Request
                    </button>
                    <button class="btn-reject" onclick="consultation.expertRejectRequest('${request.id}')">
                        <i class="fas fa-times"></i> Decline
                    </button>
                </div>
            `;
            requestsGrid.appendChild(requestCard);
        });
    }

    // ========== ENHANCED EXPERT ACCEPTED REQUESTS ==========
    loadExpertAcceptedRequests() {
        if (!this.isExpert) return;
        
        const requests = this.getAllRequests();
        const acceptedRequests = requests.filter(req => 
            req.status === 'accepted' && req.expertAccepted
        );
        
        const acceptedGrid = document.getElementById('acceptedRequestsGrid');
        if (!acceptedGrid) return;
        
        acceptedGrid.innerHTML = '';
        
        if (acceptedRequests.length === 0) {
            acceptedGrid.innerHTML = `
                <div class="no-requests">
                    <i class="fas fa-video"></i>
                    <p>No accepted consultations</p>
                    <small>Accepted requests will appear here</small>
                </div>
            `;
            return;
        }
        
        acceptedRequests.forEach(request => {
            const requestCard = document.createElement('div');
            requestCard.className = `request-card accepted`;
            requestCard.innerHTML = `
                <div class="request-header">
                    <div class="request-user">
                        <i class="fas fa-user"></i> ${request.userName}
                    </div>
                    <div class="request-status status-accepted">
                        ACCEPTED
                    </div>
                </div>
                <div class="request-issue">
                    <strong>Issue:</strong> ${this.getIssueTypeText(request.issueType)}
                </div>
                <div class="request-description">
                    ${this.escapeHtml(request.description)}
                </div>
                <div class="request-meta">
                    <div class="scheduled-time">
                        <i class="fas fa-clock"></i> Scheduled: ${this.formatDateTime(request.scheduledTime)}
                    </div>
                </div>
                <div class="request-actions">
                    <button class="btn-start-now" onclick="consultation.startScheduledCall('${request.id}')">
                        <i class="fas fa-play"></i> Start Consultation Now
                    </button>
                </div>
            `;
            acceptedGrid.appendChild(requestCard);
        });
    }

    // ========== CONSULTATION HISTORY FOR USERS ==========
    loadConsultationHistory() {
        if (this.isAdmin) return;
        
        const history = this.getConsultationHistory();
        const userHistory = history.filter(record => record.userId === this.getCurrentUserName());
        
        let historySection = document.getElementById('consultationHistorySection');
        if (!historySection) {
            historySection = document.createElement('div');
            historySection.id = 'consultationHistorySection';
            historySection.className = 'consultation-history-section';
            historySection.innerHTML = `
                <h3><i class="fas fa-history"></i> Consultation History</h3>
                <div class="history-grid" id="historyGrid"></div>
            `;
            const userRequests = document.getElementById('userRequestsSection');
            if (userRequests) {
                userRequests.parentNode.insertBefore(historySection, userRequests.nextSibling);
            }
        }

        const historyGrid = document.getElementById('historyGrid');
        historyGrid.innerHTML = '';

        if (userHistory.length === 0) {
            historyGrid.innerHTML = `
                <div class="no-requests">
                    <i class="fas fa-video"></i>
                    <p>No consultation history</p>
                    <small>Completed consultations will appear here</small>
                </div>
            `;
            return;
        }

        userHistory.forEach(record => {
            const historyCard = document.createElement('div');
            historyCard.className = `history-card ${record.status}`;
            historyCard.innerHTML = `
                <div class="history-header">
                    <div class="history-expert">
                        <i class="fas fa-user-tie"></i> ${record.expertName}
                    </div>
                    <div class="history-duration">
                        ${this.formatDuration(record.duration)}
                    </div>
                </div>
                <div class="history-details">
                    <div class="history-detail">
                        <i class="fas fa-leaf"></i>
                        <span>Issue: ${this.getIssueTypeText(record.issueType)}</span>
                    </div>
                    <div class="history-detail">
                        <i class="fas fa-calendar"></i>
                        <span>Date: ${this.formatDateTime(record.date)}</span>
                    </div>
                    <div class="history-detail">
                        <i class="fas fa-star"></i>
                        <span>Rating: 
                            <span class="rating-stars">
                                ${'★'.repeat(record.rating)}${'☆'.repeat(5 - record.rating)}
                            </span>
                            (${record.rating}/5)
                        </span>
                    </div>
                </div>
            `;
            historyGrid.appendChild(historyCard);
        });
    }

    saveConsultationRecord(duration) {
        const record = {
            id: 'cons_' + Date.now(),
            userId: this.getCurrentUserName(),
            expertName: this.currentConsultant?.name || 'Agricultural Expert',
            duration: duration,
            date: new Date().toISOString(),
            issueType: this.getLastRequestType() || 'general',
            rating: Math.floor(Math.random() * 2) + 4, // Random rating 4-5
            status: 'completed'
        };
        
        let history = this.getConsultationHistory();
        history.push(record);
        localStorage.setItem('consultationHistory', JSON.stringify(history));
        
        // Reload history displays
        this.loadConsultationHistory();
        if (this.isAdmin) this.loadAdminRecords();
    }

    getLastRequestType() {
        const requests = this.getAllRequests();
        const userRequests = requests.filter(req => req.userName === this.getCurrentUserName());
        return userRequests.length > 0 ? userRequests[userRequests.length - 1].issueType : null;
    }

    getConsultationHistory() {
        return JSON.parse(localStorage.getItem('consultationHistory') || '[]');
    }

    // ========== ADMIN FUNCTIONS ==========
    loadAdminPanel() {
        if (!this.isAdmin) return;
        
        const requests = this.getAllRequests();
        this.displayAdminRequests(requests);
        this.loadAdminStatistics();
    }

    displayAdminRequests(requests) {
        const adminRequestsGrid = document.getElementById('adminRequestsGrid');
        if (!adminRequestsGrid) return;
        
        adminRequestsGrid.innerHTML = '';

        if (requests.length === 0) {
            adminRequestsGrid.innerHTML = `
                <div class="no-requests">
                    <i class="fas fa-inbox"></i>
                    <p>No consultation requests</p>
                    <small>All requests will appear here</small>
                </div>
            `;
            return;
        }

        requests.forEach(request => {
            const requestCard = document.createElement('div');
            requestCard.className = `admin-request-card view-only ${request.status} ${request.urgency}`;
            
            const durationInfo = request.callDuration ? 
                `<div class="call-duration">Duration: ${this.formatDuration(request.callDuration)}</div>` : '';
            
            requestCard.innerHTML = `
                <div class="admin-request-header">
                    <div class="request-user-info">
                        <div class="request-user">
                            <i class="fas fa-user"></i> ${request.userName}
                        </div>
                        <div class="request-id">#${request.id.substring(0, 8)}</div>
                    </div>
                    <div class="request-meta-info">
                        <div class="request-urgency urgency-${request.urgency}">
                            ${request.urgency.toUpperCase()}
                        </div>
                        <div class="request-status status-${request.status}">
                            ${request.status.charAt(0).toUpperCase() + request.status.slice(1)}
                        </div>
                    </div>
                </div>
                
                <div class="request-issue">
                    <strong>Issue Type:</strong> ${this.getIssueTypeText(request.issueType)}
                </div>
                
                <div class="request-description">
                    ${this.escapeHtml(request.description)}
                </div>
                
                <div class="request-details">
                    <div class="detail-item">
                        <i class="fas fa-clock"></i>
                        <span>Submitted: ${this.formatDateTime(request.timestamp)}</span>
                    </div>
                    ${request.scheduledTime ? `
                        <div class="detail-item">
                            <i class="fas fa-video"></i>
                            <span>Scheduled: ${this.formatDateTime(request.scheduledTime)}</span>
                        </div>
                    ` : ''}
                    ${request.expertAssigned ? `
                        <div class="detail-item">
                            <i class="fas fa-user-tie"></i>
                            <span>Expert: ${request.expertAssigned}</span>
                        </div>
                    ` : ''}
                    ${request.expertAccepted ? `
                        <div class="detail-item">
                            <i class="fas fa-check-circle"></i>
                            <span>Expert Accepted: Yes</span>
                        </div>
                    ` : ''}
                    ${durationInfo ? `
                        <div class="detail-item">
                            ${durationInfo}
                        </div>
                    ` : ''}
                </div>

                <div class="admin-request-actions view-only">
                    <span class="view-only-badge">
                        <i class="fas fa-eye"></i> View Only - Admin
                    </span>
                </div>
            `;
            adminRequestsGrid.appendChild(requestCard);
        });
    }

    loadAdminStatistics() {
        if (!this.isAdmin) return;
        
        const requests = this.getAllRequests();
        const stats = this.calculateAdminStats(requests);
        this.updateAdminStatsDisplay(stats);
    }

    calculateAdminStats(requests) {
        const total = requests.length;
        const pending = requests.filter(req => req.status === 'pending').length;
        const accepted = requests.filter(req => req.status === 'accepted').length;
        const rejected = requests.filter(req => req.status === 'rejected').length;
        const completed = requests.filter(req => req.status === 'completed').length;
        const expertAccepted = requests.filter(req => req.expertAccepted).length;
        
        const urgencyStats = {
            low: requests.filter(req => req.urgency === 'low').length,
            medium: requests.filter(req => req.urgency === 'medium').length,
            high: requests.filter(req => req.urgency === 'high').length
        };

        const issueTypeStats = {};
        requests.forEach(req => {
            issueTypeStats[req.issueType] = (issueTypeStats[req.issueType] || 0) + 1;
        });

        return {
            total,
            pending,
            accepted,
            rejected,
            completed,
            expertAccepted,
            urgencyStats,
            issueTypeStats,
            completionRate: total > 0 ? Math.round((completed) / total * 100) : 0,
            acceptanceRate: total > 0 ? Math.round((accepted) / total * 100) : 0
        };
    }

    updateAdminStatsDisplay(stats) {
        document.getElementById('totalRequests').textContent = stats.total;
        document.getElementById('pendingRequests').textContent = stats.pending;
        document.getElementById('acceptedRequests').textContent = stats.accepted;
        document.getElementById('rejectedRequests').textContent = stats.rejected;
        document.getElementById('completedRequests').textContent = stats.completed;
        document.getElementById('expertAccepted').textContent = stats.expertAccepted;
        document.getElementById('completionRate').textContent = stats.completionRate + '%';
        document.getElementById('acceptanceRate').textContent = stats.acceptanceRate + '%';

        document.getElementById('lowUrgency').textContent = stats.urgencyStats.low;
        document.getElementById('mediumUrgency').textContent = stats.urgencyStats.medium;
        document.getElementById('highUrgency').textContent = stats.urgencyStats.high;

        const issueTypeGrid = document.getElementById('issueTypeStats');
        if (issueTypeGrid) {
            issueTypeGrid.innerHTML = '';
            Object.entries(stats.issueTypeStats).forEach(([type, count]) => {
                const statItem = document.createElement('div');
                statItem.className = 'issue-type-stat';
                statItem.innerHTML = `
                    <div class="issue-type-name">${this.getIssueTypeText(type)}</div>
                    <div class="issue-type-count">${count}</div>
                `;
                issueTypeGrid.appendChild(statItem);
            });
        }
    }

    // ========== ENHANCED ADMIN RECORDS ==========
    loadAdminRecords() {
        if (!this.isAdmin) return;
        
        const requests = this.getAllRequests();
        const history = this.getConsultationHistory();
        
        // Combine requests and history for complete records
        const allRecords = [...requests, ...history];
        this.displayAdminRecords(allRecords);
    }

    displayAdminRecords(records) {
        const recordsGrid = document.getElementById('recordsGrid');
        if (!recordsGrid) return;
        
        recordsGrid.innerHTML = '';

        if (records.length === 0) {
            recordsGrid.innerHTML = `
                <div class="no-requests">
                    <i class="fas fa-database"></i>
                    <p>No consultation records</p>
                    <small>All consultation data will appear here</small>
                </div>
            `;
            return;
        }

        // Sort by date (newest first)
        records.sort((a, b) => new Date(b.timestamp || b.date) - new Date(a.timestamp || a.date));

        records.forEach(record => {
            const isHistory = record.hasOwnProperty('duration');
            const recordCard = document.createElement('div');
            recordCard.className = `record-card ${record.status}`;
            
            const durationInfo = isHistory ? 
                `<div class="call-duration">Duration: ${this.formatDuration(record.duration)}</div>` : '';
            
            const ratingInfo = record.rating ? 
                `<div class="call-quality">
                    <i class="fas fa-star"></i> Rating: ${record.rating}/5
                </div>` : '';

            recordCard.innerHTML = `
                <div class="record-header">
                    <div class="record-user">
                        <i class="fas fa-user"></i> ${record.userName || record.userId}
                    </div>
                    <div class="record-status status-${record.status}">
                        ${record.status.toUpperCase()}
                    </div>
                </div>
                
                <div class="record-details">
                    <div class="record-detail">
                        <i class="fas fa-leaf"></i>
                        <span>Issue: ${this.getIssueTypeText(record.issueType)}</span>
                    </div>
                    <div class="record-detail">
                        <i class="fas fa-calendar"></i>
                        <span>Date: ${this.formatDateTime(record.timestamp || record.date)}</span>
                    </div>
                    ${record.expertAssigned ? `
                        <div class="record-detail">
                            <i class="fas fa-user-tie"></i>
                            <span>Expert: ${record.expertAssigned}</span>
                        </div>
                    ` : ''}
                    ${durationInfo ? `
                        <div class="record-detail">
                            ${durationInfo}
                        </div>
                    ` : ''}
                    ${ratingInfo ? `
                        <div class="record-detail">
                            ${ratingInfo}
                        </div>
                    ` : ''}
                </div>

                <div class="admin-request-actions view-only">
                    <span class="view-only-badge">
                        <i class="fas fa-eye"></i> View Only - Admin
                    </span>
                </div>
            `;
            recordsGrid.appendChild(recordCard);
        });
    }

    filterAdminRecords() {
        if (!this.isAdmin) return;
        
        const dateFilter = document.getElementById('dateFilter').value;
        const statusFilter = document.getElementById('statusFilter').value;
        
        const requests = this.getAllRequests();
        const history = this.getConsultationHistory();
        let allRecords = [...requests, ...history];
        
        // Apply date filter
        if (dateFilter !== 'all') {
            const now = new Date();
            let startDate;
            
            switch (dateFilter) {
                case 'today':
                    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                    break;
                case 'week':
                    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 7);
                    break;
                case 'month':
                    startDate = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
                    break;
            }
            
            allRecords = allRecords.filter(record => {
                const recordDate = new Date(record.timestamp || record.date);
                return recordDate >= startDate;
            });
        }
        
        // Apply status filter
        if (statusFilter !== 'all') {
            allRecords = allRecords.filter(record => record.status === statusFilter);
        }
        
        this.displayAdminRecords(allRecords);
    }

    // ========== CHAT FUNCTIONS ==========
    sendMessage() {
        const chatInput = document.getElementById('chatInput');
        const message = chatInput.value.trim();
        
        if (message) {
            this.addUserMessage(message);
            chatInput.value = '';
            
            setTimeout(() => {
                this.simulateExpertResponse(message);
            }, 1000 + Math.random() * 2000);
        }
    }

    addUserMessage(text) {
        const chatMessages = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message user';
        messageDiv.innerHTML = `
            <div class="message-content">
                <div class="message-text">${this.escapeHtml(text)}</div>
                <div class="message-time">${this.getCurrentTime()}</div>
            </div>
            <div class="message-avatar">
                <i class="fas fa-user"></i>
            </div>
        `;
        chatMessages.appendChild(messageDiv);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    addExpertMessage(text) {
        const chatMessages = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message expert';
        messageDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-user-tie"></i>
            </div>
            <div class="message-content">
                <div class="message-sender">Agricultural Expert</div>
                <div class="message-text">${this.escapeHtml(text)}</div>
                <div class="message-time">${this.getCurrentTime()}</div>
            </div>
        `;
        chatMessages.appendChild(messageDiv);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    addSystemMessage(text) {
        const chatMessages = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message system';
        messageDiv.innerHTML = `
            <div class="message-content">
                <i class="fas fa-info-circle"></i>
                ${this.escapeHtml(text)}
            </div>
        `;
        chatMessages.appendChild(messageDiv);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    simulateExpertResponse(userMessage) {
        const responses = [
            "I understand your concern about that issue. Let me provide some guidance.",
            "Based on your description, this seems like a common problem farmers face.",
            "I recommend checking the soil moisture levels first.",
            "Have you noticed any specific patterns in the affected plants?",
            "This could be related to recent weather conditions in your area.",
            "Let me suggest some organic treatment options for this."
        ];
        
        const randomResponse = responses[Math.floor(Math.random() * responses.length)];
        this.addExpertMessage(randomResponse);
    }

    // ========== FILE ATTACHMENT FUNCTIONS ==========
    attachImage() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = 'image/*';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (file) {
                this.addSystemMessage(`Image attached: ${file.name}`);
                this.showNotification('Image attached successfully', 'success');
            }
        };
        input.click();
    }

    recordAudio() {
        this.showNotification('Audio recording feature would be implemented here', 'info');
    }

    shareScreen() {
        this.showNotification('Screen sharing would be implemented here', 'info');
    }

    // ========== EXPERT MANAGEMENT ==========
    loadAvailableExperts() {
        const experts = [
            { id: 1, name: "Dr. Green", specialty: "Plant Pathology", rating: 4.8, online: true },
            { id: 2, name: "Dr. Sharma", specialty: "Soil Science", rating: 4.9, online: true },
            { id: 3, name: "Ms. Chen", specialty: "Organic Farming", rating: 4.7, online: true },
            { id: 4, name: "Mr. Rodriguez", specialty: "Irrigation", rating: 4.6, online: false }
        ];

        const expertsGrid = document.getElementById('expertsGrid');
        if (!expertsGrid) return;
        
        expertsGrid.innerHTML = '';

        experts.forEach(expert => {
            const expertCard = document.createElement('div');
            expertCard.className = 'expert-card';
            expertCard.innerHTML = `
                <div class="expert-avatar">
                    <i class="fas fa-user-tie"></i>
                </div>
                <div class="expert-info">
                    <h4>${expert.name}</h4>
                    <p class="expert-specialty">${expert.specialty}</p>
                    <div class="expert-rating">
                        <i class="fas fa-star"></i> ${expert.rating}
                    </div>
                    <div class="expert-status ${expert.online ? 'online' : 'offline'}">
                        ${expert.online ? 'Online' : 'Offline'}
                    </div>
                </div>
            `;
            expertCard.addEventListener('click', () => this.showConsultantModal(expert));
            expertsGrid.appendChild(expertCard);
        });
    }

    // ========== MODAL FUNCTIONS ==========
    showConsultantModal(consultant) {
        this.currentConsultant = consultant;
        const modal = document.getElementById('consultantModal');
        modal.style.display = 'block';
        
        document.getElementById('consultantName').textContent = consultant.name;
        document.getElementById('consultantSpecialty').textContent = consultant.specialty + ' Expert';
        document.getElementById('consultantRating').textContent = consultant.rating;
    }

    closeModal() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.style.display = 'none';
        });
    }

    connectToConsultant() {
        this.closeModal();
        this.startCall();
    }

    // ========== UTILITY FUNCTIONS ==========
    getAllRequests() {
        return JSON.parse(localStorage.getItem('consultationRequests') || '[]');
    }

    saveAllRequests(requests) {
        localStorage.setItem('consultationRequests', JSON.stringify(requests));
    }

    getCurrentUserName() {
        return localStorage.getItem('userName') || 'Current User';
    }

    getCurrentExpertName() {
        return localStorage.getItem('expertName') || 'Agricultural Expert';
    }

    getIssueTypeText(issueType) {
        const types = {
            'plant_disease': 'Plant Disease',
            'pest_control': 'Pest Control',
            'soil_health': 'Soil Health',
            'irrigation': 'Irrigation',
            'fertilizer': 'Fertilizer Use',
            'other': 'Other'
        };
        return types[issueType] || issueType;
    }

    formatDate(timestamp) {
        return new Date(timestamp).toLocaleDateString();
    }

    formatDateTime(timestamp) {
        return new Date(timestamp).toLocaleString();
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    getCurrentTime() {
        return new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    showNotification(message, type = 'info') {
        // Remove existing notifications
        document.querySelectorAll('.notification').forEach(notif => notif.remove());
        
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            background: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#dc3545' : '#ffc107'};
            color: white;
            border-radius: 8px;
            z-index: 10000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            max-width: 300px;
            font-size: 0.9rem;
        `;
        notification.innerHTML = `
            <div style="display: flex; align-items: center; gap: 10px;">
                <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
                <span>${message}</span>
            </div>
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.opacity = '0';
            notification.style.transform = 'translateX(100px)';
            setTimeout(() => notification.remove(), 300);
        }, 4000);
    }

    updateStats() {
        const stats = {
            onlineExperts: Math.floor(Math.random() * 10) + 8,
            avgWait: Math.floor(Math.random() * 3) + 1,
            rating: (Math.random() * 0.4 + 4.6).toFixed(1)
        };

        document.getElementById('online-experts').textContent = stats.onlineExperts;
        document.getElementById('avg-wait').textContent = stats.avgWait + ' min';
        document.getElementById('rating').textContent = stats.rating;
    }
}

// ========== GLOBAL FUNCTIONS ==========
let consultation;

document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, initializing enhanced consultation system...');
    consultation = new VideoConsultation();
});

// Video Call Functions
function toggleVideo() { consultation?.toggleVideo(); }
function toggleAudio() { consultation?.toggleAudio(); }
function toggleScreenShare() { consultation?.toggleScreenShare(); }
function startCall() { consultation?.startCall(); }
function endCall() { consultation?.endCall(); }

// Request Functions
function requestConsultant() { consultation?.requestConsultant(); }
function quickConnect(type) { consultation?.quickConnect(type); }
function submitRequest() { consultation?.submitRequest(); }

// Chat Functions
function sendMessage() { consultation?.sendMessage(); }
function attachImage() { consultation?.attachImage(); }
function recordAudio() { consultation?.recordAudio(); }
function shareScreen() { consultation?.shareScreen(); }

// Modal Functions
function closeModal() { consultation?.closeModal(); }
function connectToConsultant() { consultation?.connectToConsultant(); }

// Expert Functions
function acceptAllRequests() { consultation?.acceptAllRequests(); }
function declineAllRequests() { consultation?.declineAllRequests(); }
function filterRequests() { consultation?.filterRequests(); }

// Admin Functions
function filterAdminRecords() { consultation?.filterAdminRecords(); }

// Role Switching Functions
function switchToAdminView() {
    localStorage.setItem('userRole', 'admin');
    location.reload();
}

function switchToUserView() {
    localStorage.setItem('userRole', 'user');
    location.reload();
}

function switchToExpertView() {
    localStorage.setItem('userRole', 'expert');
    localStorage.setItem('expertName', 'Agricultural Expert');
    location.reload();
}

// Debug function
function checkConsultation() {
    console.log('Consultation system status:', {
        initialized: !!consultation,
        isAdmin: consultation?.isAdmin,
        isExpert: consultation?.isExpert,
        isCallActive: consultation?.isCallActive,
        requests: consultation?.getAllRequests()?.length || 0,
        history: consultation?.getConsultationHistory()?.length || 0
    });
}

// Ai Live
// Enhanced Field Command Center JavaScript
class FieldCommandCenter {
    constructor() {
        this.fieldData = [];
        this.sensorData = {};
        this.isSatelliteView = false;
        this.droneSurveyInProgress = false;
        this.soilAnalysisInProgress = false;
        this.modalManager = new ModalManager();
        this.init();
    }

    init() {
        this.generateFieldGrid();
        this.startLiveDataUpdates();
        this.setupEventListeners();
        this.initializeModals();
        this.setupSensorInteractions();
        this.initializeDroneFieldGrid();
    }

    // Generate dynamic field grid with enhanced animations
    generateFieldGrid() {
        const fieldGrid = document.getElementById('fieldGrid');
        fieldGrid.innerHTML = '';
        
        const gridSize = 16; // 4x4 grid
        const fieldConditions = ['excellent', 'good', 'warning', 'critical'];
        
        for (let i = 0; i < gridSize; i++) {
            const block = document.createElement('div');
            block.className = 'field-block';
            
            const row = Math.floor(i / 4);
            const col = i % 4;
            const blockId = `${String.fromCharCode(65 + row)}${col + 1}`;
            
            // Weighted random conditions for more realistic distribution
            const weights = [0.4, 0.35, 0.15, 0.1]; // excellent, good, warning, critical
            const condition = this.getWeightedRandomCondition(fieldConditions, weights);
            
            block.classList.add(condition);
            block.dataset.blockId = blockId;
            block.dataset.condition = condition;
            
            block.innerHTML = `
                <div class="block-label">${blockId}</div>
                <div class="block-status">${this.getStatusText(condition)}</div>
                <div class="block-glow"></div>
            `;
            
            // Add click handler with animation
            block.addEventListener('click', () => this.showBlockDetails(block));
            
            // Add hover effects
            block.addEventListener('mouseenter', () => this.animateBlockHover(block));
            block.addEventListener('mouseleave', () => this.animateBlockHoverOut(block));
            
            fieldGrid.appendChild(block);
            
            // Store block data
            this.fieldData.push({
                id: blockId,
                condition: condition,
                sensors: this.generateBlockSensorData(condition)
            });
        }
    }

    getWeightedRandomCondition(conditions, weights) {
        const random = Math.random();
        let sum = 0;
        for (let i = 0; i < weights.length; i++) {
            sum += weights[i];
            if (random <= sum) return conditions[i];
        }
        return conditions[0];
    }

    getStatusText(condition) {
        const statusMap = {
            excellent: 'Optimal',
            good: 'Healthy',
            warning: 'Needs Care',
            critical: 'Attention!'
        };
        return statusMap[condition] || 'Unknown';
    }

    generateBlockSensorData(condition) {
        const baseRanges = {
            excellent: { temp: [20, 26], moisture: [60, 80], ph: [6.5, 7.0], nitrogen: [50, 70] },
            good: { temp: [18, 28], moisture: [50, 70], ph: [6.0, 7.2], nitrogen: [40, 60] },
            warning: { temp: [15, 30], moisture: [30, 50], ph: [5.5, 8.0], nitrogen: [30, 50] },
            critical: { temp: [10, 35], moisture: [20, 40], ph: [5.0, 8.5], nitrogen: [20, 40] }
        };

        const range = baseRanges[condition];
        return {
            temperature: (Math.random() * (range.temp[1] - range.temp[0]) + range.temp[0]).toFixed(1),
            moisture: (Math.random() * (range.moisture[1] - range.moisture[0]) + range.moisture[0]).toFixed(0),
            ph: (Math.random() * (range.ph[1] - range.ph[0]) + range.ph[0]).toFixed(1),
            nitrogen: (Math.random() * (range.nitrogen[1] - range.nitrogen[0]) + range.nitrogen[0]).toFixed(0)
        };
    }

    // Enhanced live data updates with realistic patterns
    startLiveDataUpdates() {
        // Update sensor data every 3 seconds for more real-time feel
        setInterval(() => {
            this.updateSensorData();
            this.updateFieldConditions();
            this.updatePredictions();
        }, 3000);

        // Initial update
        this.updateSensorData();
        this.updateFieldConditions();
        this.updatePredictions();
    }

    // Update sensor data with realistic patterns and trends
    updateSensorData() {
        const sensors = {
            soilTemp: { 
                min: 18, max: 32, unit: '°C',
                trend: this.generateRealisticTrend('temperature')
            },
            soilMoisture: { 
                min: 25, max: 85, unit: '%',
                trend: this.generateRealisticTrend('moisture')
            },
            soilPH: { 
                min: 5.8, max: 7.2, unit: '',
                trend: this.generateRealisticTrend('ph')
            },
            nitrogenLevel: { 
                min: 40, max: 80, unit: 'ppm',
                trend: this.generateRealisticTrend('nitrogen')
            },
            phosphorusLevel: { 
                min: 30, max: 70, unit: 'ppm',
                trend: this.generateRealisticTrend('phosphorus')
            },
            potassiumLevel: { 
                min: 50, max: 90, unit: 'ppm',
                trend: this.generateRealisticTrend('potassium')
            }
        };

        Object.keys(sensors).forEach(sensorId => {
            const sensor = sensors[sensorId];
            const currentElement = document.getElementById(sensorId);
            
            if (currentElement) {
                const currentValue = parseFloat(currentElement.textContent) || (sensor.min + sensor.max) / 2;
                const newValue = this.calculateNewSensorValue(currentValue, sensor);
                
                this.animateValueChange(currentElement, newValue + sensor.unit);
                this.updateSensorTrend(sensorId, sensor.trend);
                
                // Store for data tracking
                this.sensorData[sensorId] = {
                    value: newValue,
                    unit: sensor.unit,
                    trend: sensor.trend
                };
            }
        });
    }

    generateRealisticTrend(type) {
        const trends = {
            temperature: { base: 0.1, variation: 0.5 },
            moisture: { base: -0.2, variation: 1.0 },
            ph: { base: 0.05, variation: 0.1 },
            nitrogen: { base: -0.3, variation: 0.8 },
            phosphorus: { base: -0.1, variation: 0.6 },
            potassium: { base: -0.2, variation: 0.7 }
        };
        
        const trend = trends[type] || { base: 0, variation: 0.5 };
        return trend.base + (Math.random() - 0.5) * trend.variation;
    }

    calculateNewSensorValue(currentValue, sensor) {
        const change = sensor.trend * (Math.random() * 2 + 1);
        let newValue = currentValue + change;
        
        // Keep within bounds with some resistance at edges
        if (newValue < sensor.min) {
            newValue = sensor.min + Math.random() * 2;
        } else if (newValue > sensor.max) {
            newValue = sensor.max - Math.random() * 2;
        }
        
        return Math.max(sensor.min, Math.min(sensor.max, newValue)).toFixed(1);
    }

    animateValueChange(element, newValue) {
        element.style.transform = 'scale(1.1)';
        element.style.color = '#4CAF50';
        
        setTimeout(() => {
            element.textContent = newValue;
            element.style.transform = 'scale(1)';
            setTimeout(() => {
                element.style.color = '';
            }, 500);
        }, 200);
    }

    updateSensorTrend(sensorId, trend) {
        const trendElement = document.querySelector(`#${sensorId} + .metric-trend`);
        if (trendElement) {
            const isPositive = trend > 0;
            const value = Math.abs(trend).toFixed(1);
            const unit = sensorId === 'soilTemp' ? '°' : '%';
            
            trendElement.className = `metric-trend ${isPositive ? 'up' : 'down'}`;
            trendElement.innerHTML = `${isPositive ? '+' : '-'}${value}${unit}`;
        }
    }

    // Enhanced field condition updates
    updateFieldConditions() {
        const blocks = document.querySelectorAll('.field-block');
        const currentHour = new Date().getHours();
        
        blocks.forEach(block => {
            const blockId = block.dataset.blockId;
            const currentCondition = block.dataset.condition;
            const blockData = this.fieldData.find(b => b.id === blockId);
            
            if (blockData) {
                // More realistic condition changes based on time and current state
                let changeProbability = 0.08; // Base probability
                
                // Increase probability during critical hours
                if ((currentHour >= 12 && currentHour <= 15) && currentCondition !== 'excellent') {
                    changeProbability = 0.15;
                }
                
                if (Math.random() < changeProbability) {
                    this.transitionBlockCondition(block, blockData);
                }
                
                // Update block status text
                const statusElement = block.querySelector('.block-status');
                if (statusElement) {
                    statusElement.textContent = this.getStatusText(currentCondition);
                }
            }
        });
    }

    transitionBlockCondition(block, blockData) {
        const conditions = ['excellent', 'good', 'warning', 'critical'];
        const currentIndex = conditions.indexOf(blockData.condition);
        let newIndex = currentIndex;
        
        // More realistic transitions (usually small changes)
        if (Math.random() < 0.7) {
            // Small change
            newIndex = Math.max(0, Math.min(conditions.length - 1, currentIndex + (Math.random() < 0.5 ? 1 : -1)));
        } else {
            // Occasionally bigger change
            newIndex = Math.floor(Math.random() * conditions.length);
        }
        
        const newCondition = conditions[newIndex];
        
        // Animate the transition
        this.animateBlockConditionChange(block, blockData, newCondition);
    }

    animateBlockConditionChange(block, blockData, newCondition) {
        block.style.transform = 'scale(0.95)';
        block.style.opacity = '0.7';
        
        setTimeout(() => {
            // Remove old condition classes
            block.classList.remove('excellent', 'good', 'warning', 'critical');
            // Add new condition
            block.classList.add(newCondition);
            block.dataset.condition = newCondition;
            
            // Update block data
            blockData.condition = newCondition;
            blockData.sensors = this.generateBlockSensorData(newCondition);
            
            block.style.transform = 'scale(1)';
            block.style.opacity = '1';
            
            // Add glow effect
            block.classList.add('condition-change-glow');
            setTimeout(() => {
                block.classList.remove('condition-change-glow');
            }, 2000);
        }, 300);
    }

    // Enhanced predictions with AI-like behavior
    updatePredictions() {
        const predictions = [
            {
                type: 'positive',
                title: 'Optimal Growth Conditions',
                desc: 'Perfect weather patterns detected for next 7 days',
                time: '3 days',
                confidence: 0.94
            },
            {
                type: 'warning', 
                title: 'Water Stress Alert',
                desc: 'Block B3 showing early signs of moisture deficiency',
                time: '36 hours',
                confidence: 0.87
            },
            {
                type: 'info',
                title: 'Growth Acceleration',
                desc: 'Expected 15% growth spike due to optimal conditions',
                time: '5 days', 
                confidence: 0.91
            }
        ];

        const predictionsList = document.querySelector('.predictions-list');
        if (predictionsList) {
            predictionsList.innerHTML = predictions.map(pred => `
                <div class="prediction-item ${pred.type}" onclick="fieldCommandCenter.showPredictionDetails('${pred.title}')">
                    <div class="prediction-icon">
                        <i class="fas fa-${this.getPredictionIcon(pred.type)}"></i>
                    </div>
                    <div class="prediction-content">
                        <div class="prediction-title">${pred.title}</div>
                        <div class="prediction-desc">${pred.desc}</div>
                        <div class="prediction-confidence">${Math.round(pred.confidence * 100)}% confidence</div>
                    </div>
                    <div class="prediction-time">${pred.time}</div>
                </div>
            `).join('');
        }

        // Update accuracy indicator with slight variations
        const accuracyElement = document.querySelector('.prediction-accuracy');
        if (accuracyElement) {
            const baseAccuracy = 94;
            const variation = (Math.random() - 0.5) * 4; // ±2% variation
            const currentAccuracy = Math.max(85, Math.min(98, baseAccuracy + variation));
            accuracyElement.textContent = `${Math.round(currentAccuracy)}% Accurate`;
        }
    }

    getPredictionIcon(type) {
        const icons = {
            positive: 'check-circle',
            warning: 'exclamation-triangle', 
            info: 'seedling'
        };
        return icons[type] || 'info-circle';
    }

    // Enhanced event listeners
    setupEventListeners() {
        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key.toLowerCase()) {
                    case 'd':
                        e.preventDefault();
                        this.dispatchDrone();
                        break;
                    case 'r':
                        e.preventDefault();
                        this.generateReport();
                        break;
                    case 'a':
                        e.preventDefault();
                        this.runSoilAnalysis();
                        break;
                    case 'e':
                        e.preventDefault();
                        this.exportFieldData();
                        break;
                }
            }
            
            // Escape key closes modals
            if (e.key === 'Escape') {
                this.modalManager.closeAllModals();
            }
        });

        // Enhanced touch support
        this.setupTouchEvents();
        
        // Real-time clock update
        this.startRealTimeClock();
        
        // Performance monitoring
        this.startPerformanceMonitoring();
    }

    setupSensorInteractions() {
        // Make all sensor metrics clickable
        const sensorMetrics = document.querySelectorAll('.sensor-metric');
        sensorMetrics.forEach(metric => {
            metric.style.cursor = 'pointer';
            metric.addEventListener('click', (e) => {
                const label = metric.querySelector('.metric-label').textContent;
                const value = metric.querySelector('.metric-value').textContent;
                this.showSensorDetails(label, value, metric);
            });
        });
    }

    setupTouchEvents() {
        let touchStartX = 0;
        let touchStartY = 0;
        let touchStartTime = 0;

        document.addEventListener('touchstart', (e) => {
            touchStartX = e.changedTouches[0].screenX;
            touchStartY = e.changedTouches[0].screenY;
            touchStartTime = Date.now();
        });

        document.addEventListener('touchend', (e) => {
            const touchEndX = e.changedTouches[0].screenX;
            const touchEndY = e.changedTouches[0].screenY;
            const touchEndTime = Date.now();
            const diffX = touchStartX - touchEndX;
            const diffY = touchStartY - touchEndY;
            const duration = touchEndTime - touchStartTime;

            // Swipe gestures
            if (duration < 500) {
                if (Math.abs(diffX) > 50 && Math.abs(diffY) < 50) {
                    if (diffX > 0) {
                        this.refreshFieldData();
                    } else {
                        this.toggleSatelliteView();
                    }
                }
                
                // Pull to refresh
                if (diffY > 100 && Math.abs(diffX) < 50) {
                    this.refreshFieldData();
                }
            }
        });
    }

    startRealTimeClock() {
        const updateClock = () => {
            const now = new Date();
            const timeString = now.toLocaleTimeString('en-US', { 
                hour12: true, 
                hour: '2-digit', 
                minute: '2-digit',
                second: '2-digit'
            });
            
            // Update any clock elements
            const clockElements = document.querySelectorAll('.real-time-clock');
            clockElements.forEach(el => {
                el.textContent = timeString;
            });
        };
        
        updateClock();
        setInterval(updateClock, 1000);
    }

    startPerformanceMonitoring() {
        // Monitor and log performance metrics
        setInterval(() => {
            const memory = performance.memory;
            const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
            
            if (memory && memory.usedJSHeapSize > 500000000) { // 500MB threshold
                console.warn('High memory usage detected:', Math.round(memory.usedJSHeapSize / 1048576) + 'MB');
            }
        }, 30000);
    }

    // Enhanced modal management
    initializeModals() {
        this.modalManager.initModals();
    }

    initializeDroneFieldGrid() {
        const droneFieldGrid = document.getElementById('droneFieldGrid');
        if (droneFieldGrid) {
            droneFieldGrid.innerHTML = '';
            for (let i = 0; i < 16; i++) {
                const block = document.createElement('div');
                block.className = 'field-block-mini';
                block.dataset.blockId = `${String.fromCharCode(65 + Math.floor(i / 4))}${(i % 4) + 1}`;
                droneFieldGrid.appendChild(block);
            }
        }
    }

    // Enhanced block interactions
    animateBlockHover(block) {
        block.style.transform = 'translateY(-5px) scale(1.05)';
        block.style.zIndex = '10';
        
        const glow = block.querySelector('.block-glow');
        if (glow) {
            glow.style.opacity = '1';
            glow.style.animation = 'pulse 2s infinite';
        }
    }

    animateBlockHoverOut(block) {
        block.style.transform = '';
        block.style.zIndex = '';
        
        const glow = block.querySelector('.block-glow');
        if (glow) {
            glow.style.opacity = '0';
            glow.style.animation = 'none';
        }
    }

    // Enhanced modal show functions
    showBlockDetails(block) {
        const blockId = block.dataset.blockId;
        const condition = block.dataset.condition;
        const blockData = this.fieldData.find(b => b.id === blockId);
        
        if (blockData) {
            this.showBlockModal(blockId, condition, blockData);
        }
    }

    showBlockModal(blockId, condition, blockData) {
        // Update modal content
        document.getElementById('blockTitle').textContent = `Block ${blockId}`;
        document.getElementById('blockStatus').textContent = condition.charAt(0).toUpperCase() + condition.slice(1);
        document.getElementById('blockStatus').className = `status-badge ${condition}`;
        
        // Update sensor data
        document.getElementById('blockTemp').textContent = `${blockData.sensors.temperature}°C`;
        document.getElementById('blockMoisture').textContent = `${blockData.sensors.moisture}%`;
        document.getElementById('blockPH').textContent = blockData.sensors.ph;
        document.getElementById('blockNitrogen').textContent = `${blockData.sensors.nitrogen} ppm`;
        
        // Update issues and recommendations
        this.updateBlockIssues(blockId, condition);
        
        // Show modal
        this.modalManager.openModal('fieldBlockModal');
    }

    updateBlockIssues(blockId, condition) {
        const issuesSection = document.getElementById('issuesSection');
        const recommendationsList = document.getElementById('recommendationsList');
        
        const issues = this.generateBlockIssues(blockId, condition);
        const recommendations = this.generateRecommendations(condition);
        
        if (issues.length > 0) {
            issuesSection.style.display = 'block';
            issuesSection.querySelector('.issue-list').innerHTML = issues.map(issue => `
                <div class="issue-item ${issue.severity}">
                    <i class="fas fa-${issue.icon}"></i>
                    <span>${issue.message}</span>
                </div>
            `).join('');
        } else {
            issuesSection.style.display = 'none';
        }
        
        recommendationsList.innerHTML = recommendations.map(rec => `<li>${rec}</li>`).join('');
    }

    generateBlockIssues(blockId, condition) {
        const issues = [];
        
        if (condition === 'critical') {
            issues.push(
                { severity: 'critical', icon: 'skull-crossbones', message: 'High pest activity detected' },
                { severity: 'critical', icon: 'tint', message: 'Severe moisture deficiency' }
            );
        } else if (condition === 'warning') {
            issues.push(
                { severity: 'warning', icon: 'exclamation-triangle', message: 'Moderate nutrient imbalance' }
            );
        } else if (condition === 'good' && Math.random() < 0.3) {
            issues.push(
                { severity: 'info', icon: 'info-circle', message: 'Minor soil compaction detected' }
            );
        }
        
        return issues;
    }

    generateRecommendations(condition) {
        const recommendations = {
            excellent: [
                'Maintain current irrigation schedule',
                'Continue regular monitoring',
                'Schedule monthly soil testing'
            ],
            good: [
                'Increase monitoring frequency',
                'Consider light fertilization',
                'Check irrigation system for consistency'
            ],
            warning: [
                'Apply targeted treatment immediately',
                'Increase irrigation by 20%',
                'Schedule expert consultation',
                'Monitor daily for changes'
            ],
            critical: [
                'URGENT: Apply emergency treatment',
                'Contact field expert immediately', 
                'Increase irrigation by 40%',
                'Isolate affected area if possible',
                'Prepare contingency plan'
            ]
        };
        
        return recommendations[condition] || recommendations.excellent;
    }

    showSensorDetails(label, value, element) {
        // Update sensor details modal
        document.getElementById('sensorDetailTitle').textContent = label;
        document.getElementById('sensorCurrentValue').textContent = value;
        
        // Show modal with animation
        this.modalManager.openModal('sensorDetailsModal');
        
        // Add visual feedback
        element.style.transform = 'scale(0.95)';
        setTimeout(() => {
            element.style.transform = '';
        }, 300);
    }

    showPredictionDetails(title) {
        this.showNotification(`Showing detailed analysis for: ${title}`, 'info');
        // In a real implementation, this would show detailed prediction analysis
    }

    showWeatherDetails() {
        this.modalManager.openModal('weatherDetailsModal');
    }

    // Enhanced drone dispatch with visual simulation
    dispatchDrone() {
        if (this.droneSurveyInProgress) {
            this.showNotification('Drone survey already in progress', 'warning');
            return;
        }
        
        this.droneSurveyInProgress = true;
        this.modalManager.openModal('droneModal');
        this.startDroneSurvey();
    }

    startDroneSurvey() {
        const droneIcon = document.getElementById('droneIcon');
        const droneProgress = document.getElementById('droneProgress');
        const droneProgressText = document.getElementById('droneProgressText');
        const currentBlock = document.getElementById('currentBlock');
        const detectionList = document.querySelector('.detection-list');
        const miniBlocks = document.querySelectorAll('.field-block-mini');
        
        let progress = 0;
        let currentBlockIndex = 0;
        const blocks = ['A1', 'A2', 'A3', 'A4', 'B1', 'B2', 'B3', 'B4', 'C1', 'C2', 'C3', 'C4', 'D1', 'D2', 'D3', 'D4'];
        const detections = [];
        
        // Initialize drone position
        this.positionDroneAtStart(droneIcon, miniBlocks[0]);
        
        const surveyInterval = setInterval(() => {
            if (currentBlockIndex < blocks.length) {
                const blockId = blocks[currentBlockIndex];
                currentBlock.textContent = blockId;
                
                // Move drone to current block
                this.animateDroneMovement(droneIcon, miniBlocks[currentBlockIndex]);
                
                // Mark block as scanned
                this.markBlockScanned(miniBlocks[currentBlockIndex]);
                
                // Random detections
                if (Math.random() < 0.3) {
                    this.addRandomDetection(detections, blockId, detectionList);
                }
                
                currentBlockIndex++;
                progress = (currentBlockIndex / blocks.length) * 100;
                droneProgress.style.width = `${progress}%`;
                droneProgressText.textContent = `${Math.round(progress)}%`;
            }
            
            if (progress >= 100) {
                clearInterval(surveyInterval);
                this.completeDroneSurvey();
            }
        }, 600);
    }

    positionDroneAtStart(droneIcon, startBlock) {
        const rect = startBlock.getBoundingClientRect();
        const containerRect = droneIcon.parentElement.getBoundingClientRect();
        
        droneIcon.style.left = `${rect.left - containerRect.left + rect.width / 2 - 20}px`;
        droneIcon.style.top = `${rect.top - containerRect.top + rect.height / 2 - 20}px`;
    }

    animateDroneMovement(droneIcon, targetBlock) {
        const rect = targetBlock.getBoundingClientRect();
        const containerRect = droneIcon.parentElement.getBoundingClientRect();
        
        const targetX = rect.left - containerRect.left + rect.width / 2 - 20;
        const targetY = rect.top - containerRect.top + rect.height / 2 - 20;
        
        droneIcon.style.transition = 'all 1s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
        droneIcon.style.left = `${targetX}px`;
        droneIcon.style.top = `${targetY}px`;
        
        // Add flying animation
        droneIcon.style.animation = 'droneFloat 1s ease-in-out';
        setTimeout(() => {
            droneIcon.style.animation = 'droneFloat 3s ease-in-out infinite';
        }, 1000);
    }

    markBlockScanned(block) {
        block.classList.add('scanned');
        block.style.animation = 'scanPulse 0.5s ease-in-out';
        setTimeout(() => {
            block.style.animation = '';
        }, 500);
    }

    addRandomDetection(detections, blockId, detectionList) {
        const detectionTypes = [
            { type: 'animal', icon: 'crow', message: 'Wild birds in sector', class: 'animal' },
            { type: 'animal', icon: 'deer', message: 'Deer spotted near', class: 'animal' },
            { type: 'human', icon: 'user', message: 'Field worker in', class: 'human' },
            { type: 'equipment', icon: 'tractor', message: 'Equipment movement in', class: 'equipment' }
        ];
        
        const detection = detectionTypes[Math.floor(Math.random() * detectionTypes.length)];
        const detectionItem = {
            type: detection.type,
            message: `${detection.message} ${blockId}`,
            class: detection.class,
            icon: detection.icon
        };
        
        detections.push(detectionItem);
        
        // Update UI
        detectionList.innerHTML = detections.slice(-3).map(det => `
            <div class="detection-item ${det.class}">
                <i class="fas fa-${det.icon}"></i>
                <span>${det.message}</span>
            </div>
        `).join('');
    }

    completeDroneSurvey() {
        this.droneSurveyInProgress = false;
        
        setTimeout(() => {
            this.modalManager.closeModal('droneModal');
            this.showNotification('Drone survey completed! Full analysis available.', 'success');
            
            // Update field data with drone findings
            this.updateFieldDataAfterDroneSurvey();
        }, 1500);
    }

    updateFieldDataAfterDroneSurvey() {
        // Simulate data updates from drone survey
        this.showNotification('Processing drone data and updating field analytics...', 'info');
        
        setTimeout(() => {
            this.refreshFieldData();
            this.showNotification('Field analytics updated with drone data', 'success');
        }, 2000);
    }

    // Enhanced soil analysis
    runSoilAnalysis() {
        if (this.soilAnalysisInProgress) {
            this.showNotification('Soil analysis already in progress', 'warning');
            return;
        }
        
        this.soilAnalysisInProgress = true;
        this.modalManager.openModal('soilAnalysisModal');
        this.startSoilAnalysis();
    }

    startSoilAnalysis() {
        const steps = document.querySelectorAll('.progress-steps .step');
        const analysisResults = document.getElementById('analysisResults');
        const analysisProgress = document.getElementById('analysisProgress');
        
        let currentStep = 0;
        
        const analysisInterval = setInterval(() => {
            if (currentStep > 0) {
                steps[currentStep - 1].classList.remove('active');
                steps[currentStep - 1].classList.add('completed');
            }
            
            if (currentStep < steps.length) {
                steps[currentStep].classList.add('active');
                this.animateStepProgress(steps[currentStep]);
                currentStep++;
            } else {
                clearInterval(analysisInterval);
                this.completeSoilAnalysis(analysisProgress, analysisResults);
            }
        }, 2000);
    }

    animateStepProgress(step) {
        const icon = step.querySelector('i');
        icon.style.transform = 'scale(1.2)';
        setTimeout(() => {
            icon.style.transform = 'scale(1)';
        }, 500);
    }

    completeSoilAnalysis(analysisProgress, analysisResults) {
        this.soilAnalysisInProgress = false;
        
        analysisProgress.style.display = 'none';
        analysisResults.style.display = 'block';
        
        // Simulate analysis results
        setTimeout(() => {
            this.modalManager.closeModal('soilAnalysisModal');
            this.showNotification('Soil analysis complete! Review recommendations.', 'success');
        }, 3000);
    }

    // Enhanced report generation
    generateReport() {
        this.showNotification('Compiling comprehensive field report...', 'info');
        
        const reportData = this.generateComprehensiveReport();
        
        setTimeout(() => {
            this.showReportModal(reportData);
            this.showNotification('Field report generated successfully', 'success');
        }, 2500);
    }

    generateComprehensiveReport() {
        const now = new Date();
        return {
            timestamp: now.toISOString(),
            period: 'Last 7 Days',
            fieldHealth: '85%',
            activeAlerts: document.querySelectorAll('.alert-item').length,
            sensorStatus: '24/24 Online',
            weatherImpact: 'Positive',
            cropGrowth: '+12%',
            recommendations: [
                'Increase irrigation in Block C1 by 15%',
                'Apply organic fertilizer in Sector B',
                'Monitor pest activity in A2 daily',
                'Schedule drone survey for next week',
                'Consider soil aeration in northern sections'
            ],
            predictions: [
                'Optimal growth conditions for next 5 days',
                'Watch for temperature spikes in afternoon',
                'Expected rainfall in 48 hours'
            ]
        };
    }

    showReportModal(reportData) {
        // In a real implementation, this would show a detailed report modal
        console.log('Generated Report:', reportData);
        this.showNotification(`Report generated for ${reportData.period}`, 'success');
        
        // For demo, show alert with key metrics
        alert(`Field Performance Report\n\n` +
              `Period: ${reportData.period}\n` +
              `Field Health: ${reportData.fieldHealth}\n` +
              `Active Alerts: ${reportData.activeAlerts}\n` +
              `Crop Growth: ${reportData.cropGrowth}\n\n` +
              `Top Recommendation: ${reportData.recommendations[0]}`);
    }

    // Enhanced agronomist connection
    connectToAgronomist() {
        this.modalManager.openModal('agronomistModal');
        
        // Simulate connection process
        setTimeout(() => {
            this.modalManager.closeModal('agronomistModal');
            this.showNotification('Connected to Dr. Sarah Chen - Senior Agronomist', 'success');
            
            // Simulate conversation start
            setTimeout(() => {
                this.showNotification('Dr. Chen: "Hello! I\'m reviewing your field data now..."', 'info');
            }, 1000);
        }, 4000);
    }

    connectToExpert(expertType) {
        const experts = {
            pest_control: { name: 'Alex Rodriguez', title: 'Pest Management Specialist' },
            irrigation: { name: 'Maria Garcia', title: 'Irrigation Engineer' },
            soil_health: { name: 'Dr. James Wilson', title: 'Soil Scientist' }
        };
        
        const expert = experts[expertType] || { name: 'Field Expert', title: 'Agricultural Specialist' };
        
        this.showNotification(`Connecting to ${expert.name} - ${expert.title}...`, 'info');
        
        setTimeout(() => {
            this.showNotification(`Connected to ${expert.name}`, 'success');
        }, 3000);
    }

    // Enhanced notification system
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <i class="fas fa-${this.getNotificationIcon(type)}"></i>
                <span>${message}</span>
            </div>
            <button class="notification-close" onclick="this.parentElement.remove()">
                <i class="fas fa-times"></i>
            </button>
        `;
        
        document.body.appendChild(notification);
        
        // Auto-remove with fade out
        setTimeout(() => {
            if (notification.parentElement) {
                notification.style.animation = 'fadeOut 0.5s ease forwards';
                setTimeout(() => {
                    if (notification.parentElement) {
                        notification.remove();
                    }
                }, 500);
            }
        }, 5000);
    }

    getNotificationIcon(type) {
        const icons = {
            success: 'check-circle',
            error: 'exclamation-circle',
            warning: 'exclamation-triangle',
            info: 'info-circle'
        };
        return icons[type] || 'info-circle';
    }

    // Toggle satellite view with enhanced animation
    toggleSatelliteView() {
        this.isSatelliteView = !this.isSatelliteView;
        const fieldGrid = document.getElementById('fieldGrid');
        const satelliteBtn = document.querySelector('[onclick="toggleSatelliteView()"]');
        
        fieldGrid.style.transition = 'all 0.5s ease-in-out';
        
        if (this.isSatelliteView) {
            fieldGrid.classList.add('satellite-view');
            satelliteBtn.classList.add('active');
            satelliteBtn.innerHTML = '<i class="fas fa-map"></i>';
            satelliteBtn.title = 'Switch to Map View';
        } else {
            fieldGrid.classList.remove('satellite-view');
            satelliteBtn.classList.remove('active');
            satelliteBtn.innerHTML = '<i class="fas fa-satellite"></i>';
            satelliteBtn.title = 'Switch to Satellite View';
        }
    }

    // Enhanced data refresh
    refreshFieldData() {
        const refreshBtn = document.querySelector('[onclick="refreshFieldData()"]');
        
        refreshBtn.classList.add('loading');
        refreshBtn.style.transform = 'scale(0.9)';
        
        this.showNotification('Syncing with field sensors...', 'info');
        
        setTimeout(() => {
            this.updateSensorData();
            this.updateFieldConditions();
            this.updatePredictions();
            
            refreshBtn.classList.remove('loading');
            refreshBtn.style.transform = '';
            
            this.showNotification('Field data synchronized successfully', 'success');
        }, 2000);
    }

    // Enhanced data export
    exportFieldData() {
        const data = {
            timestamp: new Date().toISOString(),
            sensorReadings: this.sensorData,
            fieldConditions: this.fieldData,
            alerts: document.querySelectorAll('.alert-item').length,
            predictions: this.getCurrentPredictions()
        };
        
        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `field-command-data-${new Date().toISOString().split('T')[0]}.json`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        this.showNotification('Field data exported successfully', 'success');
    }

    getCurrentPredictions() {
        const predictions = [];
        document.querySelectorAll('.prediction-item').forEach(item => {
            predictions.push({
                title: item.querySelector('.prediction-title').textContent,
                type: Array.from(item.classList).find(cls => cls.includes('positive') || cls.includes('warning') || cls.includes('info')),
                time: item.querySelector('.prediction-time').textContent
            });
        });
        return predictions;
    }

    // Emergency shutdown with confirmation
    emergencyShutdown() {
        if (confirm('🚨 EMERGENCY SHUTDOWN 🚨\n\nThis will immediately:\n• Stop all irrigation systems\n• Halt drone operations\n• Disable sensor networks\n• Notify field personnel\n\nAre you sure you want to proceed?')) {
            this.showNotification('EMERGENCY SHUTDOWN INITIATED - All systems offline', 'error');
            
            // Visual shutdown effect
            document.body.style.filter = 'grayscale(50%)';
            setTimeout(() => {
                document.body.style.filter = '';
            }, 3000);
        }
    }
}

// Modal Manager Class
class ModalManager {
    constructor() {
        this.modals = {};
        this.currentModal = null;
    }

    initModals() {
        document.querySelectorAll('.modal').forEach(modal => {
            const modalId = modal.id;
            this.modals[modalId] = modal;
            
            // Close buttons
            modal.querySelectorAll('.close').forEach(closeBtn => {
                closeBtn.addEventListener('click', () => this.closeModal(modalId));
            });
            
            // Close on background click
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeModal(modalId);
                }
            });
            
            // Escape key support
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && this.currentModal === modalId) {
                    this.closeModal(modalId);
                }
            });
        });
    }

    openModal(modalId) {
        const modal = this.modals[modalId];
        if (modal) {
            this.currentModal = modalId;
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden';
            
            // Add opening animation
            modal.style.animation = 'modalFadeIn 0.3s ease';
        }
    }

    closeModal(modalId) {
        const modal = this.modals[modalId];
        if (modal) {
            modal.style.animation = 'modalFadeOut 0.3s ease forwards';
            setTimeout(() => {
                modal.style.display = 'none';
                modal.style.animation = '';
                this.currentModal = null;
                document.body.style.overflow = '';
            }, 250);
        }
    }

    closeAllModals() {
        Object.keys(this.modals).forEach(modalId => {
            this.closeModal(modalId);
        });
    }
}

// Initialize the command center when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.fieldCommandCenter = new FieldCommandCenter();
});

// Global functions for HTML onclick handlers
function toggleSatelliteView() {
    window.fieldCommandCenter.toggleSatelliteView();
}

function refreshFieldData() {
    window.fieldCommandCenter.refreshFieldData();
}

function dispatchDrone() {
    window.fieldCommandCenter.dispatchDrone();
}

function runSoilAnalysis() {
    window.fieldCommandCenter.runSoilAnalysis();
}

function generateReport() {
    window.fieldCommandCenter.generateReport();
}

function connectToAgronomist() {
    window.fieldCommandCenter.connectToAgronomist();
}

function connectToExpert(expertType) {
    window.fieldCommandCenter.connectToExpert(expertType);
}

function scheduleIrrigation(blockId) {
    window.fieldCommandCenter.scheduleIrrigation(blockId);
}

function showWeatherDetails() {
    window.fieldCommandCenter.showWeatherDetails();
}

function showSensorDetails(label, value) {
    // This will be handled by the sensor metric click listeners
}

// Additional utility functions
function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.log('Fullscreen request failed:', err);
        });
    } else {
        document.exitFullscreen();
    }
}

// Add enhanced CSS animations
const enhancedStyles = document.createElement('style');
enhancedStyles.textContent = `
    .condition-change-glow {
        animation: conditionGlow 2s ease-in-out;
    }
    
    .block-glow {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        border-radius: inherit;
        opacity: 0;
        background: radial-gradient(circle at center, rgba(255,255,255,0.3) 0%, transparent 70%);
        pointer-events: none;
        transition: opacity 0.3s ease;
    }
    
    .scanned {
        background: #4CAF50 !important;
        box-shadow: 0 0 20px rgba(76, 175, 80, 0.5);
    }
    
    .field-block-mini {
        transition: all 0.5s ease;
    }
    
    @keyframes conditionGlow {
        0% { box-shadow: 0 0 0 0 rgba(76, 175, 80, 0.7); }
        50% { box-shadow: 0 0 20px 10px rgba(76, 175, 80, 0.3); }
        100% { box-shadow: 0 0 0 0 rgba(76, 175, 80, 0); }
    }
    
    @keyframes scanPulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.1); }
        100% { transform: scale(1); }
    }
    
    @keyframes droneFloat {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        50% { transform: translateY(-10px) rotate(5deg); }
    }
    
    @keyframes modalFadeOut {
        to { 
            opacity: 0;
            transform: translateY(-50px) scale(0.9);
        }
    }
    
    .prediction-confidence {
        font-size: 0.75rem;
        color: #b3d4fc;
        margin-top: 0.25rem;
    }
    
    .step.completed {
        color: #4CAF50;
    }
    
    .step.completed i {
        color: #4CAF50 !important;
    }
    
    .detection-item.equipment {
        border-left: 4px solid #9C27B0;
    }
    
    .real-time-clock {
        font-family: 'Courier New', monospace;
        font-weight: bold;
        background: rgba(255,255,255,0.1);
        padding: 0.25rem 0.5rem;
        border-radius: 4px;
        border: 1px solid rgba(255,255,255,0.2);
    }
`;
document.head.appendChild(enhancedStyles);

// Performance optimization
window.addEventListener('load', () => {
    // Preload critical resources
    const criticalImages = [
        'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="%231a237e"/><circle cx="30" cy="30" r="8" fill="%234caf50"/><circle cx="70" cy="40" r="6" fill="%238bc34a"/><circle cx="50" cy="70" r="10" fill="%23ffc107"/><circle cx="80" cy="20" r="4" fill="%23f44336"/></svg>'
    ];
    
    criticalImages.forEach(src => {
        const img = new Image();
        img.src = src;
    });
});

// Error handling
window.addEventListener('error', (e) => {
    console.error('Application error:', e.error);
    // In production, you might want to send this to a logging service
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { FieldCommandCenter, ModalManager };
}