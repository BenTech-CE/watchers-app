class StarDistributionModel {
  double starRating;
  int quantity;

  StarDistributionModel({
    required this.starRating,
    required this.quantity,
  });

  factory StarDistributionModel.fromJson(Map<String, dynamic> json) {
    return StarDistributionModel(
      starRating: (json['star_rating'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}