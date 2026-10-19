import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'data.dart';
import 'button.dart';

class Priority extends StatelessWidget {
  const Priority({super.key, required this.priority});

  final int priority;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.buttons});

  final JobData job;
  final List<Button> buttons;

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
              Priority(priority: job.priority),
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
          Row(mainAxisAlignment: .spaceEvenly, children: buttons),
        ],
      ),
    );
  }
}

class DefaultJobCard extends StatelessWidget {
  const DefaultJobCard({
    super.key,
    required this.job,
    required this.editPageRoute,
    required this.toggleDoneCallback,
  });

  final JobData job;
  final Route editPageRoute;
  final VoidCallback toggleDoneCallback;

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(
      builder: (context, account, child) {
        return JobCard(
          job: job,
          buttons: [
            if (account.type == .manager)
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
        );
      },
    );
  }
}

class JobSelectorCard extends StatelessWidget {
  const JobSelectorCard({super.key, required this.job});

  final JobData job;

  @override
  Widget build(BuildContext context) {
    return Consumer<JobList>(
      builder: (context, joblist, child) => JobCard(
        job: job,
        buttons: [
          if (!joblist.has(job))
            GreenButton(
              text: "Add",
              onPressed: () => joblist.add(job),
              icon: Icons.add,
            ),
          if (joblist.has(job))
            RedButton(
              text: "Remove",
              onPressed: () => joblist.removeJob(job),
              icon: Icons.remove,
            ),
        ],
      ),
    );
  }
}
