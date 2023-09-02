class KeyValue<T, U> {
  KeyValue({required this.key, this.value});
  T key;
  U? value;

  toString() {
    return "${key.toString()}, ${value.toString()}";
  }
}
