import 'package:flutest/data.dart';
import 'package:flutter/material.dart';

import 'button.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.editPageRoute,
    required this.toggleDoneCallback,
    required this.isManager,
  });

  final JobData job;
  final Route editPageRoute;
  final VoidCallback toggleDoneCallback;
  final bool isManager;

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
                  job.crop,
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
                    (job.priority - 1) / 2,
                  )?.toColor(),
                ),
                child: Center(
                  child: Text(
                    job.priority.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          Text(job.location, style: Theme.of(context).textTheme.titleSmall),
          Expanded(
            child: Text(
              job.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: .only(bottom: 20, top: 10),
            child: Divider(height: 0),
          ),
          Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              if (isManager)
                GreenButton(
                  text: "Edit",
                  onPressed: () => Navigator.push(context, editPageRoute),
                  icon: Icons.edit,
                ),
              if (job.isCompleted == 0)
                GreenButton(
                  text: "Mark done",
                  onPressed: toggleDoneCallback,
                  icon: Icons.done,
                ),
              if (job.isCompleted == 1)
                RedButton(
                  text: "Mark not done",
                  onPressed: toggleDoneCallback,
                  icon: Icons.cancel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
