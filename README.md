# Awali Home Spare Parts — website

A complete storefront for spare parts (washing machines, refrigerators, air
conditioners, vacuum cleaners, ovens) plus a maintenance department. Customers
browse or scan a QR code, then order on **WhatsApp**. Prices in **US dollars ($)**.

You get the site in **two forms** — use whichever suits you:

| File / folder | What it is | Best for |
|---|---|---|
| **`index.html`** | The whole site in one file | Preview on your phone, drag-and-drop hosting |
| **`separate-files/`** | The same site split into separate HTML / CSS / JS | Editing one page or style at a time |
| **`supabase-setup.sql`** | The database setup script | Run once when connecting the database |

Both forms behave identically. The single `index.html` is the easy one to host.

---

## 1. Try it right now (no setup)

Open `index.html` on your phone or computer — it works immediately. Until you
connect the database (next section), everything is saved **only in that one
browser**: accounts, products and carts don't move between devices, and it isn't
secure for real customers. That's fine for trying things out.

---

## 2. Connect the database (for real, shared accounts)

Real accounts, a shared product catalogue and saved carts need a small backend.
We use **Supabase** — a free hosted database with a proper, secure login system
(passwords are stored safely on its servers, never in the page).

**You do these steps once (I can't do them for you — they need your account):**

1. **Create a project** at [supabase.com](https://supabase.com) → *New project*.
   Choose a name and a database password, and wait a minute for it to start.
2. **Run the setup script.** In your project: **SQL Editor → New query**, open
   `supabase-setup.sql`, paste the whole file, and press **Run**. This creates the
   tables, the security rules, and (optionally) the 8 demo products.
3. **Paste your keys into the site.** In Supabase: **Project Settings → API**, copy
   the **Project URL** and the **anon public** key, then:
   - **Single file:** open `index.html`, and near the top find the
     `window.AWALI_CONFIG = { … }` block. Put the URL and key between the quotes.
   - **Separate files:** open `config.js` and do the same there.
4. **Make yourself the owner.** Open the site → the **person icon** → **Sign up**
   with the email you want to own the shop (e.g. `owner@awalispareparts.com`).
   Then back in Supabase **SQL Editor**, run (edit the email to match):

   ```sql
   update public.profiles set role = 'owner' where email = 'owner@awalispareparts.com';
   ```

   Log out and back in — you'll now see the full management panel.
5. **Recommended:** in Supabase **Authentication → Providers → Email**, turn **off**
   *"Confirm email"* so customer sign-ups log in straight away.

That's it — the site now stores everything in the database and works across all
devices. If the keys are left blank, it quietly falls back to single-browser mode.

> I can't reach your Supabase project from here to test the live connection, so
> once you've set it up let's confirm together that sign-up, login and saving
> products all work.

---

## 3. Accounts

- **One person icon** in the header for everyone.
- **You (owner)** log in with your owner email and unlock management:
  **Products, Add / edit, Featured banner, Categories, Customers, Settings, Backup.**
- **Customers** sign up with name / email / password; their **cart is saved to
  their account** and follows them between devices.
- **Guests** can browse and order on WhatsApp without an account; if they sign in
  later, their guest cart merges into their account.

Change your owner email, password and shop details anytime in **Settings**.

---

## 4. Contact numbers

The shop uses a **list of WhatsApp / phone numbers** (not just one). It ships with:

- `+961 3 470 410`
- `+961 70 310 213`
- `+961 76 470 410`

When a customer places an order or books maintenance, they pick which number to
message. All numbers also appear in the footer (tap to call or open WhatsApp).
Edit the list in **Settings** (one number per line, with an optional label like
`Sales | +961…`).

---

## 5. Owner tools worth knowing

- **Featured banner** (Featured tab): put any product — or your own photo and
  message — at the very top of the home page.
- **Hide a category** (Categories tab): removes it from menus and filters. Its
  products still show under *All parts*, search and offers, and their QR codes
  still work.
- **Hide a single product** (eye icon in Products): unlists it, but its page still
  opens from a direct link or its QR label.
- **QR labels:** each product has its own QR code (customers scan it to open that
  product and order). **"Print all QR labels"** makes a printable sheet for the
  whole catalogue.
- **Backup:** export all products and settings to a file, and restore from it.

---

## 6. Put it online

The single `index.html` (with your keys pasted in) is all you need to host:

- **Netlify** — drag `index.html` onto [app.netlify.com/drop](https://app.netlify.com/drop).
- **Cloudflare Pages** or **GitHub Pages** — upload and deploy.
- For the **separate-files** version, upload the whole folder together (keep the
  file/folder structure).

Then point **awalispareparts.com** at your host (add the domain in the host's
dashboard and update your domain's DNS as they instruct).

---

### Notes
- Product photos are stored in the database as part of each product. Keep them
  reasonably sized so pages stay fast.
- QR codes and the QR-label sheet need an internet connection (they use a small
  online library).
