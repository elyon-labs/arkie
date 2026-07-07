# macOS Deployment Tooling

The macOS deploy tooling is pinned to Ruby 3.3.6. Do not run Fastlane from a
global Homebrew Ruby install; install and invoke it through Bundler from this
directory so the locked gem versions are used.

```sh
cd apps/front_end/macos
bundle install
bundle exec fastlane <lane>
```

For isolated local installs, keep gems inside the macOS app directory:

```sh
bundle config set path vendor/bundle
bundle install
```

If your shell still resolves `bundle` from the system Ruby, activate the repo
toolchain first:

```sh
mise install
mise exec ruby@3.3.6 -- bundle install
mise exec ruby@3.3.6 -- bundle exec fastlane <lane>
```

CI or non-interactive deploy jobs can also set `FASTLANE_SKIP_UPDATE_CHECK=1`
to avoid Fastlane startup network checks.
