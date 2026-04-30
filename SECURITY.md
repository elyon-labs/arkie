# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities through GitHub private vulnerability reporting if it is enabled for the repository. If it is not enabled, open a GitHub issue with a minimal description and ask for a private contact path before sharing exploit details.

Do not include real RCON passwords, private server addresses, tokens, certificates, provisioning profiles, or other secrets in public issues, pull requests, logs, or screenshots.

## Supported code

Security fixes are accepted for the current `main` branch. Binary release signing and distribution are handled outside this public repository.

## Scope

In scope:

- RCON protocol parsing and authentication behavior.
- Local storage behavior for saved server connections.
- Desktop UI behavior that could disclose saved server credentials.
- CI configuration in this public repository.

Out of scope:

- Counter-Strike 2 server configuration.
- Third-party infrastructure, package registries, and platform stores.
- Private release automation and signing infrastructure that is not part of this repository.
