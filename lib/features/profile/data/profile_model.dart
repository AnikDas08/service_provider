class ProfileModel {
  final bool success;
  final String message;
  final ProfileData? data;

  ProfileModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileModel.fromJson(Map<dynamic, dynamic> json) {
    return ProfileModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ProfileData {
  final String? id;
  final String? role;
  final String? name;
  final String? image;
  final String? email;
  final String? contact;
  final String? location;
  final int? credits;
  final bool? isActive;
  final bool? verified;
  final bool? isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  ProfileData({
    this.id,
    this.role,
    this.name,
    this.image,
    this.email,
    this.contact,
    this.location,
    this.credits,
    this.isActive,
    this.verified,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['_id'],
      role: json['role'],
      name: json['name'],
      image: json['image'],
      email: json['email'],
      contact: json['contact'],
      location: json['location'],
      credits: json['credits'],
      isActive: json['isActive'],
      verified: json['verified'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'role': role,
      'name': name,
      'image': image,
      'email': email,
      'contact': contact,
      'location': location,
      'credits': credits,
      'isActive': isActive,
      'verified': verified,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
