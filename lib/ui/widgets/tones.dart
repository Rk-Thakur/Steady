import '../../domain/models/models.dart';
import 'kit.dart';

/// Category tile tone → shared banner/tile tone.
BannerTone toneOf(CategoryTone? tone) => switch (tone) {
  CategoryTone.warning => BannerTone.warning,
  CategoryTone.info => BannerTone.info,
  CategoryTone.danger => BannerTone.danger,
  CategoryTone.neutral => BannerTone.neutral,
  _ => BannerTone.primary,
};
