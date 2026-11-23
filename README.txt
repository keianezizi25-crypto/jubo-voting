JUBO - Supabase + GitHub Pages migration package

FILES
- index.html: updated JUBO site. Uses Supabase for authentication, campaign settings, and votes.
- SECURE_ADMIN_POLICIES.sql: run this in Supabase SQL Editor before deploying the site.

IMPORTANT
1. Your Supabase project URL and publishable key are configured in index.html.
   A publishable key is designed for browser use. Never put a Supabase secret/service_role key in this file.
2. The initial JUBO setup SQL was already run in your project. Run SECURE_ADMIN_POLICIES.sql once now to harden the admin policy and grants.
3. Your admin user was already inserted into public.jubo_admins. The site signs in with that user's email and password.
4. The voting system starts fresh because the website uses new v2 local browser keys and the new Supabase vote tables.
5. Image editing uses image URLs, not file uploads. Upload a picture to an image host and paste its direct HTTPS image URL into Photo URL in the dashboard. Then click Save & publish changes.
6. The public poll can be hosted on GitHub Pages. Supabase remains the backend for data and authentication.

DEPLOY ON GITHUB PAGES
1. Create a GitHub account if needed and create a new public repository named jubo-voting.
2. Upload index.html to the repository root.
3. Open repository Settings -> Pages.
4. Under Build and deployment, choose Deploy from a branch; select main and /(root), then Save.
5. Wait for GitHub Pages to publish and open the generated URL.
6. In Supabase -> Authentication -> URL Configuration, set Site URL to your GitHub Pages URL. Add the same URL to Redirect URLs if shown.
7. Open your GitHub Pages site, choose Admin, and sign in using the Supabase admin email/password you created.

TEST BEFORE SHARING
- Visit the public page and cast one test vote.
- Open /#/admin and sign in.
- Confirm the vote appears in analytics.
- Change a flavour's Photo URL to a direct HTTPS image URL and save.
- Open the public page in another browser/tab to confirm it updates.
- Test Reset Votes only when you are ready to clear the campaign.

SECURITY / LIMITATIONS
- Supabase RLS protects campaign writes and admin-only reset actions. Never expose a secret/service_role key.
- The current one-vote-per-browser mechanism uses a browser-generated UUID in local storage. It discourages repeat votes from the same browser but is not strong identity verification; a visitor can clear browser storage or use another device.
- Do not publish or share the admin credentials.
