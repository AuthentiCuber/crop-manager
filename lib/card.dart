import 'package:flutter/material.dart';

import 'button.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    required this.crop,
    required this.location,
    required this.description,
    required this.priority,
    required this.editCallback,
    super.key,
  });

  final String crop;
  final String location;
  final String description;
  final int priority;
  final VoidCallback editCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .all(Radius.circular(14)),
        color: Colors.grey[300],
      ),
      padding: .symmetric(vertical: 20, horizontal: 20),
      child: Column(
        spacing: 2,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .start,
            children: [
              Flexible(
                child: Text(
                  crop,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: .all(Radius.circular(32)),
                  color: HSVColor.lerp(
                    HSVColor.fromAHSV(1, 0, 1, 0.7),
                    HSVColor.fromAHSV(1, 110, 1, 0.7),
                    (priority - 1) / 2,
                  )?.toColor(),
                ),
                child: Center(
                  child: Text(
                    priority.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          Text(location, style: Theme.of(context).textTheme.titleSmall),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: .only(bottom: 20, top: 10),
            child: Divider(height: 0),
          ),
          Center(
            child: GreenButton(
              text: "Edit",
              onPressed: editCallback,
              icon: Icons.edit,
            ),
          ),
        ],
      ),
    );
  }
}
