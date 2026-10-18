---
name: release
description: Prepare a log_custom_printer release - pick the semver bump, update pubspec.yaml and CHANGELOG.md, run analysis, tests and the pub publish dry run, then commit and tag. Use when the user asks to release, cut, bump or publish a new version of the package.
---

# Release log_custom_printer

Publishing to pub.dev and pushing tags are outward-facing and cannot be undone. Prepare everything
locally, show the user the result, and only publish or push after they confirm.

## 1. Decide the version

- Read the `## Unreleased` section of `CHANGELOG.md` and `git log v_<last>..HEAD --oneline`
  (tags look like `v_3.2.0`; run `git tag --sort=-v:refname | head` to find the last one).
- Choose the bump with semver:
  - **major** — removed/renamed export in `lib/log_custom_printer.dart`, changed public signature,
    changed serialized JSON format (breaks caches written by older versions);
  - **minor** — new export, new parameter with a default, new log type;
  - **patch** — fixes, docs, CI, tests only.
- If the user named a version, use it, but point out if it contradicts the changes.

## 2. Update files

- `pubspec.yaml`: set `version:`.
- `CHANGELOG.md`: rename `## Unreleased` to `## <version>`. Entries use the existing
  `- Fix:` / `- Feature:` / `- Refactor:` / `- Docs:` / `- CI:` prefixes and
  **Breaking change:** in bold for majors. If there is no `## Unreleased` section, write the entry
  from the git log.
- If the public API changed, check that `README.md` and `doc/` mention it.

## 3. Verify

```powershell
dart pub get
dart analyze
dart test
dart pub publish --dry-run
```

All four must pass. The dry run must report no warnings other than ones the user already accepts;
show its output to the user.

## 4. Commit and tag (local)

```powershell
git checkout -b release/<version>
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: release <version>"
```

Open a PR to `main`. Create the tag only after it is merged, on the merge commit:

```powershell
git tag v_<version>
```

## 5. Publish (only after explicit confirmation)

```powershell
git push origin v_<version>
dart pub publish
```

`dart pub publish` asks for confirmation and needs the maintainer's pub.dev login; let the user run
it with `! dart pub publish` if it needs interaction.
