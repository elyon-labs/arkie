import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_maps.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_rcon_connection.dart';

void main() {
  group('WatchServerMaps', () {
    group('when known maps are present', () {
      test('they are emitted in the maps list', () async {
        final connection = FakeRCONConnection(
          onSendCommand: (command) async {
            if (command == 'maps *') {
              return Ok(RCONServerPacket.responseValue(id: 1, body: _validMapsResponse));
            } else {
              fail('Unexpected command: $command');
            }
          },
        );

        final watcher = WatchServerMaps(
          connection: connection,
          pollInterval: const Duration(milliseconds: 10),
        );

        final serverMaps = await watcher().first;

        expect(serverMaps, containsAll(KnownMap.directory));
      });
    });
  });
}

const _validMapsResponse = '''
	ar_baggage
	ar_baggage_vanity
	ar_pool_day
	ar_shoots
	ar_shoots_night
	cs_agency
	cs_italy
	cs_italy_vanity
	cs_office
	cs_office_vanity
	de_ancient
	de_ancient_night
	de_ancient_night_vanity
	de_ancient_vanity
	de_anubis
	de_anubis_vanity
	de_dust2
	de_dust2_vanity
	de_golden
	de_inferno
	de_inferno_vanity
	de_mirage
	de_mirage_vanity
	de_nuke
	de_nuke_vanity
	de_overpass
	de_overpass_vanity
	de_palacio
	de_rooftop
	de_train
	de_train_vanity
	de_vertigo
	de_vertigo_vanity
	editor/toolscene_lighting_de_dust_day
	editor/zoo/script_zoo
	editor/zoo/smartprop_zoo
	error
	graphics_settings
	lobby_mapveto
	prefabs/ar_baggage/ar_baggage_skybox
	prefabs/ar_shoots/new/ar_shoots_night_skybox
	prefabs/ar_shoots/new/ar_shoots_s2_skybox
	prefabs/ar_shoots/new/ar_shoots_skybox
	prefabs/ar_shoots/new/ar_shoots_skybox_v1
	prefabs/ar_shoots/new/ar_shoots_skybox_v2
	prefabs/cs_italy/cs_italy_skybox
	prefabs/cs_italy/cs_italy_skybox_s2
	prefabs/cs_italy_s2/cs_italy_s2_skybox
	prefabs/cs_office/cs_office_3d_skybox
	prefabs/de_ancient/de_ancient_3dskybox
	prefabs/de_ancient/de_ancient_3dskybox_v1
	prefabs/de_ancient/de_ancient_3dskybox_v2
	prefabs/de_ancient/de_ancient_3dskybox_v3
	prefabs/de_ancient/de_ancient_night_skybox
	prefabs/de_ancient/de_ancient_skybox
	prefabs/de_anubis/de_anubis_skybox
	prefabs/de_dust2/de_dust2_skybox
	prefabs/de_inferno/3d_skybox
	prefabs/de_inferno/3d_skybox_s2
	prefabs/de_inferno/de_inferno_skybox
	prefabs/de_inferno/inferno_backdrop
	prefabs/de_inferno/inferno_skybox
	prefabs/de_inferno/s2_3d_skybox
	prefabs/de_mirage/3dskybox_mirage
	prefabs/de_mirage/3dskybox_mirage_legacy
	prefabs/de_nuke/de_nuke_skybox02
	prefabs/de_train/3dskybox
	prefabs/de_train/de_train_skybox
	prefabs/de_train/hrts2_3d_skybox
	prefabs/de_vertigo/de_vertigo_skybox
	prefabs/de_vertigo/skybox2
	prefabs/misc/counterterrorist_team_intro
	prefabs/misc/counterterrorist_team_intro_variant2
	prefabs/misc/counterterrorist_wingman_intro
	prefabs/misc/end_of_match
	prefabs/misc/team_select
	prefabs/misc/terrorist_team_intro
	prefabs/misc/terrorist_team_intro_variant2
	prefabs/misc/terrorist_wingman_intro
	prefabs/overpass/overpass_3d_skybox
	templates/env_particle_glow_template
	templates/env_sun_entity_template
	ui/acknowledge_item
	ui/buy_menu
	ui/csgo_ui_particle_scene_panel_empty
	ui/dev/pet_editor
	ui/icon_generation_basic
	ui/icon_generation_basic_dust2_bombsitea
	ui/icon_generation_basic_dust2_uppertunnel
	ui/icon_generation_basic_nuke_bombsitea
	ui/icon_generation_basic_test_using_prefab
	ui/icon_generation_empty
	ui/icon_generation_nuke
	ui/inspect_agents
	ui/inspect_case
	ui/inspect_displayitem
	ui/inspect_gloves
	ui/inspect_item
	ui/inspect_laptop
	ui/inspect_melee
	ui/inspect_musickit
	ui/inspect_spray
	ui/inspect_weapons
	ui/major_medal
	ui/major_souvenir_cases
	ui/major_souvenir_cases_major_23
	ui/major_souvenir_cases_major_24
	ui/major_souvenir_cases_major_25
	ui/match_mvp
	ui/match_mvp_basic
	ui/match_mvp_bombdefuse
	ui/match_mvp_bombplant
	ui/match_mvp_burndamage
	ui/match_mvp_np
	ui/nametag
	ui/season_medal
	ui/xpshop_case
	ui/xpshop_item
	warehouse_vanity
	workshop_preview_ancient
	workshop_preview_dust2
	workshop_preview_inferno
''';
