# SDIdelay Plus — failsafe

This repository is the "dead man's switch" for SDIdelay Plus licences (STVN AudioVisual).

- The licence server updates `alive.json` once a day.
- Every day, GitHub checks it (`.github/workflows/failsafe.yml`). If it is 45 days old, the signed unlock file is
  published as `unlock.lic`, and every SDIdelay Plus with a permanent licence becomes Broadcast, for good,
  without the licence server.
- Customers can't trigger it, and the unlock can't be faked: the app only accepts it with STVN's signature,
  and only from this repository.

## Set-up (once)
1. **Create the repository** on github.com: New repository → name `sdidelay-failsafe` → **Public** (the apps read
   `unlock.lic` without logging in) → Create. Upload the files of this folder **including the hidden `.github`
   folder** (Add file → Upload files; or drag the whole folder in). On a Mac, Finder hides `.github`: press
   ⌘⇧. (Command-Shift-period) to see it.
2. **Token for the licence server**: github.com → your picture → Settings → Developer settings → Personal access
   tokens → **Fine-grained tokens** → Generate new token. Repository access: **Only select repositories** →
   `sdidelay-failsafe`. Permissions → Repository permissions → **Contents: Read and write**. Expiration: the
   longest possible (the licence server e-mails you 30 days before it ends).
3. **compose.yaml** of the licence server (then rebuild the container):
   ```
   FAILSAFE_REPO: "<your GitHub user name>/sdidelay-failsafe"
   FAILSAFE_TOKEN: "github_pat_…"
   ```
   Within a minute `alive.json` appears in the repository, and the admin page shows "last still alive".
4. **The unlock file**: admin page → Failsafe → **Download unlock file**. In the repository: Settings → Secrets and
   variables → Actions → New repository secret → Name `FAILSAFE_UNLOCK`, Secret = the whole contents of the file
   (open it with TextEdit, copy everything). Then delete the downloaded file from your Mac.
5. **Test**: repository → Actions → SDIdelay failsafe → Run workflow (leave "no") → it should end with "OK".
6. **The app**: `bash set-licence-key.sh <licence server address>` again before building, so the app knows this
   repository's address (it reads it from the server).

## Good to know
- From day 30 without a heartbeat the daily run fails on purpose: GitHub e-mails you "Run failed" — a warning
  15 days before the unlock.
- NAS down but you are fine: restore the server within 45 days, or open `alive.json` here and edit the numbers
  ("unix": the current time in seconds, e.g. from https://www.unixtimestamp.com) to push the date out.
- Emergency, by hand: Actions → SDIdelay failsafe → Run workflow → type `YES`.
- Once `unlock.lic` is published, the apps that have seen it stay Broadcast even if you delete it again.
- GitHub turns off scheduled workflows in a repository with no activity for 60 days; the server's daily update
  is that activity, and 45 days stays inside it.
