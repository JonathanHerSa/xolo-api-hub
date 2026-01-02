class KeyValuePair {
  final String key;
  final String value;
  final bool
  isActive; // Para poder desactivar una línea sin borrarla (como Postman)

  KeyValuePair({this.key = '', this.value = '', this.isActive = true});

  KeyValuePair copyWith({String? key, String? value, bool? isActive}) {
    return KeyValuePair(
      key: key ?? this.key,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }
}
