# Vercel Redeployment Guide

## Quick Redeployment Steps

Your GitHub repository is already updated with all fixes (commits d96f367 and 5d942bd). Follow these steps to redeploy:

### Method 1: Automatic Redeployment (Recommended)

If you have GitHub integration enabled, Vercel should automatically redeploy when it detects the new commits.

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Find your PM-AJAY project
3. Click on "Deployments" tab
4. You should see a new deployment in progress with the latest commit (d96f367)
5. Wait for build to complete (typically 2-3 minutes)

### Method 2: Manual Redeployment

If automatic deployment didn't trigger:

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click on your PM-AJAY project
3. Go to the "Deployments" tab
4. Find the most recent successful deployment
5. Click the three dots menu (⋮) on the right
6. Select "Redeploy"
7. In the dialog, ensure "Use existing Build Cache" is **UNCHECKED**
8. Click "Redeploy"

### Method 3: Force New Deployment via Git

Trigger a new deployment by making a small change:

```bash
# Create an empty commit to trigger deployment
git commit --allow-empty -m "trigger: Force Vercel redeployment"
git push origin master
```

## Verify Deployment Configuration

Before redeploying, ensure your Vercel project has these settings:

### Build & Development Settings

1. Go to Project → Settings → General
2. Verify these settings:

**Framework Preset**: Other (or None)

**Build Command**:
```
flutter build web --release --web-renderer canvaskit
```

**Output Directory**:
```
build/web
```

**Install Command**: (leave default or empty)

### Environment Variables

No environment variables are required for basic deployment.

If you're using Supabase, add:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anon/public key

## Post-Deployment Verification

After deployment completes:

### 1. Check Deployment Status
- ✅ Build should show "Ready" or "Completed"
- ✅ No build errors in logs
- ✅ Deployment URL should be generated

### 2. Test the Live Site
Visit your deployment URL and verify:

- [ ] Page loads (no white screen)
- [ ] No console errors (F12 → Console tab)
- [ ] Assets load correctly (F12 → Network tab)
- [ ] Navigation works
- [ ] Claim submission dialog opens
- [ ] All features are functional

### 3. Check Browser Console
Open Developer Tools (F12) and check for:
- ❌ No CORS errors
- ❌ No "Failed to load resource" errors
- ❌ No WASM/CanvasKit errors
- ✅ No 404 errors for assets

### 4. Network Tab Verification
In Network tab (F12 → Network), verify these load successfully:
- `index.html` (200)
- `main.dart.js` (200)
- `flutter.js` (200)
- `canvaskit/canvaskit.wasm` (200)
- `assets/*` files (200)

## Troubleshooting Failed Deployment

### Build Fails

**Check Build Logs**:
1. Go to Deployments → Click on failed deployment
2. Click "Building" or "Build Logs"
3. Look for error messages

**Common issues**:
- Flutter SDK not found → Vercel should auto-install
- Build timeout → Contact Vercel support for extended timeout
- Memory error → Upgrade Vercel plan

### White Page After Deployment

If you still see a white page after redeployment:

1. **Hard Refresh**: Press Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
2. **Clear Cache**: Clear browser cache completely
3. **Check Console**: Look for specific error messages
4. **Verify vercel.json**: Ensure it matches the updated configuration
5. **Check Build Output**: Verify `build/web` directory has all files

### Assets Not Loading (404 errors)

1. Verify `outputDirectory` is set to `build/web`
2. Check that `flutter build web --release` completes successfully locally
3. Ensure `vercel.json` routes are correct
4. Try deploying from a clean build:
   ```bash
   flutter clean
   flutter build web --release
   git add build/web -f  # if needed
   git commit -m "chore: Update build artifacts"
   git push origin master
   ```

### CORS Errors

1. Verify `vercel.json` has these headers:
   ```json
   "Cross-Origin-Embedder-Policy": "credentialless"
   "Cross-Origin-Opener-Policy": "same-origin"
   ```
2. If errors persist, try `credentialless` → `require-corp`
3. Redeploy after making changes

## Getting Your Deployment URL

After successful deployment:

1. Go to Vercel Dashboard → Your Project
2. You'll see your deployment URL at the top
3. Format: `https://your-project-name.vercel.app`
4. Or custom domain if configured

## Custom Domain Setup (Optional)

To use a custom domain:

1. Go to Project Settings → Domains
2. Click "Add Domain"
3. Enter your domain name
4. Follow DNS configuration instructions
5. Wait for DNS propagation (5-30 minutes)

## Latest Changes Included

The redeployment will include:

### Commit d96f367: Documentation
- `VERCEL_WHITE_PAGE_FIX.md` - Complete troubleshooting guide

### Commit 5d942bd: Configuration Fix
- Updated `vercel.json` with:
  - Proper asset routing
  - CORS headers for WASM support
  - Caching configuration
  - Build command specification

### Commit 1844adb & 225961a: Feature Updates
- 5-step claim submission dialog
- Real-time geo-tagging
- Project/milestone selection
- Photo/video capture with GPS

## Expected Build Time

- **First build**: 3-5 minutes (Flutter SDK download)
- **Subsequent builds**: 2-3 minutes (cached SDK)

## Monitoring Deployment

You can monitor in real-time:

1. Go to Deployments tab
2. Click on "Building" deployment
3. Watch live logs as build progresses
4. See each step: Install → Build → Deploy

## Success Indicators

✅ Build status: "Ready"
✅ No errors in build logs
✅ Deployment preview works
✅ Production URL accessible
✅ All features functional

## If All Else Fails

1. **Delete and reimport project**:
   - Go to Project Settings → General
   - Scroll to "Delete Project"
   - Reimport from GitHub

2. **Contact Vercel Support**:
   - Go to [Vercel Support](https://vercel.com/support)
   - Provide project name and deployment logs
   - Reference the configuration in this guide

## Summary

Your repository is ready for deployment with all fixes applied. Simply trigger a redeployment using one of the methods above, and the white page issue should be resolved. The updated `vercel.json` configuration ensures proper asset serving, CORS headers, and routing for Flutter web.

After redeployment completes, share your deployment URL to verify everything works correctly.