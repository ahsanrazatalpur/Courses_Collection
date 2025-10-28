// Select elements
const menuToggle = document.getElementById('menuToggle');
const navLinks = document.getElementById('navLinks');

// Toggle navigation visibility
menuToggle.addEventListener('click', () => {
    navLinks.classList.toggle('show');
});