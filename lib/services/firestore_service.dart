import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/badge_model.dart';
import '../models/guide_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(AppConstants.usersCollection).doc(uid);

  Future<UserModel?> getUser(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUser(UserModel user) =>
      _userDoc(user.uid).set(user.toFirestore());

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _userDoc(uid).update(data);

  Stream<UserModel?> userStream(String uid) =>
      _userDoc(uid).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      });

  // --- Completed Challenges ---

  CollectionReference<Map<String, dynamic>> _completedChallenges(String uid) =>
      _userDoc(uid).collection(AppConstants.completedChallengesSubcollection);

  Future<void> addCompletedChallenge(
    String uid,
    CompletedChallenge completed,
  ) => _completedChallenges(
    uid,
  ).doc(completed.challengeId).set(completed.toFirestore());

  Future<List<CompletedChallenge>> getCompletedChallenges(String uid) async {
    final snapshot = await _completedChallenges(
      uid,
    ).orderBy('completedAt', descending: true).get();
    return snapshot.docs.map(CompletedChallenge.fromFirestore).toList();
  }

  Future<bool> isChallengeCompleted(String uid, String challengeId) async {
    final doc = await _completedChallenges(uid).doc(challengeId).get();
    return doc.exists;
  }

  // --- Challenges ---

  Future<List<ChallengeModel>> getChallenges({bool activeOnly = true}) async {
    Query<Map<String, dynamic>> query = _db.collection(
      AppConstants.challengesCollection,
    );
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    final snapshot = await query.orderBy('order').get();
    return snapshot.docs.map(ChallengeModel.fromFirestore).toList();
  }

  Future<ChallengeModel?> getChallenge(String id) async {
    final doc = await _db
        .collection(AppConstants.challengesCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return ChallengeModel.fromFirestore(doc);
  }

  // --- Badges ---

  Future<List<BadgeModel>> getBadges() async {
    final snapshot = await _db.collection(AppConstants.badgesCollection).get();
    return snapshot.docs.map(BadgeModel.fromFirestore).toList();
  }

  // --- Guides ---

  Future<List<GuideModel>> getGuides({
    String? category,
    String? platform,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(
      AppConstants.guidesCollection,
    );
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (platform != null) {
      query = query.where('platforms', arrayContains: platform);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(GuideModel.fromFirestore).toList();
  }

  Future<GuideModel?> getGuide(String id) async {
    final doc = await _db
        .collection(AppConstants.guidesCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return GuideModel.fromFirestore(doc);
  }

  Future<void> incrementGuideViews(String id) => _db
      .collection(AppConstants.guidesCollection)
      .doc(id)
      .update({'views': FieldValue.increment(1)});
}
