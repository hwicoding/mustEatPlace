class FireBaseReviewList {
  String? id;
  String name;
  String phone;
  double lat;
  double lng;
  String? image;
  String estimate;
  String initdate;

  FireBaseReviewList({
    this.id,
    required this.name,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.image,
    required this.estimate,
    required this.initdate,
  });
}
