# webapp-testing (vendored)

Third-party skill copied into this repo so its content is fixed, reviewable, and versioned with the rest of the agent system. Claude loads `SKILL.md`; this README is for humans. Do not edit the vendored files. Replace them as a whole after re-vetting.

## Provenance

| | |
|---|---|
| Source | https://github.com/anthropics/skills, folder `skills/webapp-testing` (official Anthropic repository) |
| Pinned commit | `2c5958ecac7cee2b583967a2c4981d0f4a75c579` (2026-11-06) |
| Copied | 2026-11-11 |
| License | See `LICENSE.txt` (kept unchanged) |
| Files | `SKILL.md`, `scripts/with_server.py`, `examples/*.py`, `LICENSE.txt` |

## Vetting done before adding it

- Read `SKILL.md` and `scripts/with_server.py` in full, and scanned all files for downloads (`curl`, `wget`), obfuscation (`base64`, `eval`), `!` shell-command syntax in the skill text, `sudo`, `rm -rf`, and installs. None found.
- `with_server.py` starts the server commands it is given with `shell=True`, waits for the port, runs a command, then stops the servers. It does what it says and nothing else, but it runs whatever command string it receives, so a call to it is not covered by the allowlist and will ask for approval.
- Nothing was executed during vetting.

## Used by

The QA role, when an acceptance criterion needs real browser behavior (see `.claude/agents/qa.md` and `shared/roles.md`).

## Prerequisite that is not met yet

The skill writes Playwright scripts in Python. The Python package is not installed on this machine (`python3 -c "import playwright"` fails). Installing it is a dependency install, which needs Simon's approval, so agents must not do it. Until Simon installs it (`pip install playwright`, plus the browsers), QA marks the criterion `not_verified` and says why.

## Updating

Through the `[META]` maintainer, with Simon's approval for installing or updating a third-party skill: fetch the new version at a specific commit, repeat the vetting above, replace the folder, and update the commit and date in this table.
