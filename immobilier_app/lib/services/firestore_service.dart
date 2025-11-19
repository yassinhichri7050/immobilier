import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection refs
  CollectionReference get propertiesRef => _db.collection('properties');
  CollectionReference get usersRef => _db.collection('users');
  CollectionReference get chatsRef => _db.collection('chats');

  // Properties
  Future<DocumentReference> addProperty(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    return await propertiesRef.add(data);
  }

  Future<void> updateProperty(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await propertiesRef.doc(id).update(data);
  }

  Future<void> deleteProperty(String id) async {
    await propertiesRef.doc(id).delete();
  }

  Stream<QuerySnapshot> streamProperties() {
    return propertiesRef.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamPropertiesRecent({int limit = 10}) {
    return propertiesRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> streamPropertiesFeatured() {
    return propertiesRef
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamPropertiesByUser(String userId) {
    return propertiesRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamPropertiesFiltered({
    String? keyword,
    String? type,
    double? minPrice,
    double? maxPrice,
    double? minSurface,
  }) {
    Query query = propertiesRef;

    if (type != null && type != 'Tous') {
      query = query.where('type', isEqualTo: type);
    }
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }
    if (minSurface != null) {
      query = query.where('surface', isGreaterThanOrEqualTo: minSurface);
    }

    return (query as Query<Map<String, dynamic>>)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // User helpers
  Future<void> setUser(String uid, Map<String, dynamic> data) async {
    await usersRef.doc(uid).set({...data, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await usersRef.doc(uid).get();
  }

  // Favorites
  Future<void> addFavorite(String uid, String propertyId) async {
    final ref = usersRef.doc(uid).collection('favorites');
    await ref
        .doc(propertyId)
        .set({'propertyId': propertyId, 'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite(String uid, String propertyId) async {
    final ref = usersRef.doc(uid).collection('favorites');
    await ref.doc(propertyId).delete();
  }

  Future<bool> isFavorite(String uid, String propertyId) async {
    final doc =
        await usersRef.doc(uid).collection('favorites').doc(propertyId).get();
    return doc.exists;
  }

  Stream<QuerySnapshot> streamFavorites(String uid) {
    return usersRef
        .doc(uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // Chat
  Future<String> getOrCreateChat(String userId1, String userId2) async {
    final participants = [userId1, userId2]..sort();
    final chatId = '${participants[0]}_${participants[1]}';
    
    final doc = await chatsRef.doc(chatId).get();
    if (!doc.exists) {
      await chatsRef.doc(chatId).set({
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  Stream<QuerySnapshot> streamChatMessages(String chatId) {
    return chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String fromId, String toId, String text) async {
    await chatsRef.doc(chatId).collection('messages').add({
      'fromId': fromId,
      'toId': toId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await chatsRef.doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageFrom': fromId,
    });
  }

  Stream<QuerySnapshot> streamChats(String userId) {
    return chatsRef
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}

