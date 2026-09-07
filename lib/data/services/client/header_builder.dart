class HeaderBuilder {
  final Map<String, String> _header;

  HeaderBuilder() : _header = {};

  HeaderBuilder setContentType(String type) {
    _header['Content-Type'] = type;
    return this;
  }

  HeaderBuilder setBearerToken(String token) {
    _header['Authorization'] = 'Bearer $token';
    return this;
  }

  Map<String, String> build() => _header;
}
