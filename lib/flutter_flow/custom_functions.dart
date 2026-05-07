String? getShortId(String? fullId) {
  if (fullId == null || fullId.length < 8) {
    return fullId ?? '';
  }
  return fullId.substring(0, 8);
}
