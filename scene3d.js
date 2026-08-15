import * as THREE from 'three';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/examples/jsm/postprocessing/OutputPass.js';

// Progressive enhancement only: bail out cleanly if the browser can't
// render WebGL, or the visitor has asked for less motion. The flat
// design underneath keeps working exactly as before either way.
function supportsWebGL() {
    try {
        const canvas = document.createElement('canvas');
        return !!(window.WebGLRenderingContext &&
            (canvas.getContext('webgl') || canvas.getContext('experimental-webgl')));
    } catch (e) {
        return false;
    }
}

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const canvas = document.getElementById('webgl-scene');

if (!canvas || prefersReducedMotion || !supportsWebGL()) {
    if (canvas) canvas.style.display = 'none';
} else {
    gsap.registerPlugin(ScrollTrigger);
    initScene(canvas);
}

function initScene(canvas) {
    const PRIMARY = 0x18b5ff;
    const SECONDARY = 0x0d5cff;
    const BG = 0x03091a;

    const scene = new THREE.Scene();
    scene.fog = new THREE.FogExp2(BG, 0.018);

    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);

    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: false });
    renderer.setClearColor(BG, 1);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.0;

    // Bloom gives the wireframe geometry a soft glow — kept restrained so it
    // reads as premium ambiance, not a neon/gamey effect.
    const composer = new EffectComposer(renderer);
    composer.addPass(new RenderPass(scene, camera));
    const bloomPass = new UnrealBloomPass(
        new THREE.Vector2(window.innerWidth, window.innerHeight),
        0.45,  // strength
        0.35,  // radius
        0.3,   // luminance threshold
    );
    composer.addPass(bloomPass);
    composer.addPass(new OutputPass());

    // --- Camera path: one waypoint per section, in document order ---
    const stops = [
        { id: 'home', pos: [0, 1.5, 20], look: [0, 1, 5] },
        { id: 'solutions', pos: [3, 2, -15], look: [3, 1, -25] },
        { id: 'about', pos: [-3, 1.5, -45], look: [-3, 1, -55] },
        { id: 'tech', pos: [0, 3, -80], look: [0, 2, -95] },
        { id: 'projects', pos: [4, 1, -125], look: [4, 1, -140] },
        { id: 'experience', pos: [-4, 2, -170], look: [-4, 2, -185] },
        { id: 'community', pos: [0, 3, -215], look: [0, 2, -230] },
        { id: 'contact', pos: [0, 1, -260], look: [0, 1, -280] },
        { id: 'faq', pos: [2, 2, -300], look: [2, 2, -315] },
    ];

    const positionCurve = new THREE.CatmullRomCurve3(stops.map(s => new THREE.Vector3(...s.pos)));
    const lookCurve = new THREE.CatmullRomCurve3(stops.map(s => new THREE.Vector3(...s.look)));

    // --- Ambient starfield spanning the whole path ---
    const STAR_COUNT = 1400;
    const starGeo = new THREE.BufferGeometry();
    const starPositions = new Float32Array(STAR_COUNT * 3);
    for (let i = 0; i < STAR_COUNT; i++) {
        starPositions[i * 3] = (Math.random() - 0.5) * 160;
        starPositions[i * 3 + 1] = (Math.random() - 0.5) * 100;
        starPositions[i * 3 + 2] = 40 - Math.random() * 380;
    }
    starGeo.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
    const starMat = new THREE.PointsMaterial({
        color: PRIMARY,
        size: 0.35,
        sizeAttenuation: true,
        transparent: true,
        opacity: 0.4,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
    });
    scene.add(new THREE.Points(starGeo, starMat));

    // --- Receding wireframe floor grid ---
    const grid = new THREE.GridHelper(420, 42, PRIMARY, SECONDARY);
    grid.position.set(0, -6, -150);
    grid.material.transparent = true;
    grid.material.opacity = 0.15;
    scene.add(grid);

    // --- Per-section landmarks (built once, animated every frame) ---
    const spinners = [];

    function addSpinner(mesh, pos, speed = 0.15) {
        mesh.position.set(...pos);
        scene.add(mesh);
        spinners.push({ mesh, speed });
        return mesh;
    }

    function wireMat(color = PRIMARY, opacity = 0.6) {
        return new THREE.MeshBasicMaterial({ color, wireframe: true, transparent: true, opacity });
    }

    // home: glowing core
    addSpinner(new THREE.Mesh(new THREE.IcosahedronGeometry(4, 1), wireMat(PRIMARY)), stops[0].look, 0.08);

    // solutions: three small shards
    const solutionsGroup = new THREE.Group();
    [-2, 0, 2].forEach((x, i) => {
        const shard = new THREE.Mesh(new THREE.OctahedronGeometry(1.1), wireMat(i === 1 ? SECONDARY : PRIMARY));
        shard.position.set(x, Math.sin(i) * 1.2, 0);
        solutionsGroup.add(shard);
    });
    addSpinner(solutionsGroup, stops[1].look, 0.12);

    // about: soft pulsing sphere
    const aboutSphere = addSpinner(new THREE.Mesh(new THREE.SphereGeometry(2.5, 16, 16), wireMat(PRIMARY, 0.5)), stops[2].look, 0.05);

    // tech: ring of orbiting nodes, laced together by a live-updating web of lines
    const techGroup = new THREE.Group();
    techGroup.add(new THREE.Mesh(new THREE.TorusGeometry(3.2, 0.05, 8, 48), wireMat(SECONDARY, 0.5)));
    const orbitNodes = [];
    const NODE_COUNT = 8;
    for (let i = 0; i < NODE_COUNT; i++) {
        const node = new THREE.Mesh(new THREE.SphereGeometry(0.28, 10, 10), wireMat(PRIMARY));
        const angle = (i / NODE_COUNT) * Math.PI * 2;
        node.userData.angle = angle;
        techGroup.add(node);
        orbitNodes.push(node);
    }
    // Each node links to the two nodes across the ring, so the shape reads as a
    // rotating constellation/network rather than a plain circle of dots.
    const linkPairs = [];
    for (let i = 0; i < NODE_COUNT; i++) {
        linkPairs.push([i, (i + 1) % NODE_COUNT]);
        linkPairs.push([i, (i + 3) % NODE_COUNT]);
    }
    const linkGeo = new THREE.BufferGeometry();
    const linkPositions = new Float32Array(linkPairs.length * 2 * 3);
    linkGeo.setAttribute('position', new THREE.BufferAttribute(linkPositions, 3));
    const linkLines = new THREE.LineSegments(linkGeo, new THREE.LineBasicMaterial({
        color: PRIMARY, transparent: true, opacity: 0.35,
    }));
    techGroup.add(linkLines);
    addSpinner(techGroup, stops[3].look, 0.1);

    // projects: drifting translucent planes
    const projectsGroup = new THREE.Group();
    [-4.5, -1.5, 1.5, 4.5].forEach((x, i) => {
        const plane = new THREE.Mesh(new THREE.PlaneGeometry(2.6, 3.4), wireMat(i % 2 ? SECONDARY : PRIMARY, 0.4));
        plane.position.set(x, 0, -i * 3);
        plane.rotation.y = 0.3;
        projectsGroup.add(plane);
    });
    addSpinner(projectsGroup, stops[4].look, 0.06);

    // experience: winding ribbon path
    const ribbonCurve = new THREE.CatmullRomCurve3([
        new THREE.Vector3(-3, -1, 6), new THREE.Vector3(0, 1, 3),
        new THREE.Vector3(3, -1, 0), new THREE.Vector3(0, 1, -3), new THREE.Vector3(-3, -1, -6),
    ]);
    const ribbon = new THREE.Mesh(new THREE.TubeGeometry(ribbonCurve, 40, 0.15, 8, false), wireMat(PRIMARY, 0.6));
    addSpinner(ribbon, stops[5].look, 0.04);

    // community: faceted globe
    addSpinner(new THREE.Mesh(new THREE.IcosahedronGeometry(3.2, 0), wireMat(SECONDARY, 0.6)), stops[6].look, 0.09);

    // contact: portal ring
    addSpinner(new THREE.Mesh(new THREE.TorusGeometry(3, 0.35, 8, 32), wireMat(PRIMARY, 0.6)), stops[7].look, 0.15);

    // faq: small floating tetrahedra
    const faqGroup = new THREE.Group();
    for (let i = 0; i < 4; i++) {
        const tet = new THREE.Mesh(new THREE.TetrahedronGeometry(0.6), wireMat(i % 2 ? SECONDARY : PRIMARY));
        tet.position.set((i - 1.5) * 1.4, Math.sin(i * 1.5) * 1, 0);
        faqGroup.add(tet);
    }
    addSpinner(faqGroup, stops[8].look, 0.1);

    // --- Scroll drives progress; render loop drives everything visual ---
    let progress = 0;
    ScrollTrigger.create({
        trigger: document.body,
        start: 'top top',
        end: 'bottom bottom',
        scrub: 0.8,
        onUpdate: (self) => { progress = self.progress; },
    });

    const mouse = { x: 0, y: 0 };
    window.addEventListener('pointermove', (e) => {
        mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
        mouse.y = (e.clientY / window.innerHeight) * 2 - 1;
    });

    const camPos = new THREE.Vector3();
    const lookPos = new THREE.Vector3();
    let parallaxX = 0, parallaxY = 0;
    let running = true;
    const clock = new THREE.Clock();

    function render() {
        if (!running) return;
        requestAnimationFrame(render);

        const t = THREE.MathUtils.clamp(progress, 0, 1);
        positionCurve.getPointAt(t, camPos);
        lookCurve.getPointAt(t, lookPos);

        parallaxX += (mouse.x * 0.7 - parallaxX) * 0.04;
        parallaxY += (-mouse.y * 0.4 - parallaxY) * 0.04;

        camera.position.set(camPos.x + parallaxX, camPos.y + parallaxY, camPos.z);
        camera.lookAt(lookPos);

        const delta = clock.getDelta();
        spinners.forEach(({ mesh, speed }) => { mesh.rotation.y += speed * delta; });
        orbitNodes.forEach((node, i) => {
            node.userData.angle += delta * 0.3;
            node.position.set(Math.cos(node.userData.angle) * 3.2, Math.sin(i * 0.6) * 0.6, Math.sin(node.userData.angle) * 3.2);
        });
        const linkPos = linkGeo.attributes.position.array;
        linkPairs.forEach(([a, b], i) => {
            const pa = orbitNodes[a].position, pb = orbitNodes[b].position;
            linkPos.set([pa.x, pa.y, pa.z, pb.x, pb.y, pb.z], i * 6);
        });
        linkGeo.attributes.position.needsUpdate = true;
        aboutSphere.scale.setScalar(1 + Math.sin(clock.elapsedTime * 0.8) * 0.05);

        composer.render();
    }
    render();

    document.addEventListener('visibilitychange', () => {
        running = !document.hidden;
        if (running) render();
    });

    window.addEventListener('resize', () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
        composer.setSize(window.innerWidth, window.innerHeight);
        bloomPass.setSize(window.innerWidth, window.innerHeight);
    });
}
