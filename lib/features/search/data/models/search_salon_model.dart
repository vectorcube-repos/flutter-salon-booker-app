import 'package:salon_booker_app/features/search/domain/entities/search_salon.dart';

class SearchSalonModel extends SearchSalon {
  const SearchSalonModel({
    required super.id,
    required super.name,
    super.description,
    super.address,
    super.city,
    super.state,
    super.image,
    super.rating,
    super.reviewsCount,
    super.isFavorite,
  });

  factory SearchSalonModel.fromApiJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null) {
      throw const FormatException('Search salon id is required');
    }

    final rawRating = json['rating'];
    final rating = rawRating is num
        ? rawRating.toDouble()
        : double.tryParse('$rawRating');
    final rawReviewsCount = json['reviews_count'];
    final reviewsCount = rawReviewsCount is int
        ? rawReviewsCount
        : int.tryParse('$rawReviewsCount') ?? 0;

    return SearchSalonModel(
      id: id,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'Salon',
      description: (json['description'] as String?)?.trim(),
      address: (json['address'] as String?)?.trim(),
      city: (json['city'] as String?)?.trim(),
      state: (json['state'] as String?)?.trim(),
      image: (json['image'] as String?)?.trim(),
      rating: rating,
      reviewsCount: reviewsCount,
      isFavorite: json['is_favorite'] == true,
    );
  }
}
