abstract class BaseModel {
  Map<String, dynamic> toJson();

  static T fromJson<T extends BaseModel>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) constructor,
  ) {
    return constructor(json);
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
