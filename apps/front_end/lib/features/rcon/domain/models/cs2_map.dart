enum CS2MapType { defusal, hostageRescue, armsRace, other }

sealed class CS2Map {
  const CS2Map({required this.name, required this.assetName});

  final String name;
  final String assetName;

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
  const WorkshopMap({required super.name, required super.assetName, required this.workshopId});

  final String workshopId;
}
