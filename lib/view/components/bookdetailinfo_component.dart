import 'package:flutter/material.dart';

Widget bookDetailInfoTile({
  required String title,
  required String data,
  required IconData icon,
}) {
  return Expanded(
    child: SizedBox(
      height: 156,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.2),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white54,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(radius: 25, child: Icon(icon, size: 25)),
            Text(
              data,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}
