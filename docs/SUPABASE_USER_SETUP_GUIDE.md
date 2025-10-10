# Supabase User Setup Guide

## Checking Existing Users

1. **Go to Supabase Dashboard**
   - Open: https://supabase.com/dashboard
   - Select your project: zkixtbwolqbafehlouyg

2. **Navigate to Authentication**
   - Click "Authentication" in the left sidebar
   - Click "Users" tab
   - You'll see a list of all registered users

## Option A: Add Role to Existing User

If you see existing users in the list:

1. **Click on the user** you want to configure
2. **Find "User Metadata" section**
3. **Click "Edit" or "Add Metadata"**
4. **Add the following JSON**:
   ```json
   {
     "role": "centre",
     "full_name": "Your Name",
     "phone": "Your Phone"
   }
   ```
5. **Choose a role value** from:
   - `"centre"` - Centre Dashboard
   - `"state"` - State Dashboard  
   - `"agency"` - Agency Dashboard
   - `"overwatch"` - Overwatch Dashboard
   - `"public"` - Public Dashboard

6. **Click "Save"**

## Option B: Create New Test User

If you don't have any users or want a fresh test user:

### Method 1: Using Register Page (Recommended)
1. **Go to your app**: http://localhost:8080
2. **Click "Register"** on login page
3. **Fill in the form**:
   - Full Name: Test User
   - Email: test@example.com
   - Phone: 1234567890
   - Role: Choose from dropdown (Agency User, State Officer, or Public)
   - Password: testpass123 (minimum 6 characters)
   - Confirm Password: testpass123
4. **Click "Register"**
5. **Check Supabase dashboard** to verify user was created with proper metadata

### Method 2: Using Supabase Dashboard
1. **Go to Authentication > Users**
2. **Click "Add User"**
3. **Enter Email**: test@example.com
4. **Enter Password**: testpass123
5. **Auto Confirm User**: Toggle ON (important!)
6. **User Metadata**: Add this JSON:
   ```json
   {
     "role": "centre",
     "full_name": "Test User",
     "phone": "1234567890"
   }
   ```
7. **Click "Create User"**

## Testing Login

After setting up a user with role metadata:

1. **Go to**: http://localhost:8080
2. **Enter credentials**:
   - Email: (the email you set up)
   - Password: (the password you set up)
3. **Click "Sign In"**
4. **Expected behavior**: You should be redirected to the appropriate dashboard based on your role

## Troubleshooting

### Error: "User role not found. Please contact administrator"
**Cause**: User exists but has no role in metadata  
**Solution**: Follow "Option A" above to add role metadata

### Error: "Invalid user role: null"
**Cause**: Same as above - missing role metadata  
**Solution**: Add role metadata using Supabase dashboard

### Error: "Invalid email or password"
**Cause**: Wrong credentials or user doesn't exist  
**Solution**: 
- Check email spelling
- Try resetting password in Supabase dashboard
- Create new test user

### Stuck on splash screen
**Cause**: Old session with invalid user data  
**Solution**:
1. Open browser DevTools (F12)
2. Go to Application > Local Storage
3. Clear all Supabase-related entries
4. Refresh page

### Can't register new user
**Cause**: Email already exists  
**Solution**:
- Use a different email
- Or delete existing user from Supabase dashboard and try again

## Quick Test Credentials

For testing, you can create these users with different roles:

**Centre Admin**:
- Email: centre@test.com
- Password: centre123
- Metadata: `{"role": "centre", "full_name": "Centre Admin", "phone": "1111111111"}`

**State Officer**:
- Email: state@test.com
- Password: state123
- Metadata: `{"role": "state", "full_name": "State Officer", "phone": "2222222222"}`

**Agency User**:
- Email: agency@test.com
- Password: agency123
- Metadata: `{"role": "agency", "full_name": "Agency User", "phone": "3333333333"}`

**Overwatch**:
- Email: overwatch@test.com
- Password: overwatch123
- Metadata: `{"role": "overwatch", "full_name": "Overwatch Officer", "phone": "4444444444"}`

**Public User**:
- Email: public@test.com
- Password: public123
- Metadata: `{"role": "public", "full_name": "Public User", "phone": "5555555555"}`

## Important Notes

1. **Auto Confirm Users**: Make sure "Auto Confirm User" is enabled in Supabase dashboard when creating users manually, otherwise they won't be able to log in immediately

2. **Role Values**: Must be exactly one of: `centre`, `state`, `agency`, `overwatch`, `public` (lowercase, no spaces)

3. **Metadata Format**: Must be valid JSON with double quotes

4. **Email Verification**: For testing, disable email confirmation in Supabase:
   - Go to Authentication > Settings
   - Under "User Signups" section
   - Disable "Enable email confirmations"

5. **Password Policy**: Minimum 6 characters (can be changed in Supabase Auth settings)