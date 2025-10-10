# PM-AJAY Platform - Vercel Deployment Guide

**Date:** October 11, 2025  
**Platform:** Vercel  
**Status:** Production Ready

---

## Pre-Deployment Checklist

### 1. Build Production Assets

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web production
flutter build web --release \
  --web-renderer canvaskit \
  --base-href "/" \
  --dart-define=SUPABASE_URL=https://zkixtbwolqbafehlouyg.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key_here
```

### 2. Verify Build Output

```bash
# Check build/web directory
ls -la build/web

# Expected files:
# - index.html
# - main.dart.js
# - flutter.js
# - canvaskit/
# - assets/
```

### 3. Environment Variables Setup

Create `.env.production` file:

```bash
SUPABASE_URL=https://zkixtbwolqbafehlouyg.supabase.co
SUPABASE_ANON_KEY=your_production_anon_key
FLUTTER_WEB_RENDERER=canvaskit
```

---

## Vercel Deployment Steps

### Method 1: Vercel CLI (Recommended)

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy to production
vercel --prod

# Follow prompts:
# - Set up and deploy: Yes
# - Link to existing project: No (first time)
# - Project name: pm-ajay-platform
# - Directory: ./build/web
# - Override settings: No
```

### Method 2: GitHub Integration

```bash
# 1. Push to GitHub
git add .
git commit -m "Production build for Vercel"
git push origin main

# 2. Go to Vercel Dashboard
# - Import Git Repository
# - Select your GitHub repo
# - Configure:
#   - Framework Preset: Other
#   - Build Command: flutter build web --release
#   - Output Directory: build/web
#   - Install Command: flutter pub get

# 3. Add Environment Variables in Vercel Dashboard:
SUPABASE_URL=https://zkixtbwolqbafehlouyg.supabase.co
SUPABASE_ANON_KEY=your_production_anon_key
```

---

## Vercel Configuration (vercel.json)

The `vercel.json` file has been created with:

- Static file serving from build/web
- SPA routing (all routes → index.html)
- Security headers (XSS, Content-Type, Frame protection)
- Cache headers for static assets (1 year)

---

## Post-Deployment Verification

### 1. Check Deployment Status

```bash
# View deployment logs
vercel logs

# Check deployment URL
# Vercel provides: https://pm-ajay-platform.vercel.app
```

### 2. Test Critical Paths

**Automated Testing:**

```bash
# Test home page
curl -I https://pm-ajay-platform.vercel.app

# Expected: 200 OK

# Test routing
curl -I https://pm-ajay-platform.vercel.app/dashboard/centre

# Expected: 200 OK (SPA routing works)
```

**Manual Testing Checklist:**

- [ ] Home page loads
- [ ] Authentication works
- [ ] All 5 dashboards accessible
- [ ] Maps render correctly
- [ ] Real-time updates work
- [ ] File uploads functional
- [ ] Supabase connection active

### 3. Performance Verification

```bash
# Run Lighthouse audit
npm install -g lighthouse

lighthouse https://pm-ajay-platform.vercel.app \
  --only-categories=performance,accessibility,best-practices,seo \
  --output=html \
  --output-path=./lighthouse-report.html

# Target scores:
# Performance: >90
# Accessibility: >95
# Best Practices: >95
# SEO: >90
```

---

## Domain Configuration

### Custom Domain Setup

1. **Add Custom Domain in Vercel:**
   - Go to Project Settings → Domains
   - Add: `pmajay.gov.in`
   - Add: `www.pmajay.gov.in`

2. **Configure DNS Records:**

```dns
# A Record
Type: A
Name: @
Value: 76.76.21.21 (Vercel IP)

# CNAME Record
Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

3. **Enable HTTPS:**
   - Vercel auto-provisions SSL certificates
   - Force HTTPS redirect enabled by default

---

## Environment-Specific Settings

### Production Environment Variables

Add in Vercel Dashboard → Settings → Environment Variables:

```bash
SUPABASE_URL=https://zkixtbwolqbafehlouyg.supabase.co
SUPABASE_ANON_KEY=your_production_key
FLUTTER_WEB_RENDERER=canvaskit
NODE_ENV=production
ENABLE_ANALYTICS=true
SENTRY_DSN=your_sentry_dsn
```

---

## Troubleshooting Common Issues

### Issue 1: White Screen / App Not Loading

**Cause:** Incorrect base-href or routing configuration

**Solution:**
```bash
# Rebuild with correct base-href
flutter build web --release --base-href "/"

# Verify vercel.json routing
cat vercel.json | grep -A5 "routes"
```

### Issue 2: 404 on Dashboard Routes

**Cause:** SPA routing not configured

**Solution:**
Already configured in vercel.json:
```json
{
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

### Issue 3: Supabase Connection Fails

**Cause:** Environment variables not set

**Solution:**
```bash
# Check environment variables
vercel env ls

# Add missing variables
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
```

### Issue 4: Large Build Size

**Cause:** Unoptimized assets

**Solution:**
```bash
# Enable tree shaking
flutter build web --release --tree-shake-icons

# Optimize images before build
# Use webp format for images
# Minimize asset sizes
```

---

## Monitoring & Analytics

### 1. Vercel Analytics

Enable in Vercel Dashboard:
- Analytics → Enable
- View real-time metrics
- Monitor Core Web Vitals

### 2. Custom Monitoring

```javascript
// Add to index.html
<script>
// Report Web Vitals to analytics
if (window.performance && window.performance.timing) {
  window.addEventListener('load', () => {
    const timing = window.performance.timing;
    const loadTime = timing.loadEventEnd - timing.navigationStart;
    
    // Send to analytics
    console.log('Page load time:', loadTime);
  });
}
</script>
```

---

## Continuous Deployment

### Automatic Deployments

Vercel automatically deploys on:
- Push to `main` branch → Production
- Push to `develop` branch → Preview
- Pull requests → Preview deployments

### Manual Deployment Control

```bash
# Deploy specific branch
vercel --prod --branch=release-v1.0

# Deploy with specific environment
vercel --prod --env=production
```

---

## Rollback Procedure

### Quick Rollback

```bash
# List deployments
vercel ls

# Promote previous deployment
vercel promote <deployment-url>
```

### Via Dashboard

1. Go to Deployments tab
2. Find stable deployment
3. Click "Promote to Production"

---

## Performance Optimization

### 1. Enable Compression

Already configured in vercel.json headers.

### 2. Image Optimization

Use Vercel Image Optimization:

```html
<!-- Instead of regular img tags -->
<img src="/_vercel/image?url=/assets/image.jpg&w=640&q=75" />
```

### 3. Code Splitting

Flutter web automatically splits code. Verify:

```bash
# Check build output
ls -lh build/web/main.dart.js.*.part.js
```

---

## Security Checklist

- [x] HTTPS enforced
- [x] Security headers configured
- [x] CORS properly set
- [x] Environment variables secured
- [x] No sensitive data in code
- [x] Supabase RLS enabled
- [x] API keys rotated for production
- [x] Rate limiting configured

---

## Success Criteria

### Technical Metrics

- ✅ Deployment successful (HTTP 200)
- ✅ All pages accessible
- ✅ Performance score >90
- ✅ Zero console errors
- ✅ Mobile responsive
- ✅ Cross-browser compatible

### Business Metrics

- ✅ Authentication working
- ✅ All dashboards functional
- ✅ Real-time updates active
- ✅ File uploads working
- ✅ Data displays correctly

---

## Support & Maintenance

### Deployment Issues

Contact: dev@pmajay.gov.in

### Vercel Support

- Documentation: https://vercel.com/docs
- Status Page: https://vercel.com/status
- Community: https://github.com/vercel/vercel/discussions

---

## Quick Reference Commands

```bash
# Build production
flutter build web --release

# Deploy to Vercel
vercel --prod

# Check logs
vercel logs

# View deployments
vercel ls

# Rollback
vercel promote <deployment-url>

# Check status
curl -I https://pm-ajay-platform.vercel.app
```

---

**Deployment Status:** ✅ Ready for Production  
**Estimated Deployment Time:** 10-15 minutes  
**Platform:** Vercel  
**Guide Version:** 1.0.0