import 'package:flutter/material.dart';

import 'helper/firebase_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImagesScreen extends StatefulWidget {
  ImagesScreen({Key? key}) : super(key: key);

  @override
  State<ImagesScreen> createState() => ImagesScreenState();
}

class ImagesScreenState extends State<ImagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getListResult('images'),
        builder: (context, AsyncSnapshot<ListResult?> snapshot) {
          //print("test: ${snapshot.data}");
          var result = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02),
                  //itemCount: int.parse(snapshot.data.toString()),
                  itemCount: result?.items.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        //print("tapped " + index.toString());

                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return FullscreenImage(index: index);
                        }));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: ImageCard(result, index, context),
                      ),
                    );
                  }),
            );
          }
        },
      ),
    );
  }

  // layout of the listed images
  Card ImageCard(ListResult? result, int index, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(children: [
        TextsAboveImage(result, index, context),
        ImageArea(index),
      ]),
      shadowColor: Colors.teal,
    );
  }

  // FutureBuilder widget
  FutureBuilder<String?> ImageArea(int index) {
    return FutureBuilder(
      future: getItemUrl('images', index),
      builder: (context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        return Expanded(
          child: Image.network(
            snapshot.data.toString(),
            fit: BoxFit.cover,
            width: 200,
          ),
        );
      },
    );
  }

  Row TextsAboveImage(ListResult? result, int index, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'bucket: ${result?.items.elementAt(index).bucket}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            Text(
              'full path: ${result?.items.elementAt(index).fullPath}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

// widget to show images on fullscreen
class FullscreenImage extends StatelessWidget {
  const FullscreenImage({Key? key, required int this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: FutureBuilder(
              future: getItemUrl('images', index),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return Image.network(
                  snapshot.data.toString(),
                );
              },
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
