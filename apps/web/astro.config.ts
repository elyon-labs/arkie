import { defineConfig, envField } from 'astro/config';

import { site } from './src/data/site';

export default defineConfig({
  site: site.url,
  output: 'static',
  trailingSlash: 'ignore',
  build: {
    format: 'directory',
    inlineStylesheets: 'auto',
  },
  devToolbar: {
    enabled: false,
  },
  env: {
    schema: {
      // Read while the releases are fetched at build time, purely to lift the
      // unauthenticated rate limit that CI runners share. The repository is
      // public, so a local build works without it until that limit is hit.
      GITHUB_TOKEN: envField.string({ context: 'server', access: 'secret', optional: true }),
    },
  },
});
