
  bool isPhoneValid(String phoneNumber) {
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    return phoneRegex.hasMatch(phoneNumber);
  }