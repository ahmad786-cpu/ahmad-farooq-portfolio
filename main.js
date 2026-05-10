import { initForm } from '@formspree/ajax';

// Initialize Lucide Icons
lucide.createIcons();

// Navbar and Scroll Effects
const navbar = document.getElementById('navbar');
const navLinks = document.querySelectorAll('.nav-links a');
const mobileToggle = document.getElementById('mobile-toggle');
const navLinksContainer = document.getElementById('nav-links');
const backToTop = document.getElementById('backToTop');
const sections = document.querySelectorAll('section');

// Typewriter Effect
const typewriterElement = document.getElementById('typewriter');
const roles = [
    "Flutter Developer",
    "Product Engineer",
    "UI/UX Designer",
    "Open Source Contributor",
    "Tech Lead"
];
let roleIndex = 0;
let charIndex = 0;
let isDeleting = false;
let typeSpeed = 100;

function type() {
    const currentRole = roles[roleIndex];
    
    if (isDeleting) {
        typewriterElement.textContent = currentRole.substring(0, charIndex - 1);
        charIndex--;
        typeSpeed = 50;
    } else {
        typewriterElement.textContent = currentRole.substring(0, charIndex + 1);
        charIndex++;
        typeSpeed = 150;
    }

    if (!isDeleting && charIndex === currentRole.length) {
        isDeleting = true;
        typeSpeed = 2000; // Pause at end
    } else if (isDeleting && charIndex === 0) {
        isDeleting = false;
        roleIndex = (roleIndex + 1) % roles.length;
        typeSpeed = 500;
    }

    setTimeout(type, typeSpeed);
}

document.addEventListener('DOMContentLoaded', () => {
    type();
    updateFooterDate();
});

// Footer Date
function updateFooterDate() {
    const dayElement = document.getElementById('current-day');
    const dateElement = document.getElementById('current-date');
    const now = new Date();
    
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    dayElement.textContent = now.getDate();
    dateElement.textContent = `${days[now.getDay()]}, ${months[now.getMonth()]} ${now.getFullYear()}`;
}

// Scroll Event Handler
window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    if (window.scrollY > 500) {
        backToTop.classList.add('show');
    } else {
        backToTop.classList.remove('show');
    }

    let current = "";
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= (sectionTop - 150)) {
            current = section.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href').includes(current)) {
            link.classList.add('active');
        }
    });
});

// Mobile Toggle
if (mobileToggle) {
    mobileToggle.addEventListener('click', () => {
        navLinksContainer.classList.toggle('active');
        const icon = mobileToggle.querySelector('i');
        if (navLinksContainer.classList.contains('active')) {
            icon.setAttribute('data-lucide', 'x');
        } else {
            icon.setAttribute('data-lucide', 'menu');
        }
        lucide.createIcons();
    });
}

// Reveal Animations
const revealElements = document.querySelectorAll('[data-reveal]');
const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('active');
        }
    });
}, { threshold: 0.1 });

revealElements.forEach(el => revealObserver.observe(el));

// Smooth scrolling
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const targetId = this.getAttribute('href');
        if (targetId === "#") return;
        e.preventDefault();
        const target = document.querySelector(targetId);
        if (target) {
            window.scrollTo({
                top: target.offsetTop - 100,
                behavior: 'smooth'
            });
            navLinksContainer.classList.remove('active');
        }
    });
});

// Back to Top Click
if (backToTop) {
    backToTop.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}
