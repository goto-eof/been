class KeyValue<T, U> {
  KeyValue({required this.key, this.value});
  T key;
  U? value;

  @override
  toString() {
    return "${key.toString()}, ${value.toString()}";
  }
}
