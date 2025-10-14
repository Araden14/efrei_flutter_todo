// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  userId: json['userId'] as String?,
  dueDate: _dateTimeFromTimestampNullable(json['dueDate'] as Timestamp?),
  priority: json['priority'] as String? ?? 'normal',
  createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp),
  status: json['status'] as String? ?? 'pending',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$TodoModelToJson(TodoModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': ?instance.description,
  'userId': ?instance.userId,
  'dueDate': ?_timestampFromDateTimeNullable(instance.dueDate),
  'priority': instance.priority,
  'createdAt': _timestampFromDateTime(instance.createdAt),
  'status': instance.status,
  'tags': instance.tags,
};
