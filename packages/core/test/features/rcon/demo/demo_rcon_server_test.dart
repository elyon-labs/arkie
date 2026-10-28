import 'package:arkie_core/features/rcon/demo/demo_rcon_server.dart';
import 'package:arkie_core/features/rcon/domain/models/cs2_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoRCONServer', () {
    DemoRCONServer buildSubject() {
      return DemoRCONServer(address: '203.0.113.10', port: 27015);
    }

    test('echoes back what it is given, which is how a connection is tested', () {
      expect(buildSubject().execute('echo ping'), 'ping');
    });

    test('reports its own address in status', () {
      final subject = DemoRCONServer(address: '198.51.100.9', port: 27020);

      expect(subject.execute('status'), contains('public 198.51.100.9:27020'));
    });

    test('agrees with itself about who is connected', () {
      final subject = buildSubject();

      final status = subject.execute('status');
      final statusJson = subject.execute('status_json');

      expect(status, contains('players : 2 humans, 3 bots (10 max)'));
      expect(statusJson, contains('"clients_human": 2'));
      expect(statusJson, contains('"clients_bot": 3'));
      expect(statusJson, contains('"name": "tempo"'));
    });

    test('lists the stock maps', () {
      final body = buildSubject().execute('maps *');

      for (final map in KnownMap.directory) {
        expect(body, contains(map.name));
      }
    });

    group('kick', () {
      test('removes the player from the next status', () {
        final subject = buildSubject();

        expect(subject.execute('kick tempo'), contains('Kicking "tempo"'));

        expect(subject.execute('status'), isNot(contains("'tempo'")));
        expect(subject.execute('status'), contains('players : 1 humans, 3 bots'));
        expect(subject.execute('status_json'), isNot(contains('"name": "tempo"')));
      });

      test('says so when nobody goes by that name', () {
        final subject = buildSubject();

        expect(subject.execute('kick nobody'), contains('No player named "nobody"'));
        expect(subject.execute('status'), contains('players : 2 humans, 3 bots'));
      });
    });

    group('banid', () {
      test('kicks the banned player', () {
        final subject = buildSubject();

        final response = subject.execute('banid 30 [U:1:84921044] kick');

        expect(response, contains('banned "tempo" for 30 minutes'));
        expect(subject.execute('status'), isNot(contains("'tempo'")));
      });

      test('treats a zero duration as permanent', () {
        final subject = buildSubject();

        expect(subject.execute('banid 0 [U:1:84921044] kick'), contains('permanently'));
      });
    });

    group('map', () {
      test('changes the map reported by status', () {
        final subject = buildSubject();
        expect(subject.execute('status'), contains('de_dust2 | world layer'));

        expect(subject.execute('map de_nuke'), contains('Changelevel to de_nuke'));

        expect(subject.execute('status'), contains('de_nuke | world layer'));
        expect(subject.execute('status_json'), contains('"map": "de_nuke"'));
      });

      test('refuses a map the server does not have', () {
        final subject = buildSubject();

        expect(subject.execute('map de_notamap'), contains('is not on this server'));
        expect(subject.execute('status'), contains('de_dust2 | world layer'));
      });

      test('takes a workshop map by id', () {
        final subject = buildSubject();

        expect(subject.execute('host_workshop_map 3070293560'), contains('3070293560'));
        expect(subject.execute('status_json'), contains('"map": "workshop/3070293560"'));
      });
    });

    group('convars', () {
      test('reads the current value', () {
        expect(buildSubject().execute('mp_warmuptime'), '"mp_warmuptime" = "60"\n');
      });

      test('keeps a value it was set to', () {
        final subject = buildSubject();

        expect(subject.execute('mp_warmuptime 15'), contains('changed to "15"'));

        expect(subject.execute('mp_warmuptime'), contains('"15"'));
        expect(subject.execute('find warmup'), contains('"15"'));
      });
    });

    test('answers an unrecognised command the way a real server does', () {
      expect(buildSubject().execute('sv_nonsense'), 'Unknown command "sv_nonsense"');
    });

    test('never answers with nothing, which would read as a dead connection', () {
      final subject = buildSubject();

      for (final command in [
        '',
        'status',
        'status_json',
        'maps *',
        'find mp_',
        'find zzz',
        'kick',
        'banid',
        'map',
        'host_workshop_map',
        'say hello',
        'mp_restartgame 1',
        'sv_nonsense',
      ]) {
        expect(subject.execute(command), isNotEmpty, reason: 'empty response to "$command"');
      }
    });
  });
}
