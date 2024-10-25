class ValidatePhoneNumber {
  String? call(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return 'Cannot be empty';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
      return 'Must contain only digits';
    }
    if (phoneNumber.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return ''; // This means the number is valid
  }
}