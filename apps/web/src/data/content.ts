export type Feature = {
  title: string;
  body: string;
};

export const features: readonly Feature[] = [
  {
    title: 'A tab for every server',
    body: 'Save a name, address, port and password once, then keep each server open in its own tab. Cmd-T opens one, Cmd-W closes it, Ctrl-Tab moves between them.',
  },
  {
    title: 'A console you can read',
    body: 'Everything you sent and everything the server said back, in a scrolling transcript with room to breathe — not eight lines wedged into the developer console.',
  },
  {
    title: 'Completion from the server itself',
    body: 'Start typing and Arkie runs find against the server, ranks what comes back, and shows each convar beside the help text the server returned. Tab completes, Enter sends.',
  },
  {
    title: 'Keep the commands you retype',
    body: 'Save any command you have already run, give it a name that means something, and it becomes a button in that server’s sidebar.',
  },
  {
    title: 'Players, without the SteamIDs',
    body: 'The live roster with humans and bots counted separately. Kick anyone from the list, or ban them for an hour, a day, or for good.',
  },
  {
    title: 'Change the map by clicking it',
    body: 'Official maps and a vetted set of workshop maps, each with its own thumbnail. One click queues the change, with a moment to cancel before it goes.',
  },
  {
    title: 'It tells you when it drops',
    body: 'A ping every five seconds, an indicator that says when the connection was last checked, and reconnection without being asked when the server comes back.',
  },
  {
    title: 'Privacy mode',
    body: 'Masks server addresses on screen so a screenshot or a stream does not hand out where your server lives. The console itself is left alone.',
  },
  {
    title: 'Nothing leaves your machine',
    body: 'No account, no telemetry, no backend. Servers and passwords are stored locally, and the only thing Arkie connects to is the server whose address you typed.',
  },
];

export type Step = {
  title: string;
  body: string;
};

export const steps: readonly Step[] = [
  {
    title: 'Turn RCON on',
    body: 'Set rcon_password on your server and make sure its port — 27015 unless you changed it — is reachable from the machine you are sitting at.',
  },
  {
    title: 'Add the server',
    body: 'Name it, paste in the address, port and password. Arkie stores it locally and connects straight away.',
  },
  {
    title: 'Run it from the window',
    body: 'Type commands, click a map, kick a player. Arkie holds the connection open and picks it back up on its own when it drops.',
  },
];

export type Requirement = {
  label: string;
  value: string;
};

export const requirements: readonly Requirement[] = [
  {
    label: 'desktop',
    value: 'macOS, Windows, and Debian-based Linux on amd64 or arm64. One app, built from the same source for all three.',
  },
  {
    label: 'server',
    value: 'Any Counter-Strike 2 server with rcon_password set. Arkie speaks the Source RCON protocol, so nothing has to be installed on the server itself.',
  },
  {
    label: 'network',
    value: 'A route to the RCON port from the machine running Arkie. There is no relay in the middle. Source RCON is an unencrypted protocol, so across the open internet a VPN or an SSH tunnel is the safer way in.',
  },
];

export type TranscriptLine = {
  kind: 'command' | 'response' | 'status';
  text: string;
};

/**
 * An illustrative session, not a screenshot: a command typed, the server's
 * answer, and the status line the real console carries underneath it.
 */
export const exampleTranscript: readonly TranscriptLine[] = [
  { kind: 'command', text: 'status' },
  { kind: 'response', text: 'hostname : Larry’s Server' },
  { kind: 'response', text: 'map      : de_dust2' },
  { kind: 'response', text: 'players  : 8 humans, 2 bots (12/12 max)' },
  { kind: 'command', text: 'mp_restartgame 1' },
  { kind: 'response', text: 'mp_restartgame = 1' },
  { kind: 'status', text: 'Connected' },
];
