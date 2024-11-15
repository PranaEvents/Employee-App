class CardItem {
  final String firstName;
  final String lastName;
   final String gender;
  final String disability;
   final String phoneNumber;
  final String email;
    final String university;
   final String department;
  final String region;
      final String city;
   final String yearofGraduate;
  final String? cvUrl;

  CardItem({required this.firstName, required this.lastName, required this.gender, required this.disability, required this.phoneNumber, required this.email, required this.university, required this.department, required this.region, required this.city, required this.yearofGraduate,  this.cvUrl});

  static fromJson(item) {}
}