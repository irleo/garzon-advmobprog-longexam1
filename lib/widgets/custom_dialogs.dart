import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import 'package:flutter/material.dart';

dynamic customDialog(BuildContext context, {required title, required content}) {
  AlertDialog alertDialog = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_DARK_PRIMARY,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Okay'),
      ),
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}

dynamic customOptionDialog(
  BuildContext context, {
  required String title,
  required String content,
  required Function onYes,
}) {
  AlertDialog alertDialog = AlertDialog(
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text(content),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("No"),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: FB_DARK_PRIMARY,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onYes();
        },
        child: const Text("Yes"),
      ),
    ],
  );

  showDialog(context: context, builder: (_) => alertDialog);
}

dynamic customShowImageDialog(
  BuildContext context, {
  required String src,
  bool isNetwork = false, 
}) {
  final bool useNetwork = isNetwork || src.startsWith('http');

  showDialog(
    context: context,
    barrierDismissible: true, 
    builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1, 
                  child: useNetwork
                      ? CachedNetworkImage(
                          imageUrl: src,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              color: FB_DARK_PRIMARY,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error, size: 60, color: Colors.red),
                          ),
                        )
                      : Image.asset(
                          src,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.error, size: 60, color: Colors.red),
                          ),
                        ),
                ),
              ),
            ),

            Positioned(
              top: 6,
              right: 6,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
