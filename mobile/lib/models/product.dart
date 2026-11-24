class Product {
  final String title;
  final String price;
  final double numericPrice;
  final String image;
  final double rating;
  final int ratingCount;
  final String store;
  final String link;
  final bool isAiTopPick;

  Product({
    required this.title,
    required this.price,
    required this.numericPrice,
    required this.image,
    required this.rating,
    required this.ratingCount,
    required this.store,
    required this.link,
    this.isAiTopPick = false,
  });

  int get reviewsCount => ratingCount;
  String? get originalPrice => null;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'] != null ? json['price'].toString() : '';
    final cleaned = rawPrice.replaceAll(RegExp(r'[^\d.]'), '');
    final numPrice = double.tryParse(cleaned) ?? 0.0;

    double parsedRating = 0.0;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        parsedRating = (json['rating'] as num).toDouble();
      } else {
        parsedRating = double.tryParse(json['rating'].toString()) ?? 0.0;
      }
    }

    int parsedRatingCount = 0;
    if (json['ratingCount'] != null) {
      if (json['ratingCount'] is num) {
        parsedRatingCount = (json['ratingCount'] as num).toInt();
      } else {
        parsedRatingCount = int.tryParse(json['ratingCount'].toString().replaceAll(',', '')) ?? 0;
      }
    }

    return Product(
      title: json['title']?.toString() ?? 'Product',
      price: cleaned.isNotEmpty ? cleaned : rawPrice,
      numericPrice: numPrice,
      image: json['image']?.toString() ?? '',
      rating: parsedRating,
      ratingCount: parsedRatingCount,
      store: _normalizeStore(json['store']?.toString()),
      link: json['link']?.toString() ?? '',
      isAiTopPick: json['isAiTopPick'] == true,
    );
  }

  static String _normalizeStore(String? raw) {
    if (raw == null) return 'Online Store';
    final lower = raw.toLowerCase();
    if (lower.contains('amazon')) return 'Amazon';
    if (lower.contains('flipkart')) return 'Flipkart';
    return raw;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'numericPrice': numericPrice,
      'image': image,
      'rating': rating,
      'ratingCount': ratingCount,
      'store': store,
      'link': link,
      'isAiTopPick': isAiTopPick,
    };
  }

  Product copyWith({bool? isAiTopPick}) {
    return Product(
      title: title,
      price: price,
      numericPrice: numericPrice,
      image: image,
      rating: rating,
      ratingCount: ratingCount,
      store: store,
      link: link,
      isAiTopPick: isAiTopPick ?? this.isAiTopPick,
    );
  }
}

class WatchlistItem {
  final String id;
  final Product product;
  final double currentPrice;
  final double previousPrice;
  final DateTime addedAt;
  final String folder;

  WatchlistItem({
    required this.id,
    required this.product,
    required this.currentPrice,
    required this.previousPrice,
    required this.addedAt,
    this.folder = 'My Wishlist',
  });

  String get title => product.title;
  String get price => product.price.startsWith('₹') ? product.price : '₹${product.price}';
  double get numericPrice => product.numericPrice > 0 ? product.numericPrice : currentPrice;
  String get image => product.image;
  String get store => product.store;
  String get link => product.link;

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    final prodJson = json['product'] is Map<String, dynamic> ? json['product'] : json;
    return WatchlistItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      product: Product.fromJson(prodJson),
      currentPrice: double.tryParse(json['currentPrice']?.toString() ?? '') ??
          (json['product'] != null ? double.tryParse(json['product']['price']?.toString() ?? '') ?? 0.0 : 0.0),
      previousPrice: double.tryParse(json['previousPrice']?.toString() ?? '') ?? 0.0,
      addedAt: json['addedAt'] != null ? DateTime.tryParse(json['addedAt'].toString()) ?? DateTime.now() : DateTime.now(),
      folder: json['folder']?.toString() ?? 'My Wishlist',
    );
  }
}

class AlertItem {
  final String id;
  final Product product;
  final double currentPrice;
  final double targetPrice;
  final DateTime createdAt;
  final bool notified;

  AlertItem({
    required this.id,
    required this.product,
    required this.currentPrice,
    required this.targetPrice,
    required this.createdAt,
    this.notified = false,
  });

  String get title => product.title;
  String get currentPriceFormatted => product.price.startsWith('₹') ? product.price : '₹${product.price}';
  double get numericCurrentPrice => product.numericPrice > 0 ? product.numericPrice : currentPrice;
  String get image => product.image;
  String get store => product.store;
  String get link => product.link;

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    final prodJson = json['product'] is Map<String, dynamic> ? json['product'] : json;
    return AlertItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      product: Product.fromJson(prodJson),
      currentPrice: double.tryParse(json['currentPrice']?.toString() ?? '') ??
          (json['product'] != null ? double.tryParse(json['product']['price']?.toString() ?? '') ?? 0.0 : 0.0),
      targetPrice: double.tryParse(json['targetPrice']?.toString() ?? '') ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      notified: json['notified'] == true,
    );
  }
}

class OrderItem {
  final String id;
  final List<Product> items;
  final double totalAmount;
  final DateTime orderedAt;
  final String orderStatus;

  OrderItem({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderedAt,
    this.orderStatus = 'Completed',
  });

  double get total => totalAmount;
  String get createdAt => orderedAt.toString().split(' ').first;
  String get status => orderStatus;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      items: rawItems.map((i) => Product.fromJson(i as Map<String, dynamic>)).toList(),
      totalAmount: double.tryParse(json['total']?.toString() ?? json['totalAmount']?.toString() ?? '0') ?? 0.0,
      orderedAt: json['orderedAt'] != null ? DateTime.tryParse(json['orderedAt'].toString()) ?? DateTime.now() : DateTime.now(),
      orderStatus: json['status']?.toString() ?? 'Completed',
    );
  }
}
