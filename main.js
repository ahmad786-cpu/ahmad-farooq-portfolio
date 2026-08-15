import { initForm } from '@formspree/ajax';

// Initialize Lucide Icons (Moved into DOMContentLoaded for safety)

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
    "React Native Developer",
    "Full-Stack Developer",
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
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
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

// Scroll Event Handler - Optimized to prevent layout thrashing
let sectionOffsets = [];

function cacheSectionOffsets() {
    sectionOffsets = Array.from(sections).map(section => ({
        id: section.getAttribute('id'),
        top: section.offsetTop - 150
    }));
}

window.addEventListener('resize', cacheSectionOffsets);
document.addEventListener('DOMContentLoaded', cacheSectionOffsets);

window.addEventListener('scroll', () => {
    const scrollPos = window.scrollY || window.pageYOffset;

    if (scrollPos > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    if (scrollPos > 500) {
        backToTop.classList.add('show');
    } else {
        backToTop.classList.remove('show');
    }

    let current = "";
    for (const section of sectionOffsets) {
        if (scrollPos >= section.top) {
            current = section.id;
        }
    }

    if (current) {
        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href').includes(current)) {
                link.classList.add('active');
            }
        });
    }
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

// FAQ Accordion Logic
const faqItems = document.querySelectorAll('.faq-item');
faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');
    question.addEventListener('click', () => {
        const isActive = item.classList.contains('active');
        
        // Close all other items
        faqItems.forEach(i => i.classList.remove('active'));
        
        // Toggle current item
        if (!isActive) {
            item.classList.add('active');
        }
    });
});

// Solution Cards Glow Effect - Optimized to prevent forced reflows
const solutionCards = document.querySelectorAll('.solution-card');
solutionCards.forEach(card => {
    let rect;

    card.addEventListener('mouseenter', () => {
        rect = card.getBoundingClientRect();
    });

    card.addEventListener('mousemove', e => {
        if (!rect) rect = card.getBoundingClientRect();
        const x = ((e.clientX - rect.left) / rect.width) * 100;
        const y = ((e.clientY - rect.top) / rect.height) * 100;
        card.style.setProperty('--mouse-x', `${x}%`);
        card.style.setProperty('--mouse-y', `${y}%`);
    });
});

// 3D Tilt Effect - project/tech/glass cards tilt toward the pointer,
// same rect-caching approach as the solution card glow above.
const tiltCards = document.querySelectorAll('.pcard, .tech-category, .glass-card');
const TILT_MAX_DEG = 4;

tiltCards.forEach(card => {
    let rect;

    card.addEventListener('mouseenter', () => {
        rect = card.getBoundingClientRect();
    });

    card.addEventListener('mousemove', e => {
        if (!rect) rect = card.getBoundingClientRect();
        const px = (e.clientX - rect.left) / rect.width;
        const py = (e.clientY - rect.top) / rect.height;
        const ry = (px - 0.5) * 2 * TILT_MAX_DEG;
        const rx = (0.5 - py) * 2 * TILT_MAX_DEG;
        card.style.setProperty('--rx', `${rx}deg`);
        card.style.setProperty('--ry', `${ry}deg`);
    });

    card.addEventListener('mouseleave', () => {
        card.style.setProperty('--rx', '0deg');
        card.style.setProperty('--ry', '0deg');
    });
});

// Navbar logo gets the same tilt treatment, with a tighter range.
const logo = document.querySelector('.logo');
if (logo) {
    let logoRect;
    const LOGO_TILT_MAX_DEG = 6;

    logo.addEventListener('mouseenter', () => {
        logoRect = logo.getBoundingClientRect();
    });

    logo.addEventListener('mousemove', e => {
        if (!logoRect) logoRect = logo.getBoundingClientRect();
        const px = (e.clientX - logoRect.left) / logoRect.width;
        const py = (e.clientY - logoRect.top) / logoRect.height;
        logo.style.setProperty('--lry', `${(px - 0.5) * 2 * LOGO_TILT_MAX_DEG}deg`);
        logo.style.setProperty('--lrx', `${(0.5 - py) * 2 * LOGO_TILT_MAX_DEG}deg`);
    });

    logo.addEventListener('mouseleave', () => {
        logo.style.setProperty('--lrx', '0deg');
        logo.style.setProperty('--lry', '0deg');
    });
}
