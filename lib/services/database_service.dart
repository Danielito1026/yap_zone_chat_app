import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yap_zone/constants/constants.dart';
import 'package:yap_zone/models/database_models.dart';
import 'package:yap_zone/models/user.dart';

class DatabaseService<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName;
  final String? subcollectionName;
  final T Function(String id, Map<String, dynamic> data) fromMap;

  final Map<String, dynamic> Function(T model) toMap;

  DatabaseService({
    required this.collectionName,
    required this.fromMap,
    required this.toMap,
    this.subcollectionName,
  });

  Future<T?> getDocument(String docId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docId).get();
      if (doc.exists) {
        return fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  Future<List<T>> getAllDocuments() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) => fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      print('Error getting all documents: $e');
      return [];
    }
  }

  Future<List<T>> getDocumentsWhere({
    required Object field,
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isNotEqualTo != null) {
        query = query.where(field, isNotEqualTo: isNotEqualTo);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (isGreaterThanOrEqualTo != null) {
        query = query.where(
          field,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        );
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (isLessThanOrEqualTo != null) {
        query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
      }
      if (whereIn != null) {
        query = query.where(field, whereIn: whereIn);
      }
      if (whereNotIn != null) {
        query = query.where(field, whereNotIn: whereNotIn);
      }
      if (isNull != null) {
        query = query.where(field, isNull: isNull);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting documents with where: $e');
      return [];
    }
  }

  Future<List<T>> getDocumentsWithFilters(List<QueryFilter> filters) async {
    try {
      Query query = _firestore.collection(collectionName);

      for (final filter in filters) {
        query = query.where(
          filter.field,
          isEqualTo: filter.isEqualTo,
          isNotEqualTo: filter.isNotEqualTo,
          isGreaterThan: filter.isGreaterThan,
          isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
          isLessThan: filter.isLessThan,
          isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
          whereIn: filter.whereIn,
          whereNotIn: filter.whereNotIn,
          isNull: filter.isNull,
          arrayContains: filter.arrayContains,
          arrayContainsAny: filter.arrayContainsAny,
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting documents with filters: $e');
      return [];
    }
  }

  Future<List<T>> getDocumentsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? orderByField,
    bool descending = false,
    QueryFilter? filter,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      if (filter != null) {
        query = query.where(
          filter.field,
          isEqualTo: filter.isEqualTo,
          isNotEqualTo: filter.isNotEqualTo,
          isGreaterThan: filter.isGreaterThan,
          isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
          isLessThan: filter.isLessThan,
          isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
          whereIn: filter.whereIn,
          whereNotIn: filter.whereNotIn,
          isNull: filter.isNull,
          arrayContains: filter.arrayContains,
          arrayContainsAny: filter.arrayContainsAny,
        );
      }

      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting paginated documents: $e');
      return [];
    }
  }

  Stream<T?> watchDocument(String docId) {
    return _firestore
        .collection(collectionName)
        .doc(docId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists ? fromMap(snapshot.id, snapshot.data()!) : null,
        );
  }

  Stream<List<T>> watchAllDocuments() {
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => fromMap(doc.id, doc.data())).toList(),
        );
  }

  Stream<List<T>> watchDocumentsWhere({
    required String field,
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
    dynamic arrayContains,
    List<dynamic>? arrayContainsAny,
  }) {
    Query query = _firestore.collection(collectionName);

    if (isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }
    if (isNotEqualTo != null) {
      query = query.where(field, isNotEqualTo: isNotEqualTo);
    }
    if (isGreaterThan != null) {
      query = query.where(field, isGreaterThan: isGreaterThan);
    }
    if (isGreaterThanOrEqualTo != null) {
      query = query.where(
        field,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      );
    }
    if (isLessThan != null) {
      query = query.where(field, isLessThan: isLessThan);
    }
    if (isLessThanOrEqualTo != null) {
      query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
    }
    if (whereIn != null) {
      query = query.where(field, whereIn: whereIn);
    }
    if (whereNotIn != null) {
      query = query.where(field, whereNotIn: whereNotIn);
    }
    if (isNull != null) {
      query = query.where(field, isNull: isNull);
    }
    if (arrayContains != null) {
      query = query.where(field, arrayContains: arrayContains);
    }
    if (arrayContainsAny != null) {
      query = query.where(field, arrayContainsAny: arrayContainsAny);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<String?> addDocument(T model) async {
    try {
      final docRef = await _firestore
          .collection(collectionName)
          .add(toMap(model));
      return docRef.id;
    } catch (e) {
      print('Error adding document: $e');
      return null;
    }
  }

  Future<String?> addDocumentToSubcollection(
    String parentDocId,
    T model,
  ) async {
    try {
      final docRef = await _firestore
          .collection(collectionName)
          .doc(parentDocId)
          .collection(subcollectionName!)
          .add(toMap(model));
      return docRef.id;
    } catch (e) {
      print('Error adding document: $e');
      return null;
    }
  }

  Future<void> setDocument(String docId, T model) async {
    try {
      await _firestore.collection(collectionName).doc(docId).set(toMap(model));
    } catch (e) {
      print('Error setting document: $e');
    }
  }

  Future<void> setDocumentMap(String docId, Map<String, dynamic> model) async {
    try {
      await _firestore.collection(collectionName).doc(docId).set(model);
    } catch (e) {
      print('Error setting document: $e');
    }
  }

  Future<void> updateDocument(
    String docId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection(collectionName).doc(docId).update(updates);
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> deleteDocument(String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> batchWrite(List<BatchOperation<T>> operations) async {
    final batch = _firestore.batch();

    for (final op in operations) {
      final docRef = _firestore.collection(collectionName).doc(op.docId);

      switch (op.type) {
        case BatchOperationType.set:
          batch.set(docRef, toMap(op.model!));
          break;
        case BatchOperationType.update:
          batch.update(docRef, op.updates!);
          break;
        case BatchOperationType.delete:
          batch.delete(docRef);
          break;
      }
    }

    try {
      await batch.commit();
    } catch (e) {
      print('Error in batch write: $e');
    }
  }

  Future<int> getCount({String? field, dynamic isEqualTo}) async {
    try {
      Query query = _firestore.collection(collectionName);
      if (field != null && isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting count: $e');
      return 0;
    }
  }

  Future<R> runTransaction<R>(
    Future<R> Function(Transaction transaction) action,
  ) async {
    return await _firestore.runTransaction(action);
  }

  CollectionReference<Map<String, dynamic>> subcollection({
    required String docId,
    required String subcollectionName,
  }) {
    return _firestore
        .collection(collectionName)
        .doc(docId)
        .collection(subcollectionName);
  }
}
