import 'package:dgg/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ChatVote extends StatelessWidget {
  final ChatViewModel model;

  const ChatVote({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model.isVoteCollapsed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.currentVote.question,
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Winning option: ${model.currentVote.getWinningOption()}",
              maxLines: 1,
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down),
              onPressed: model.toggleVoteCollapse,
            ),
          ],
        ),
      );
    } else {
      int voteTotal = model.currentVote.getTotalVotes();
      int adjustedVoteTotal = voteTotal == 0 ? 1 : voteTotal;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.currentVote.question,
              style: TextStyle(fontSize: 24),
            ),
            Text(
              model.currentVote.time - model.voteTimePassed > 0
                  ? "Voting time remaining: ${(model.currentVote.time - model.voteTimePassed)}"
                  : "Voting finished",
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: model.currentVote.options.length,
              itemBuilder: (context, index) {
                double percent =
                    model.currentVote.voteCount[index] / adjustedVoteTotal;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${index + 1}: ${model.currentVote.options[index]}"),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: LinearPercentIndicator(
                        animation: true,
                        animateFromLastPercent: true,
                        animationDuration: 250,
                        lineHeight: 20.0,
                        percent: percent,
                        center: Text(
                          "${(percent * 100).round()}%",
                          style: TextStyle(color: Colors.black),
                        ),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_up),
              onPressed: model.toggleVoteCollapse,
            ),
          ],
        ),
      );
    }
  }
}
