class QueryFilter {
  final String field;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;
  final bool? isNull;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;

  QueryFilter({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
    this.arrayContains,
    this.arrayContainsAny,
  });
}

enum BatchOperationType { set, update, delete }

class BatchOperation<T> {
  final String docId;
  final BatchOperationType type;
  final T? model;
  final Map<String, dynamic>? updates;

  BatchOperation.set({
    required this.docId,
    required this.model,
  })  : type = BatchOperationType.set,
        updates = null;

  BatchOperation.update({
    required this.docId,
    required this.updates,
  })  : type = BatchOperationType.update,
        model = null;

  BatchOperation.delete({
    required this.docId,
  })  : type = BatchOperationType.delete,
        model = null,
        updates = null;
}