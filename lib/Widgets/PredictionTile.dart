import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Widgets/progressdialogue.dart';
import 'package:uber_app/datamodels/address.dart';
import 'package:uber_app/datamodels/prediction.dart';
import 'package:uber_app/dataprovider/appdata.dart';
import 'package:uber_app/helpers/RequestHelper.dart';

import '../brand_colors.dart';

class PredictionTile extends StatelessWidget {

  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeID,context) async
  {
    
    showDialog(context: context,barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialogue(status: 'Please wait...',)
  );
    
  String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if(response=='failed'){
        return;
      }
    if(response['status']=='OK')
      {
        Address thisPlace = new Address();
        thisPlace.placeName = response['result']['name'];
        thisPlace.placeId = placeID;
        thisPlace.latitude = response['result']['geometry']['location']['lat'];
        thisPlace.longitude = response['result']['geometry']['location']['lng'];

        Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
        print(thisPlace.placeName);

        Navigator.pop(context,'getDirection');
      }
    }

  @override
  Widget build(BuildContext context) {

    return FlatButton(
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);
      },
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Icon(
                  OMIcons.locationOn,
                  color: BrandColors.colorDimText,
                ),
                SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        prediction.mainText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        prediction.secondaryText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 12.0, color: BrandColors.colorDimText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
