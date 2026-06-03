class RfidTag {
  final String epc;
  final int rssi;
  final DateTime readTime;
  int count;

  RfidTag({
    required this.epc,
    required this.rssi,
    required this.readTime,
    this.count = 1,
  });

  String get displayName {
    String hex = epc.trim();
    if (hex.length % 2 != 0) {
      return hex;
    }
    try {
      List<int> bytes = [];
      for (int i = 0; i < hex.length; i += 2) {
        String charHex = hex.substring(i, i + 2);
        int byte = int.parse(charHex, radix: 16);
        if (byte != 0) {
          bytes.add(byte);
        }
      }
      bool isPrintable = bytes.every((b) => (b >= 32 && b <= 126) || b == 10 || b == 13);
      if (isPrintable && bytes.isNotEmpty) {
        return String.fromCharCodes(bytes);
      }
    } catch (_) {}
    return hex;
  }

  bool get isDecoded => displayName != epc;
}
