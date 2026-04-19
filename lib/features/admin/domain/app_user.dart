class AppUser {
  final String id;
  final String name;
  final String email;
  final String profilePictureUrl;
  final DateTime joinDate;
  final int totalOrders;
  final bool isDisabled;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl = 'https://i.pravatar.cc/150?img=68',
    required this.joinDate,
    required this.totalOrders,
    this.isDisabled = false,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePictureUrl,
    DateTime? joinDate,
    int? totalOrders,
    bool? isDisabled,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      joinDate: joinDate ?? this.joinDate,
      totalOrders: totalOrders ?? this.totalOrders,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePictureUrl: json['profilePictureUrl'] as String? ?? 'https://i.pravatar.cc/150?img=68',
      joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : DateTime.now(),
      totalOrders: json['totalOrders'] as int? ?? 0,
      isDisabled: json['isDisabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'joinDate': joinDate.toIso8601String(),
      'totalOrders': totalOrders,
      'isDisabled': isDisabled,
    };
  }
}
