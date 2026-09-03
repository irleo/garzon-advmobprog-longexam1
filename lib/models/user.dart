class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.gender,
    required this.image,
    required this.phone,
    required this.birthDate,
    required this.university,
    required this.address,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String gender;
  final String image;
  final String phone;
  final String birthDate;
  final String university;
  final String address;

  String get fullName => '$firstName $lastName'.trim();

  User copyWith({String? username}) => User(
    id: id,
    firstName: firstName,
    lastName: lastName,
    username: username ?? this.username,
    email: email,
    gender: gender,
    image: image,
    phone: phone,
    birthDate: birthDate,
    university: university,
    address: address,
  );

  factory User.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'];
    final addressMap = addressJson is Map<String, dynamic>
        ? addressJson
        : <String, dynamic>{};
    final city = addressMap['city']?.toString() ?? '';
    final state = addressMap['state']?.toString() ?? '';
    final location = [city, state].where((part) => part.isNotEmpty).join(', ');

    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      birthDate: json['birthDate']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      address: location,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'username': username,
    'email': email,
    'gender': gender,
    'image': image,
    'phone': phone,
    'birthDate': birthDate,
    'university': university,
    'address': <String, String>{'city': address},
  };
}
