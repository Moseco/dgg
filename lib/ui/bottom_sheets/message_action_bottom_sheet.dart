import 'package:dgg/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked_services/stacked_services.dart';

class MessageActionBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const MessageActionBottomSheet({
    required this.request,
    required this.completer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy message'),
            onTap: () => completer(SheetResponse(data: MessageAction.copy)),
          ),
          ListTile(
            leading: const Icon(Icons.reply),
            title: Text('Reply to ${request.data.user.nick}'),
            onTap: () => completer(SheetResponse(data: MessageAction.reply)),
          ),
          ListTile(
            leading: const Icon(Icons.person_off),
            title: Text('Ignore ${request.data.user.nick}'),
            onTap: () => completer(SheetResponse(data: MessageAction.ignore)),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
              DateFormat.jm().add_yMMMMd().format(request.data.timestamp),
            ),
            onTap: () => completer(SheetResponse(data: MessageAction.ignore)),
          ),
        ],
      ),
    );
  }
}
