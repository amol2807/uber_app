import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Widgets/BrandDivider.dart';
import 'package:uber_app/Widgets/PredictionTile.dart';
import 'package:uber_app/brand_colors.dart';
import 'package:uber_app/datamodels/prediction.dart';
import 'package:uber_app/dataprovider/appdata.dart';
import 'package:uber_app/helpers/RequestHelper.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickUpController = TextEditingController();
  var destinationController = TextEditingController();

  var focusDestination = FocusNode();
  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  void searchPlace(String placeName) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs&sessiontoken=123254251&components=country:in';

    var response = await RequestHelper.getRequest(url);

    if (placeName.length > 1) {
      if (response == 'failed') {
        print('Response Failed');
        return;
      }
      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];

        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();

        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    String address =
        Provider.of<AppData>(context).pickUpAddress.placeName ?? '';
    pickUpController.text = address;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, top: 48.0, right: 24, bottom: 20.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Center(
                        child: Text(
                          'Set Destination',
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: 'Brand-Bold'),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    children: <Widget>[
                      Image(
                        image: AssetImage('images/pickicon.png'),
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              controller: pickUpController,
                              decoration: InputDecoration(
                                hintText: 'Pickup Location',
                                fillColor: BrandColors.colorLightGrayFair,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 8, bottom: 8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Image(
                        image: AssetImage('images/desticon.png'),
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorLightGrayFair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              onChanged: (value) {
                                searchPlace(value);
                              },
                              focusNode: focusDestination,
                              controller: destinationController,
                              decoration: InputDecoration(
                                hintText: 'Where to',
                                fillColor: BrandColors.colorLightGrayFair,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 8, bottom: 8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          (destinationPredictionList.length > 0)
              ? SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                          prediction: destinationPredictionList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          BrandDivider(),
                      itemCount: destinationPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  ),
                )
              : SingleChildScrollView(child: Container()),
        ],
      ),
    );
  }
}
