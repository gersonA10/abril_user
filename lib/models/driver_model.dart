class DriverModel {
  final String name;
  final String driverLicense;
  final double rating;
  final String year;
  final String color;
  final String photoDriver;
  final String photoVehicle;
  final String brand;
  final String nroMovil;
  final String placa;
  final int driverId;

  DriverModel({
    required this.name,
    required this.driverLicense,
    required this.rating,
    required this.year,
    required this.color,
    required this.photoDriver,
    required this.photoVehicle,
    required this.brand,
    required this.nroMovil,
    required this.placa,
    required this.driverId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'driverLicense': driverLicense,
        'rating': rating,
        'year': year,
        'color': color,
        'photoDriver': photoDriver,
        'photoVehicle': photoVehicle,
        'brand': brand,
        'nroMovil': nroMovil,
        'placa': placa,
        'driverId': driverId,
      };

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        name: json['name'],
        driverLicense: json['driverLicense'],
        rating: (json['rating'] as num).toDouble(),
        year: json['year'],
        color: json['color'],
        photoDriver: json['photoDriver'],
        photoVehicle: json['photoVehicle'],
        brand: json['brand'],
        nroMovil: json['nroMovil'] ?? '',
         placa: json['placa'] ?? '',
        driverId: json['driverId'] ?? 0
      );
}
