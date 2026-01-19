---
name: astro-performance
description: Astro performance optimization and best practices
license: MIT
compatibility: opencode
metadata:
  stack: astro, javascript, web-performance
  audience: frontend-developers
---

## What I do

I provide comprehensive guidance on optimizing Astro applications for maximum performance:

- Core Web Vitals optimization
- Image optimization strategies
- Build-time vs runtime considerations
- Component hydration patterns
- Content Collections best practices
- API route optimization
- Caching strategies
- Bundle size optimization

## When to use me

Use this skill when:

- Starting a new Astro project and want optimal setup
- Need to improve Core Web Vitals scores
- Experiencing slow page loads or builds
- Optimizing images and assets
- Implementing proper caching strategies
- Reducing JavaScript bundle size
- Improving SEO and performance metrics

## Core Web Vitals Optimization

### 1. Largest Contentful Paint (LCP)

**Target: < 2.5s**

```astro
---
// Optimize images (largest impact on LCP)
import { Image } from 'astro:assets';
import hero from '../assets/hero.jpg';
---

<!-- Use Astro's Image component for automatic optimization -->
<Image 
  src={hero}
  alt="Hero image"
  width={1200}
  height={600}
  format="webp"
  quality={80}
  loading="eager"  <!-- Don't lazy load above-the-fold images -->
  fetchpriority="high"
/>

<!-- Or for remote images -->
<Image 
  src="https://example.com/image.jpg"
  alt="Remote"
  width={800}
  height={400}
  inferSize
/>
```

**Preload critical assets:**

```astro
---
// src/layouts/BaseLayout.astro
---
<html>
  <head>
    <!-- Preload critical fonts -->
    <link 
      rel="preload" 
      href="/fonts/inter-var.woff2" 
      as="font" 
      type="font/woff2" 
      crossorigin 
    />
    
    <!-- Preload hero image -->
    <link 
      rel="preload" 
      as="image" 
      href={hero.src} 
      type="image/webp"
    />
    
    <!-- DNS prefetch for external domains -->
    <link rel="dns-prefetch" href="https://api.example.com" />
    <link rel="preconnect" href="https://api.example.com" crossorigin />
  </head>
  <body>
    <slot />
  </body>
</html>
```

### 2. First Input Delay (FID) / Interaction to Next Paint (INP)

**Target: < 100ms (FID), < 200ms (INP)**

```astro
---
// Minimize JavaScript hydration
import HeavyComponent from '../components/HeavyComponent.jsx';
---

<!-- Only hydrate when component is visible -->
<HeavyComponent client:visible />

<!-- Load when browser is idle -->
<HeavyComponent client:idle />

<!-- Only hydrate on mobile -->
<HeavyComponent client:media="(max-width: 768px)" />

<!-- Don't hydrate at all if not needed (use .astro components) -->
```

### 3. Cumulative Layout Shift (CLS)

**Target: < 0.1**

```astro
---
import { Image } from 'astro:assets';
---

<!-- Always specify width and height to prevent layout shift -->
<Image 
  src={image}
  width={800}
  height={600}
  alt="Description"
/>

<!-- Reserve space for dynamic content -->
<div style="min-height: 200px;">
  <slot />
</div>

<!-- Use aspect-ratio for responsive containers -->
<style>
  .video-container {
    aspect-ratio: 16 / 9;
    width: 100%;
  }
</style>
```

## Image Optimization

### Responsive Images

```astro
---
import { Image } from 'astro:assets';
import { getImage } from 'astro:assets';
import heroImage from '../assets/hero.jpg';

// Generate multiple sizes
const sizes = [400, 800, 1200, 1600];
const images = await Promise.all(
  sizes.map(width => 
    getImage({
      src: heroImage,
      width,
      format: 'webp',
      quality: 80
    })
  )
);
---

<!-- Method 1: Using Image component with widths -->
<Image 
  src={heroImage}
  alt="Hero"
  widths={[400, 800, 1200, 1600]}
  sizes="(max-width: 640px) 400px, (max-width: 1024px) 800px, (max-width: 1280px) 1200px, 1600px"
  quality={80}
/>

<!-- Method 2: Manual picture element for more control -->
<picture>
  <source 
    type="image/webp"
    srcset={images.map((img, i) => `${img.src} ${sizes[i]}w`).join(', ')}
    sizes="(max-width: 640px) 400px, (max-width: 1024px) 800px, 1200px"
  />
  <img 
    src={images[2].src}
    alt="Hero"
    width={heroImage.width}
    height={heroImage.height}
    loading="lazy"
  />
</picture>
```

### Image Loading Strategies

```astro
---
import { Image } from 'astro:assets';
---

<!-- Above-the-fold: eager loading -->
<Image 
  src={heroImage}
  alt="Hero"
  loading="eager"
  fetchpriority="high"
/>

<!-- Below-the-fold: lazy loading (default) -->
<Image 
  src={contentImage}
  alt="Content"
  loading="lazy"
/>

<!-- Background images with proper sizing -->
<div class="hero" style={`background-image: url(${heroImage.src})`}>
  <!-- Content -->
</div>

<style>
  .hero {
    aspect-ratio: 16 / 9;
    background-size: cover;
    background-position: center;
  }
</style>
```

## Component Hydration Strategies

### Island Architecture Patterns

```astro
---
// src/pages/dashboard.astro
import StaticHeader from '../components/Header.astro';
import StaticFooter from '../components/Footer.astro';
import InteractiveChart from '../components/Chart.jsx';
import UserMenu from '../components/UserMenu.vue';
import NotificationBell from '../components/NotificationBell.svelte';
---

<!-- Static components (0 JS) -->
<StaticHeader />

<main>
  <!-- Critical interactive components: load immediately -->
  <UserMenu client:load />
  
  <!-- Non-critical: load when idle -->
  <NotificationBell client:idle />
  
  <!-- Below fold: load when visible -->
  <InteractiveChart client:visible />
  
  <!-- Mobile only -->
  <MobileNav client:media="(max-width: 768px)" />
  
  <!-- No SSR, client-only -->
  <ClientOnlyWidget client:only="react" />
</main>

<StaticFooter />
```

### Minimize Client-Side JavaScript

```astro
---
// ❌ Bad: Using React for static content
import StaticCard from '../components/Card.jsx';
---
<StaticCard client:load title="Hello" />

---
// ✅ Good: Use .astro for static content
import StaticCard from '../components/Card.astro';
---
<StaticCard title="Hello" />
```

## Content Collections Optimization

### Efficient Content Queries

```astro
---
import { getCollection, getEntry } from 'astro:content';

// ✅ Good: Filter at query time
const publishedPosts = await getCollection('blog', ({ data }) => {
  return data.draft !== true && data.pubDate < new Date();
});

// ❌ Bad: Fetch all then filter
const allPosts = await getCollection('blog');
const published = allPosts.filter(p => !p.data.draft);

// ✅ Good: Get single entry directly
const post = await getEntry('blog', 'my-post-slug');

// ❌ Bad: Filter all to find one
const allPosts = await getCollection('blog');
const post = allPosts.find(p => p.slug === 'my-post-slug');
---
```

### Optimize getStaticPaths

```astro
---
// src/pages/blog/[slug].astro
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog', ({ data }) => {
    return data.draft !== true;
  });
  
  return posts.map((post) => ({
    params: { slug: post.slug },
    props: { 
      post,
      // ❌ Bad: Pass entire content
      // content: post.body
      
      // ✅ Good: Only pass what's needed
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate
    },
  }));
}

const { post } = Astro.props;
const { Content } = await post.render();
---

<article>
  <h1>{post.data.title}</h1>
  <Content />
</article>
```

## Build Optimization

### Astro Configuration

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import compress from 'astro-compress';

export default defineConfig({
  // Production optimizations
  build: {
    inlineStylesheets: 'auto', // Inline small CSS files
    assets: '_assets', // Custom asset directory
  },
  
  // Prefetch for faster navigation
  prefetch: {
    prefetchAll: true,
    defaultStrategy: 'viewport', // or 'hover', 'load', 'tap'
  },
  
  // Compress HTML, CSS, JS
  compressHTML: true,
  
  // Enable View Transitions
  experimental: {
    viewTransitions: true,
  },
  
  // Compression plugin
  integrations: [
    compress({
      css: true,
      html: true,
      js: true,
      img: false, // Image component already optimizes
      svg: true,
    }),
  ],
  
  // Vite optimizations
  vite: {
    build: {
      minify: 'terser',
      terserOptions: {
        compress: {
          drop_console: true, // Remove console.log in production
          drop_debugger: true,
        },
      },
      cssMinify: true,
      rollupOptions: {
        output: {
          manualChunks: {
            // Split vendor chunks for better caching
            'vendor-react': ['react', 'react-dom'],
            'vendor-utils': ['lodash', 'date-fns'],
          },
        },
      },
    },
    optimizeDeps: {
      include: ['react', 'react-dom'], // Pre-bundle dependencies
    },
  },
});
```

### Code Splitting

```astro
---
// Lazy load heavy components
const HeavyComponent = () => import('../components/HeavyComponent.jsx');
---

<HeavyComponent client:visible />
```

## Caching Strategies

### Static Assets Caching

```javascript
// astro.config.mjs
export default defineConfig({
  vite: {
    build: {
      rollupOptions: {
        output: {
          // Add content hash for cache busting
          entryFileNames: 'assets/[name].[hash].js',
          chunkFileNames: 'assets/[name].[hash].js',
          assetFileNames: 'assets/[name].[hash][extname]',
        },
      },
    },
  },
});
```

### API Response Caching

```typescript
// src/pages/api/posts.json.ts
import type { APIRoute } from 'astro';

export const GET: APIRoute = async ({ request }) => {
  const posts = await fetchPosts(); // Your data fetching
  
  return new Response(JSON.stringify(posts), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      // Cache for 1 hour
      'Cache-Control': 'public, max-age=3600',
      // Revalidate in background
      'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
    },
  });
};
```

## Font Optimization

```astro
---
// src/layouts/BaseLayout.astro
---
<html>
  <head>
    <!-- Preload critical fonts -->
    <link 
      rel="preload" 
      href="/fonts/inter-var.woff2" 
      as="font" 
      type="font/woff2" 
      crossorigin 
    />
    
    <!-- Self-host fonts (don't use Google Fonts) -->
    <style>
      @font-face {
        font-family: 'Inter';
        font-style: normal;
        font-weight: 100 900;
        font-display: swap; /* or 'optional' for best performance */
        src: url('/fonts/inter-var.woff2') format('woff2');
      }
    </style>
  </head>
</html>
```

## View Transitions

```astro
---
// src/layouts/BaseLayout.astro
import { ViewTransitions } from 'astro:transitions';
---

<html>
  <head>
    <ViewTransitions />
  </head>
  <body>
    <slot />
  </body>
</html>

<!-- Opt out specific elements -->
<img src="logo.png" alt="Logo" transition:persist />

<!-- Custom transition -->
<div transition:name="hero" transition:animate="slide">
  <h1>Page Title</h1>
</div>
```

## Monitoring Performance

### Add Performance Monitoring

```astro
---
// src/components/PerformanceMonitor.astro
---

<script>
  // Core Web Vitals monitoring
  if ('PerformanceObserver' in window) {
    // LCP
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        console.log('LCP:', entry.startTime);
        // Send to analytics
      }
    }).observe({ entryTypes: ['largest-contentful-paint'] });
    
    // FID
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        console.log('FID:', entry.processingStart - entry.startTime);
      }
    }).observe({ entryTypes: ['first-input'] });
    
    // CLS
    new PerformanceObserver((list) => {
      let cls = 0;
      for (const entry of list.getEntries()) {
        if (!entry.hadRecentInput) {
          cls += entry.value;
        }
      }
      console.log('CLS:', cls);
    }).observe({ entryTypes: ['layout-shift'] });
  }
</script>
```

## Performance Checklist

- [ ] Use `Image` component for all images
- [ ] Specify width/height for all images
- [ ] Lazy load below-the-fold images
- [ ] Use `loading="eager"` for hero images
- [ ] Optimize font loading with `font-display: swap`
- [ ] Self-host fonts (avoid Google Fonts)
- [ ] Minimize JavaScript with proper hydration directives
- [ ] Use `.astro` components for static content
- [ ] Enable View Transitions for smoother navigation
- [ ] Configure proper caching headers
- [ ] Split vendor bundles
- [ ] Enable compression (gzip/brotli)
- [ ] Remove unused CSS
- [ ] Preload critical resources
- [ ] Use Content Collections for content
- [ ] Implement proper error boundaries
- [ ] Monitor Core Web Vitals
- [ ] Test on real devices and networks
- [ ] Use Lighthouse/PageSpeed Insights
- [ ] Enable prefetch for internal links

## Useful Tools

- **Lighthouse**: Performance auditing
- **PageSpeed Insights**: Real-world performance data
- **WebPageTest**: Detailed performance testing
- **Chrome DevTools**: Performance profiling
- **Astro DevTools**: Astro-specific debugging
- **Bundle analyzers**: Visualize bundle size
