// lib/models/participant_model.dart

// Konsep OOP 1: ENCAPSULATION
// Properti dibuat private dengan underscore (_) dan hanya bisa diakses
// melalui getter publik. Ini menyembunyikan detail implementasi.
class Participant {
  final String _name;
  final String _bloodType;
  final String _location;
  final String _phoneNumber;

  Participant(this._name, this._bloodType, this._location, this._phoneNumber);

  // Getter untuk mengakses properti private
  String get name => _name;
  String get bloodType => _bloodType;
  String get location => _location;
  String get phoneNumber => _phoneNumber;
}

// Konsep OOP 2: INHERITANCE
// Class `UrgentNeed` adalah turunan dari `Participant`. Ia mewarisi semua
// properti dan method dari Participant, dan menambahkan properti baru.
class UrgentNeed extends Participant {
  final String _urgencyReason;

  UrgentNeed(String name, String bloodType, String location, String phoneNumber, this._urgencyReason)
      : super(name, bloodType, location, phoneNumber); // Memanggil constructor parent

  String get urgencyReason => _urgencyReason;
}

// Konsep OOP 3: POLYMORPHISM akan kita lihat penerapannya di HomeScreen,
// di mana kita bisa memasukkan object `Participant` dan `UrgentNeed`
// ke dalam satu List yang sama dan memperlakukannya secara seragam.