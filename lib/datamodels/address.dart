class Address{
  String placeName;
  double latitude;
  double longitude;
  String placeId;
  String placeFomattedAddress;

  Address(
      {
        this.placeId,
        this.latitude,
        this.longitude,
        this.placeName,
        this.placeFomattedAddress
      });
}