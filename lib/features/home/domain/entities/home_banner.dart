import 'package:equatable/equatable.dart';

class HomeBanner extends Equatable {
  final String title;
  final String subTitle;
  final String imageUrl;

  const HomeBanner({
    this.title = '',
    this.subTitle = '',
    this.imageUrl = '',
  });

  @override
  List<Object?> get props => [title, subTitle, imageUrl];
}
