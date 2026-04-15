/// User Model - Represents all user types (patient, doctor, hospital)

class UserModel {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? profileImage;
  final String? bloodGroup;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? allergies;
  final String? chronicConditions;
  final bool isVerified;
  final DoctorProfile? doctorProfile;
  final HospitalProfile? hospital;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.profileImage,
    this.bloodGroup,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.allergies,
    this.chronicConditions,
    this.isVerified = false,
    this.doctorProfile,
    this.hospital,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'patient',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      profileImage: json['profile_image'],
      bloodGroup: json['blood_group'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      allergies: json['allergies'],
      chronicConditions: json['chronic_conditions'],
      isVerified: json['is_verified'] ?? false,
      doctorProfile: json['doctorProfile'] != null
          ? DoctorProfile.fromJson(json['doctorProfile'])
          : null,
      hospital: json['hospital'] != null
          ? HospitalProfile.fromJson(json['hospital'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'blood_group': bloodGroup,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
    };
  }
}

class DoctorProfile {
  final String id;
  final String specialization;
  final String qualification;
  final int experienceYears;
  final String registrationNumber;
  final double consultationFee;
  final String? bio;
  final List<String> languages;
  final List<String> availableDays;
  final String? availableFrom;
  final String? availableTo;
  final bool isAvailable;
  final double rating;
  final int totalReviews;
  final String? hospitalId;

  DoctorProfile({
    required this.id,
    required this.specialization,
    required this.qualification,
    required this.experienceYears,
    required this.registrationNumber,
    required this.consultationFee,
    this.bio,
    this.languages = const ['English'],
    this.availableDays = const [],
    this.availableFrom,
    this.availableTo,
    this.isAvailable = true,
    this.rating = 0,
    this.totalReviews = 0,
    this.hospitalId,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] ?? '',
      specialization: json['specialization'] ?? '',
      qualification: json['qualification'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      consultationFee: double.tryParse(json['consultation_fee']?.toString() ?? '0') ?? 0,
      bio: json['bio'],
      languages: json['languages'] != null ? List<String>.from(json['languages']) : ['English'],
      availableDays: json['available_days'] != null ? List<String>.from(json['available_days']) : [],
      availableFrom: json['available_from'],
      availableTo: json['available_to'],
      isAvailable: json['is_available'] ?? true,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      totalReviews: json['total_reviews'] ?? 0,
      hospitalId: json['hospital_id'],
    );
  }
}

class HospitalProfile {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String address;
  final String city;
  final String state;
  final String phone;
  final double? latitude;
  final double? longitude;
  final List<String> specializations;
  final List<String> facilities;
  final bool emergencyServices;
  final bool ambulanceAvailable;
  final String? ambulancePhone;
  final double rating;
  final String? imageUrl;
  final double? distance;

  HospitalProfile({
    required this.id,
    required this.name,
    this.type = 'hospital',
    this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    this.latitude,
    this.longitude,
    this.specializations = const [],
    this.facilities = const [],
    this.emergencyServices = false,
    this.ambulanceAvailable = false,
    this.ambulancePhone,
    this.rating = 0,
    this.imageUrl,
    this.distance,
  });

  factory HospitalProfile.fromJson(Map<String, dynamic> json) {
    return HospitalProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'hospital',
      description: json['description'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      phone: json['phone'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      specializations: json['specializations'] != null ? List<String>.from(json['specializations']) : [],
      facilities: json['facilities'] != null ? List<String>.from(json['facilities']) : [],
      emergencyServices: json['emergency_services'] ?? false,
      ambulanceAvailable: json['ambulance_available'] ?? false,
      ambulancePhone: json['ambulance_phone'],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'],
      distance: double.tryParse(json['distance']?.toString() ?? ''),
    );
  }
}
