import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:groovenation_flutter/widgets/filters/filters.dart';

class FilterWidget extends StatefulWidget {
  final String imagePath;
  final Function onImagePicked;

  const FilterWidget(
      {Key? key, required this.imagePath, required this.onImagePicked})
      : super(key: key);
  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  final GlobalKey _globalKey = GlobalKey();
  final PageController _pageController = PageController();
  bool _imageSaving = false;

  final List<List<double>> filters = [
    NO_FILTER_MATRIX,
    OLD_TIMES_MATRIX,
    COLD_LIFE_MATRIX,
    SEPIUM_MATRIX,
    MILK_MATRIX,
    SUNNY_DAYS_MATRIX,
    SEPIA_MATRIX,
    GREYSCALE_MATRIX,
    VINTAGE_MATRIX,
    SWEET_MATRIX
  ];

  void convertWidgetToImage() async {
    setState(() {
      _imageSaving = true;
    });

    RenderRepaintBoundary? repaintBoundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;

    ui.Image boxImage = await repaintBoundary!.toImage(pixelRatio: 3);
    ByteData? byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);

    Uint8List uint8list = byteData!.buffer.asUint8List();

    File imageFile = File(widget.imagePath);

    String newImagePath =
        "${imageFile.parent.path}/filtered-${imageFile.path.split('/').last}";

    File newFile =
        await File(newImagePath).writeAsBytes(uint8list, mode: FileMode.write);

    imageFile.delete();

    widget.onImagePicked(newFile.path);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Image image = Image.file(
      File(widget.imagePath),
      width: size.width,
      fit: BoxFit.cover,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add a Filter",
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: true,
        actions: [
          _imageSaving
              ? _loadingIndicator()
              : IconButton(
                  icon: Icon(Icons.check), onPressed: convertWidgetToImage),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _globalKey,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: size.width,
                    maxHeight: size.width,
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      return ColorFiltered(
                        colorFilter: ColorFilter.matrix(filters[index]),
                        child: image,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 156,
            child: ListView.builder(
              itemCount: filters.length,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return _colorFilterItem(image, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorFilterItem(Image image, int index) {
    return Container(
      height: 156,
      width: 156,
      child: InkWell(
        onTap: () => _pageController.animateToPage(
          index,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 250),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(filters[index]),
          child: image,
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
}
