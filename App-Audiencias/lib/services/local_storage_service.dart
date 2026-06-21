import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/audiencia.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite no esta disponible en navegador. Ejecuta la app en Android, iOS o Windows.',
      );
    }

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasesPath = await databaseFactory.getDatabasesPath();
    final path = join(databasesPath, 'audiencias.db');

    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE audiencias(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nurej TEXT NOT NULL,
            demandante TEXT NOT NULL,
            demandado TEXT NOT NULL,
            fecha_hora TEXT NOT NULL,
            tipo_proceso TEXT NOT NULL,
            tipo_audiencia TEXT NOT NULL,
            sala TEXT NOT NULL,
            juez TEXT NOT NULL,
            estado TEXT NOT NULL,
            observaciones TEXT NOT NULL,
            motivo_suspension TEXT,
            historial TEXT NOT NULL
          )
        ''');
        },
        onOpen: (db) async {
          final count =
              Sqflite.firstIntValue(
                await db.rawQuery('SELECT COUNT(*) FROM audiencias'),
              ) ??
              0;
          if (count == 0) {
            await _seedData(db);
          }
        },
      ),
    );
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();
    final samples = <Audiencia>[
      Audiencia(
        nurej: '123456789',
        demandante: 'Maria Lopez',
        demandado: 'Carlos Lopez',
        fechaHora: DateTime(now.year, now.month, now.day, 9, 0),
        tipoProceso: 'Divorcio',
        tipoAudiencia: 'Conciliacion',
        sala: 'Sala 1',
        juez: 'Dra. Jimenez',
        estado: 'Programada',
        observaciones: 'Expediente prioritario',
        historial: ['Registro inicial del expediente'],
      ),
      Audiencia(
        nurej: '456789123',
        demandante: 'Ana Flores',
        demandado: 'Luis Flores',
        fechaHora: DateTime(now.year, now.month, now.day, 10, 30),
        tipoProceso: 'Asistencia Familiar',
        tipoAudiencia: 'Ratificacion',
        sala: 'Sala 2',
        juez: 'Dr. Perez',
        estado: 'Programada',
        observaciones: 'Pendiente verificar notificacion',
        historial: ['Registro inicial del expediente'],
      ),
      Audiencia(
        nurej: '852147963',
        demandante: 'Rocio Vargas',
        demandado: 'Jorge Rojas',
        fechaHora: now.subtract(const Duration(days: 1)),
        tipoProceso: 'Guarda',
        tipoAudiencia: 'Evaluacion',
        sala: 'Sala 3',
        juez: 'Dra. Salazar',
        estado: 'Concluida',
        observaciones: 'Sin observaciones',
        historial: ['Registro inicial', 'Audiencia concluida'],
      ),
      Audiencia(
        nurej: '741258963',
        demandante: 'Elena Diaz',
        demandado: 'Mario Diaz',
        fechaHora: now.add(const Duration(days: 3)),
        tipoProceso: 'Regimen de Visitas',
        tipoAudiencia: 'Seguimiento',
        sala: 'Sala 1',
        juez: 'Dr. Quiroga',
        estado: 'Suspendida',
        observaciones: 'Reprogramar cuando corresponda',
        motivoSuspension: 'Falta de notificacion',
        historial: ['Registro inicial', 'Suspendida por falta de notificacion'],
      ),
    ];

    for (final audiencia in samples) {
      await db.insert('audiencias', audiencia.toMap());
    }
  }

  Future<List<Audiencia>> getAudiencias() async {
    final db = await database;
    final items = await db.query('audiencias', orderBy: 'fecha_hora ASC');
    return items.map(Audiencia.fromMap).toList();
  }

  Future<int> insertAudiencia(Audiencia audiencia) async {
    final db = await database;
    return db.insert('audiencias', audiencia.toMap());
  }

  Future<int> updateAudiencia(Audiencia audiencia) async {
    final db = await database;
    return db.update(
      'audiencias',
      audiencia.toMap(),
      where: 'id = ?',
      whereArgs: [audiencia.id],
    );
  }

  Future<int> deleteAudiencia(int id) async {
    final db = await database;
    return db.delete('audiencias', where: 'id = ?', whereArgs: [id]);
  }
}
