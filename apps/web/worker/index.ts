/**
 * Sends `www` to the canonical host, and serves the built site for everything
 * else.
 *
 * The site is still a static assets upload; this exists only because a
 * hostname redirect is the one thing the asset server cannot do on its own.
 * `run_worker_first` is what makes that true — without it the asset server
 * answers first and a www request is served rather than redirected.
 */

// Structural rather than `Fetcher` from @cloudflare/workers-types: one method
// is the whole of what this uses, and it saves the dependency.
interface Env {
  ASSETS: { fetch(request: Request): Promise<Response> };
}

export default {
  fetch(request: Request, env: Env): Response | Promise<Response> {
    const url = new URL(request.url);

    if (url.hostname.startsWith('www.')) {
      url.hostname = url.hostname.slice('www.'.length);

      // 301 rather than 302: the canonical host is not going to change back,
      // and the <link rel="canonical"> tags already point at it.
      return Response.redirect(url.toString(), 301);
    }

    return env.ASSETS.fetch(request);
  },
};
