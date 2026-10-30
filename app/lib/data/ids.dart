import 'package:uuid/uuid.dart';

/// Identificadores deterministas: dos teléfonos que crean «lo mismo» (el
/// frambueso, el registro de una unidad en una semana…) generan el mismo id,
/// así al sincronizar se combinan en vez de duplicarse.
abstract final class Ids {
  static const _namespace = 'a3f1c2d4-5b6e-4f70-8a91-b2c3d4e5f607';
  static const _uuid = Uuid();

  static String _v5(String name) => _uuid.v5(_namespace, name);

  static String crop(String code) => _v5('crop:$code');
  static String scale(String cropCode, String scaleName) => _v5('scale:$cropCode:$scaleName');
  static String macro(String scaleId, String code) => _v5('macro:$scaleId:$code');
  static String stage(String scaleId, String code) => _v5('stage:$scaleId:$code');
  static String observation(String seasonId, String unitId, int week) => _v5('obs:$seasonId:$unitId:$week');
  static String weekStatus(String seasonId, int week) => _v5('week:$seasonId:$week');
  static String observationValue(String defId, String observationId) => _v5('mv:$defId:$observationId');
  static String varietyValue(String defId, String seasonId, String varietyId) => _v5('mv:$defId:$seasonId:$varietyId');
}
