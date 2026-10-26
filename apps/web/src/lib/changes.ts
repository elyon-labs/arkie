/**
 * Which release-note lines are worth telling a reader about.
 *
 * Release bodies are written from pull request titles, and those titles are
 * conventional commits. The type at the front says who the work was for: a
 * `feat` or a `fix` changed the app someone is running, while `chore`, `docs`,
 * `refactor`, `test`, `build` and `ci` are work on the app rather than a change
 * to it, and reading about them tells a user nothing they can act on.
 *
 * So only `feat` and `fix` are advertised, and the type is stripped back off
 * for display — it is grammar for the repository, not for the page.
 */

/** The types a reader is told about. `fix` is conventional commits' bug type. */
const ADVERTISED_TYPES: ReadonlySet<string> = new Set(['feat', 'fix']);

/**
 * `type: summary`, with an optional `(scope)` and an optional `!` marking a
 * breaking change. A breaking change is still a change to the app, so it is
 * advertised like any other.
 */
const CONVENTIONAL = /^([a-z]+)(?:\(([^)]*)\))?!?:\s*(\S.*)$/;

/**
 * The line to show for a pull request title, or null when it describes work a
 * reader has no use for — including anything that is not a conventional commit
 * at all, which is how the generated "New Contributors" lines fall out.
 */
export function advertisedChange(title: string): string | null {
  const match = CONVENTIONAL.exec(title.trim());

  if (!match) {
    return null;
  }

  const [, type, , summary] = match;

  if (!ADVERTISED_TYPES.has(type)) {
    return null;
  }

  return capitalize(summary.trim());
}

/**
 * Titles are written lowercase after the type, which reads as a mistake once
 * the type is gone and the summary is the whole line.
 */
function capitalize(summary: string): string {
  return summary.charAt(0).toUpperCase() + summary.slice(1);
}
