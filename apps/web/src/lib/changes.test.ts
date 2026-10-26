import { describe, expect, it } from 'vitest';

import { advertisedChange } from './changes';

describe('advertisedChange', () => {
  it('advertises a feature, without its type', () => {
    expect(advertisedChange('feat: de_cache support')).toBe(
      'De_cache support',
    );
  });

  it('advertises a fix, which is the bug type', () => {
    expect(advertisedChange('fix: properly handle server disconnection errors in RCONSocket')).toBe(
      'Properly handle server disconnection errors in RCONSocket',
    );
  });

  it('drops a scope, which names a part of the repository rather than the change', () => {
    expect(advertisedChange('feat(front-end): native tab management')).toBe(
      'Native tab management',
    );
  });

  it('still advertises a breaking change', () => {
    expect(advertisedChange('feat(front-end)!: distribute macOS with Developer ID instead of the App Store')).toBe(
      'Distribute macOS with Developer ID instead of the App Store',
    );
  });

  it.each(['chore', 'docs', 'refactor', 'test', 'build', 'ci', 'perf', 'style'])(
    'keeps %s off the page',
    (type) => {
      expect(advertisedChange(`${type}: something internal`)).toBeNull();
    },
  );

  it('keeps a title that is not a conventional commit off the page', () => {
    expect(advertisedChange('Add CS2 server process management')).toBeNull();
  });

  it('keeps the generated new-contributor line off the page', () => {
    expect(advertisedChange('@someone made their first contribution')).toBeNull();
  });

  it('is not fooled by a colon later in the title', () => {
    expect(advertisedChange('Fix the thing: it was broken')).toBeNull();
  });

  it('ignores a type it has never heard of', () => {
    expect(advertisedChange('wip: half a thought')).toBeNull();
  });

  it('needs a summary after the type', () => {
    expect(advertisedChange('feat:')).toBeNull();
    expect(advertisedChange('feat:   ')).toBeNull();
  });

  it('leaves a summary that is already capitalised alone', () => {
    expect(advertisedChange('fix: RCON reconnects after the server restarts')).toBe(
      'RCON reconnects after the server restarts',
    );
  });
});
