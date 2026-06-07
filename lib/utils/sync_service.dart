import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:karina_app/models/flashcard.dart';
import 'db_helper.dart';

class SyncService {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  bool _isFirebaseInitialized() {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Sincroniza las lecciones desde Firestore hacia el SQLite local.
  Future<void> syncDecksAndFlashcards() async {
    if (!_isFirebaseInitialized()) {
      debugPrint("SyncService: Firebase no está inicializado. Omitiendo sincronización remota.");
      return;
    }
    
    if (!await isOnline()) {
      debugPrint("SyncService: Sin conexión a internet. Usando base de datos local offline.");
      return;
    }

    try {
      debugPrint("SyncService: Iniciando sincronización de contenidos...");
      final db = DBHelper();
      final firestore = FirebaseFirestore.instance;

      // 1. Obtener Decks desde Firestore
      final decksSnap = await firestore.collection('decks').get();
      if (decksSnap.docs.isEmpty) {
        debugPrint("SyncService: No se encontraron lecciones en Firestore.");
        return;
      }

      for (var doc in decksSnap.docs) {
        final data = doc.data();
        final int deckId = data['id'] as int? ?? int.tryParse(doc.id) ?? 0;
        final String title = data['title'] as String? ?? 'Lección';

        // Insertar o actualizar Deck en SQLite
        await db.insert('deck', {
          'id': deckId,
          'title': title,
        });

        // 2. Obtener Flashcards asociadas a este Deck
        final cardsSnap = await firestore
            .collection('flashcards')
            .where('deckId', isEqualTo: deckId)
            .get();

        for (var cardDoc in cardsSnap.docs) {
          final cardData = cardDoc.data();
          final int cardId = cardData['id'] as int? ?? int.tryParse(cardDoc.id) ?? 0;

          final flashcard = Flashcard(
            id: cardId,
            deckId: deckId,
            category: cardData['category'] as String? ?? 'General',
            spanish: cardData['spanish'] as String? ?? '',
            karina: cardData['karina'] as String? ?? '',
            audioPath: cardData['audioPath'] as String?,
            imagePath: cardData['imagePath'] as String?,
            exampleSentence: cardData['exampleSentence'] as String?,
            difficultyLevel: (cardData['difficultyLevel'] as num?)?.toInt() ?? 1,
          );

          await db.insert('flashcard', flashcard.toMap());
        }
      }
      debugPrint("SyncService: Sincronización remota finalizada con éxito.");
    } catch (e) {
      debugPrint("SyncService: Error sincronizando desde Firestore: $e");
    }
  }

  /// Sincroniza el progreso del usuario hacia Firestore.
  Future<void> syncUserProgress(String userId, int level, int xp, int lives) async {
    if (!_isFirebaseInitialized()) return;
    if (userId.isEmpty || userId == 'bypass-id' || userId.contains('bypass') || userId.contains('admin')) {
      debugPrint("SyncService: El usuario bypass no se sincroniza con Firebase.");
      return;
    }
    if (!await isOnline()) {
      debugPrint("SyncService: Guardado de progreso en la nube pendiente (sin internet).");
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).set({
        'level': level,
        'xp': xp,
        'lives': lives,
        'lastSyncedTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("SyncService: Progreso del usuario sincronizado con éxito.");
    } catch (e) {
      debugPrint("SyncService: Error sincronizando progreso del usuario: $e");
    }
  }

  /// Descarga el progreso del usuario desde Firestore si existe.
  Future<Map<String, dynamic>?> fetchUserProgress(String userId) async {
    if (!_isFirebaseInitialized() || !await isOnline()) return null;
    if (userId.isEmpty || userId.contains('bypass') || userId.contains('admin')) return null;

    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint("SyncService: Error obteniendo progreso del usuario: $e");
    }
    return null;
  }
}
