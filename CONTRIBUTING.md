# Contributing

Thanks for helping improve CS2 RCON. This repository is the public source tree, so keep changes source-focused and avoid committing private server details, credentials, signing assets, or release automation secrets.

## Local setup

1. Install Flutter 3.35.7 or newer with Dart 3.8.1 or newer.
2. Install Melos:

```bash
dart pub global activate melos
```

3. Bootstrap the workspace from the repository root:

```bash
melos bootstrap
```

## Development workflow

- Run commands through Melos so every package uses the same workflow.
- Use `melos run codegen` after editing generated front-end models.
- Keep pull requests focused on one behavior change or cleanup.
- Add or update tests for user-visible behavior, protocol parsing, persistence, and error handling changes.
- Do not include real RCON passwords, private server addresses, local paths, signing files, provisioning profiles, certificates, or tokens in commits, issues, logs, or screenshots.

## Checks

Before opening a pull request, run the same checks used by CI:

```bash
melos run format:flutter:ci
melos run format:dart:ci
melos run analyze:flutter:ci
melos run analyze:dart:ci
melos run test:flutter:ci
melos run test:dart:ci
```

## Releases

Release signing, App Store deployment, release tags, and binary asset publishing are intentionally handled outside this public repository. Public pull requests should not add signing credentials, release credentials, or workflows that require repository secrets.
