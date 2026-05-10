import { initForm } from '@formspree/ajax';

// Initialize Lucide Icons
lucide.createIcons();

// Navbar Scroll Effect
const navbar = document.getElementById('navbar');
const navLinks = document.querySelectorAll('.nav-links a');
const backToTop = document.getElementById('backToTop');

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
    
    // Update active link on scroll
    updateActiveLink();
});

backToTop.addEventListener('click', () => {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
});

function updateActiveLink() {
    let current = "";
    const sections = document.querySelectorAll('section');
    
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
}

// Reveal Animations on Scroll
const revealElements = document.querySelectorAll('[data-reveal]');

const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('active');
            // Stop observing once revealed
            // revealObserver.unobserve(entry.target); 
        }
    });
}, {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
});

revealElements.forEach(el => {
    revealObserver.observe(el);
});

// Contact Form Handling
const contactForm = document.getElementById('portfolio-contact-form');

if (contactForm) {
    initForm({
        formElement: '#portfolio-contact-form',
        formId: 'mjglporl',
        onSuccess: () => {
            const btn = contactForm.querySelector('button');
            const originalText = btn.innerHTML;
            btn.innerHTML = 'Message Sent! <i data-lucide="check"></i>';
            btn.style.background = 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)';
            lucide.createIcons();
            contactForm.reset();
            
            setTimeout(() => {
                btn.innerHTML = 'Send Message <i data-lucide="send"></i>';
                btn.style.background = '';
                btn.disabled = false;
                lucide.createIcons();
            }, 4000);
        },
        onError: () => {
            const btn = contactForm.querySelector('button');
            btn.innerHTML = 'Error! Try Again <i data-lucide="alert-circle"></i>';
            btn.style.background = '#ef4444';
            lucide.createIcons();
            
            setTimeout(() => {
                btn.innerHTML = 'Send Message <i data-lucide="send"></i>';
                btn.style.background = '';
                btn.disabled = false;
                lucide.createIcons();
            }, 4000);
        }
    });

    // Add a simple listener for the "Sending..." state
    contactForm.addEventListener('submit', () => {
        const btn = contactForm.querySelector('button');
        btn.innerHTML = 'Sending...';
        btn.disabled = true;
    });
}

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            window.scrollTo({
                top: target.offsetTop - 80,
                behavior: 'smooth'
            });
        }
    });
});
