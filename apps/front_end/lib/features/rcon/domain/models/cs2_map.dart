import 'package:collection/collection.dart';

enum CS2MapType { defusal, hostageRescue, armsRace, other }

sealed class CS2Map {
  const CS2Map({required this.name, required this.assetName});

  final String name;
  final String assetName;

  String get displayName => name;

  String get assetPath => 'assets/maps/$assetName.png';

  CS2MapType get type {
    if (name.startsWith('de_')) {
      return CS2MapType.defusal;
    } else if (name.startsWith('cs_') || name.startsWith('csgo_')) {
      return CS2MapType.hostageRescue;
    } else if (name.startsWith('ar_')) {
      return CS2MapType.armsRace;
    } else {
      return CS2MapType.other;
    }
  }
}

class KnownMap extends CS2Map {
  const KnownMap({required super.name, required super.assetName});

  static List<CS2Map> get directory {
    // Assets are sourced from https://steamcommunity.com/sharedfiles/filedetails/?id=2894805422
    return const [
      KnownMap(name: 'ar_baggage', assetName: 'ar_baggage'),
      KnownMap(name: 'ar_pool_day', assetName: 'ar_pool_day'),
      KnownMap(name: 'ar_shoots', assetName: 'ar_shoots'),
      KnownMap(name: 'ar_shoots_night', assetName: 'ar_shoots_night'),
      KnownMap(name: 'cs_italy', assetName: 'cs_italy'),
      KnownMap(name: 'cs_office', assetName: 'cs_office'),
      KnownMap(name: 'de_ancient', assetName: 'de_ancient'),
      KnownMap(name: 'de_ancient_night', assetName: 'de_ancient_night'),
      KnownMap(name: 'de_anubis', assetName: 'de_anubis'),
      KnownMap(name: 'de_cache', assetName: 'de_cache'),
      KnownMap(name: 'de_dust2', assetName: 'de_dust2'),
      KnownMap(name: 'de_golden', assetName: 'de_golden'),
      KnownMap(name: 'de_inferno', assetName: 'de_inferno'),
      KnownMap(name: 'de_mirage', assetName: 'de_mirage'),
      KnownMap(name: 'de_nuke', assetName: 'de_nuke'),
      KnownMap(name: 'de_overpass', assetName: 'de_overpass'),
      KnownMap(name: 'de_palacio', assetName: 'de_palacio'),
      KnownMap(name: 'de_rooftop', assetName: 'de_rooftop'),
      KnownMap(name: 'de_train', assetName: 'de_train'),
      KnownMap(name: 'de_vertigo', assetName: 'de_vertigo'),
    ];
  }
}

class WorkshopMap extends CS2Map {
  const WorkshopMap({
    required super.name,
    required super.assetName,
    required this.slug,
    required this.workshopId,
    required this.displayName,
  });

  final String slug;
  final String workshopId;

  @override
  final String displayName;

  @override
  String get assetPath => 'assets/maps/$assetName.webp';

  static List<WorkshopMap> get directory {
    return const [
      // HLA_WORKSHOP_MAPS_START
      // Generated from https://hla.gg/api/maps/index.
      WorkshopMap(
        name: 'awp-india',
        assetName: 'workshop_awp_india',
        slug: 'awp-india',
        workshopId: '3070290869',
        displayName: 'AWP India',
      ),
      WorkshopMap(
        name: 'abstract',
        assetName: 'workshop_abstract',
        slug: 'abstract',
        workshopId: '3079043089',
        displayName: 'Abstract',
      ),
      WorkshopMap(
        name: 'anchor',
        assetName: 'workshop_anchor',
        slug: 'anchor',
        workshopId: '3592187337',
        displayName: 'Anchor',
      ),
      WorkshopMap(
        name: 'assembly',
        assetName: 'workshop_assembly',
        slug: 'assembly',
        workshopId: '3071005299',
        displayName: 'Assembly',
      ),
      WorkshopMap(
        name: 'belts',
        assetName: 'workshop_belts',
        slug: 'belts',
        workshopId: '3665625941',
        displayName: 'Belts',
      ),
      WorkshopMap(
        name: 'blagai',
        assetName: 'workshop_blagai',
        slug: 'blagai',
        workshopId: '3284441858',
        displayName: 'Blagai',
      ),
      WorkshopMap(
        name: 'boutiques',
        assetName: 'workshop_boutiques',
        slug: 'boutiques',
        workshopId: '3450441262',
        displayName: 'Boutiques',
      ),
      WorkshopMap(
        name: 'boyard',
        assetName: 'workshop_boyard',
        slug: 'boyard',
        workshopId: '3228904725',
        displayName: 'Boyard',
      ),
      WorkshopMap(
        name: 'brewery',
        assetName: 'workshop_brewery',
        slug: 'brewery',
        workshopId: '3070290240',
        displayName: 'Brewery',
      ),
      WorkshopMap(
        name: 'brownstone',
        assetName: 'workshop_brownstone',
        slug: 'brownstone',
        workshopId: '3663976049',
        displayName: 'Brownstone',
      ),
      WorkshopMap(
        name: 'catains',
        assetName: 'workshop_catains',
        slug: 'catains',
        workshopId: '3551454297',
        displayName: 'Catains',
      ),
      WorkshopMap(
        name: 'chalice',
        assetName: 'workshop_chalice',
        slug: 'chalice',
        workshopId: '3176165615',
        displayName: 'Chalice',
      ),
      WorkshopMap(
        name: 'de-cbble-cobblestone',
        assetName: 'workshop_de_cbble_cobblestone',
        slug: 'de-cbble-cobblestone',
        workshopId: '3070293560',
        displayName: 'Cobblestone',
      ),
      WorkshopMap(
        name: 'cobblestone',
        assetName: 'workshop_cobblestone',
        slug: 'cobblestone',
        workshopId: '3645126146',
        displayName: 'Cobblestone',
      ),
      WorkshopMap(
        name: 'debris',
        assetName: 'workshop_debris',
        slug: 'debris',
        workshopId: '3539217452',
        displayName: 'Debris',
      ),
      WorkshopMap(
        name: 'dogtown',
        assetName: 'workshop_dogtown',
        slug: 'dogtown',
        workshopId: '3414036782',
        displayName: 'Dogtown',
      ),
      WorkshopMap(
        name: 'drawbridge',
        assetName: 'workshop_drawbridge',
        slug: 'drawbridge',
        workshopId: '3070192462',
        displayName: 'Drawbridge',
      ),
      WorkshopMap(
        name: 'el-dorado',
        assetName: 'workshop_el_dorado',
        slug: 'el-dorado',
        workshopId: '3408790618',
        displayName: 'El Dorado',
      ),
      WorkshopMap(
        name: 'extraction',
        assetName: 'workshop_extraction',
        slug: 'extraction',
        workshopId: '3460964702',
        displayName: 'Extraction',
      ),
      WorkshopMap(
        name: 'fontaine',
        assetName: 'workshop_fontaine',
        slug: 'fontaine',
        workshopId: '3443162558',
        displayName: 'Fontaine',
      ),
      WorkshopMap(
        name: 'foroglio',
        assetName: 'workshop_foroglio',
        slug: 'foroglio',
        workshopId: '3132854332',
        displayName: 'Foroglio',
      ),
      WorkshopMap(
        name: 'hive',
        assetName: 'workshop_hive',
        slug: 'hive',
        workshopId: '3336683348',
        displayName: 'Hive',
      ),
      WorkshopMap(
        name: 'hotel-belneva',
        assetName: 'workshop_hotel_belneva',
        slug: 'hotel-belneva',
        workshopId: '3589967903',
        displayName: 'H\u00f4tel Belneva',
      ),
      WorkshopMap(
        name: 'lake',
        assetName: 'workshop_lake',
        slug: 'lake',
        workshopId: '3219506727',
        displayName: 'Lake',
      ),
      WorkshopMap(
        name: 'lublin',
        assetName: 'workshop_lublin',
        slug: 'lublin',
        workshopId: '3507728279',
        displayName: 'Lublin',
      ),
      WorkshopMap(
        name: 'maginot',
        assetName: 'workshop_maginot',
        slug: 'maginot',
        workshopId: '3195399109',
        displayName: 'Maginot',
      ),
      WorkshopMap(
        name: 'memento',
        assetName: 'workshop_memento',
        slug: 'memento',
        workshopId: '3165559377',
        displayName: 'Memento',
      ),
      WorkshopMap(
        name: 'outback',
        assetName: 'workshop_outback',
        slug: 'outback',
        workshopId: '3681511672',
        displayName: 'Outback',
      ),
      WorkshopMap(
        name: 'palais',
        assetName: 'workshop_palais',
        slug: 'palais',
        workshopId: '3257582863',
        displayName: 'Palais',
      ),
      WorkshopMap(
        name: 'petroleum',
        assetName: 'workshop_petroleum',
        slug: 'petroleum',
        workshopId: '3435397830',
        displayName: 'Petroleum',
      ),
      WorkshopMap(
        name: 'poseidon',
        assetName: 'workshop_poseidon',
        slug: 'poseidon',
        workshopId: '3522144043',
        displayName: 'Poseidon',
      ),
      WorkshopMap(
        name: 'rainfall',
        assetName: 'workshop_rainfall',
        slug: 'rainfall',
        workshopId: '3265650949',
        displayName: 'Rainfall',
      ),
      WorkshopMap(
        name: 'ravine',
        assetName: 'workshop_ravine',
        slug: 'ravine',
        workshopId: '3121051997',
        displayName: 'Ravine',
      ),
      WorkshopMap(
        name: 'redline',
        assetName: 'workshop_redline',
        slug: 'redline',
        workshopId: '3131775712',
        displayName: 'Redline',
      ),
      WorkshopMap(
        name: 'rialto',
        assetName: 'workshop_rialto',
        slug: 'rialto',
        workshopId: '3085490518',
        displayName: 'Rialto',
      ),
      WorkshopMap(
        name: 'rooftop',
        assetName: 'workshop_rooftop',
        slug: 'rooftop',
        workshopId: '3536622725',
        displayName: 'Rooftop',
      ),
      WorkshopMap(
        name: 'sanctum',
        assetName: 'workshop_sanctum',
        slug: 'sanctum',
        workshopId: '3643331442',
        displayName: 'Sanctum',
      ),
      WorkshopMap(
        name: 'shortdust',
        assetName: 'workshop_shortdust',
        slug: 'shortdust',
        workshopId: '3070612859',
        displayName: 'Shortdust (classic)',
      ),
      WorkshopMap(
        name: 'shortdust-remade',
        assetName: 'workshop_shortdust_remade',
        slug: 'shortdust-remade',
        workshopId: '3618786679',
        displayName: 'Shortdust (remade)',
      ),
      WorkshopMap(
        name: 'splat',
        assetName: 'workshop_splat',
        slug: 'splat',
        workshopId: '3439120481',
        displayName: 'Splat',
      ),
      WorkshopMap(
        name: 'stockwell',
        assetName: 'workshop_stockwell',
        slug: 'stockwell',
        workshopId: '3613009299',
        displayName: 'Stockwell',
      ),
      WorkshopMap(
        name: 'thurlow',
        assetName: 'workshop_thurlow',
        slug: 'thurlow',
        workshopId: '3463369046',
        displayName: 'Thurlow',
      ),
      WorkshopMap(
        name: 'tile',
        assetName: 'workshop_tile',
        slug: 'tile',
        workshopId: '3315995254',
        displayName: 'Tile',
      ),
      WorkshopMap(
        name: 'transit',
        assetName: 'workshop_transit',
        slug: 'transit',
        workshopId: '3542662073',
        displayName: 'Transit',
      ),
      WorkshopMap(
        name: 'trash',
        assetName: 'workshop_trash',
        slug: 'trash',
        workshopId: '3428771893',
        displayName: 'Trash',
      ),
      WorkshopMap(
        name: 'vandal',
        assetName: 'workshop_vandal',
        slug: 'vandal',
        workshopId: '3071899764',
        displayName: 'Vandal',
      ),
      WorkshopMap(
        name: 'visitor',
        assetName: 'workshop_visitor',
        slug: 'visitor',
        workshopId: '3636261467',
        displayName: 'Visitor',
      ),
      WorkshopMap(
        name: 'whistle',
        assetName: 'workshop_whistle',
        slug: 'whistle',
        workshopId: '3308613773',
        displayName: 'Whistle',
      ),
      // HLA_WORKSHOP_MAPS_END
    ];
  }

  static WorkshopMap? findByWorkshopId(String workshopId) {
    return directory.firstWhereOrNull((map) => map.workshopId == workshopId);
  }
}
