import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:groovenation_flutter/widgets/filter/filter_selector.dart';
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';

class FilterWidget extends StatefulWidget {
  final String imageFilePath;

  const FilterWidget({Key key, @required this.imageFilePath}) : super(key: key);

  @override
  _FilterWidgetState createState() => new _FilterWidgetState(imageFilePath);
}

class _FilterWidgetState extends State<FilterWidget> {
  String fileName;
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  final String imageFilePath;
  imageLib.Image image;
  imageLib.Image compressedImage;

  _FilterWidgetState(this.imageFilePath);

  @override
  void initState() {
    super.initState();

    fileName = imageFilePath.split('/').last;

    initialize();
  }

  bool isLoaded = false;
  void initialize() async {
    File imageFile = new File(imageFilePath);

    image = imageLib.decodeImage(await imageFile.readAsBytes());
    image = imageLib.copyResize(image, width: 600);
    
    // var result = await FlutterImageCompress.compressAndGetFile(
    //   imageFilePath,
    //   "${File("imageFilePath").parent.path}/compressed-${imageFilePath.split('/').last}",
    //   quality: 50,
    // );

    // compressedImage = imageLib.decodeImage(await result.readAsBytes());
    compressedImage = imageLib.copyResize(image, width: 96);

    print(compressedImage);

    setState(() {
      isLoaded = true;
    });
  }

  List<Filter> mypresetFiltersList = [
    NoFilter(),
    AddictiveBlueFilter(),
    AddictiveRedFilter(),
    AdenFilter(),
    AmaroFilter(),
    AshbyFilter(),
  ];

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? FilterSelector(
            title: Text("Add Filters"),
            image: image,
            imageBytes: image.getBytes(),
            compressedImage: compressedImage,
            filters: presetFiltersList,
            filename: fileName,
            appBarColor: Colors.deepPurple,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          )
        : Container(
            color: Colors.white,
            child: Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(),
              ),  
            ),
          );
  }
}
