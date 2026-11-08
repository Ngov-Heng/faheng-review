/// Trims and lowercases an email so the same address
/// is always stored the same way.
String normalizeEmail(String email) => email.trim().toLowerCase();

/// Removes spaces, dashes, dots and brackets from a phone number
/// (keeps a leading +).
String normalizePhone(String phone) =>
    phone.replaceAll(RegExp(r'[\s\-().]'), '');

/// True for a simple, plausible email address.
bool isValidEmail(String email) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

/// True for 8 to 15 digits, with an optional leading +.
bool isValidPhone(String phone) => RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone);
