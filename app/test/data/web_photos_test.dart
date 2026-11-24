import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/drive/data_sync.dart';
import 'package:frambitacora/data/drive/drive_sync.dart';
import 'package:frambitacora/data/photo_source.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';

import '../fake_drive.dart';
import '../helpers.dart';
import 'data_sync_test.dart' show Device;

/// Foto de prueba: para la fuente de fotos solo importa el nombre del archivo.
Photo _photo(String fileName) => Photo(
  id: fileName,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  observationId: 'o',
  kind: 'detail',
  seq: 1,
  fileName: fileName,
  localPath: 'fotos/x/$fileName',
  takenAt: DateTime(2026),
  uploadStatus: uploadedToDrive,
);

void main() {
  late Directory tmp;
  late FakeDrive drive;
  late Device phone, web;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('frambitacora_web_fotos');
    drive = FakeDrive();
    phone = Device('telefono', await testDatabase(), PhotoStore('${tmp.path}/t'), MemorySyncStateStore('t'), drive);
    web = Device('web', await testDatabase(), PhotoStore('${tmp.path}/w'), MemorySyncStateStore('w'), drive);
  });

  tearDown(() async {
    await phone.db.close();
    await web.db.close();
    await tmp.delete(recursive: true);
  });

  test('una foto subida desde la web llega a Drive y el teléfono la baja', () async {
    final crop = await phone.db.select(phone.db.crops).getSingle();
    final scale = await phone.catalog.defaultScale(crop.id);
    final project = await phone.projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.varietyTrial,
      name: 'Ensayo',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final season = (await phone.projects.watchCurrentSeason(project).first)!.id;
    final unit = await phone.projects.createUnit(projectId: project, label: 'Regina');
    await phone.run();
    await web.run();

    // En la web: registro de la semana 5 y una foto sin archivo local.
    final obs = await web.sampling.ensureObservation(season, unit, 5);
    final photo = await web.sampling.addPhotoRecord(
      observationId: obs,
      kind: PhotoKind.detail,
      takenAt: DateTime(2026, 10, 6),
    );
    expect(photo.fileName, '20261006_FRB_REGINA_D1.jpg');
    expect(photo.localPath, 'fotos/$season/20261006_FRB_REGINA_D1.jpg');
    await web.sync.uploadPhotoBytes(photo, [9, 8, 7]);
    expect(drive.paths, contains('/FramBitácora/Ensayo/2026-27/Semana 05/20261006_FRB_REGINA_D1.jpg'));

    await web.run();
    final r = await phone.run();
    expect(r.downloaded, 1);
    final onPhone = await (phone.db.select(phone.db.photos)).getSingle();
    expect(onPhone.uploadStatus, uploadedToDrive);
    expect(phone.photos.file(onPhone.localPath).readAsBytesSync(), [9, 8, 7]);
  });

  test('la fuente de fotos de la web lee de Drive y recuerda las recientes', () async {
    final folder = await drive.folder('x');
    await drive.uploadBytes([1, 2, 3], name: 'a.jpg', parentId: folder, mime: 'image/jpeg');
    final source = DrivePhotoSource(drive, capacity: 1);
    expect(await source.bytes(_photo('a.jpg')), Uint8List.fromList([1, 2, 3]));
    expect(await source.bytes(_photo('no-existe.jpg')), isNull);
    source.remember(_photo('b.jpg'), Uint8List.fromList([4]));
    expect(await source.bytes(_photo('b.jpg')), [4], reason: 'recién subida: no se descarga');
  });
}
